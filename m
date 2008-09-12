Received: by wr-out-0506.google.com with SMTP id c30so631893wra.14
        for <linux-mm@kvack.org>; Fri, 12 Sep 2008 12:17:06 -0700 (PDT)
Message-ID: <48CAC02B.8090003@gmail.com>
Date: Fri, 12 Sep 2008 22:16:59 +0300
From: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>
MIME-Version: 1.0
Subject: mmap/munmap latency on multithreaded apps, because pagefaults hold
 mmap_sem during disk read
References: <48B1CC15.2040006@gmail.com> <1219643476.20732.1.camel@twins>	<48B25988.8040302@gmail.com> <1219656190.8515.7.camel@twins>	<48B28015.3040602@gmail.com> <1219658527.8515.16.camel@twins>	<48B287D8.1000000@gmail.com> <1219660582.8515.24.camel@twins>	<48B290E7.4070805@gmail.com> <1219664477.8515.54.camel@twins>	<20080825134801.GN1408@mit.edu> <87y72k9otw.fsf@basil.nowhere.org> <48C57898.1080304@gmail.com>
In-Reply-To: <48C57898.1080304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Theodore Tso <tytso@mit.edu>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux Kernel <linux-kernel@vger.kernel.org>, "Thomas Gleixner mingo@redhat.com" <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2008-09-08 22:10, Torok Edwin wrote:
> [snip]
> There is however a problem with mmap [mmap with N threads is as slow as
> mmap with 1 thread, i.e. it is sequential :(], pagefaults and disk I/O,
> I think I am hitting the problem described in this thread (2 years ago!)
> http://lwn.net/Articles/200215/
> http://lkml.org/lkml/2006/9/19/260
>
> It looks like such a patch is still not part of 2.6.27, what happened to it?
> I will see if that patch applies to 2.6.27, and will rerun my test with
> that patch applied too.
>   

The patch doesn't apply to 2.6.27-rc6, I tried manually applying the patch.
There have been many changes since 2.6.18 (like replacing find_get_page
with find_lock_page, filemap returning VM_FAULT codes, etc.).
I have probably done something wrong, because the resulting kernel won't
boot: I  get abnormal exits and random sigbus during boot.

Can you please help porting the patch to 2.6.27-rc6? I have attached my
2 attempts at the end of this mail.

Also it looks like the original patch just releases the mmap_sem if
there is lock contention on the page, but keeps mmap_sem during read?
I would like mmap_sem be released during disk I/O too.

I also tried changing i_mmap_lock into a semaphore, however I that won't
work since some users of i_mmap_lock can't sleep.
Taking the i_mmap_lock spinlock in filemap fault is also not possible,
since we would sleep while holding a spinlock.

Just to confirm that the problem is with pagefaults and mmap, I dropped
the mmap_sem in filemap_fault, and then
I got same performance in my testprogram for mmap and read. Of course
this is totally unsafe, because the mapping could change at any time.

> [2] the test program is available here:
>  http://edwintorok.googlepages.com/scalability.tar.gz
> You just build it using 'make' (has to be GNU make), and the run
> $ sh ./runtest.sh /usr/bin/ | tee log
> $ sh ./postproc.sh log

I've written a latency tracer (using ptrace), and I identified the
mutex/mmap related latencies (total runtime 23m):
- mmap-ed files (created by libclamav) ~6680 ms  total
- creating/removing anonymous mappings, created by glibc, when I use
functions like fopen/fclose:

With 8 threads:
=====> Total: 3227.732 ms, average: 3.590 ms, times: 899
=== /lib/libc.so.6  (mmap)
=== /lib/libc.so.6  (_IO_file_doallocate)
=== /lib/libc.so.6  (_IO_doallocbuf)
=== /lib/libc.so.6  (_IO_file_seekoff)
=== /lib/libc.so.6  (_IO_file_attach)
=== /lib/libc.so.6  (_IO_fdopen)
=== /usr/lib/libz.so.1  (gzflush)
=== /usr/lib/libz.so.1  (gzdopen)
=== /usr/local/lib/libclamav.so.5 libclamav/scanners.c:470 (cli_scangzip)

=====> Total: 2069.519 ms, average: 3.624 ms, times: 571
=== /lib/libc.so.6  (munmap)
=== /lib/libc.so.6  (_IO_setb)
=== /lib/libc.so.6  (_IO_file_close_it)
=== /lib/libc.so.6  (_IO_fclose)
=== /usr/lib/libz.so.1  (gzerror)
=== /usr/local/lib/libclamav.so.5 libclamav/scanners.c:529 (cli_scangzip)

with 4 threads:
=====> Total: 578.607 ms, average: 4.743 ms, times: 122
=== /lib/libc.so.6  (munmap)
=== /lib/libc.so.6  (_IO_setb)
=== /lib/libc.so.6  (_IO_file_close_it)
=== /lib/libc.so.6  (_IO_fclose)
=== /usr/lib/libz.so.1  (gzerror)
=== /usr/local/lib/libclamav.so.5 libclamav/scanners.c:529 (cli_scangzip)

=====> Total: 148.083 ms, average: 2.278 ms, times: 65
=== /lib/libc.so.6  (mmap)
=== /lib/libc.so.6  (_IO_file_doallocate)
=== /lib/libc.so.6  (_IO_doallocbuf)
=== /lib/libc.so.6  (_IO_file_seekoff)
=== /lib/libc.so.6  (_IO_file_attach)
=== /lib/libc.so.6  (_IO_fdopen)
=== /usr/lib/libz.so.1  (gzflush)
=== /usr/lib/libz.so.1  (gzdopen)
=== /usr/local/lib/libclamav.so.5 libclamav/scanners.c:470 (cli_scangzip)

With 8 threads situation is much worse than with 4 threads even for
functions using anonymous mappings.

Of course the latency tracer has its own overhead (1.2 ms average, 67 ms
max  for 8 threads, and 0.1 ms average, 31 ms max for 4 threads),but
these latencies are above that value.

Best regards,
--Edwin

---
First attempt:
 arch/x86/mm/fault.c      |   33 +++++++++++++++++++++++++++------
 include/linux/mm.h       |    1 +
 include/linux/mm_types.h |    1 -
 include/linux/sched.h    |    1 +
 mm/filemap.c             |   18 ++++++++++++------
 5 files changed, 41 insertions(+), 13 deletions(-)
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 455f3fe..38bea4b 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -578,10 +578,7 @@ int show_unhandled_signals = 1;
  * and the problem, and then passes it off to one of the appropriate
  * routines.
  */
-#ifdef CONFIG_X86_64
-asmlinkage
-#endif
-void __kprobes do_page_fault(struct pt_regs *regs, unsigned long
error_code)
+static inline void __do_page_fault(struct pt_regs *regs, unsigned long
error_code)
 {
     struct task_struct *tsk;
     struct mm_struct *mm;
@@ -702,6 +699,7 @@ again:
         down_read(&mm->mmap_sem);
     }
 
+retry:
     vma = find_vma(mm, address);
     if (!vma)
         goto bad_area;
@@ -761,8 +759,21 @@ survive:
     }
     if (fault & VM_FAULT_MAJOR)
         tsk->maj_flt++;
