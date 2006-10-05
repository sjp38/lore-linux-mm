Date: Wed, 4 Oct 2006 19:37:01 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061004192714.20412e08.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610041931170.32103@attu2.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
 <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
 <20061001234858.fe91109e.pj@sgi.com> <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
 <20061002014121.28b759da.pj@sgi.com> <20061003111517.a5cc30ea.pj@sgi.com>
 <Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
 <20061004084552.a07025d7.pj@sgi.com> <Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
 <20061004192714.20412e08.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2006, Paul Jackson wrote:

> > There are two reasons I persued this alternative:
> > 
> >  1) Contrary to what I said before, we (SGI, on large ia64 sn2 systems)
> >     have seen real customer loads where the cost to scan the zonelist
> >     was a problem, due to many nodes being full of memory before
> >     we got to a node we could use.  Or at least, I think we have.
> >     This was related to me by another engineer, based on experiences
> >     from some time past.  So this is not guaranteed.  Most likely, though.
> > 
> >     The following approach should help such real numa systems just as
> >     much as it helps fake numa systems, or any combination thereof.
> >     
> >  2) The effort to distinguish fake from real numa, using node_distance,
> >     so that we could cache a fake numa node and optimize choosing
> >     it over equivalent distance fake nodes, while continuing to
> >     properly scan all real nodes in distance order, was going to
> >     require a nasty blob of zonelist and node distance munging.
> > 
> >     The following approach has no new dependency on node distances or
> >     zone sorting.
> 
> 
> David wrote:
> > I was under the impression that there was nothing wrong with the way 
> > current real NUMA systems allocate pages.  If not, please point me to the 
> > thread that _specifically_ discusses this with _data_ that shows it's 
> > inefficient.
> 
> See above.  I don't have data, so cannot justify going far out of our
> way.
> 

I've never seen the zonelist ordering pose a problem on real NUMA systems, 
especially to the degree where any non-trivial speedup could be suggested.  
So I was curious as to whether this has ever been seen in practice with a 
sufficiently large workload and a considerable number of nodes.

> If someone has a better way to skin this fake numa cat, that does not
> benefit (or harm) real numa, that would still be worth careful
> consideration.
> 

Well, if it turns out that there is really no trouble with the real NUMA 
case (and I suspect that there isn't), then your speed-up could definitely 
be used only for the fake case.  The only change that would be required is 
to abstract a macro to test against if NUMA emulation was configured 
correctly at boot-time instead of just NUMA_BUILD.  That's a trivial 
change so once the data is presented that shows that this speeds up page 
allocation, it would be very nice to see this implemented even if it 
doesn't do anything for real NUMA.  I'm a big fan of it for the fake case.

>  * It has no dependencies on zonelist sorting, node distances,
>    fake vs real numa nodes or any of that.

Yes, it is nice that no change to __node_distance needs to be made so 
there's no chance of the srat warning coming around later and causing 
trouble.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
