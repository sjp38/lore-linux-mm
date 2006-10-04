Date: Wed, 4 Oct 2006 08:45:52 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061004084552.a07025d7.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
	<20061001234858.fe91109e.pj@sgi.com>
	<Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
	<20061002014121.28b759da.pj@sgi.com>
	<20061003111517.a5cc30ea.pj@sgi.com>
	<Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

David responding to pj:
> > I'm still curious as to why I can't get away with an unsigned short there.
> > 
> 
> Because it's unnecessary.  On my 4G machine with numa=fake=256, each of 
> these node_id arrays is going to be 1.5K.  You could get away with the 
> exact same behavior with using a u8 or unsigned char.

Are you trying to tell to me that the reason I can NOT get away with
u16 is because I CAN get away with u16, but u8 would be better?

This makes no bleeping sense ...

Not to mention that I obviously can NOT get away with u8, as I already
have 1024 real nodes on some systems.

> If you are going to abstract this functionality to other architectures or 
> even generically

Yes - I am trying to generalize whatever code changes we make to
get_page_from_freelist() to be at least neutral for all arch's, and
to benefit at least systems with large counts of nodes, real or fake.

> I would suggest following Magnus Damm's example ...

I don't know what example you mean - please provide a pointer.

> The only thing that is being sped-up with your node_id array 
> in each zonelist_faster is moving this calculation from two steps to one 
> step; since the mainline implementation today are both inline functions I 
> think the improvement is minimal.

No - I'm optimizing cache line misses, not classic algorithmic
complexity or number of function calls.  Scanning say 256 zones
with the existing kernel code uses 256 or 512 cache lines, at
one or two per zone.  Scanning 256 zones with my zonelist_faster
patch uses however many cache lines it takes to hold 512 consecutive
bytes of memory, which is much fewer.

Hopefully Martin can get us some real numbers.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
