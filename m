Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C34336B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 03:06:56 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id r20so3917239wiv.15
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 00:06:56 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id e10si23760287wjw.68.2014.06.02.00.06.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 00:06:55 -0700 (PDT)
Received: by mail-wg0-f46.google.com with SMTP id n12so4644443wgh.29
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 00:06:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20140521193336.5df90456.akpm@linux-foundation.org>
 <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Mon, 2 Jun 2014 09:06:34 +0200
Message-ID: <CAHO5Pa3iQXRZPXG89OyRCmD6jPKp0M8TCfJind6XD0wbyoguxg@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: introduce fincore()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>

Hello Naoya,

As Christoph noted, it would be best to provide some good user
documentation for this proposed system call, to aid design review.

Also, as per Documentation/SubmitChecklist, patches that change the
kernel-userspace API/ABI should CC
linux-api@vger.kernel.org (see
https://www.kernel.org/doc/man-pages/linux-api-ml.html).

Thanks,

Michael


On Mon, Jun 2, 2014 at 7:24 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> This patch provides a new system call fincore(2), which provides mincore()-
> like information, i.e. page residency of a given file. But unlike mincore(),
> fincore() can have a mode flag and it enables us to extract more detailed
> information about page cache like pfn and page flag. This kind of information
> is very helpful for example when applications want to know the file cache
> status to control IO on their own way.
>
> Detail about the data format being passed to userspace are explained in
> inline comment, but generally in long entry format, we can choose which
> information is extraced flexibly, so you don't have to waste memory by
> extracting unnecessary information. And with FINCORE_SKIP_HOLE flag,
> we can skip hole pages (not on memory,) which makes us avoid a flood of
> meaningless zero entries when calling on extremely large (but only few
> pages of it are loaded on memory) file.
>
> Basic testset is added in a next patch on tools/testing/selftests/fincore/.
>
> [1] http://thread.gmane.org/gmane.linux.kernel/1439212/focus=1441919
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  arch/x86/syscalls/syscall_64.tbl |   1 +
>  include/linux/syscalls.h         |   2 +
>  mm/Makefile                      |   2 +-
>  mm/fincore.c                     | 362 +++++++++++++++++++++++++++++++++++++++
>  4 files changed, 366 insertions(+), 1 deletion(-)
>  create mode 100644 mm/fincore.c
>
> diff --git v3.15-rc7.orig/arch/x86/syscalls/syscall_64.tbl v3.15-rc7/arch/x86/syscalls/syscall_64.tbl
> index 04376ac3d9ef..0a6b6dd77708 100644
> --- v3.15-rc7.orig/arch/x86/syscalls/syscall_64.tbl
> +++ v3.15-rc7/arch/x86/syscalls/syscall_64.tbl
> @@ -323,6 +323,7 @@
>  314    common  sched_setattr           sys_sched_setattr
>  315    common  sched_getattr           sys_sched_getattr
>  316    common  renameat2               sys_renameat2
> +317    common  fincore                 sys_fincore
>
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git v3.15-rc7.orig/include/linux/syscalls.h v3.15-rc7/include/linux/syscalls.h
> index a4a0588c5397..d625ec9cb73d 100644
> --- v3.15-rc7.orig/include/linux/syscalls.h
> +++ v3.15-rc7/include/linux/syscalls.h
> @@ -866,4 +866,6 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
>  asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
>                          unsigned long idx1, unsigned long idx2);
>  asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
> +asmlinkage long sys_fincore(int fd, loff_t start, long nr_pages,
> +                       int mode, unsigned char __user *vec);
>  #endif
> diff --git v3.15-rc7.orig/mm/Makefile v3.15-rc7/mm/Makefile
> index b484452dac57..55e1d13ddb76 100644
> --- v3.15-rc7.orig/mm/Makefile
> +++ v3.15-rc7/mm/Makefile
> @@ -18,7 +18,7 @@ obj-y                 := filemap.o mempool.o oom_kill.o fadvise.o \
>                            mm_init.o mmu_context.o percpu.o slab_common.o \
>                            compaction.o balloon_compaction.o vmacache.o \
>                            interval_tree.o list_lru.o workingset.o \
> -                          iov_iter.o $(mmu-y)
> +                          iov_iter.o fincore.o $(mmu-y)
>
>  obj-y += init-mm.o
>
> diff --git v3.15-rc7.orig/mm/fincore.c v3.15-rc7/mm/fincore.c
> new file mode 100644
> index 000000000000..3fc3ef465471
> --- /dev/null
> +++ v3.15-rc7/mm/fincore.c
> @@ -0,0 +1,362 @@
> +/*
> + * fincore(2) system call
> + *
> + * Copyright (C) 2014 NEC Corporation, Naoya Horiguchi
> + */
> +
> +#include <linux/syscalls.h>
> +#include <linux/pagemap.h>
> +#include <linux/file.h>
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/hugetlb.h>
> +
> +/*
> + * You can control how the buffer in userspace is filled with this mode
> + * parameters:
> + *
> + * - FINCORE_BMAP:
> + *     The page status is returned in a vector of bytes.
> + *     The least significant bit of each byte is 1 if the referenced page
> + *     is in memory, otherwise it is zero.
> + *
> + * - FINCORE_PFN:
> + *     stores pfn, using 8 bytes.
> + *
> + * - FINCORE_PAGEFLAGS:
> + *     stores page flags, using 8 bytes. See definition of KPF_* for details.
> + *
> + * - FINCORE_PAGECACHE_TAGS:
> + *     stores pagecache tags, using 8 bytes. See definition of PAGECACHE_TAG_*
> + *     for details.
> + *
> + * - FINCORE_SKIP_HOLE: if this flag is set, fincore() doesn't store any
> + *     information about hole. Instead each records per page has the entry
> + *     of page offset (using 8 bytes.) This mode is useful if we handle
> + *     large file and only few pages are on memory for the file.
> + *
> + * FINCORE_BMAP shouldn't be used combined with any other flags, and returnd
> + * data in this mode is like this:
> + *
> + *   page offset  0   1   2   3   4
> + *              +---+---+---+---+---+
> + *              | 1 | 0 | 0 | 1 | 1 | ...
> + *              +---+---+---+---+---+
> + *               <->
> + *              1 byte
> + *
> + * For FINCORE_PFN, page data is formatted like this:
> + *
> + *   page offset    0       1       2       3       4
> + *              +-------+-------+-------+-------+-------+
> + *              |  pfn  |  pfn  |  pfn  |  pfn  |  pfn  | ...
> + *              +-------+-------+-------+-------+-------+
> + *               <----->
> + *               8 byte
> + *
> + * We can use multiple flags among FINCORE_(PFN|PAGEFLAGS|PAGECACHE_TAGS).
> + * For example, when the mode is FINCORE_PFN|FINCORE_PAGEFLAGS, the per-page
> + * information is stored like this:
> + *
> + *    page offset 0    page offset 1   page offset 2
> + *   +-------+-------+-------+-------+-------+-------+
> + *   |  pfn  | flags |  pfn  | flags |  pfn  | flags | ...
> + *   +-------+-------+-------+-------+-------+-------+
> + *    <-------------> <-------------> <------------->
> + *       16 bytes        16 bytes        16 bytes
> + *
> + * When FINCORE_SKIP_HOLE is set, we ignore holes and add page offset entry
> + * (8 bytes) instead. For example, the data format of mode
> + * FINCORE_PFN|FINCORE_SKIP_HOLE is like follows:
> + *
> + *   +-------+-------+-------+-------+-------+-------+
> + *   | pgoff |  pfn  | pgoff |  pfn  | pgoff |  pfn  | ...
> + *   +-------+-------+-------+-------+-------+-------+
> + *    <-------------> <-------------> <------------->
> + *       16 bytes        16 bytes        16 bytes
> + */
> +#define FINCORE_BMAP           0x01    /* bytemap mode */
> +#define FINCORE_PFN            0x02
> +#define FINCORE_PAGE_FLAGS     0x04
> +#define FINCORE_PAGECACHE_TAGS 0x08
> +#define FINCORE_SKIP_HOLE      0x10
> +
> +#define FINCORE_MODE_MASK      0x1f
> +#define FINCORE_LONGENTRY_MASK (FINCORE_PFN | FINCORE_PAGE_FLAGS | \
> +                                FINCORE_PAGECACHE_TAGS | FINCORE_SKIP_HOLE)
> +
> +struct fincore_control {
> +       int mode;
> +       int width;              /* width of each entry (in bytes) */
> +       unsigned char *buffer;
> +       long buffer_size;
> +       void *cursor;           /* current position on the buffer */
> +       pgoff_t pgstart;        /* start point of page cache scan in each run
> +                                * of the while loop */
> +       long nr_pages;          /* number of pages to be copied to userspace
> +                                * (decreasing while scan proceeds) */
> +       long scanned_offset;    /* page offset of the lastest scanned page */
> +       struct address_space *mapping;
> +};
> +
> +/*
> + * TODO: doing radix_tree_tag_get() for each tag is not optimal, but no easy
> + * way without degrading finely tuned radix tree routines.
> + */
> +static unsigned long get_pagecache_tags(struct radix_tree_root *root,
> +                                       unsigned long index)
> +{
> +       int i;
> +       unsigned long tags = 0;
> +       for (i = 0; i < __NR_PAGECACHE_TAGS; i++)
> +               if (radix_tree_tag_get(root, index, i))
> +                       tags |=  1 << i;
> +       return tags;
> +}
> +
> +#define store_entry(fc, type, data) ({         \
> +       *(type *)fc->cursor = (type)data;       \
> +       fc->cursor += sizeof(type);             \
> +})
> +
> +/*
> + * Store page cache data to temporal buffer in the specified format depending
> + * on fincore mode.
> + */
> +static void __do_fincore(struct fincore_control *fc, struct page *page,
> +                        unsigned long index)
> +{
> +       VM_BUG_ON(!page);
> +       VM_BUG_ON((unsigned long)fc->cursor - (unsigned long)fc->buffer
> +                 >= fc->buffer_size);
> +       if (fc->mode & FINCORE_BMAP)
> +               store_entry(fc, unsigned char, PageUptodate(page));
> +       else if (fc->mode & (FINCORE_LONGENTRY_MASK)) {
> +               if (fc->mode & FINCORE_SKIP_HOLE)
> +                       store_entry(fc, unsigned long, index);
> +               if (fc->mode & FINCORE_PFN)
> +                       store_entry(fc, unsigned long, page_to_pfn(page));
> +               if (fc->mode & FINCORE_PAGE_FLAGS)
> +                       store_entry(fc, unsigned long, stable_page_flags(page));
> +               if (fc->mode & FINCORE_PAGECACHE_TAGS)
> +                       store_entry(fc, unsigned long,
> +                                   get_pagecache_tags(&fc->mapping->page_tree,
> +                                                      index));
> +       }
> +}
> +
> +/*
> + * Traverse page cache tree. It's assumed that temporal buffer are zeroed
> + * in advance. Due to this, we don't have to store zero entry explicitly
> + * one-by-one and we just set fc->cursor to the position of the next
> + * on-memory page.
> + *
> + * Return value is the number of pages whose data is stored in fc->buffer.
> + */
> +static long do_fincore(struct fincore_control *fc, int nr_pages)
> +{
> +       pgoff_t pgend = fc->pgstart + nr_pages;
> +       struct radix_tree_iter iter;
> +       void **slot;
> +       long nr = 0;
> +
> +       fc->cursor = fc->buffer;
> +
> +       rcu_read_lock();
> +restart:
> +       radix_tree_for_each_slot(slot, &fc->mapping->page_tree, &iter,
> +                                fc->pgstart) {
> +               long jump;
> +               struct page *page;
> +
> +               fc->scanned_offset = iter.index;
> +               /* Handle holes */
> +               jump = iter.index - fc->pgstart - nr;
> +               if (jump) {
> +                       if (!(fc->mode & FINCORE_SKIP_HOLE)) {
> +                               if (iter.index < pgend) {
> +                                       fc->cursor += jump * fc->width;
> +                                       nr = iter.index - fc->pgstart;
> +                               } else {
> +                                       /*
> +                                        * Fill remaining buffer as hole. Next
> +                                        * call should start at offset pgend.
> +                                        */
> +                                       nr = nr_pages;
> +                                       fc->scanned_offset = pgend - 1;
> +                                       break;
> +                               }
> +                       }
> +               }
> +repeat:
> +               page = radix_tree_deref_slot(slot);
> +               if (unlikely(!page))
> +                       /*
> +                        * No need to increment nr and fc->cursor, because next
> +                        * iteration should detect hole and update them there.
> +                        */
> +                       continue;
> +               else if (radix_tree_exception(page)) {
> +                       if (radix_tree_deref_retry(page)) {
> +                               /*
> +                                * Transient condition which can only trigger
> +                                * when entry at index 0 moves out of or back
> +                                * to root: none yet gotten, safe to restart.
> +                                */
> +                               WARN_ON(iter.index);
> +                               goto restart;
> +                       }
> +                       __do_fincore(fc, page, iter.index);
> +               } else {
> +                       if (!page_cache_get_speculative(page))
> +                               goto repeat;
> +
> +                       /* Has the page moved? */
> +                       if (unlikely(page != *slot)) {
> +                               page_cache_release(page);
> +                               goto repeat;
> +                       }
> +
> +                       __do_fincore(fc, page, iter.index);
> +                       page_cache_release(page);
> +               }
> +
> +               if (++nr == nr_pages)
> +                       break;
> +       }
> +       rcu_read_unlock();
> +
> +       return nr;
> +}
> +
> +static inline bool fincore_validate_mode(int mode)
> +{
> +       if (mode & ~FINCORE_MODE_MASK)
> +               return false;
> +       if (!(!!(mode & FINCORE_BMAP) ^ !!(mode & FINCORE_LONGENTRY_MASK)))
> +               return false;
> +       if ((mode & FINCORE_LONGENTRY_MASK) == FINCORE_SKIP_HOLE)
> +               return false;
> +       return true;
> +}
> +
> +#define FINCORE_LOOP_STEP      256L
> +
> +/*
> + * The fincore(2) system call
> + *
> + *  @fd:        file descriptor of the target file
> + *  @start:     starting address offset of the target file (in byte).
> + *              This should be aligned to page cache size.
> + *  @nr_pages:  the number of pages from which the page data is passed to
> + *              userspace. If you don't set FINCORE_SKIP_HOLE, it's identical
> + *             to the pages to be scanned.
> + *  @mode       fincore mode flags to determine the entry's format
> + *  @vec        pointer of the userspace buffer. The size must be equal to or
> + *              larger than (@nr_pages * width), where width is the size of
> + *              each entry.
> + *
> + * fincore() returns the memory residency status and additional info (like
> + * pfn and page flags) of the given file's pages.
> + *
> + * Depending on the fincore mode, caller can receive the different formatted
> + * information. See the comment on definition of FINCORE_* above.
> + *
> + * Because the status of a page can change after fincore() checks it
> + * but before it returns to the application, the returned vector may
> + * contain stale information.
> + *
> + * return values:
> + *  -EBADF:     @fd isn't a valid open file descriptor
> + *  -EFAULT:    @vec points to an illegal address
> + *  -EINVAL:    @start is not aligned to page cache size, or @mode is invalid
> + *  non-negative value: fincore() is successfully done and the value means
> + *              the number of valid entries stored on userspace buffer
> + */
> +SYSCALL_DEFINE5(fincore, int, fd, loff_t, start, long, nr_pages,
> +               int, mode, unsigned char __user *, vec)
> +{
> +       long ret;
> +       long step;
> +       long nr = 0;
> +       int pc_shift = PAGE_CACHE_SHIFT;
> +       struct fd f;
> +
> +       struct fincore_control fc = {
> +               .mode   = mode,
> +               .width  = sizeof(unsigned char),
> +       };
> +
> +       if (!fincore_validate_mode(mode))
> +               return -EINVAL;
> +
> +       f = fdget(fd);
> +
> +       if (is_file_hugepages(f.file))
> +               pc_shift = huge_page_shift(hstate_file(f.file));
> +
> +       if (!IS_ALIGNED(start, 1 << pc_shift)) {
> +               ret = -EINVAL;
> +               goto fput;
> +       }
> +
> +       /*
> +        * TODO: support /dev/mem, /proc/pid/mem for system/process wide
> +        * page survey, which would obsolete /proc/kpageflags, and
> +        * /proc/pid/pagemap.
> +        */
> +       if (!S_ISREG(file_inode(f.file)->i_mode)) {
> +               ret = -EBADF;
> +               goto fput;
> +       }
> +
> +       fc.pgstart = start >> pc_shift;
> +       fc.nr_pages = nr_pages;
> +       fc.mapping = f.file->f_mapping;
> +       if (mode & FINCORE_LONGENTRY_MASK)
> +               fc.width = ((mode & FINCORE_PFN ? 1 : 0) +
> +                           (mode & FINCORE_PAGE_FLAGS ? 1 : 0) +
> +                           (mode & FINCORE_PAGECACHE_TAGS ? 1 : 0) +
> +                           (mode & FINCORE_SKIP_HOLE ? 1 : 0)
> +                       ) * sizeof(unsigned long);
> +       step = min(fc.nr_pages, FINCORE_LOOP_STEP);
> +
> +       fc.buffer_size = step * fc.width;
> +       fc.buffer = kzalloc(fc.buffer_size, GFP_TEMPORARY);
> +       if (!fc.buffer) {
> +               ret = -ENOMEM;
> +               goto fput;
> +       }
> +
> +       while (true) {
> +               ret = do_fincore(&fc, min(step, fc.nr_pages));
> +               /* Reached the end of the file */
> +               if (ret == 0) {
> +                       ret = nr;
> +                       break;
> +               }
> +               if (ret < 0)
> +                       break;
> +               if (copy_to_user(vec + nr * fc.width,
> +                                fc.buffer, ret * fc.width)) {
> +                       ret = -EFAULT;
> +                       break;
> +               }
> +               fc.nr_pages -= ret;
> +               fc.pgstart = fc.scanned_offset + 1;
> +               nr += ret;
> +               /* Completed scanning the requested numbers of pages */
> +               if (fc.nr_pages == 0) {
> +                       ret = nr;
> +                       break;
> +               }
> +               /* Clear buffer for next do_fincore() */
> +               memset(fc.buffer, 0, step * fc.width);
> +       }
> +
> +       kfree(fc.buffer);
> +fput:
> +       fdput(f);
> +       return ret;
> +}
> --
> 1.9.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
