Date: Wed, 4 Oct 2006 15:10:59 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061004084552.a07025d7.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
 <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
 <20061001234858.fe91109e.pj@sgi.com> <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
 <20061002014121.28b759da.pj@sgi.com> <20061003111517.a5cc30ea.pj@sgi.com>
 <Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
 <20061004084552.a07025d7.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2006, Paul Jackson wrote:

> Are you trying to tell to me that the reason I can NOT get away with
> u16 is because I CAN get away with u16, but u8 would be better?
> 
> This makes no bleeping sense ...
> 
> Not to mention that I obviously can NOT get away with u8, as I already
> have 1024 real nodes on some systems.
> 

Isn't this the exact behavior that ordered zonelists are supposed to solve 
for real NUMA systems?  Has there been an _observed_ case where the cost 
to scan the zonelists was considered excessive on real NUMA systems?  If 
not, then this implementation is simply adding more (and unnecessary) 
complexity because now there's two strategies for determining the zones to 
check on every get_page_from_freelist and one of the major reasons we 
order zonelists in the first place is to deal with NUMA.

> Yes - I am trying to generalize whatever code changes we make to
> get_page_from_freelist() to be at least neutral for all arch's, and
> to benefit at least systems with large counts of nodes, real or fake.
> 

I was under the impression that there was nothing wrong with the way 
current real NUMA systems allocate pages.  If not, please point me to the 
thread that _specifically_ discusses this with _data_ that shows it's 
inefficient.  In fact, when this thread started you recommended as little 
changes as possible to the code to not interfere with what already works.  
I suggest if changes are going to be made to page allocation on fake AND 
real NUMA setups that you provide convincing data that it does indeed 
improve the efficiency of such an algorithm and thus far the only test I 
have seen you solicit is that of the fake case.

> > I would suggest following Magnus Damm's example ...
> 
> I don't know what example you mean - please provide a pointer.
> 

It was the same example that I posted in the other thread which caused you 
to add Magnus to the Cc.

http://marc.theaimsgroup.com/?l=linux-mm&m=113161386520342

If you read the thread this time, you'll notice that Andi Kleen's original 
objection to abstracting this generically was because he felt it was a 
debugger hack and didn't deserve the attention.  But as more and more 
discussion has taken place on the viability of using NUMA emulation in 
conjunction with cpusets for the purpose of resource management, perhaps 
he has relaxed that objection.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
