Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 08E366B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 22:28:13 -0400 (EDT)
Date: Thu, 20 Sep 2012 11:30:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] memory-hotplug: fix zone stat mismatch
Message-ID: <20120920023053.GD13234@bbox>
References: <1348039748-32111-1-git-send-email-minchan@kernel.org>
 <CAHGf_=oSSsJEeh7eN+R6P3n0vq2h5+3DPmogpXqDiu1jJyKmpg@mail.gmail.com>
 <20120919201738.GA2425@barrios>
 <505A6EB7.5070305@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <505A6EB7.5070305@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Shaohua Li <shli@fusionio.com>

On Thu, Sep 20, 2012 at 09:17:43AM +0800, Wen Congyang wrote:
> At 09/20/2012 04:17 AM, Minchan Kim Wrote:
> > Hi KOSAKI,
> > 
> > On Wed, Sep 19, 2012 at 02:05:20PM -0400, KOSAKI Motohiro wrote:
> >> On Wed, Sep 19, 2012 at 3:29 AM, Minchan Kim <minchan@kernel.org> wrote:
> >>> During memory-hotplug stress test, I found NR_ISOLATED_[ANON|FILE]
> >>> are increasing so that kernel are hang out.
> >>>
> >>> The cause is that when we do memory-hotadd after memory-remove,
> >>> __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
> >>> without draining vm_stat_diff of all CPU.
> >>>
> >>> This patch fixes it.
> >>
> >> zone_pcp_update() is called from online pages path. but IMHO,
> >> the statistics should be drained offline path. isn't it?
> > 
> > It isn't necessary because statistics is right until we reset it to zero
> > in online path.
> > Do you have something on your mind that we have to drain it in offline path?
> 
> When a node is offlined and onlined again. We create node_data[i] in the

I would like to clarify your word.
Create or recreate?
Why I have a question is as I look over the source code, hotadd_new_pgdat
seem to be called if we do hotadd *new* memory. It's not the case for
offline and online again you mentioned. If you're right, I should find 
arch_free_nodedata to free pgdat when node is disappear but I can't find it.
Do I miss something?


> function hotadd_new_pgdat(), and we will lost the statistics stored in
> zone->pageset. So we should drain it in offline path.

Even we drain in offline patch, it still has a problem.

1. offline
2. drain -> OKAY 
3. schedule
4. Process A increase zone stat
5. Process B increase zone stat
6. online
7. reset it -> we ends up lost zone stat counter which is modified between 2-6


> 
> Thanks
> Wen Congyang
> 
> > 
> >>
> >> thanks.
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
