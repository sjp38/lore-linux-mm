Date: Wed, 4 Oct 2006 21:07:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061004210711.aefaea6c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64N.0610042036230.27222@attu3.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
	<20061001234858.fe91109e.pj@sgi.com>
	<Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
	<20061002014121.28b759da.pj@sgi.com>
	<20061003111517.a5cc30ea.pj@sgi.com>
	<Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
	<20061004084552.a07025d7.pj@sgi.com>
	<Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
	<20061004192714.20412e08.pj@sgi.com>
	<Pine.LNX.4.64N.0610041931170.32103@attu2.cs.washington.edu>
	<20061004195313.892838e4.pj@sgi.com>
	<Pine.LNX.4.64N.0610041954470.642@attu2.cs.washington.edu>
	<20061004202656.18830f76.pj@sgi.com>
	<Pine.LNX.4.64N.0610042036230.27222@attu3.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2006 20:49:20 -0700 (PDT)
David Rientjes <rientjes@cs.washington.edu> wrote:

> On Wed, 4 Oct 2006, Paul Jackson wrote:
> 
> > And as to why my position changed as to whether the zonelist scans
> > were ever a performance issue on real numa, I've already answered that
> > question ... a couple of times.  Let me know if you need me to repeat
> > this answer a third time.
> > 
> 
> No, what I need repeated a third time is why changes are being made 
> without data to support it, especially to something like 
> get_page_from_freelist that has never been complained about on real NUMA 
> setups.  Second, what I need repeated a third time is why changes are 
> being made to the real NUMA case without data to show it's a problem in 
> the first place.  This is a scientific process where we can experiment and 
> then collect data and analyize it to see what went right and what went 
> wrong.  I'm a big supporter of making changes when you have a feeling that 
> it will make a difference because often times the experiments will prove 
> that it did.  But I'm not a big supporter of saying "the real NUMA case 
> being slow was mentioned to me in passing once, I've never witnessed it, 
> I can't describe how to test it, and I have nothing to compare it to, so 
> let's add more code because it can't make it worse."

We do that sort of thing all the time ;)

It's sometimes OK to rely on common sense and not require benchmark results
or in-field observations for everything.

Or one can concoct artificial microbenchmarks, measure the impact and then
use plain old brainpower to decide whether anyone is ever likely to want to
do anything in real life which is approximately modelled by that benchmark.

The latter is the case here and I'd say the answer is "yes".  People might
be impacted by this in real life.

For example: my HPC job needs lots of memory.  An amount of memory which
requires 100 nodes to be allocated to it.  Some other user is in a similar
situation and needs 50 nodes.  (I think.  This sounds _too_ likely, so
there's perhaps some well-established way to prevent it?)

> So I really don't see what the point of debating the issue is when any 
> number of tests could either prove or disprove this and those tests don't 
> need to be run by Rohit on a fake NUMA setup.  You have a NUMA setup with 
> 1024 nodes, so let's see ANY workload IN ANY CIRCUMSTANCE where the HARD 
> DATA shows that it improves the case.  Theory is great for discussion, but 
> real numbers actually make the case.

But we know without even testing it that an Altix can be made to run like
crap by forcing a workload to walk 100 nodes to allocate each page. 
That'll be 99 off-node accesses to the zone structures per page too, I
think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
