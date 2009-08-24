Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A6DAB6B00A2
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:07:32 -0400 (EDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp [192.51.44.36])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7O1sGIt017580
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 24 Aug 2009 10:54:16 +0900
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7O1reK9006491
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 24 Aug 2009 10:53:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D47245DE51
	for <linux-mm@kvack.org>; Mon, 24 Aug 2009 10:53:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F32645DE4D
	for <linux-mm@kvack.org>; Mon, 24 Aug 2009 10:53:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52C981DB8037
	for <linux-mm@kvack.org>; Mon, 24 Aug 2009 10:53:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D24B7E08002
	for <linux-mm@kvack.org>; Mon, 24 Aug 2009 10:53:36 +0900 (JST)
Date: Mon, 24 Aug 2009 10:51:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
Message-Id: <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
	<28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Hiroaki Wakabayashi <primulaelatior@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 2009 10:44:41 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sun, Aug 23, 2009 at 1:54 AM, Hiroaki
> Wakabayashi<primulaelatior@gmail.com> wrote:
> > From 27b2fde0222c59049026e7d0bdc4a2a68d0720f5 Mon Sep 17 00:00:00 2001
> > From: Hiroaki Wakabayashi <primulaelatior@gmail.com>
> > Date: Sat, 22 Aug 2009 19:14:53 +0900
> > Subject: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
> >
> > This patch is for making commit 4779280d1e (mm: make get_user_pages()
> > interruptible) complete.
> >
> > At first, munlock() assumes that all pages in vma are pinned,
> >
> > Now, by the commit, mlock() can be interrupted by SIGKILL, etc A So, part of
> > pages are not pinned.
> > If SIGKILL, In exit() path, munlock is called for unlocking pinned pages
> > in vma.
> >
> > But, there, get_user_pages(write) is used for munlock(). Then, pages are
> > allocated via page-fault for exsiting process !!! This is problem at canceling
> > big mlock.
> > This patch tries to avoid allocating new pages at munlock().
> >
> > A  mlock( big area )
> > A  A  A  A <===== sig kill
> > A  do_exit()
> > A  A ->mmput()
> > A  A  A  -> do_munlock()
> > A  A  A  A  -> get_user_pages()
> > A  A  A  A  A  A  A  <allocate *never used* memory>
> > A  A  A  ->.....freeing allocated memory.
> >
> > * Test program
> > % cat run.sh
> > #!/bin/sh
> >
> > ./mlock_test 2000000000 &
> > sleep 2
> > kill -9 $!
> > wait
> >
> > % cat mlock_test.c
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <string.h>
> > #include <sys/mman.h>
> > #include <sys/types.h>
> > #include <sys/stat.h>
> > #include <fcntl.h>
> > #include <errno.h>
> > #include <time.h>
> > #include <unistd.h>
> > #include <sys/time.h>
> >
> > int main(int argc, char **argv)
> > {
> > A  A  A  A size_t length = 50 * 1024 * 1024;
> > A  A  A  A void *addr;
> > A  A  A  A time_t timer;
> >
> > A  A  A  A if (argc >= 2)
> > A  A  A  A  A  A  A  A length = strtoul(argv[1], NULL, 10);
> > A  A  A  A printf("PID = %d\n", getpid());
> > A  A  A  A addr = mmap(NULL, length, PROT_READ | PROT_WRITE,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> > A  A  A  A if (addr == MAP_FAILED) {
> > A  A  A  A  A  A  A  A fprintf(stderr, "mmap failed: %s, length=%lu\n",
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A strerror(errno), length);
> > A  A  A  A  A  A  A  A exit(EXIT_FAILURE);
> > A  A  A  A }
> > A  A  A  A printf("try mlock length=%lu\n", length);
> > A  A  A  A timer = time(NULL);
> > A  A  A  A if (mlock(addr, length) < 0) {
> > A  A  A  A  A  A  A  A fprintf(stderr, "mlock failed: %s, time=%lu[sec]\n",
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A strerror(errno), time(NULL) - timer);
> > A  A  A  A  A  A  A  A exit(EXIT_FAILURE);
> > A  A  A  A }
> > A  A  A  A printf("mlock succeed, time=%lu[sec]\n\n", time(NULL) - timer);
> > A  A  A  A printf("try munlock length=%lu\n", length);
> > A  A  A  A timer = time(NULL);
> > A  A  A  A if (munlock(addr, length) < 0) {
> > A  A  A  A  A  A  A  A fprintf(stderr, "munlock failed: %s, time=%lu[sec]\n",
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A strerror(errno), time(NULL)-timer);
> > A  A  A  A  A  A  A  A exit(EXIT_FAILURE);
> > A  A  A  A }
> > A  A  A  A printf("munlock succeed, time=%lu[sec]\n\n", time(NULL) - timer);
> > A  A  A  A if (munmap(addr, length) < 0) {
> > A  A  A  A  A  A  A  A fprintf(stderr, "munmap failed: %s\n", strerror(errno));
> > A  A  A  A  A  A  A  A exit(EXIT_FAILURE);
> > A  A  A  A }
> > A  A  A  A return 0;
> > }
> >
> > * Executed Result
> > -- Original executed result
> > % time ./run.sh
> >
> > PID = 2678
> > try mlock length=2000000000
> > ./run.sh: line 6: A 2678 Killed A  A  A  A  A  A  A  A  A ./mlock_test 2000000000
> > ./run.sh A 0.00s user 2.59s system 13% cpu 18.781 total
> > %
> >
> > -- After applied this patch
> > % time ./run.sh
> >
> > PID = 2512
> > try mlock length=2000000000
> > ./run.sh: line 6: A 2512 Killed A  A  A  A  A  A  A  A  A ./mlock_test 2000000000
> > ./run.sh A 0.00s user 1.15s system 45% cpu 2.507 total
> > %
> >
> > Signed-off-by: Hiroaki Wakabayashi <primulaelatior@gmail.com>
> > ---
> > A mm/internal.h | A  A 1 +
> > A mm/memory.c A  | A  A 9 +++++++--
> > A mm/mlock.c A  A | A  35 +++++++++++++++++++----------------
> > A 3 files changed, 27 insertions(+), 18 deletions(-)
> >
> > diff --git a/mm/internal.h b/mm/internal.h
> > index f290c4d..4ab5b24 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -254,6 +254,7 @@ static inline void
> > mminit_validate_memmodel_limits(unsigned long *start_pfn,
> > A #define GUP_FLAGS_FORCE A  A  A  A  A  A  A  A  A 0x2
> > A #define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
> > A #define GUP_FLAGS_IGNORE_SIGKILL A  A  A  A  0x8
> > +#define GUP_FLAGS_ALLOW_NULL A  A  A  A  A  A  0x10
> >
> 
> I am worried about adding new flag whenever we need it.
> But I think this case makes sense to me.
> In addition, I guess ZERO page can also use this flag.
> 
> Kame. What do you think about it?
> 
I do welcome this !
Then, I don't have to take care of mlock/munlock in ZERO_PAGE patch.
 
And without this patch, munlock() does copy-on-write just for unpinning memory.
So, this patch shows some right direction, I think.

One concern is flag name, ALLOW_NULL sounds not very good.

  GUP_FLAGS_NOFAULT ?

I wonder we can remove a hack of FOLL_ANON for core-dump by this flag, too.

Thanks,
-Kame


> 
> > A int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> > A  A  A  A  A  A  A  A  A  A  unsigned long start, int len, int flags,
> > diff --git a/mm/memory.c b/mm/memory.c
> > index aede2ce..b41fbf9 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1217,6 +1217,7 @@ int __get_user_pages(struct task_struct *tsk,
> > struct mm_struct *mm,
> > A  A  A  A int force = !!(flags & GUP_FLAGS_FORCE);
> > A  A  A  A int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
> > A  A  A  A int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
> > + A  A  A  int allow_null = !!(flags & GUP_FLAGS_ALLOW_NULL);
> >
> > A  A  A  A if (nr_pages <= 0)
> > A  A  A  A  A  A  A  A return 0;
> > @@ -1312,6 +1313,8 @@ int __get_user_pages(struct task_struct *tsk,
> > struct mm_struct *mm,
> > A  A  A  A  A  A  A  A  A  A  A  A while (!(page = follow_page(vma, start, foll_flags))) {
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A int ret;
> >
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (allow_null)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A ret = handle_mm_fault(mm, vma, start,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A (foll_flags & FOLL_WRITE) ?
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A FAULT_FLAG_WRITE : 0);
> > @@ -1351,8 +1354,10 @@ int __get_user_pages(struct task_struct *tsk,
> > struct mm_struct *mm,
> > A  A  A  A  A  A  A  A  A  A  A  A if (pages) {
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pages[i] = page;
> >
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  flush_anon_page(vma, page, start);
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  flush_dcache_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (page) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  flush_anon_page(vma, page, start);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  flush_dcache_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  }
> > A  A  A  A  A  A  A  A  A  A  A  A }
> > A  A  A  A  A  A  A  A  A  A  A  A if (vmas)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A vmas[i] = vma;
> > diff --git a/mm/mlock.c b/mm/mlock.c
> > index 45eb650..0f5827b 100644
> > --- a/mm/mlock.c
> > +++ b/mm/mlock.c
> > @@ -178,9 +178,10 @@ static long __mlock_vma_pages_range(struct
> > vm_area_struct *vma,
> > A  A  A  A  */
> > A  A  A  A if (!mlock)
> > A  A  A  A  A  A  A  A gup_flags |= GUP_FLAGS_IGNORE_VMA_PERMISSIONS |
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A GUP_FLAGS_IGNORE_SIGKILL;
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A GUP_FLAGS_IGNORE_SIGKILL |
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A GUP_FLAGS_ALLOW_NULL;
> >
> > - A  A  A  if (vma->vm_flags & VM_WRITE)
> > + A  A  A  if (mlock && (vma->vm_flags & VM_WRITE))
> > A  A  A  A  A  A  A  A gup_flags |= GUP_FLAGS_WRITE;
> >
> > A  A  A  A while (nr_pages > 0) {
> > @@ -220,21 +221,23 @@ static long __mlock_vma_pages_range(struct
> > vm_area_struct *vma,
> > A  A  A  A  A  A  A  A for (i = 0; i < ret; i++) {
> > A  A  A  A  A  A  A  A  A  A  A  A struct page *page = pages[i];
> >
> > - A  A  A  A  A  A  A  A  A  A  A  lock_page(page);
> > - A  A  A  A  A  A  A  A  A  A  A  /*
> > - A  A  A  A  A  A  A  A  A  A  A  A * Because we lock page here and migration is blocked
> > - A  A  A  A  A  A  A  A  A  A  A  A * by the elevated reference, we need only check for
> > - A  A  A  A  A  A  A  A  A  A  A  A * page truncation (file-cache only).
> > - A  A  A  A  A  A  A  A  A  A  A  A */
> > - A  A  A  A  A  A  A  A  A  A  A  if (page->mapping) {
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (mlock)
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  mlock_vma_page(page);
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  else
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  munlock_vma_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  if (page) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  lock_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * Because we lock page here and migration is
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * blocked by the elevated reference, we need
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * only check for page truncation
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * (file-cache only).
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (page->mapping) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (mlock)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  mlock_vma_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  else
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  munlock_vma_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unlock_page(page);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  put_page(page); /* ref from get_user_pages() */
> > A  A  A  A  A  A  A  A  A  A  A  A }
> > - A  A  A  A  A  A  A  A  A  A  A  unlock_page(page);
> > - A  A  A  A  A  A  A  A  A  A  A  put_page(page); A  A  A  A  /* ref from get_user_pages() */
> > -
> > A  A  A  A  A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  A  A  A  A  * here we assume that get_user_pages() has given us
> > A  A  A  A  A  A  A  A  A  A  A  A  * a list of virtually contiguous pages.
> > --
> > 1.5.6.5
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at A http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at A http://www.tux.org/lkml/
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
