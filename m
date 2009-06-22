Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5612D6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 11:27:34 -0400 (EDT)
Subject: Re: [Patch] mm tracepoints update - use case.
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20090622115756.21F3.A69D9226@jp.fujitsu.com>
References: <20090616170811.99A6.A69D9226@jp.fujitsu.com>
	 <1245352954.3212.67.camel@dhcp-100-19-198.bos.redhat.com>
	 <20090622115756.21F3.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Jun 2009 11:28:08 -0400
Message-Id: <1245684488.3212.111.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, =?UTF-8?Q?Fr=E9=A6=98=E9=A7=BBic?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-22 at 12:37 +0900, KOSAKI Motohiro wrote:

Thanks for the feedback Kosaki! 

> Hi
> 
> > Thanks for the feedback Kosaki!
> > 
> > 
> > > Scenario 1. OOM killer happend. why? and who bring it?
> > 
> > Doesnt the showmem() and stack trace to the console when the OOM kill
> > occurred show enough in the majority of cases?  I realize that direct
> > alloc_pages() calls are not accounted for here but that can be really
> > invasive.
> 
> showmem() display _result_ of memory usage and fragmentation.
> but Administrator often need to know the _reason_.

Right, thats why I have mm tracepoints in locations like shrink_zone,
shrink_active and shrink_inactive so we can drill down into exactly what
happened when either kswapd ran or a direct reclaim occured out of the
page allocator.  Since we will know the timestamps and the number of
pages scanned and reclaimed we can tell the reason the page reclamation
did not supply enough pages and therefore the OOM occurred.

Do you think this is enough information or do you thine we need more?

> 
> Plus, kmemtrace already trace slab allocate/free activity.
> You mean you think this is really invasive?
> 
> 
> > > Scenario 2. page allocation failure by memory fragmentation
> > 
> > Are you talking about order>0 allocation failures here?  Most of the
> > slabs are single page allocations now.
> 
> Yes, order>0.
> but I confused. Why do you talk about slab, not page alloc?
> 
> Note, non-x86 architecture freqently use order-1 allocation for
> making stack.

OK, I can add a tracepoint in the lumpy reclaim logic when it fails to
get enough contiguous memory to satisfy a high order allocation.

> 
> 
> 
> > > Scenario 3. try_to_free_pages() makes very long latency. why?
> > 
> > This is available in the mm tracepoints, they all include timestamps.
> 
> perhaps, no.
> Administrator need to know the reason. not accumulated time. it's the result.
> 
> We can guess some reason
>   - IO congestion

This can be seen when the number of page scans is significantly greater
than the number pf page frees and pagouts.  Do you thing we need to
combine these tracepoints or add one to throttle_vm_writeout() when it
needs to stall?
 
>   - memory eating speed is fast than reclaim speed

The anonymous and filemapped tracepoints combined with the reclaim
tracepoints will tell us this, do you thing we need more tracepoints to
pinpoint when allocations outpace reclamations?

>   - memory fragmentation

Would adding the order to the page_allocation tracepoint satisfy this?
Currently this tracepoint only triggers when the allocation fails and we
need to reclaim memory.  Another option would be to include the order
information to the direct reclaim tracepoint so we can tell if it was
triggered due to memory fragmentation.  Sorry but I navent seen many
cases in which fragmented memory caused failures.

> 
> but it's only guess. we often need to get data.
> 
> 
> > > Scenario 4. sar output that free memory dramatically reduced at 10 minute ago, and
> > >             it already recover now. What's happen?
> > 
> > Is this really important?  It would take buffering lots of data to
> > figure out what happened in the past.
> 
> ok, my scenario description is a bit wrong.
> 
> if userland process explicitly  consume memory or explicitely write
> many data, it is true.
> 
> Is this more appropriate?
> 
> "userland process take the same action periodically, but only 10 minute ago
> free memory reduced, why?"
> 
We could have a user space script that enabled specific tracepoints only
when it noticed something like the free pages fell below some threshold
and disabled it when free pages climbed back up above some other
threshold.  Would this help?

> 
> 
> > >   - suspects
> > >     - kernel memory leak
> > 
> > Other than direct callers to the page allocator isnt that covered with
> > the kmemtrace stuff?
> 
> Yeah.
> perhaps, kmemtrace enhance to cover page allocator is good approach.
> 
> 
> > >     - userland memory leak
> > 
> > The mm tracepoints track all user space allocations and frees(perhaps
> > too many?).
> 
> hmhm.

Is this a yes?  Would the user space script described above help?

> 
> 
> > 
> > >     - stupid driver use too much memory
> > 
> > hopefully kmemtrace will catch this?
> 
> ditto.
> I agree with kmemtrace enhancement is good idea.
> 
> > 
> > >     - userland application suddenly start to use much memory
> > 
> > The mm tracepoints track all user space allocations and frees.
> 
> ok.
> 
> 
> > >   - what information are valuable?
> > >     - slab usage information (kmemtrace already does)
> > >     - page allocator usage information
> > >     - rss of all processes at oom happend
> > >     - why recent try_to_free_pages() can't reclaim any page?
> > 
> > The counters in the mm tracepoints do give counts but not the reasons
> > that the pagereclaim code fails.
> 
> That's very important key point. please don't ignore.

OK, would you suggest changing the code to count failures or simply
adding a tracepoint to the failure path which would potentially capture
lots more data?

> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
