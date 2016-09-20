Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA0E36B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:28:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 21so15724430pfy.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:28:24 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f125si30783134pfa.105.2016.09.19.22.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 22:28:23 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <20160909054336.GA2114@bbox>
	<87sht824n3.fsf@yhuang-mobile.sh.intel.com>
	<20160913061349.GA4445@bbox> <87y42wgv5r.fsf@yhuang-dev.intel.com>
	<20160913070524.GA4973@bbox>
	<87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
	<20160913091652.GB7132@bbox> <87intu9dng.fsf@yhuang-dev.intel.com>
	<20160919070805.GA4083@bbox> <87wpi72sd0.fsf@yhuang-dev.intel.com>
	<20160920050245.GA3425@bbox>
Date: Tue, 20 Sep 2016 13:28:19 +0800
In-Reply-To: <20160920050245.GA3425@bbox> (Minchan Kim's message of "Tue, 20
	Sep 2016 14:06:05 +0900")
Message-ID: <87k2e72l8s.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On Tue, Sep 20, 2016 at 10:54:35AM +0800, Huang, Ying wrote:
>> Hi, Minchan,
>> 
>> Minchan Kim <minchan@kernel.org> writes:
>> > Hi Huang,
>> >
>> > On Sun, Sep 18, 2016 at 09:53:39AM +0800, Huang, Ying wrote:
>> >> Minchan Kim <minchan@kernel.org> writes:
>> >> 
>> >> > On Tue, Sep 13, 2016 at 04:53:49PM +0800, Huang, Ying wrote:
>> >> >> Minchan Kim <minchan@kernel.org> writes:
>> >> >> > On Tue, Sep 13, 2016 at 02:40:00PM +0800, Huang, Ying wrote:
>> >> >> >> Minchan Kim <minchan@kernel.org> writes:
>> >> >> >> 
>> >> >> >> > Hi Huang,
>> >> >> >> >
>> >> >> >> > On Fri, Sep 09, 2016 at 01:35:12PM -0700, Huang, Ying wrote:
>> >> >> >> >
>> 
>> [snip]
>> 
>> >> >> > 1. If we solve batching swapout, then how is THP split for swapout bad?
>> >> >> > 2. Also, how is current conservatie swapin from khugepaged bad?
>> >> >> >
>> >> >> > I think it's one of decision point for the motivation of your work
>> >> >> > and for 1, we need batching swapout feature.
>> >> >> >
>> >> >> > I am saying again that I'm not against your goal but only concern
>> >> >> > is approach. If you don't agree, please ignore me.
>> >> >> 
>> >> >> I am glad to discuss my final goal, that is, swapping out/in the full
>> >> >> THP without splitting.  Why I want to do that is copied as below,
>> >> >
>> >> > Yes, it's your *final* goal but what if it couldn't be acceptable
>> >> > on second step you mentioned above, for example?
>> >> >
>> >> >         Unncessary binded implementation to rejected work.
>> >> 
>> >> So I want to discuss my final goal.  If people accept my final goal,
>> >> this is resolved.  If people don't accept, I will reconsider it.
>> >
>> > No.
>> >
>> > Please keep it in mind. There are lots of factors the project would
>> > be broken during going on by several reasons because we are human being
>> > so we can simply miss something clear and realize it later that it's
>> > not feasible. Otherwise, others can show up with better idea for the
>> > goal or fix other subsystem which can affect your goals.
>> > I don't want to say such boring theoretical stuffs any more.
>> >
>> > My point is patchset should be self-contained if you really want to go
>> > with step-by-step approach because we are likely to miss something
>> > *easily*.
>> >
>> >> 
>> >> > If you want to achieve your goal step by step, please consider if
>> >> > one of step you are thinking could be rejected but steps already
>> >> > merged should be self-contained without side-effect.
>> >> 
>> >> What is the side-effect or possible regressions of the step 1 as in this
>> >
>> > Adding code complexity for unproved feature.
>> >
>> > When I read your steps, your *most important* goal is to avoid split/
>> > collapsing anon THP page for swap out/in. As a bonus with the approach,
>> > we could increase swapout/in bandwidth, too. Do I understand correctly?
>> 
>> It's hard to say what is the *most important* goal.  But it is clear
>> that to improve swapout/in performance isn't the only goal.  The other
>> goal to avoid split/collapsing THP page for swap out/in is very
>> important too.
>
> Okay, then, couldn't you focus a goal in patchset? After solving a problem,
> then next one. What's the problem?
> One of your goal is swapout performance and it's same with Tim's work.
> That's why I wanted to make your patchset based on Tim's work. But if you
> want your patch first, please make patchset independent with your other goal
> so everyone can review easily and focus on *a* problem.
> In your patchset, THP split delaying part could be folded into in your second
> patchset which is to avoid THP split/collapsing.

I thought multiple goals for one patchset is common.  But if you want
just one goal for review, I suggest you to review the patchset for the
goal to avoid split/collapsing anon THP page for swap out/in.  And this
patchset is just the first step for that.

>> > However, swap-in/out bandwidth enhance is common requirement for both
>> > normal and THP page and with Tim's work, we could enhance swapout path.
>> >
>> > So, I think you should give us to number about how THP split is bad
>> > for the swapout bandwidth even though we applied Tim's work.
>> > If it's serious, next approach is yours that we could tweak swap code
>> > be aware of a THP to avoid splitting a THP.
>> 
>> It's not only about CPU cycles spent in splitting and collapsing THP,
>> but also how to make THP work effectively on systems with swap turned
>> on.
>> 
>> To avoid disturbing user applications etc., THP collapsing doesn't work
>> aggressively to collapse anonymous pages into THP.  This means, once the
>> THP is split, it will take quite long time (wall time, instead of CPU
>> cycles) to be collapsed to become a THP, especially on machines with
>> large memory size.  And on systems with swap turned on, THP will be
>> split during swap out/in now.  If much swapping out/in is triggered
>> during system running, it is possible that many THP is split, and have
>> no chance to be collapsed.  Even if the THP that has been split gets
>> opportunity to be collapsed again, the applications lose the opportunity
>> to take advantage of the THP for quite long time too.  And the memory
>> will be fragmented during the process, this makes it hard to allocate
>> new THP.  The end result is that THP usage is very low in this
>> situation.  One solution is to avoid to split/collapse THP during swap
>> out/in.
>
> I understand what you want. I have a few questions for the goal but
> will not ask now because I want to see more in your description to
> understand current situation well.
>
> Huang, please, don't mix your goals in a patchset and include your
> claim with number we can justify. It would make more reviewer happy.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
