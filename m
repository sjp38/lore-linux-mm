Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6C766B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:29:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f6so75266925ith.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:29:49 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id as6si814983pac.173.2016.06.13.06.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 06:29:49 -0700 (PDT)
Subject: Re: [PATCH v1 0/3] per-process reclaim
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <8f2190f4-4388-0eb2-0ffc-b2190280b11a@codeaurora.org>
Date: Mon, 13 Jun 2016 18:59:40 +0530
MIME-Version: 1.0
In-Reply-To: <1465804259-29345-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Redmond <u93410091@gmail.com>, "ZhaoJunmin Zhao(Junmin)" <zhaojunmin@huawei.com>, Juneho Choi <juno.choi@lge.com>, Sangwoo Park <sangwoo2.park@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

On 6/13/2016 1:20 PM, Minchan Kim wrote:
> Hi all,
>
> http://thread.gmane.org/gmane.linux.kernel/1480728
>
> I sent per-process reclaim patchset three years ago. Then, last
> feedback from akpm was that he want to know real usecase scenario.
>
> Since then, I got question from several embedded people of various
> company "why it's not merged into mainline" and heard they have used
> the feature as in-house patch and recenlty, I noticed android from
> Qualcomm started to use it.
>
> Of course, our product have used it and released it in real procuct.
>
> Quote from Sangwoo Park <angwoo2.park@lge.com>
> Thanks for the data, Sangwoo!
> "
> - Test scenaro
>   - platform: android
>   - target: MSM8952, 2G DDR, 16G eMMC
>   - scenario
>     retry app launch and Back Home with 16 apps and 16 turns
>     (total app launch count is 256)
>   - result:
> 			  resume count   |  cold launching count
> -----------------------------------------------------------------
>  vanilla           |           85        |          171
>  perproc reclaim   |           184       |           72
> "
>
> Higher resume count is better because cold launching needs loading
> lots of resource data which takes above 15 ~ 20 seconds for some
> games while successful resume just takes 1~5 second.
>
> As perproc reclaim way with new management policy, we could reduce
> cold launching a lot(i.e., 171-72) so that it reduces app startup
> a lot.
>
Thanks Minchan for bringing this up. When we had tried the earlier patchset in its original form,
the resume of the app that was reclaimed, was taking a lot of time. But from the data shown above it looks
to be improving the resume time. Is that the resume time of "other" apps which were able to retain their working set
because of the more efficient swapping of low priority apps with per process reclaim ?
Because of the higher resume time we had to modify the logic a bit and device a way to pick a "set" of low priority
(oom_score_adj) tasks and reclaim certain number of pages (only anon) from each of them (the number of pages reclaimed
from each task being proportional to task size). This deviates from the original intention of the patch to rescue a
particular app of interest, but still using the hints on working set provided by userspace and avoiding high resume stalls.
The increased swapping was helping in maintaining a better memory state and lesser page cache reclaim,
resulting in better app resume time, and lesser task kills.

So would it be better if a userspace knob is provided to tell the kernel, the max number of pages to be reclaimed from a task ?
This way userspace can make calculations depending on priority, task size etc and reclaim the required number of pages from
each task, and thus avoid the resume stall because of reclaiming an entire task.

And also, would it be possible to implement the same using per task memcg by setting the limits and swappiness in such a
way that it results inthe same thing that per process reclaim does ?

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
