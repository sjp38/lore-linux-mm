Date: Wed, 4 Oct 2006 19:27:14 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061004192714.20412e08.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> Isn't this the exact behavior that ordered zonelists are supposed to solve 
> for real NUMA systems?  Has there been an _observed_ case where the cost 
> to scan the zonelists was considered excessive on real NUMA systems?

Well ... the good news is I understood your comments this time.

I guess I should be happy it only took about 3 iterations.

Historically the ordered zonelists addressed the situation where one
almost always found free memory near the front of the ordered zonelist.

Yes, you are correct that I originally didn't think we had a problem
with real numa zonelist scans.


Three days ago, when I introduced this alternative patch that started
this current thread, I changed my position, stating at that time:
>
> There are two reasons I persued this alternative:
> 
>  1) Contrary to what I said before, we (SGI, on large ia64 sn2 systems)
>     have seen real customer loads where the cost to scan the zonelist
>     was a problem, due to many nodes being full of memory before
>     we got to a node we could use.  Or at least, I think we have.
>     This was related to me by another engineer, based on experiences
>     from some time past.  So this is not guaranteed.  Most likely, though.
> 
>     The following approach should help such real numa systems just as
>     much as it helps fake numa systems, or any combination thereof.
>     
>  2) The effort to distinguish fake from real numa, using node_distance,
>     so that we could cache a fake numa node and optimize choosing
>     it over equivalent distance fake nodes, while continuing to
>     properly scan all real nodes in distance order, was going to
>     require a nasty blob of zonelist and node distance munging.
> 
>     The following approach has no new dependency on node distances or
>     zone sorting.


David wrote:
> I was under the impression that there was nothing wrong with the way 
> current real NUMA systems allocate pages.  If not, please point me to the 
> thread that _specifically_ discusses this with _data_ that shows it's 
> inefficient.

See above.  I don't have data, so cannot justify going far out of our
way.

If someone has a better way to skin this fake numa cat, that does not
benefit (or harm) real numa, that would still be worth careful
consideration.


> In fact, when this thread started you recommended as little 
> changes as possible to the code to not interfere with what already works.  

Yes, I did start with that recommendation.  See above.

And see above for my current reasons for persuing this patch.

Some more things I like about this patch:
 * Conceptually, it is very localized, making no changes to the
   larger code or data structure, just adding a cache of some
   hot data.
 * Further, it makes few assumptions about the larger scheme of
   things.
 * It has no dependencies on zonelist sorting, node distances,
   fake vs real numa nodes or any of that.
 * It makes no discernable difference in the memory placement
   behaviour of a system.

Downside - it's still a linear zonelist scan, and it's a cache bolted on
the side of things, rather than an inherently fast algorithm and data
structure.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
