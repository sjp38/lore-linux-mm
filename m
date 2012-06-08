Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2D44C6B0070
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:43:23 -0400 (EDT)
Message-ID: <4FD1BB29.1050805@kernel.org>
Date: Fri, 08 Jun 2012 17:43:21 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Some vmevent fixes...
References: <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com> <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com> <20120601122118.GA6128@lizard> <alpine.LFD.2.02.1206032125320.1943@tux.localdomain> <4FCC7592.9030403@kernel.org> <20120604113811.GA4291@lizard> <4FCD14F1.1030105@gmail.com> <CAOJsxLHR4wSgT2hNfOB=X6ud0rXgYg+h7PTHzAZYCUdLs6Ktug@mail.gmail.com> <20120605083921.GA21745@lizard> <4FD014D7.6000605@kernel.org> <20120608074906.GA27095@lizard>
In-Reply-To: <20120608074906.GA27095@lizard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On 06/08/2012 04:49 PM, Anton Vorontsov wrote:

> On Thu, Jun 07, 2012 at 11:41:27AM +0900, Minchan Kim wrote:
> [...]
>> How about this?
> 
> So, basically this is just another shrinker callback (well, it's
> very close to), but only triggered after some magic index crosses
> a threshold.
> 
> Some information beforehand: current ALMK is broken in the regard
> that it does not do what it is supposed to do according to its
> documentation. It uses shrinker notifiers (alike to your code), but
> kernel calls shrinker when there is already pressure on the memory,
> and ALMK's original idea was to start killing processes when there
> is [yet] no pressure at all, so ALMK was supposed to act in advance,
> e.g. "kill unneeded apps when there's say 64 MB free memory left,
> irrespective of the current pressure". ALMK doesn't do this
> currently, it only reacts to the shrinker.


When I hear your information, I feel it's a problem is in VM.
VM's goal is to use available memory enough while it can reclaim used
page as soon as possible so that user program should not feel big latency
if there are enough easy reclaimable pages in VM.

So, when reclaim start firstly, maybe there are lots of reclaimable pages
in VM so it can be reclaimed easily. Nontheless, if you feel it's very slow,
in principle, it's a VM's problem. But I don't have been heard such latency
complain from desktop people once there are lots of reclaimable pages.\

I admit there is big latency if we have lots of dirty pages while clean pages are
almost out and backed devices are very slow which is known problem and several
mm guys still have tried to solve it. 

I admit you can argue what's the reclaimable pages easily.
Normally, we can order it following as.

1. non-mapped clean cache page
2. mapped-clean cache page
3. non-mapped dirty cache page
4. mapped dirty cache page
5. anon pages, tmpfs/shmem pages.

So I want to make math by those and VM's additional information and user can configure
weight because in some crazy system, swapout which is backed by SSD can be faster than
dirty file page flush which is backed very slow rotation device.

And we can improve it by adding new LRU list - CFLRU[1] which would be good for swap in embedded device, too.
If clean LRU is about to be short, it's a good indication on latency so we can trigger notification or start vmevent timer.

[1] http://staff.ustc.edu.cn/~jpq/paper/flash/2006-CASES-CFLRU-%20A%20Replacement%20Algorithm%20for%20Flash%20Memory.pdf

> 
> So, the solution would be then two-fold:
> 
> 1. Use your memory pressure notifications. They must be quite fast when
>    we starting to feel the high pressure. (I see the you use
>    zone_page_state() and friends, which is vm_stat, and it is updated


VM has other information like nr_reclaimed, nr_scanned, nr_congested, recent_scanned,
recent_rotated, too. I hope we can make math by them and improve as we improve
VM reclaimer.

>    very infrequently, but to get accurate notification we have to
>    update it much more frequently, but this is very expensive. So
>    KOSAKI and Christoph will complain. :-)


Reclaimer already have used that and if we need accuracy, we handled it
like zone_watermark_ok_safe. If it's very inaccurate, VM should be fixed, too.

> 2. Plus use deferred timers to monitor /proc/vmstat, we don't have to
>    be fast here. But I see Pekka and Leonid don't like it already,
>    so we're stuck.
> 
> Thanks,


>>
>> -- 
>> Kind regards,
>> Minchan Kim
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
