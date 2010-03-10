Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC536B00B2
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 09:32:20 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o2AEVpVE023816
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 14:31:51 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2AEVp6U1355992
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 15:31:51 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o2AEVoim001108
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 15:31:51 +0100
Message-ID: <4B97AD52.7080201@linux.vnet.ibm.com>
Date: Wed, 10 Mar 2010 15:31:46 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] Fix Readahead stalling by plugged device queues
References: <4B979104.6010907@linux.vnet.ibm.com> <20100310130932.GB18509@localhost>
In-Reply-To: <20100310130932.GB18509@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ronald <intercommit@gmail.com>, Bart Van Assche <bart.vanassche@gmail.com>, Vladislav Bolkhovitin <vst@vlnb.net>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>



Wu Fengguang wrote:
[...]
> Christian, did you notice this commit for 2.6.33?
> 
> commit 65a80b4c61f5b5f6eb0f5669c8fb120893bfb388
[...]

I didn't see that particular one, due to the fact that whatever the 
result is it needs to work .32

Anyway I'll test it tomorrow and if that already accepted one fixes my 
issue as well I'll recommend distros older than 2.6.33 picking that one 
up in their on top patches.

> 
> It should at least improve performance between .32 and .33, because
> once two readahead requests are merged into one single IO request,
> the PageUptodate() will be true at next readahead, and hence
> blk_run_backing_dev() get called to break out of the suboptimal
> situation.

As you saw from my blktrace thats already the case without that patch.
Once the second readahead comes in and merged it gets unplugged in 
2.6.32 too - but still that is bad behavior as it denies my things like 
68% throughput improvement :-).

> 
> Your patch does reduce the possible readahead submit latency to 0.

yeah and I think/hope that is fine, because as I stated:
- low utilized disk -> not an issue
- high utilized disk -> unplug is an noop

At least personally I consider a case where merging of a readahead 
window with anything except its own sibling very rare - and therefore 
fair to unplug after and RA is submitted.

> Is your workload a simple dd on a single disk? If so, it sounds like
> something illogical hidden in the block layer.

It might still be illogical hidden as e.g. 2.6.27 unplugged after the 
first readahead as well :-)
But no my load is iozone running with different numbers of processes 
with one disk per process.
That neatly resembles e.g. nightly backup jobs which tend to take longer 
and longer in all time increasing customer scenarios. Such an 
improvement might banish the backups back to the night were they belong :-)

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
