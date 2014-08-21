Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 51E226B003A
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 15:37:39 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so5319066iec.19
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 12:37:39 -0700 (PDT)
Received: from mail-ie0-x24a.google.com (mail-ie0-x24a.google.com [2607:f8b0:4001:c03::24a])
        by mx.google.com with ESMTPS id t1si30504144icu.50.2014.08.21.12.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 12:37:38 -0700 (PDT)
Received: by mail-ie0-f202.google.com with SMTP id rl12so776324iec.5
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 12:37:38 -0700 (PDT)
Date: Thu, 21 Aug 2014 15:37:37 -0400
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH] mm: softdirty: write protect PTEs created for read
 faults after VM_SOFTDIRTY cleared
Message-ID: <20140821193737.GC16042@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <20140820234543.GA7987@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140820234543.GA7987@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <damm@opensource.se>

On Thu, Aug 21, 2014 at 02:45:43AM +0300, Kirill A. Shutemov wrote:
> On Wed, Aug 20, 2014 at 05:46:22PM -0400, Peter Feiner wrote:
> It basically means VM_SOFTDIRTY require writenotify on the vma.
> 
> What about patch below? Untested. And it seems it'll introduce bug similar
> to bug fixed by c9d0bf241451, *but* IIUC we have it already in mprotect()
> code path.
> 
> I'll look more careful tomorrow.
> 
> Not-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index dfc791c42d64..67d509a15969 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -851,8 +851,9 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>                         if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
>                                 continue;
>                         if (type == CLEAR_REFS_SOFT_DIRTY) {
> -                               if (vma->vm_flags & VM_SOFTDIRTY)
> -                                       vma->vm_flags &= ~VM_SOFTDIRTY;
> +                               vma->vm_flags &= ~VM_SOFTDIRTY;
> +                               vma->vm_page_prot = vm_get_page_prot(
> +                                               vma->vm_flags & ~VM_SHARED);
>                         }
>                         walk_page_range(vma->vm_start, vma->vm_end,
>                                         &clear_refs_walk);
> -- 
>  Kirill A. Shutemov

Thanks Kirill, I prefer your approach. I'll send a v2.

I believe you're right about c9d0bf241451. It seems like passing the old & new
pgprot through pgprot_modify would handle the problem. Furthermore, as you
suggest, mprotect_fixup should use pgprot_modify when it turns write
notification on.  I think a patch like this is in order:

Not-signed-off-by: Peter Feiner <pfeiner@google.com>

diff --git a/mm/mmap.c b/mm/mmap.c
index c1f2ea4..86f89a1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1611,18 +1611,15 @@ munmap_back:
 	}
 
 	if (vma_wants_writenotify(vma)) {
-		pgprot_t pprot = vma->vm_page_prot;
-
 		/* Can vma->vm_page_prot have changed??
 		 *
 		 * Answer: Yes, drivers may have changed it in their
 		 *         f_op->mmap method.
 		 *
-		 * Ensures that vmas marked as uncached stay that way.
+		 * Ensures that vmas marked with special bits stay that way.
 		 */
-		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
-		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
-			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
+		                        vm_get_page_prot(vm_flags & ~VM_SHARED);
 	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557..6826313 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -324,7 +324,8 @@ success:
 					  vm_get_page_prot(newflags));
 
 	if (vma_wants_writenotify(vma)) {
-		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
+		vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
+		                       vm_get_page_prot(newflags & ~VM_SHARED));
 		dirty_accountable = 1;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