-    else
-        tsk->min_flt++;
+    else {
+        if ((fault & VM_FAULT_RETRY) && (current->flags &
PF_FAULT_MAYRETRY)) {
+            current->flags &= ~PF_FAULT_MAYRETRY;
+            goto retry;
+        }
+        /*
+         * If we had to retry (PF_FAULT_MAYRETRY cleared), then
+         * the page originally wasn't up to date before the
+         * retry, but now it is.
+         */
+        if (!(current->flags & PF_FAULT_MAYRETRY))
+            tsk->maj_flt++;
+        else
+            tsk->min_flt++;
+    }
 
 #ifdef CONFIG_X86_32
     /*
@@ -909,6 +920,16 @@ do_sigbus:
     tsk->thread.trap_no = 14;
     force_sig_info_fault(SIGBUS, BUS_ADRERR, address, tsk);
 }
+#ifdef CONFIG_X86_64
+asmlinkage
+#endif
+void __kprobes do_page_fault(struct pt_regs *regs,
+           unsigned long error_code)
+{
+    current->flags |= PF_FAULT_MAYRETRY;
+    __do_page_fault(regs, error_code);
+    current->flags &= ~PF_FAULT_MAYRETRY;
+}
 
 DEFINE_SPINLOCK(pgd_lock);
 LIST_HEAD(pgd_list);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72a15dc..4511f68 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -697,6 +697,7 @@ static inline int page_mapped(struct page *page)
 
 #define VM_FAULT_NOPAGE    0x0100    /* ->fault installed the pte, not
return page */
 #define VM_FAULT_LOCKED    0x0200    /* ->fault locked the returned page */
