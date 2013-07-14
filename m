Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 259E66B0031
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 10:17:47 -0400 (EDT)
Date: Sun, 14 Jul 2013 16:11:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private
	anonymous memory
Message-ID: <20130714141154.GA29815@redhat.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com> <1373596462-27115-2-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373596462-27115-2-git-send-email-ccross@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

Sorry if this was already discussed... I am still trying to think if
we can make a simpler patch.

So, iiuc, the main problem is that if you want to track a vma you need
to prevent the merging with other vma's.

Question: is it important that vma's with the same vma_name should be
_merged_ automatically?

If not, can't we make "do not merge" a separate feature and then add
vma_name?

IOW, please forget about vma_name for the moment. Can't we start with
the trivial patch below? It simply adds the new vm flag which blocks
the merging, and MADV_ to set/clear it.

Yes, this is more limited. Once you set VM_TAINTED this vma is always
isolated. If you unmap a page in this vma, you create 2 isolated vma's.
If, for example, you do MADV_DONTFORK + MADV_DOFORK inside the tainted
vma, you will have 2 adjacent VM_TAINTED vma's with the same flags after
that. But you can do MADV_UNTAINT + MADV_TAINT again if you want to
merge them back. And perhaps this feature is useful even without the
naming. And perhaps we can also add MAP_TAINTED.

Now about vma_name. In this case PR_SET_VMA or MADV_NAME should simply
set/overwrite vma_name and nothing else, no need to do merge/split vma.

And if we add MAP_TAINTED, MAP_ANONYMOUS can reuse pgoff as vma_name
(we only need a simple changes in do_mmap_pgoff and mmap_region). But
this is minor.

Or this is too simple/ugly? Probably yes, this means that an allocator
which simply does a lot of MAP_ANONYMOUS + MADV_TAINT will create more
vma's than it needs. So I won't insist but I'd like to ask anyway.

Oleg.

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -90,6 +90,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_TAINTED	0x00001000
+
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529..888af10 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -52,6 +52,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_TAINT	18
+#define MADV_UNTAINT	19
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 7055883..0ddc76f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -81,6 +81,12 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		}
 		new_flags &= ~VM_DONTDUMP;
 		break;
+	case MADV_TAINT:
+		new_flags |= VM_TAINTED;
+		break;
+	case MADV_UNTAINT:
+		new_flags &= ~VM_TAINTED;
+		break;
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
 		error = ksm_madvise(vma, start, end, behavior, &new_flags);
@@ -407,6 +413,8 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_TAINT:
+	case MADV_UNTAINT:
 		return 1;
 
 	default:
diff --git a/mm/mmap.c b/mm/mmap.c
index f681e18..00323b7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1003,9 +1003,9 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 
 	/*
 	 * We later require that vma->vm_flags == vm_flags,
-	 * so this tests vma->vm_flags & VM_SPECIAL, too.
+	 * so this tests vma->vm_flags & VM_XXX, too.
 	 */
-	if (vm_flags & VM_SPECIAL)
+	if (vm_flags & (VM_SPECIAL | VM_TAINTED))
 		return NULL;
 
 	if (prev)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
