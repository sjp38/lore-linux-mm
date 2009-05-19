Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7DE896B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 00:30:20 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J4Ukea020539
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 13:30:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CC0822AEA81
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:30:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A24601EF084
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:30:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 66B6DE18005
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:30:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DA112E08004
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:30:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <4D05DB80B95B23498C72C700BD6C2E0B2EF6E29A@pdsmsx502.ccr.corp.intel.com>
References: <20090519102634.4EB4.A69D9226@jp.fujitsu.com> <4D05DB80B95B23498C72C700BD6C2E0B2EF6E29A@pdsmsx502.ccr.corp.intel.com>
Message-Id: <20090519125744.4EC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 13:30:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Wu, Fengguang" <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> >>-----Original Message-----
> >>From: KOSAKI Motohiro [mailto:kosaki.motohiro@jp.fujitsu.com]
> >>Sent: 2009$B%Hs%d%D(B19$B%M%f(B 10:54
> >>To: Wu, Fengguang
> >>Cc: kosaki.motohiro@jp.fujitsu.com; LKML; linux-mm; Andrew Morton; Rik van
> >>Riel; Christoph Lameter; Zhang, Yanmin
> >>Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
> >>
> >>> On Wed, May 13, 2009 at 12:08:12PM +0900, KOSAKI Motohiro wrote:
> >>> > Subject: [PATCH] zone_reclaim_mode is always 0 by default
> >>> >
> >>> > Current linux policy is, if the machine has large remote node distance,
> >>> >  zone_reclaim_mode is enabled by default because we've be able to assume
> 
> >>
> >>ok, I would explain zone reclaim design and performance tendency.
> >>
> >>Firstly, we can make classification of linux eco system, roughly.
> >> - HPC
> >> - high-end server
> >> - volume server
> >> - desktop
> >> - embedded
> >>
> >>it is separated by typical workload mainly.
> >>
> >>Secondly, zone_reclaim mean "I strongly dislike remote node access than
> >>disk access".
> >>it is very fitting on HPC workload. it because
> >>  - HPC workload typically make the number of the same as cpus of processess
> >>(or thread).
> >>    IOW, the workload typically use memory equally each node.
> >>  - HPC workload is typically CPU bounded job. CPU migration is rare.
> >>  - HPC workload is typically long lived. (possible >1 year)
> >>    IOW, remote node allocation makes _very_ _very_ much remote node access.
> >>
> >>but zone_reclaim don't fit typical server workload.
> >>  - server workload often make thread pool and some thread is sleeping until
> >>    a request receved.
> >>    IOW, when thread waking-up, the thread might move another cpu.
> >>    node distance tendency don't make sense on weak cpu locality workload.
> >>
> >>Plus, disk-cache is the file-server's identity. we shouldn't think it's not
> >>important.
> >>Plus, DB software can consume almost system memory and (In general) RDB data
> >>makes
> >>harder to split equally as hpc.
> >>
> >>desktop workload is special. desktop peopole can run various workload beyond
> >>our assumption. So, we shouldn't have any workload assumption to desktop
> >>people.
> >>However, AFAIK almost desktop software use memory as UMA.
> >>
> >>we don't need to care embedded. it is typically UMA.
> >>
> >>
> >>IOW, the benefit of zone reclaim depend on "strong cpu locality" and
> >>"workload is cpu bounded" and "thead is long lived".
> >>but many workload don't fill above requirement. IOW, zone reclaim is
> >>workload depended feature (as Wu said).
> >>
> >>
> >>In general, the feature of workload depended don't fit default option.
> >>we can't know end-user run what workload anyway.
> >>
> >>Fortunately (or Unfortunately), typical workload and machine size had
> >>significant mutuality.
> >>Thus, the current default setting calculation had worked well in past days.
> [YM] Your analysis is clear and deep.

Thanks!


> >>Now, it was breaked. What should we do?
> >>Yanmin, We know 99% linux people use intel cpu and you are one of
> >>most hard repeated testing
> [YM] It's very easy to reproduce them on my machines. :) Sometimes, because the 
> issues only exist on machines with lots of cpu while other community developers
> have no such environments. 
>
> 
>  guy in lkml and you have much test.
> >>May I ask your tested machine and benchmark?
> [YM] Usually I started lots of benchmark testing against the latest kernel, but 
> as for this issue, it's reported by a customer firstly. The customer runs apache
> on Nehalem machines to access lots of files. So the issue is an example of file 
> server.

hmmm. 
I'm surprised this report. I didn't know this problem. oh..

Actually, I don't think apache is only file server.
apache is one of killer application in linux. it run on very widely organization.
you think large machine don't run apache? I don't think so.



> BTW, I found many test cases of fio have big drop after I upgraded BIOS of one 
> Nehalem machine. By checking vmstat data, I found almost a half memory is always free. It's also related to zone_reclaim_mode because new BIOS changes the node
> distance to a large value. I use numactl --interleave=all to walkaround the problem temporarily.
> 
> I have no HPC environment.

Yeah, that's ok. I and cristoph have. My worries is my unknown workload become regression.
so, May I assume you run your benchmark both zonre reclaim 0 and 1 and you 
haven't seen regression by non-zone reclaim mode?
if so, it encourage very much to me.

if zone reclaim mode disabling don't have regression, I'll pushing to 
remove default zone reclaim mode completely again.


> >>if zone_reclaim=0 tendency workload is much than zone_reclaim=1 tendency
> >>workload,
> >> we can drop our afraid and we would prioritize your opinion, of cource.
> So it seems only file servers have the issue currently.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
