Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0A17F6B00B4
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 05:34:13 -0400 (EDT)
Date: Tue, 11 Sep 2012 10:34:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: steering allocations to particular parts of memory
Message-ID: <20120911093407.GH11266@suse.de>
References: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: dan.magenheimer@oracle.com, linux-mm@kvack.org

On Fri, Sep 07, 2012 at 11:27:15AM -0700, Larry Bassel wrote:
> I am looking for a way to steer allocations (these may be
> by either userspace or the kernel) to or away from particular
> ranges of memory. The reason for this is that some parts of
> memory are different from others (i.e. some memory may be
> faster/slower). For instance there may be 500M of "fast"
> memory and 1500M of "slower" memory on a 2G platform.
> 

Hi Larry,

> At the memory mini-summit last week, it was mentioned
> that the Super-H architecture was using NUMA for this
> purpose, which was considered to be an very bad thing
> to do -- we have ported NUMA to ARM here (as an experiment)
> and agree that NUMA doesn't work well for solving this problem.
> 

Yes, I remember the discussion and regret it had to be cut short.

NUMA is almost always considered to be the first solution to this type
of problem but as you say it's considered to be a "very bad thing to do".
It's convenient in one sense because you get data structures that track all
the pages for you and create the management structures. It's bad because
page allocation uses these slow nodes when the fast nodes are full which
is a very poor placement policy. Similarly pages from the slow node are
reclaimed based on memory pressure. It comes down to luck whether the
optimal pages are in the slow node or not. You can try wedging your own
placement policy on the side but it won't be pretty.

> After the NUMA discussion, I spoke briefly to you and asked
> you what a good approach would be. You thought that something
> based on transcendent memory (which I am somewhat familiar
> with, having built something based upon it which can be used either
> as contiguous memory or as clean cache) might work, but
> you didn't supply any details.
> 

I was running out the door to catch a bus unfortunately. It was a somewhat
off-the-cuff remark that tmem might help you and what I was really
interested in what tmem used as a placement policy. All I was really sure
of was that a plain NUMA node is a bad idea. Unfortunately I have not
sat down to properly design a solution for this that would satisfy all
interested parties.  Hence take all this with a big grain of salt.

The reason why tmem (http://lwn.net/Articles/340080/) came to mind is that
it addresses a similar class of problem to yours. Very broadly speaking
it was described as memory of an "unknown and dynamically variable size,
is addressable only indirectly by the kernel, can be configured either
as persistent or as "ephemeral" (meaning it will be around for awhile,
but might disappear without warning), and is still fast enough to be
synchronously accessible"

This is not an exact fit obviously. The slow memory node (slowmem) is
fixed size and is directly accessible. The core idea might still be
useful to you though. I'm actually not familiar with tmem but it would
be worth investigating if you can use the same API to decide whether
pages should migrate to/from slowmem and when to simply discard pages
from slowmem.

A possibly variation would be to have cleancache and similar mechanisms
use slowmem as a backend.

A third variation is for people considering creating RAM-like devices
that are backed by some sort of fast storage. These would be interested
in an almost identical sort of API that you need.

Note that none of this actually stops you using a pgdat structure to
represent slowmem and to creating the struct pages for you. This could
be core helper code that allocates a pgdat structure and initialises all
the pages but does not create a kswapd thread, link it to zonelists etc.
The key Ideally there would be a placement policy API (maybe similar
to tmems) that can be shared with slowmem, cleancache, whatever you are
implementing and potentially tmem if it gets revived.

In my simple mind the final solution to cover most or all of these use
causes would look something like this ASCII scribble.


             movement trigger
        KSM? kswapd hook? faults?
                    |
               placement policy
               notification API
                    |
          |------------------|
          |                  |
        placement         placement
        policy            policy                       faulting, IO
          |                  |                              |
          |------------------|                              |
                   |                                        |
       API to move pages RAM<->backing,         get_user_pages like API
           discard pages                        page for userspace access
                   |                                        |
		   |----------------------------------------|
                   |
      Interface to make it look like RAM
      Create struct pages, partial pgdat,
       no kswapd, not linked to zonelist
                   |
   ------------------------------
   |               |            |
slowmem      block device     tmem

Hope this clarifies my position a little but people like Dan who have
focused on this problem in the past may have a much better idea.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
