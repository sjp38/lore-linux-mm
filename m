Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33D056B02B8
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 21:23:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s87so2212003pfg.19
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 18:23:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p14-v6si320481pli.114.2018.02.06.18.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 18:23:07 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap, frontswap: Fix THP swap if frontswap enabled
References: <20180206065404.18815-1-ying.huang@intel.com>
	<20180206083101.GA17082@eng-minchan1.roam.corp.google.com>
	<871shy3421.fsf@yhuang-dev.intel.com>
	<20180206090244.GA20545@eng-minchan1.roam.corp.google.com>
	<CAC=cRTNCDLdobmepCA-9s6HxCgWs16adhre_LfT0HxtXg6meyw@mail.gmail.com>
	<20180206143505.GB25912@eng-minchan1.roam.corp.google.com>
Date: Wed, 07 Feb 2018 10:23:03 +0800
In-Reply-To: <20180206143505.GB25912@eng-minchan1.roam.corp.google.com>
	(Minchan Kim's message of "Tue, 6 Feb 2018 06:35:05 -0800")
Message-ID: <87fu6d1qt4.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: huang ying <huang.ying.caritas@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Minchan Kim <minchan@kernel.org> writes:

> On Tue, Feb 06, 2018 at 09:34:44PM +0800, huang ying wrote:
>> On Tue, Feb 6, 2018 at 5:02 PM, Minchan Kim <minchan@kernel.org> wrote:
>> > On Tue, Feb 06, 2018 at 04:39:18PM +0800, Huang, Ying wrote:
>> >> Hi, Minchan,
>> >>
>> >> Minchan Kim <minchan@kernel.org> writes:
>> >>
>> >> > Hi Huang,
>> >> >
>> >> > On Tue, Feb 06, 2018 at 02:54:04PM +0800, Huang, Ying wrote:
>> >> >> From: Huang Ying <ying.huang@intel.com>
>> >> >>
>> >> >> It was reported by Sergey Senozhatsky that if THP (Transparent Huge
>> >> >> Page) and frontswap (via zswap) are both enabled, when memory goes low
>> >> >> so that swap is triggered, segfault and memory corruption will occur
>> >> >> in random user space applications as follow,
>> >> >>
>> >> >> kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
>> >> >>  #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
>> >> >>  #1  0x00007fc08889c2f3 malloc (libc.so.6)
>> >> >>  #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
>> >> >>  #3  0x0000560e6005e75c n/a (urxvt)
>> >> >>  #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>> >> >>  #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
>> >> >>  #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
>> >> >>  #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
>> >> >>  #8  0x0000560e6005cb55 ev_run (urxvt)
>> >> >>  #9  0x0000560e6003b9b9 main (urxvt)
>> >> >>  #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
>> >> >>  #11 0x0000560e6003f9da _start (urxvt)
>> >> >>
>> >> >> After bisection, it was found the first bad commit is
>> >> >> bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
>> >> >> out").
>> >> >>
>> >> >> The root cause is as follow.
>> >> >>
>> >> >> When the pages are written to storage device during swapping out in
>> >> >> swap_writepage(), zswap (fontswap) is tried to compress the pages
>> >> >> instead to improve the performance.  But zswap (frontswap) will treat
>> >> >> THP as normal page, so only the head page is saved.  After swapping
>> >> >> in, tail pages will not be restored to its original contents, so cause
>> >> >> the memory corruption in the applications.
>> >> >>
>> >> >> This is fixed via splitting THP at the begin of swapping out if
>> >> >> frontswap is enabled.  To avoid frontswap to be enabled at runtime,
>> >> >> whether the page is THP is checked before using frontswap during
>> >> >> swapping out too.
>> >> >
>> >> > Nice catch, Huang. However, before the adding a new dependency between
>> >> > frontswap and vmscan that I want to avoid if it is possible, let's think
>> >> > whether frontswap can support THP page or not.
>> >> > Can't we handle it with some loop to handle all of subpages of THP page?
>> >> > It might be not hard?
>> >>
>> >> Yes.  That could be an optimization over this patch.  This patch is just
>> >> a simple fix to make things work and be suitable for stable tree.
>> >
>> > Yub, it would be more complex than this patch. However, this patch introduces
>> > a new dependency to vmscan.c. IOW, we have been good without knowing frontswap
>> > in vmscan.c but from now on, we should be aware of that, which is unfortunate.
>> >
>> > Can't we simple do like that if you want to make it simple and rely on someone
>> > who makes frontswap THP-aware later?
>> >
>> > diff --git a/mm/swapfile.c b/mm/swapfile.c
>> > index 42fe5653814a..4bf1725407aa 100644
>> > --- a/mm/swapfile.c
>> > +++ b/mm/swapfile.c
>> > @@ -934,7 +934,11 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
>> >
>> >         /* Only single cluster request supported */
>> >         WARN_ON_ONCE(n_goal > 1 && cluster);
>> > +#ifdef CONFIG_FRONTSWAP
>> > +       /* Now, frontswap doesn't support THP page */
>> > +       if (frontswap_enabled() && cluster)
>> > +               return;
>> > +#endif
>> >         avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
>> >         if (avail_pgs <= 0)
>> >                 goto noswap;
>> >
>> 
>> This can avoid introduce dependency on frontswap in vmscan.c.  But
>> IMHO it doesn't look like the right place to place the logic.
>> vmscan.c is the place we put policy to determine whether to split THP.
>
> It adds split policy in vmscan.c like you said.
>
> shrink_page_list already relies on swap_file.c to decide split a THP page.
> IOW, if a THP swap stuff is not avilable, split a thp.
> It's totally same logic. I don't see any difference at all.
>
> shrink_page_list:
>
> if (!add_to_swap(page)) {
> 	if (PageTransHuge(page))
> 		goto activate_locked;
> 	if (split_huge_page_to_list(page, page_list))
> 		goto activate_locked;
> 	count_vm_event(THP_SWPOUT_FALLBACK);
> 	if (!add_to_swap(page))
> 		goto activate_locked;
> }

OK.  I will change the code as you suggested.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
