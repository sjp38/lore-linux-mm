Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE6C76B0038
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:54:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so10368766pfj.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 19:54:40 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m2si32329011pam.255.2016.09.19.19.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 19:54:39 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<20160909054336.GA2114@bbox>
	<87sht824n3.fsf@yhuang-mobile.sh.intel.com>
	<20160913061349.GA4445@bbox> <87y42wgv5r.fsf@yhuang-dev.intel.com>
	<20160913070524.GA4973@bbox>
	<87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
	<20160913091652.GB7132@bbox> <87intu9dng.fsf@yhuang-dev.intel.com>
	<20160919070805.GA4083@bbox>
Date: Tue, 20 Sep 2016 10:54:35 +0800
In-Reply-To: <20160919070805.GA4083@bbox> (Minchan Kim's message of "Mon, 19
	Sep 2016 16:08:05 +0900")
Message-ID: <87wpi72sd0.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:
> Hi Huang,
>
> On Sun, Sep 18, 2016 at 09:53:39AM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Tue, Sep 13, 2016 at 04:53:49PM +0800, Huang, Ying wrote:
>> >> Minchan Kim <minchan@kernel.org> writes:
>> >> > On Tue, Sep 13, 2016 at 02:40:00PM +0800, Huang, Ying wrote:
>> >> >> Minchan Kim <minchan@kernel.org> writes:
>> >> >> 
>> >> >> > Hi Huang,
>> >> >> >
>> >> >> > On Fri, Sep 09, 2016 at 01:35:12PM -0700, Huang, Ying wrote:
>> >> >> >

[snip]

>> >> > 1. If we solve batching swapout, then how is THP split for swapout bad?
>> >> > 2. Also, how is current conservatie swapin from khugepaged bad?
>> >> >
>> >> > I think it's one of decision point for the motivation of your work
>> >> > and for 1, we need batching swapout feature.
>> >> >
>> >> > I am saying again that I'm not against your goal but only concern
>> >> > is approach. If you don't agree, please ignore me.
>> >> 
>> >> I am glad to discuss my final goal, that is, swapping out/in the full
>> >> THP without splitting.  Why I want to do that is copied as below,
>> >
>> > Yes, it's your *final* goal but what if it couldn't be acceptable
>> > on second step you mentioned above, for example?
>> >
>> >         Unncessary binded implementation to rejected work.
>> 
>> So I want to discuss my final goal.  If people accept my final goal,
>> this is resolved.  If people don't accept, I will reconsider it.
>
> No.
>
> Please keep it in mind. There are lots of factors the project would
> be broken during going on by several reasons because we are human being
> so we can simply miss something clear and realize it later that it's
> not feasible. Otherwise, others can show up with better idea for the
> goal or fix other subsystem which can affect your goals.
> I don't want to say such boring theoretical stuffs any more.
>
> My point is patchset should be self-contained if you really want to go
> with step-by-step approach because we are likely to miss something
> *easily*.
>
>> 
>> > If you want to achieve your goal step by step, please consider if
>> > one of step you are thinking could be rejected but steps already
>> > merged should be self-contained without side-effect.
>> 
>> What is the side-effect or possible regressions of the step 1 as in this
>
> Adding code complexity for unproved feature.
>
> When I read your steps, your *most important* goal is to avoid split/
> collapsing anon THP page for swap out/in. As a bonus with the approach,
> we could increase swapout/in bandwidth, too. Do I understand correctly?

It's hard to say what is the *most important* goal.  But it is clear
that to improve swapout/in performance isn't the only goal.  The other
goal to avoid split/collapsing THP page for swap out/in is very
important too.

> However, swap-in/out bandwidth enhance is common requirement for both
> normal and THP page and with Tim's work, we could enhance swapout path.
>
> So, I think you should give us to number about how THP split is bad
> for the swapout bandwidth even though we applied Tim's work.
> If it's serious, next approach is yours that we could tweak swap code
> be aware of a THP to avoid splitting a THP.

It's not only about CPU cycles spent in splitting and collapsing THP,
but also how to make THP work effectively on systems with swap turned
on.

To avoid disturbing user applications etc., THP collapsing doesn't work
aggressively to collapse anonymous pages into THP.  This means, once the
THP is split, it will take quite long time (wall time, instead of CPU
cycles) to be collapsed to become a THP, especially on machines with
large memory size.  And on systems with swap turned on, THP will be
split during swap out/in now.  If much swapping out/in is triggered
during system running, it is possible that many THP is split, and have
no chance to be collapsed.  Even if the THP that has been split gets
opportunity to be collapsed again, the applications lose the opportunity
to take advantage of the THP for quite long time too.  And the memory
will be fragmented during the process, this makes it hard to allocate
new THP.  The end result is that THP usage is very low in this
situation.  One solution is to avoid to split/collapse THP during swap
out/in.

> For THP swap-in, I think it's another topic we should discuss.
> For each step, it's orthogonal work so it shouldn't rely on next goal.
>
>
>> patchset?  Lacks the opportunity to allocate consecutive 512 swap slots
>> in 2 non-free swap clusters?  I don't think that is a regression,
>> because the patchset will NOT make free swap clusters consumed faster
>> than that in current code.  Even if it were better to allocate
>> consecutive 512 swap slots in 2 non-free swap clusters, it could be an
>> incremental improvement to the simple solution in this patchset.  That
>> is, to allocate 512 swap slots, the simple solution is:
>> 
>> a) Try to allocate a free swap cluster
>> b) If a) fails, give up
>> 
>> The improved solution could be (if it were needed finally)
>> 
>> a) Try to allocate a free swap cluster
>> b) If a) fails, try to allocate consecutive 512 swap slots in 2 non-free
>>    swap clusters
>> c) If b) fails, give up
>
> I didn't mean it. Please read above.
>
>> 
>> > If it's hard, send full patchset all at once so reviewers can think
>> > what you want of right direction and implementation is good for it.
>> 
>> Thanks for suggestion.
>
> Huang,
>
> I'm sorry if I misunderstand something. And I should admit I'm not a THP
> user even so I'm blind on a THP workload so sorry too if I miss really
> something clear. However, my concern is adding more complexity to swap
> layer without justfication and to me, it's really hard to understand your
> motivation from your description.
>
> If you want step by step approach, for the first step, please prove
> how THP split is bad in swapout path and it would be better to consider
> how to make codes shareable with normal pages batching so THP awareness
> on top of normal page batching, it would be more easy to prove/review,
> I think.

If it were needed by normal pages batching, the free swap cluster
allocating/freeing functions in this patchset could be reused by normal
pages batching I think.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
