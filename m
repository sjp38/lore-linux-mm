Message-ID: <4410AFD3.7090505@bigpond.net.au>
Date: Fri, 10 Mar 2006 09:44:35 +1100
From: Peter Williams <pwil3058@bigpond.net.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: yield during swap prefetching
References: <200603081013.44678.kernel@kolivas.org> <200603081212.03223.kernel@kolivas.org> <440FEDF7.2040008@aitel.hist.no> <200603092008.16792.kernel@kolivas.org> Sender:	linux-kernel-owner@vger.kernel.org X-Mailing-List:	linux-kernel@vger.kernel.org
In-Reply-To: <200603092008.16792.kernel@kolivas.org> Sender:	linux-kernel-owner@vger.kernel.org X-Mailing-List:	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Helge Hafting <helge.hafting@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Thursday 09 March 2006 19:57, Helge Hafting wrote:
> 
>>Con Kolivas wrote:
>>
>>>On Wed, 8 Mar 2006 12:11 pm, Andrew Morton wrote:
>>>
>>>>but, but.  If prefetching is prefetching stuff which that game will soon
>>>>use then it'll be an aggregate improvement.  If prefetch is prefetching
>>>>stuff which that game _won't_ use then prefetch is busted.  Using yield()
>>>>to artificially cripple kprefetchd is a rather sad workaround isn't it?
>>>
>>>It's not the stuff that it prefetches that's the problem; it's the disk
>>>access.
>>
>>Well, seems you have some sorry kind of disk driver then?
>>An ide disk not using dma?
>>
>>A low-cpu task that only abuses the disk shouldn't make an impact
>>on a 3D game that hogs the cpu only.  Unless the driver for your
>>harddisk is faulty, using way more cpu than it need.
>>
>>Use hdparm, check the basics:
>>unmaksirq=1, using_dma=1, multcount is some positive number,
>>such as 8 or 16, readahead is some positive number.
>>Also use hdparm -i and verify that the disk is using some
>>nice udma mode.  (too old for that, and it probably isn't worth
>>optimizing this for...)
>>
>>Also make sure the disk driver isn't sharing an irq with the
>>3D card.
>>
>>Come to think of it, if your 3D game happens to saturate the
>>pci bus for long times, then disk accesses might indeed
>>be noticeable as they too need the bus.  Check if going to
>>a slower dma mode helps - this might free up the bus a bit.
> 
> 
> Thanks for the hints. 
> 
> However I actually wrote the swap prefetch code and this is all about changing 
> its behaviour to make it do what I want. The problem is that nice 19 will 
> give it up to 5% cpu in the presence of a nice 0 task when I really don't 
> want swap prefetch doing anything.

I'm working on a patch to add soft and hard CPU rate caps to the 
scheduler and the soft caps may be useful for what you're trying to do. 
  They are a generalization of your SCHED_BATCH implementation in 
staircase (which would have been better called SCHED_BACKGROUND :-) 
IMHO) in that a task with a soft cap will only use more CPU than that 
cap if it (the cpu) would otherwise go unused.  The main difference 
between this mechanism and staircase's SCHED_BATCH mechanism is that you 
can specify how much (as parts per thousand of a CPU) the task can use 
instead of just being background or not background.  With the soft cap 
set to zero the effect would be essentially the same.

> Furthermore because it is constantly 
> waking up from sleep (after disk activity) it is always given lower latency 
> scheduling than a fully cpu bound nice 0 task - this is normally appropriate 
> behaviour. Yielding regularly works around that issue. 
> 
> Ideally taking into account cpu usage and only working below a certain cpu 
> threshold may be the better mechanism and it does appear this would be more 
> popular. It would not be hard to implement, but does add yet more code to an 
> increasingly complex heuristic used to detect "idleness". I am seriously 
> considering it.

See above re CPU rate soft caps.  I'm holding off on submitting this 
patch for consideration until the current scheduler modifications being 
tested in -mm have had time to settle.

Peter
-- 
Peter Williams                                   pwil3058@bigpond.net.au

"Learning, n. The kind of ignorance distinguishing the studious."
  -- Ambrose Bierce

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
