Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id BB6506B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:23:04 -0400 (EDT)
Received: by mail-qe0-f41.google.com with SMTP id b10so510328qen.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:23:03 -0700 (PDT)
Message-ID: <5165CA22.6080808@gmail.com>
Date: Wed, 10 Apr 2013 16:22:58 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@gmail.com

(3/12/13 3:38 AM), Minchan Kim wrote:
> First of all, let's define the term.
> From now on, I'd like to call it as vrange(a.k.a volatile range)
> for anonymous page. If you have a better name in mind, please suggest.
> 
> This version is still *RFC* because it's just quick prototype so
> it doesn't support THP/HugeTLB/KSM and even couldn't build on !x86.
> Before further sorting out issues, I'd like to post current direction
> and discuss it. Of course, I'd like to extend this discussion in
> comming LSF/MM.
> 
> In this version, I changed lots of thing, expecially removed vma-based
> approach because it needs write-side lock for mmap_sem, which will drop
> performance in mutli-threaded big SMP system, KOSAKI pointed out.
> And vma-based approach is hard to meet requirement of new system call by
> John Stultz's suggested semantic for consistent purged handling.
> (http://linux-kernel.2935.n7.nabble.com/RFC-v5-0-8-Support-volatile-for-anonymous-range-tt575773.html#none)
> 
> I tested this patchset with modified jemalloc allocator which was
> leaded by Jason Evans(jemalloc author) who was interest in this feature
> and was happy to port his allocator to use new system call.
> Super Thanks Jason!
> 
> The benchmark for test is ebizzy. It have been used for testing the
> allocator performance so it's good for me. Again, thanks for recommending
> the benchmark, Jason.
> (http://people.freebsd.org/~kris/scaling/ebizzy.html)
> 
> The result is good on my machine (12 CPU, 1.2GHz, DRAM 2G)
> 
> 	ebizzy -S 20
> 
> jemalloc-vanilla: 52389 records/sec
> jemalloc-vrange: 203414 records/sec
> 
> 	ebizzy -S 20 with background memory pressure
> 
> jemalloc-vanilla: 40746 records/sec
> jemalloc-vrange: 174910 records/sec
> 
> And it's much improved on KVM virtual machine.
> 
> This patchset is based on v3.9-rc2
> 
> - What's the sys_vrange(addr, length, mode, behavior)?
> 
>   It's a hint that user deliver to kernel so kernel can *discard*
>   pages in a range anytime. mode is one of VRANGE_VOLATILE and
>   VRANGE_NOVOLATILE. VRANGE_NOVOLATILE is memory pin operation so
>   kernel coudn't discard any pages any more while VRANGE_VOLATILE
>   is memory unpin opeartion so kernel can discard pages in vrange
>   anytime. At a moment, behavior is one of VRANGE_FULL and VRANGE
>   PARTIAL. VRANGE_FULL tell kernel that once kernel decide to
>   discard page in a vrange, please, discard all of pages in a
>   vrange selected by victim vrange. VRANGE_PARTIAL tell kernel
>   that please discard of some pages in a vrange. But now I didn't
>   implemented VRANGE_PARTIAL handling yet.
> 
> - What happens if user access page(ie, virtual address) discarded
>   by kernel?
> 
>   The user can encounter SIGBUS.
> 
> - What should user do for avoding SIGBUS?
>   He should call vrange(addr, length, VRANGE_NOVOLATILE, mode) before
>   accessing the range which was called
>   vrange(addr, length, VRANGE_VOLATILE, mode)
> 
> - What happens if user access page(ie, virtual address) doesn't
>   discarded by kernel?
> 
>   The user can see vaild data which was there before calling
> vrange(., VRANGE_VOLATILE) without page fault.
> 
> - What's different with madvise(DONTNEED)?
> 
>   System call semantic
> 
>   DONTNEED makes sure user always can see zero-fill pages after
>   he calls madvise while vrange can see data or encounter SIGBUS.

For replacing DONTNEED, user want to zero-fill pages like DONTNEED
instead of SIGBUS. So, new flag option would be nice.

I played a bit this patch. The result looks really promissing.
(i.e. 20x faster)

My machine have 24cpus, 8GB ram, kvm guest. I guess current DONTNEED
implementation doesn't fit kvm at all.


# of     # of   # of
thread   iter   iter (patched glibc)
----------------------------------
  1      438    10740
  2      842    20916
  4      987    32534
  8      717    15155
 12      714    14109
 16      708    13457
 20      720    13742
 24      727    13642
 28      715    13328
 32      709    13096
 36      705    13661
 40      708    13634
 44      707    13367
 48      714    13377


---------libc patch (just dirty hack) ----------------------

diff --git a/malloc/arena.c b/malloc/arena.c
index 12a48ad..da04f67 100644
--- a/malloc/arena.c
+++ b/malloc/arena.c
@@ -365,6 +365,8 @@ extern struct dl_open_hook *_dl_open_hook;
 libc_hidden_proto (_dl_open_hook);
 #endif

+int vrange_enabled = 0;
+
 static void
 ptmalloc_init (void)
 {
@@ -457,6 +459,18 @@ ptmalloc_init (void)
     if (check_action != 0)
       __malloc_check_init();
   }
+
+  {
+    char *vrange = getenv("MALLOC_VRANGE");
+    if (vrange) {
+      int val = atoi(vrange);
+      if (val) {
+       printf("glibc: vrange enabled\n");
+       vrange_enabled = !!val;
+      }
+    }
+  }
+
   void (*hook) (void) = force_reg (__malloc_initialize_hook);
   if (hook != NULL)
     (*hook)();
@@ -628,9 +642,14 @@ shrink_heap(heap_info *h, long diff)
        return -2;
       h->mprotect_size = new_size;
     }
-  else
-    __madvise ((char *)h + new_size, diff, MADV_DONTNEED);
+  else {
+    if (vrange_enabled) {
+      syscall(314, (char *)h + new_size, diff, 0, 1);
+    } else {
+      __madvise ((char *)h + new_size, diff, MADV_DONTNEED);
+    }
   /*fprintf(stderr, "shrink %p %08lx\n", h, new_size);*/
+  }

   h->size = new_size;
   return 0;
diff --git a/malloc/malloc.c b/malloc/malloc.c
index 70b9329..3782244 100644
--- a/malloc/malloc.c
+++ b/malloc/malloc.c
@@ -4403,6 +4403,7 @@ _int_pvalloc(mstate av, size_t bytes)
 /*
   ------------------------------ malloc_trim ------------------------------
 */
+extern int vrange_enabled;

 static int mtrim(mstate av, size_t pad)
 {
@@ -4443,7 +4444,12 @@ static int mtrim(mstate av, size_t pad)
                       content.  */
                    memset (paligned_mem, 0x89, size & ~psm1);
 #endif
-                   __madvise (paligned_mem, size & ~psm1, MADV_DONTNEED);
+
+                   if (vrange_enabled) {
+                     syscall(314, paligned_mem, size & ~psm1, 0, 1);
+                   } else {
+                     __madvise (paligned_mem, size & ~psm1, MADV_DONTNEED);
+                   }

                    result = 1;
                  }
(END)






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
