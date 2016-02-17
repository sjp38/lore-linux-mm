Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7F59D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 03:49:54 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id a4so17178627wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 00:49:54 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id a8si3019433wmi.35.2016.02.17.00.49.52
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 00:49:53 -0800 (PST)
Message-ID: <56C42F9B.2050309@huawei.com>
Date: Wed, 17 Feb 2016 16:30:19 +0800
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

Hi David,

Thanks for your advice.

I have a stupid question, what's the main difference between lmk and oom?
1) lmk is called when reclaim memory, and oom is called when alloc failed in slow path.
2) lmk has several lowmem thresholds and oom is not.
3) others?

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
