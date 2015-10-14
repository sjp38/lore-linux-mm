Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9A63182F64
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:41:54 -0400 (EDT)
Received: by payp3 with SMTP id p3so7100078pay.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 06:41:54 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id v9si13382183pbs.198.2015.10.14.06.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 06:41:53 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NW702117Q1RLW80@mailout3.samsung.com> for linux-mm@kvack.org;
 Wed, 14 Oct 2015 22:41:51 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1444656800-29915-1-git-send-email-pintu.k@samsung.com>
 <1444660139-30125-1-git-send-email-pintu.k@samsung.com>
 <alpine.DEB.2.10.1510132000270.18525@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1510132000270.18525@chino.kir.corp.google.com>
Subject: RE: [RESEND PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat
 counter
Date: Wed, 14 Oct 2015 19:11:05 +0530
Message-id: <081301d10686$370d2e10$a5278a30$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Rientjes' <rientjes@google.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com

Hi,

Thank you very much for your review and comments.

> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Wednesday, October 14, 2015 8:36 AM
> To: Pintu Kumar
> Cc: akpm@linux-foundation.org; minchan@kernel.org; dave@stgolabs.net;
> mhocko@suse.cz; koct9i@gmail.com; hannes@cmpxchg.org; penguin-kernel@i-
> love.sakura.ne.jp; bywxiaobai@163.com; mgorman@suse.de; vbabka@suse.cz;
> js1304@gmail.com; kirill.shutemov@linux.intel.com;
> alexander.h.duyck@redhat.com; sasha.levin@oracle.com; cl@linux.com;
> fengguang.wu@intel.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.ping@gmail.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com; c.rajkumar@samsung.com;
> sreenathd@samsung.com
> Subject: Re: [RESEND PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat
> counter
> 
> On Mon, 12 Oct 2015, Pintu Kumar wrote:
> 
> > This patch maintains the number of oom victims kill count in
> > /proc/vmstat.
> > Currently, we are dependent upon kernel logs when the kernel OOM occurs.
> > But kernel OOM can went passed unnoticed by the developer as it can
> > silently kill some background applications/services.
> > In some small embedded system, it might be possible that OOM is
> > captured in the logs but it was over-written due to ring-buffer.
> > Thus this interface can quickly help the user in analyzing, whether
> > there were any OOM kill happened in the past, or whether the system
> > have ever entered the oom kill stage till date.
> >
> > Thus, it can be beneficial under following cases:
> > 1. User can monitor kernel oom kill scenario without looking into the
> >    kernel logs.
> 
> I'm not sure how helpful that would be since we don't know anything about the
> oom kill itself, only that at some point during the uptime there were oom
kills.
> 
Not sure about others.
For me it was very helpful during sluggish and long duration ageing tests.
With this, I don't have to look into the logs manually.
I just monitor this count in a script. 
The moment I get nr_oom_victims > 1, I know that kernel OOM would have happened
and I need to take the log dump.
So, then I do: dmesg >> oom_logs.txt
Or, even stop the tests for further tuning.

> > 2. It can help in tuning the watermark level in the system.
> 
> I disagree with this one, because we can encounter oom kills due to
> fragmentation rather than low memory conditions for high-order allocations.
> The amount of free memory may be substantially higher than all zone
> watermarks.
> 
AFAIK, kernel oom happens only for lower-order (PAGE_ALLOC_COSTLY_ORDER).
For higher-order we get page allocation failure.

> > 3. It can help in tuning the low memory killer behavior in user space.
> 
> Same reason as above.
> 
> > 4. It can be helpful on a logless system or if klogd logging
> >    (/var/log/messages) are disabled.
> >
> 
> This would be similar to point (1) above, and I question how helpful it would
be.
> I notice that all oom kills (system, cpuset, mempolicy, and
> memcg) are treated equally in this case and there's no way to differentiate
them.
> That would lead me to believe that you are targeting this change for systems
> that don't use mempolicies or cgroups.  That's fine, but I doubt it will be
helpful
> for anybody else.
> 
No, we are not targeting any specific category.
Our goal is simple, track and report kernel oom kill as soon as it occurs.

> > A snapshot of the result of 3 days of over night test is shown below:
> > System: ARM Cortex A7, 1GB RAM, 8GB EMMC
> > Linux: 3.10.xx
> > Category: reference smart phone device
> > Loglevel: 7
> > Conditions: Fully loaded, BT/WiFi/GPS ON
> > Tests: auto launching of ~30+ apps using test scripts, in a loop for
> > 3 days.
> > At the end of tests, check:
> > $ cat /proc/vmstat
> > nr_oom_victims 6
> >
> > As we noticed, there were around 6 oom kill victims.
> >
> > The OOM is bad for any system. So, this counter can help in quickly
> > tuning the OOM behavior of the system, without depending on the logs.
> >
> 
> NACK to the patch since it isn't justified.
> 
> We've long had a desire to have a better oom reporting mechanism rather than
> just the kernel log.  It seems like you're feeling the same pain.  I think it
would be
> better to have an eventfd notifier for system oom conditions so we can track
> kernel oom kills (and conditions) in userspace.  I have a patch for that, and
it
> works quite well when userspace is mlocked with a buffer in memory.
> 
Ok, this would be interesting.
Can you point me to the patches?
I will quickly check if it is useful for us.

> If you are only interested in a strict count of system oom kills, this could
then
> easily be implemented without adding vmstat counters.
>
We are interested only to know when kernel OOM occurs and not even the oom
victim count. So that we can tune something is user space to avoid or delay it
as far as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
