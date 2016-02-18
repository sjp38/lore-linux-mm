Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id C6AE86B0005
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 01:53:35 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id xk3so53111468obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 22:53:35 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id q7si7157564obf.0.2016.02.17.22.53.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 22:53:35 -0800 (PST)
Message-ID: <56C569EC.7070107@huawei.com>
Date: Thu, 18 Feb 2016 14:51:24 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate tasksize
 in lowmem_scan()
References: <56C2EDC1.2090509@huawei.com> <20160216173849.GA10487@kroah.com> <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2016/2/17 8:35, David Rientjes wrote:

> On Tue, 16 Feb 2016, Greg Kroah-Hartman wrote:
> 
>> On Tue, Feb 16, 2016 at 05:37:05PM +0800, Xishi Qiu wrote:
>>> Currently tasksize in lowmem_scan() only calculate rss, and not include swap.
>>> But usually smart phones enable zram, so swap space actually use ram.
>>
>> Yes, but does that matter for this type of calculation?  I need an ack
>> from the android team before I could ever take such a core change to
>> this code...
>>
> 
> The calculation proposed in this patch is the same as the generic oom 
> killer, it's an estimate of the amount of memory that will be freed if it 
> is killed and can exit.  This is better than simply get_mm_rss().
> 
> However, I think we seriously need to re-consider the implementation of 
> the lowmem killer entirely.  It currently abuses the use of TIF_MEMDIE, 
> which should ideally only be set for one thread on the system since it 
> allows unbounded access to global memory reserves.
> 

Hi David,

Does somebody do the work of re-implementation of the lowmem killer entirely
now? Could you give me some details? e.g. when and how?

Here are another two questions.
1) lmk has several lowmem thresholds, it's "lowmem_minfree[]", and the value is
static definition, so is it reasonable for different memory size(e.g. 2G/3G/4G...)
of smart phones?
2) There are many adjustable arguments in /proc/sys/vm/, and the default value
maybe not benefit for smart phones, so any suggestions?

Thanks,
Xishi Qiu

> It also abuses the user-visible /proc/self/oom_score_adj tunable: this 
> tunable is used by the generic oom killer to bias or discount a proportion 
> of memory from a process's usage.  This is the only supported semantic of 
> the tunable.  The lowmem killer uses it as a strict prioritization, so any 
> process with oom_score_adj higher than another process is preferred for 
> kill, REGARDLESS of memory usage.  This leads to priority inversion, the 
> user is unable to always define the same process to be killed by the 
> generic oom killer and the lowmem killer.  This is what happens when a 
> tunable with a very clear and defined purpose is used for other reasons.
> 
> I'd seriously consider not accepting any additional hacks on top of this 
> code until the implementation is rewritten.
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
