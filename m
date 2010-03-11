Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5874A6B00C8
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 04:58:28 -0500 (EST)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate4.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o2B9wNOG027204
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 09:58:23 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2B9wNnB1368318
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 09:58:23 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o2B9wM06015816
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 09:58:23 GMT
Message-ID: <4B98BEB0.6020800@linux.vnet.ibm.com>
Date: Thu, 11 Mar 2010 10:58:08 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] Fix Readahead stalling by plugged device queues
References: <4B979104.6010907@linux.vnet.ibm.com> <20100310130932.GB18509@localhost> <4B97AD52.7080201@linux.vnet.ibm.com> <20100311014542.GA8134@localhost>
In-Reply-To: <20100311014542.GA8134@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ronald <intercommit@gmail.com>, Bart Van Assche <bart.vanassche@gmail.com>, Vladislav Bolkhovitin <vst@vlnb.net>, Randy Dunlap <randy.dunlap@oracle.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> On Wed, Mar 10, 2010 at 10:31:46PM +0800, Christian Ehrhardt wrote:
>>
>> Wu Fengguang wrote:
>> [...]
>>> Christian, did you notice this commit for 2.6.33?
>>>
>>> commit 65a80b4c61f5b5f6eb0f5669c8fb120893bfb388
>> [...]
>>
>> I didn't see that particular one, due to the fact that whatever the 
>> result is it needs to work .32
>>
>> Anyway I'll test it tomorrow and if that already accepted one fixes my 
>> issue as well I'll recommend distros older than 2.6.33 picking that one 
>> up in their on top patches.
> 
> OK, thanks!

That patch fixes my issue completely and is as we discussed less 
aggressive which is fine - thanks for pointing it out - Now I have 
something already upstream accepted to fix the issue, thats much better!

>>> It should at least improve performance between .32 and .33, because
>>> once two readahead requests are merged into one single IO request,
>>> the PageUptodate() will be true at next readahead, and hence
>>> blk_run_backing_dev() get called to break out of the suboptimal
>>> situation.
>> As you saw from my blktrace thats already the case without that patch.
>> Once the second readahead comes in and merged it gets unplugged in 
>> 2.6.32 too - but still that is bad behavior as it denies my things like 
>> 68% throughput improvement :-).
> 
> I mean, when readahead windows A and B are submitted in one IO --
> let's call it AB -- commit 65a80b4c61 will explicitly unplug on doing
> readahead C.  While in your trace, the unplug appears on AB.
> 
> The 68% improvement is very impressive. Wondering if commit 65a80b4c61
> (the _conditional_ unplug) can achieve the same level of improvement :)

Yep it can !
We can post update the patch description to bigger numbers :-)

>>> Your patch does reduce the possible readahead submit latency to 0.
>> yeah and I think/hope that is fine, because as I stated:
>> - low utilized disk -> not an issue
>> - high utilized disk -> unplug is an noop
>>
>> At least personally I consider a case where merging of a readahead 
>> window with anything except its own sibling very rare - and therefore 
>> fair to unplug after and RA is submitted.
> 
> They are reasonable assumptions. However I'm not sure if this
> unconditional unplug will defeat CFQ's anticipatory logic -- if there
> are any. You know commit 65a80b4c61 is more about a *defensive*
> protection against the rare case that two readahead windows get
> merged.
> 
>>> Is your workload a simple dd on a single disk? If so, it sounds like
>>> something illogical hidden in the block layer.
>> It might still be illogical hidden as e.g. 2.6.27 unplugged after the 
>> first readahead as well :-)
>> But no my load is iozone running with different numbers of processes 
>> with one disk per process.
>> That neatly resembles e.g. nightly backup jobs which tend to take longer 
>> and longer in all time increasing customer scenarios. Such an 
>> improvement might banish the backups back to the night were they belong :-)
> 
> Exactly one process per disk? Are they doing sequential reads or more
> complicated access patterns?

Just sequential read where I see the win, but I also had sequential 
write, and random read/write as well as some mixed stuff like dbench.
It improved sequential read and did not impact the others which is fine.

Thank you for you quick replies!

> Thanks,
> Fengguang

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
