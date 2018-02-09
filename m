Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B97F26B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 19:39:15 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id m39so828212plg.6
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 16:39:15 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c1si661168pge.118.2018.02.08.16.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 16:39:14 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2] mm, swap, frontswap: Fix THP swap if frontswap enabled
References: <20180207070035.30302-1-ying.huang@intel.com>
	<CAC=cRTOacms57fSuQrYjfj_vijxx-9nK9c9u0YQ60qcYJ64Eow@mail.gmail.com>
	<20180208173734.GA80964@eng-minchan1.roam.corp.google.com>
Date: Fri, 09 Feb 2018 08:39:10 +0800
In-Reply-To: <20180208173734.GA80964@eng-minchan1.roam.corp.google.com>
	(Minchan Kim's message of "Thu, 8 Feb 2018 09:37:35 -0800")
Message-ID: <87a7wjyp1t.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: huang ying <huang.ying.caritas@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On Thu, Feb 08, 2018 at 11:27:50PM +0800, huang ying wrote:
>> On Wed, Feb 7, 2018 at 3:00 PM, Huang, Ying <ying.huang@intel.com> wrote:
>> > From: Huang Ying <huang.ying.caritas@gmail.com>
>> >
>> > It was reported by Sergey Senozhatsky that if THP (Transparent Huge
>> > Page) and frontswap (via zswap) are both enabled, when memory goes low
>> > so that swap is triggered, segfault and memory corruption will occur
>> > in random user space applications as follow,
>> >
>> > kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
>> >  #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
>> >  #1  0x00007fc08889c2f3 malloc (libc.so.6)
>> >  #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
>> >  #3  0x0000560e6005e75c n/a (urxvt)
>> >  #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>> >  #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
>> >  #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
>> >  #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
>> >  #8  0x0000560e6005cb55 ev_run (urxvt)
>> >  #9  0x0000560e6003b9b9 main (urxvt)
>> >  #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
>> >  #11 0x0000560e6003f9da _start (urxvt)
>> >
>> > After bisection, it was found the first bad commit is
>> > bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
>> > out").
>> >
>> > The root cause is as follow.
>> >
>> > When the pages are written to swap device during swapping out in
>> > swap_writepage(), zswap (fontswap) is tried to compress the pages
>> > instead to improve the performance.  But zswap (frontswap) will treat
>> > THP as normal page, so only the head page is saved.  After swapping
>> > in, tail pages will not be restored to its original contents, so cause
>> > the memory corruption in the applications.
>> >
>> > This is fixed via splitting THP before writing the page to swap device
>> > if frontswap is enabled.  To deal with the situation where frontswap
>> > is enabled at runtime, whether the page is THP is checked before using
>> > frontswap during swapping out too.
>> >
>> > Reported-and-tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>> > Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> > Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>> > Cc: Dan Streetman <ddstreet@ieee.org>
>> > Cc: Seth Jennings <sjenning@redhat.com>
>> > Cc: Minchan Kim <minchan@kernel.org>
>> > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> > Cc: Shaohua Li <shli@kernel.org>
>> > Cc: Michal Hocko <mhocko@suse.com>
>> > Cc: Johannes Weiner <hannes@cmpxchg.org>
>> > Cc: Mel Gorman <mgorman@techsingularity.net>
>> > Cc: Shakeel Butt <shakeelb@google.com>
>> > Cc: stable@vger.kernel.org # 4.14
>> > Fixes: bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped out")
>> >
>> > Changelog:
>> >
>> > v2:
>> >
>> > - Move frontswap check into swapfile.c to avoid to make vmscan.c
>> >   depends on frontswap.
>> > ---
>> >  mm/page_io.c  | 2 +-
>> >  mm/swapfile.c | 3 +++
>> >  2 files changed, 4 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/mm/page_io.c b/mm/page_io.c
>> > index b41cf9644585..6dca817ae7a0 100644
>> > --- a/mm/page_io.c
>> > +++ b/mm/page_io.c
>> > @@ -250,7 +250,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>> >                 unlock_page(page);
>> >                 goto out;
>> >         }
>> > -       if (frontswap_store(page) == 0) {
>> > +       if (!PageTransHuge(page) && frontswap_store(page) == 0) {
>> >                 set_page_writeback(page);
>> >                 unlock_page(page);
>> >                 end_page_writeback(page);
>> > diff --git a/mm/swapfile.c b/mm/swapfile.c
>> > index 006047b16814..0b7c7883ce64 100644
>> > --- a/mm/swapfile.c
>> > +++ b/mm/swapfile.c
>> > @@ -934,6 +934,9 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
>> >
>> >         /* Only single cluster request supported */
>> >         WARN_ON_ONCE(n_goal > 1 && cluster);
>> > +       /* Frontswap doesn't support THP */
>> > +       if (frontswap_enabled() && cluster)
>> > +               goto noswap;
>> 
>> I found this will cause THP swap optimization be turned off forever if
>> CONFIG_ZSWAP=y (which cannot =m).  Because frontswap is enabled quite
>> statically instead of dynamically.  If frontswap_ops is registered, it
>> will be enabled unconditionally and forever.  And zswap will register
>> frontswap_ops during initialize regardless whether zswap is enabled or
>> not.
>
> Indeed.
>
>> 
>> So I think it will be better to remove swapfile.c changes in this
>> patch, just keep page_io.c changes.  Because THP is more dynamic, it
>
> Then, I think it should be done by frontswap backend rather than generic
> swap layer. Because there are two backends now and one of them can support
> first.
>
> diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
> index bf13d1ec51f3..bdaf309aeea6 100644
> --- a/drivers/xen/tmem.c
> +++ b/drivers/xen/tmem.c
> @@ -284,6 +284,9 @@ static int tmem_frontswap_store(unsigned type, pgoff_t offset,
>         int pool = tmem_frontswap_poolid;
>         int ret;
>  
> +       if (PageTransHuge(page))
> +               return -EINVAL;
> +
>         if (pool < 0)
>                 return -1;
>         if (ind64 != ind)
> diff --git a/mm/zswap.c b/mm/zswap.c
> index c004aa4fd3f4..e343534d2892 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1007,6 +1007,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         u8 *src, *dst;
>         struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
>  
> +       if (PageTransHuge(page))
> +               return -EINVAL;
> +
>         if (!zswap_enabled || !tree) {
>                 ret = -ENODEV;
>                 goto reject;

Good suggestion!  I will do this.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
