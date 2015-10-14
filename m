Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6DF6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 23:05:59 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so7871956igb.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 20:05:59 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id f63si2420186ioi.86.2015.10.13.20.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 20:05:58 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so39834927pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 20:05:58 -0700 (PDT)
Date: Tue, 13 Oct 2015 20:05:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat
 counter
In-Reply-To: <1444660139-30125-1-git-send-email-pintu.k@samsung.com>
Message-ID: <alpine.DEB.2.10.1510132000270.18525@chino.kir.corp.google.com>
References: <1444656800-29915-1-git-send-email-pintu.k@samsung.com> <1444660139-30125-1-git-send-email-pintu.k@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On Mon, 12 Oct 2015, Pintu Kumar wrote:

> This patch maintains the number of oom victims kill count in
> /proc/vmstat.
> Currently, we are dependent upon kernel logs when the kernel OOM occurs.
> But kernel OOM can went passed unnoticed by the developer as it can
> silently kill some background applications/services.
> In some small embedded system, it might be possible that OOM is captured
> in the logs but it was over-written due to ring-buffer.
> Thus this interface can quickly help the user in analyzing, whether there
> were any OOM kill happened in the past, or whether the system have ever
> entered the oom kill stage till date.
> 
> Thus, it can be beneficial under following cases:
> 1. User can monitor kernel oom kill scenario without looking into the
>    kernel logs.

I'm not sure how helpful that would be since we don't know anything about 
the oom kill itself, only that at some point during the uptime there were 
oom kills.

> 2. It can help in tuning the watermark level in the system.

I disagree with this one, because we can encounter oom kills due to 
fragmentation rather than low memory conditions for high-order 
allocations.  The amount of free memory may be substantially higher than 
all zone watermarks.

> 3. It can help in tuning the low memory killer behavior in user space.

Same reason as above.

> 4. It can be helpful on a logless system or if klogd logging
>    (/var/log/messages) are disabled.
> 

This would be similar to point (1) above, and I question how helpful it 
would be.  I notice that all oom kills (system, cpuset, mempolicy, and 
memcg) are treated equally in this case and there's no way to 
differentiate them.  That would lead me to believe that you are targeting 
this change for systems that don't use mempolicies or cgroups.  That's 
fine, but I doubt it will be helpful for anybody else.

> A snapshot of the result of 3 days of over night test is shown below:
> System: ARM Cortex A7, 1GB RAM, 8GB EMMC
> Linux: 3.10.xx
> Category: reference smart phone device
> Loglevel: 7
> Conditions: Fully loaded, BT/WiFi/GPS ON
> Tests: auto launching of ~30+ apps using test scripts, in a loop for
> 3 days.
> At the end of tests, check:
> $ cat /proc/vmstat
> nr_oom_victims 6
> 
> As we noticed, there were around 6 oom kill victims.
> 
> The OOM is bad for any system. So, this counter can help in quickly
> tuning the OOM behavior of the system, without depending on the logs.
> 

NACK to the patch since it isn't justified.

We've long had a desire to have a better oom reporting mechanism rather 
than just the kernel log.  It seems like you're feeling the same pain.  I 
think it would be better to have an eventfd notifier for system oom 
conditions so we can track kernel oom kills (and conditions) in 
userspace.  I have a patch for that, and it works quite well when 
userspace is mlocked with a buffer in memory.

If you are only interested in a strict count of system oom kills, this 
could then easily be implemented without adding vmstat counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
