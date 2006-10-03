Date: Tue, 3 Oct 2006 12:37:52 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061003111517.a5cc30ea.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
 <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
 <20061001234858.fe91109e.pj@sgi.com> <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
 <20061002014121.28b759da.pj@sgi.com> <20061003111517.a5cc30ea.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2006, Paul Jackson wrote:

> pj, responding to David:
> > > With NODES_SHIFT equal to 10 as you recommend, you can't get away with an 
> > > unsigned short there. 
> > 
> > Apparently it's time for me to be a stupid git again.  That's ok; I'm
> > getting quite accustomed to it.
> > 
> > Could you spell out exactly why I can't get away with an unsigned short
> > node_id if NODES_SHIFT is 10?
> 
> 
> Is this still in your queue to respond to, David?
> 
> I'm still curious as to why I can't get away with an unsigned short there.
> 

Because it's unnecessary.  On my 4G machine with numa=fake=256, each of 
these node_id arrays is going to be 1.5K.  You could get away with the 
exact same behavior with using a u8 or unsigned char.  There's no reason 
to support anything greater than a shift of 8 since NUMA emulation is 
_only_ available on x86_64 and doesn't even work right as it stands in the 
current mainline so that you could boot my machine with anything more than 
numa=fake=8.

If you are going to abstract this functionality to other architectures or 
even generically I would suggest following Magnus Damm's example and 
creating a NODES_SHIFT_HW instead that would limit the number of numa=fake 
nodes.  There is simply no reason for this to be greater than 8 (even a 
128G machine with numa=fake=256 would have 512M nodes).

Secondly, the entire node_id lookup is redundant on x86_64 in the first 
place (see arch/x86_64/mm/numa.c and include/asm-x86_64/mmzone.h for 
memnodemap).  The only thing that is being sped-up with your node_id array 
in each zonelist_faster is moving this calculation from two steps to one 
step; since the mainline implementation today are both inline functions I 
think the improvement is minimal.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
