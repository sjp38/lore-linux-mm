Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5049F6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 20:57:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e5so20133294ith.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 17:57:57 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d84si32391343ioj.120.2016.06.14.17.57.55
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 17:57:56 -0700 (PDT)
Date: Wed, 15 Jun 2016 09:57:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 0/3] per-process reclaim
Message-ID: <20160615005755.GD17127@bbox>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <8f2190f4-4388-0eb2-0ffc-b2190280b11a@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f2190f4-4388-0eb2-0ffc-b2190280b11a@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Redmond <u93410091@gmail.com>, "ZhaoJunmin Zhao(Junmin)" <zhaojunmin@huawei.com>, Juneho Choi <juno.choi@lge.com>, Sangwoo Park <sangwoo2.park@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

On Mon, Jun 13, 2016 at 06:59:40PM +0530, Vinayak Menon wrote:
> On 6/13/2016 1:20 PM, Minchan Kim wrote:
> > Hi all,
> >
> > http://thread.gmane.org/gmane.linux.kernel/1480728
> >
> > I sent per-process reclaim patchset three years ago. Then, last
> > feedback from akpm was that he want to know real usecase scenario.
> >
> > Since then, I got question from several embedded people of various
> > company "why it's not merged into mainline" and heard they have used
> > the feature as in-house patch and recenlty, I noticed android from
> > Qualcomm started to use it.
> >
> > Of course, our product have used it and released it in real procuct.
> >
> > Quote from Sangwoo Park <angwoo2.park@lge.com>
> > Thanks for the data, Sangwoo!
> > "
> > - Test scenaro
> >   - platform: android
> >   - target: MSM8952, 2G DDR, 16G eMMC
> >   - scenario
> >     retry app launch and Back Home with 16 apps and 16 turns
> >     (total app launch count is 256)
> >   - result:
> > 			  resume count   |  cold launching count
> > -----------------------------------------------------------------
> >  vanilla           |           85        |          171
> >  perproc reclaim   |           184       |           72
> > "
> >
> > Higher resume count is better because cold launching needs loading
> > lots of resource data which takes above 15 ~ 20 seconds for some
> > games while successful resume just takes 1~5 second.
> >
> > As perproc reclaim way with new management policy, we could reduce
> > cold launching a lot(i.e., 171-72) so that it reduces app startup
> > a lot.
> >
> Thanks Minchan for bringing this up. When we had tried the earlier patchset in its original form,
> the resume of the app that was reclaimed, was taking a lot of time. But from the data shown above it looks
> to be improving the resume time. Is that the resume time of "other" apps which were able to retain their working set
> because of the more efficient swapping of low priority apps with per process reclaim ?

Sorry for confusing. I meant the app should start from the scratch
if it was killed, which might need load a hundread megabytes while
resume needs to load just workingset memory which would be smaller.

> Because of the higher resume time we had to modify the logic a bit and device a way to pick a "set" of low priority
> (oom_score_adj) tasks and reclaim certain number of pages (only anon) from each of them (the number of pages reclaimed
> from each task being proportional to task size). This deviates from the original intention of the patch to rescue a
> particular app of interest, but still using the hints on working set provided by userspace and avoiding high resume stalls.
> The increased swapping was helping in maintaining a better memory state and lesser page cache reclaim,
> resulting in better app resume time, and lesser task kills.

Fair enough.

> 
> So would it be better if a userspace knob is provided to tell the kernel, the max number of pages to be reclaimed from a task ?
> This way userspace can make calculations depending on priority, task size etc and reclaim the required number of pages from
> each task, and thus avoid the resume stall because of reclaiming an entire task.
> 
> And also, would it be possible to implement the same using per task memcg by setting the limits and swappiness in such a
> way that it results inthe same thing that per process reclaim does ?

Yeb, I read Johannes's thread which suggests one-cgroup-per-app model.
It does make sense to me. It is worth to try although I guess it's not
easy to control memory usage on demand, not proactively.
If we can do, maybe we don't need per-process reclaim policy which
is rather coarse-grained model of reclaim POV.
However, a concern with one-cgroup-per-app model is LRU list size
of a cgroup is much smaller so how LRU aging works well and
LRU churing(e.g., compaction) effect would be severe than old.

I guess codeaurora tried memcg model for android.
Could you share if you know something?

Thanks.


> 
> Thanks,
> Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
