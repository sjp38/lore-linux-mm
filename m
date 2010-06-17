Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 63D216B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 14:45:23 -0400 (EDT)
Subject: Re: [RFC PATCH] mm: let the bdi_writeout fraction respond more
 quickly
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <4C1A09DF.9070809@kernel.dk>
References: <1276523894.1980.85.camel@castor.rsk>
	 <1276526681.1980.89.camel@castor.rsk>  <1276714466.1745.625.camel@laptop>
	 <1276774796.1978.11.camel@castor.rsk>  <4C1A09DF.9070809@kernel.dk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Jun 2010 19:45:16 +0100
Message-ID: <1276800316.1978.67.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <axboe@kernel.dk>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-06-17 at 13:41 +0200, Jens Axboe wrote:
> On 2010-06-17 13:39, Richard Kennedy wrote:
> > On Wed, 2010-06-16 at 20:54 +0200, Peter Zijlstra wrote:
> >> On Mon, 2010-06-14 at 15:44 +0100, Richard Kennedy wrote:
> >>>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> >>>> index 2fdda90..315dd04 100644
> >>>> --- a/mm/page-writeback.c
> >>>> +++ b/mm/page-writeback.c
> >>>> @@ -144,7 +144,7 @@ static int calc_period_shift(void)
> >>>>       else
> >>>>               dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> >>>>                               100;
> >>>> -     return 2 + ilog2(dirty_total - 1);
> >>>> +     return ilog2(dirty_total - 1) - 4;
> >>>>  } 
> >>
> >> IIRC I suggested similar things in the past and all we needed to do was
> >> find people doing the measurements on different bits of hardware or so..
> >>
> >> I don't have any problems with the approach, all we need to make sure is
> >> that we never return 0 or a negative number (possibly ensure a minimum
> >> positive shift value).
> > 
> > Yep that sounds reasonable. would minimum shift of 4 be ok ?
> > 
> > something like
> > 
> > 	max ( (ilog2(dirty_total - 1)- 4) , 4);
> > 
> > Unfortunately volunteers don't seem to be leaping out of the woodwork,
> > maybe Andrew could be persuaded to try this in his tree for a while and
> > see if any one squeaks ?
> 
> I'm pretty sure that most volunteers are curious what to actually test,
> so they shy away from it. If you added a good explanation of an easy way
> to test the before and after, then it would be more approachable.
> 
> I'll give it a spin here.
> 

Ah - sorry. but I thought what it did was obvious ;)

Finding a test that's going to show a difference isn't going to be that
easy, It isn't going to have any effect on writing to a single bdi, but
only workloads writing to 2 (or more) disks.

Calc_period_shift controls the speed that the bdi dirty threshold gets
updated, which in turn controls how much of the vm_dirty cache a bdi can
use.
 The first graph shows that currently it is rather slow in reacting to
change so that when you switch the writes from sda to sdb, the threshold
doesn't react quickly enough and sdb isn't allowed to use it's fair
share of the cache and is forced to write to the spinning disk sooner.
Therefore it's slower overall. But the speed difference is highly
dependent on the size of the write v. the size of the cache and the
speed of the disk v. speed of writing to memory.

The tests I run here are writing a large file to one disk then after a
small delay start a small write to the second disk, but it's not easy to
get repeatable results from them.

I don't have a simple test, but the patch will improve the fairness of
the vm_dirty cache sharing. I had in mind the sort of server workloads
where some disks are dedicated to particular applications and others to
general use. There may also be some desktop improvements but they are
difficult to pin down.  

I'm sorry I wasn't clearer before and hope this has explained what I've
been trying to do.

regards
Richard




 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