+#define VM_FAULT_RETRY  0x0400
 
 #define VM_FAULT_ERROR    (VM_FAULT_OOM | VM_FAULT_SIGBUS)
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bf33413..9d065a4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -108,7 +108,6 @@ struct vm_area_struct {
     unsigned long vm_start;        /* Our start address within vm_mm. */
     unsigned long vm_end;        /* The first byte after our end address
                        within vm_mm. */
-
     /* linked list of VM areas per task, sorted by address */
     struct vm_area_struct *vm_next;
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3d9120c..bc39432 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1507,6 +1507,7 @@ extern cputime_t task_gtime(struct task_struct *p);
 #define PF_SPREAD_PAGE    0x01000000    /* Spread page cache over cpuset */
 #define PF_SPREAD_SLAB    0x02000000    /* Spread some slab caches over
cpuset */
 #define PF_THREAD_BOUND    0x04000000    /* Thread bound to specific cpu */
+#define PF_FAULT_MAYRETRY 0x08000000    /* I may drop mmap_sem during
fault */
 #define PF_MEMPOLICY    0x10000000    /* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER    0x20000000    /* Thread belongs to the rt
mutex tester */
 #define PF_FREEZER_SKIP    0x40000000    /* Freezer should not count it
as freezeable */
diff --git a/mm/filemap.c b/mm/filemap.c
index 876bc59..f9f11bd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1443,18 +1443,17 @@ int filemap_fault(struct vm_area_struct *vma,
struct vm_fault *vmf)
     /*
      * Do we have something in the page cache already?
      */
-retry_find:
     page = find_lock_page(mapping, vmf->pgoff);
     /*
      * For sequential accesses, we use the generic readahead logic.
      */
     if (VM_SequentialReadHint(vma)) {
         if (!page) {
+            up_read(&vma->vm_mm->mmap_sem);
             page_cache_sync_readahead(mapping, ra, file,
                                vmf->pgoff, 1);
-            page = find_lock_page(mapping, vmf->pgoff);
-            if (!page)
-                goto no_cached_page;
+            down_read(&vma->vm_mm->mmap_sem);
+            return VM_FAULT_RETRY;
         }
         if (PageReadahead(page)) {
             page_cache_async_readahead(mapping, ra, file, page,
@@ -1489,7 +1488,10 @@ retry_find:
 
             if (vmf->pgoff > ra_pages / 2)
                 start = vmf->pgoff - ra_pages / 2;
+            up_read(&vma->vm_mm->mmap_sem);
             do_page_cache_readahead(mapping, file, start, ra_pages);
+            down_read(&vma->vm_mm->mmap_sem);
+            return VM_FAULT_RETRY;
         }
         page = find_lock_page(mapping, vmf->pgoff);
         if (!page)
@@ -1527,7 +1529,9 @@ no_cached_page:
      * We're only likely to ever get here if MADV_RANDOM is in
      * effect.
      */
+    up_read(&vma->vm_mm->mmap_sem);
     error = page_cache_read(file, vmf->pgoff);
+    down_read(&vma->vm_mm->mmap_sem);
 
     /*
      * The page we want has now been added to the page cache.
@@ -1535,7 +1539,7 @@ no_cached_page:
      * meantime, we'll just come back here and read it again.
      */
     if (error >= 0)
-        goto retry_find;
+        return VM_FAULT_RETRY;
 
     /*
      * An error return from page_cache_read can result if the
@@ -1560,16 +1564,18 @@ page_not_uptodate:
      * and we need to check for errors.
      */
     ClearPageError(page);
+    up_read(&vma->vm_mm->mmap_sem);
     error = mapping->a_ops->readpage(file, page);
     if (!error) {
         wait_on_page_locked(page);
         if (!PageUptodate(page))
             error = -EIO;
     }
+    down_read(&vma->vm_mm->mmap_sem);
     page_cache_release(page);
 
     if (!error || error == AOP_TRUNCATED_PAGE)
-        goto retry_find;
+        return VM_FAULT_RETRY;
 
     /* Things didn't work out. Return zero to tell the mm layer so. */
     shrink_readahead_size_eio(file, ra);

---
Second attempt
 arch/x86/mm/fault.c   |   33 ++++++++++++++++++++++++-----
 include/linux/mm.h    |    1
 include/linux/sched.h |    1
 mm/filemap.c          |   56
+++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 80 insertions(+), 11 deletions(-)
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 455f3fe..38bea4b 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -578,10 +578,7 @@ int show_unhandled_signals = 1;
  * and the problem, and then passes it off to one of the appropriate
  * routines.
  */
-#ifdef CONFIG_X86_64
-asmlinkage
-#endif
-void __kprobes do_page_fault(struct pt_regs *regs, unsigned long
error_code)
+static inline void __do_page_fault(struct pt_regs *regs, unsigned long
error_code)
 {
     struct task_struct *tsk;
     struct mm_struct *mm;
@@ -702,6 +699,7 @@ again:
         down_read(&mm->mmap_sem);
     }
 
+retry:
     vma = find_vma(mm, address);
     if (!vma)
         goto bad_area;
@@ -761,8 +759,21 @@ survive:
     }
     if (fault & VM_FAULT_MAJOR)
         tsk->maj_flt++;
-    else
-        tsk->min_flt++;
+    else {
+        if ((fault & VM_FAULT_RETRY) && (current->flags &
PF_FAULT_MAYRETRY)) {
+            current->flags &= ~PF_FAULT_MAYRETRY;
+            goto retry;
+        }
+        /*
+         * If we had to retry (PF_FAULT_MAYRETRY cleared), then
+         * the page originally wasn't up to date before the
+         * retry, but now it is.
+         */
+        if (!(current->flags & PF_FAULT_MAYRETRY))
+            tsk->maj_flt++;
+        else
+            tsk->min_flt++;
+    }
 
 #ifdef CONFIG_X86_32
     /*
@@ -909,6 +920,16 @@ do_sigbus:
     tsk->thread.trap_no = 14;
     force_sig_info_fault(SIGBUS, BUS_ADRERR, address, tsk);
 }
+#ifdef CONFIG_X86_64
+asmlinkage
+#endif
+void __kprobes do_page_fault(struct pt_regs *regs,
+           unsigned long error_code)
+{
+    current->flags |= PF_FAULT_MAYRETRY;
+    __do_page_fault(regs, error_code);
+    current->flags &= ~PF_FAULT_MAYRETRY;
+}
 
 DEFINE_SPINLOCK(pgd_lock);
 LIST_HEAD(pgd_list);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72a15dc..e150c80 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -694,6 +694,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_SIGBUS    0x0002
 #define VM_FAULT_MAJOR    0x0004
 #define VM_FAULT_WRITE    0x0008    /* Special case for get_user_pages */
+#define VM_FAULT_RETRY  0x0016
 
 #define VM_FAULT_NOPAGE    0x0100    /* ->fault installed the pte, not
return page */
 #define VM_FAULT_LOCKED    0x0200    /* ->fault locked the returned page */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3d9120c..bc39432 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1507,6 +1507,7 @@ extern cputime_t task_gtime(struct task_struct *p);
 #define PF_SPREAD_PAGE    0x01000000    /* Spread page cache over cpuset */
 #define PF_SPREAD_SLAB    0x02000000    /* Spread some slab caches over
cpuset */
 #define PF_THREAD_BOUND    0x04000000    /* Thread bound to specific cpu */
+#define PF_FAULT_MAYRETRY 0x08000000    /* I may drop mmap_sem during
fault */
 #define PF_MEMPOLICY    0x10000000    /* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER    0x20000000    /* Thread belongs to the rt
mutex tester */
 #define PF_FREEZER_SKIP    0x40000000    /* Freezer should not count it
as freezeable */
diff --git a/mm/filemap.c b/mm/filemap.c
index 876bc59..212ea0f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -670,6 +670,7 @@ repeat:
 }
 EXPORT_SYMBOL(find_get_page);
 
+#define NOPAGE_RETRY ((struct page*)-1)
 /**
  * find_lock_page - locate, pin and lock a pagecache page
  * @mapping: the address_space to search
@@ -680,14 +681,31 @@ EXPORT_SYMBOL(find_get_page);
  *
  * Returns zero if the page was not present. find_lock_page() may sleep.
  */
-struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
+static struct page *__find_lock_page(struct address_space *mapping,
+             pgoff_t offset, struct rw_semaphore *mmap_sem)
 {
     struct page *page;
 
 repeat:
     page = find_get_page(mapping, offset);
     if (page) {
-        lock_page(page);
+        if(!mmap_sem) {
+            lock_page(page);
+        } else if(!trylock_page(page)) {
+            /*
+             * Page is already locked by someone else.
+             * We don't want to be holding down_read(mmap_sem)
+             * inside lock_page(), so use wait_on_page_locked()
here.             
+             */
+            up_read(mmap_sem);
+            wait_on_page_locked(page);
+            down_read(mmap_sem);
+            /*
+             * The VMA tree may have changed at this point.
+             */
+            page_cache_release(page);
+            goto repeat;
+        }
         /* Has the page been truncated? */
         if (unlikely(page->mapping != mapping)) {
             unlock_page(page);
@@ -698,6 +716,10 @@ repeat:
     }
     return page;
 }
+struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
+{
+    return  __find_lock_page(mapping, offset, NULL);
+}
 EXPORT_SYMBOL(find_lock_page);
 
 /**
@@ -1427,6 +1449,8 @@ int filemap_fault(struct vm_area_struct *vma,
struct vm_fault *vmf)
     struct address_space *mapping = file->f_mapping;
     struct file_ra_state *ra = &file->f_ra;
     struct inode *inode = mapping->host;
+    struct rw_semaphore *mmap_sem;
+    struct rw_semaphore *mmap_sem_mayretry;
     struct page *page;
     pgoff_t size;
     int did_readaround = 0;
@@ -1435,6 +1459,7 @@ int filemap_fault(struct vm_area_struct *vma,
struct vm_fault *vmf)
     size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
     if (vmf->pgoff >= size)
         return VM_FAULT_SIGBUS;
+    up_read(&vma->vm_mm->mmap_sem);
 
     /* If we don't want any read-ahead, don't bother */
     if (VM_RandomReadHint(vma))
@@ -1443,16 +1468,25 @@ int filemap_fault(struct vm_area_struct *vma,
struct vm_fault *vmf)
     /*
      * Do we have something in the page cache already?
      */
+    mmap_sem = &vma->vm_mm->mmap_sem;
+    mmap_sem_mayretry = current->flags & PF_FAULT_MAYRETRY ? mmap_sem :
NULL;
 retry_find:
-    page = find_lock_page(mapping, vmf->pgoff);
+    page = __find_lock_page(mapping, vmf->pgoff, mmap_sem_mayretry);
+    if(page == NOPAGE_RETRY)
+        goto nopage_retry;
     /*
      * For sequential accesses, we use the generic readahead logic.
      */
     if (VM_SequentialReadHint(vma)) {
         if (!page) {
+            up_read(mmap_sem);
             page_cache_sync_readahead(mapping, ra, file,
                                vmf->pgoff, 1);
-            page = find_lock_page(mapping, vmf->pgoff);
+            down_read(mmap_sem);
+            page = __find_lock_page(mapping, vmf->pgoff,
+                             mmap_sem_mayretry);
+            if(page == NOPAGE_RETRY)
+                goto nopage_retry;
             if (!page)
                 goto no_cached_page;
         }
@@ -1489,9 +1523,15 @@ retry_find:
 
             if (vmf->pgoff > ra_pages / 2)
                 start = vmf->pgoff - ra_pages / 2;
+            up_read(mmap_sem);
             do_page_cache_readahead(mapping, file, start, ra_pages);
+            down_read(mmap_sem);
         }
-        page = find_lock_page(mapping, vmf->pgoff);
+        page = __find_lock_page(mapping, vmf->pgoff,
+                (current->flags & PF_FAULT_MAYRETRY) ?
+                    &vma->vm_mm->mmap_sem : NULL);
+        if(page == NOPAGE_RETRY)
+            goto nopage_retry;
         if (!page)
             goto no_cached_page;
     }
@@ -1527,7 +1567,9 @@ no_cached_page:
      * We're only likely to ever get here if MADV_RANDOM is in
      * effect.
      */
+    up_read(mmap_sem);
     error = page_cache_read(file, vmf->pgoff);
+    down_read(mmap_sem);
 
     /*
      * The page we want has now been added to the page cache.
@@ -1560,12 +1602,14 @@ page_not_uptodate:
      * and we need to check for errors.
      */
     ClearPageError(page);
+    up_read(mmap_sem);
     error = mapping->a_ops->readpage(file, page);
     if (!error) {
         wait_on_page_locked(page);
         if (!PageUptodate(page))
             error = -EIO;
     }
+    down_read(mmap_sem);
     page_cache_release(page);
 
     if (!error || error == AOP_TRUNCATED_PAGE)
@@ -1574,6 +1618,8 @@ page_not_uptodate:
     /* Things didn't work out. Return zero to tell the mm layer so. */
     shrink_readahead_size_eio(file, ra);
     return VM_FAULT_SIGBUS;
+nopage_retry:
+    return VM_FAULT_RETRY;
 }
 EXPORT_SYMBOL(filemap_fault);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
