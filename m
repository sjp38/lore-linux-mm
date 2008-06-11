Date: Wed, 11 Jun 2008 20:03:11 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080611190311.GA30958@shadowen.org>
References: <20080606180506.081f686a.akpm@linux-foundation.org> <20080608163413.08d46427@bree.surriel.com> <20080608135704.a4b0dbe1.akpm@linux-foundation.org> <20080608173244.0ac4ad9b@bree.surriel.com> <20080608162208.a2683a6c.akpm@linux-foundation.org> <20080608193420.2a9cc030@bree.surriel.com> <20080608165434.67c87e5c.akpm@linux-foundation.org> <Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com> <20080610153702.4019e042@cuia.bos.redhat.com> <20080610143334.c53d7d8a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080610143334.c53d7d8a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 10, 2008 at 02:33:34PM -0700, Andrew Morton wrote:
> On Tue, 10 Jun 2008 15:37:02 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > On Tue, 10 Jun 2008 12:17:23 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > On Sun, 8 Jun 2008, Andrew Morton wrote:
> > > 
> > > > And it will take longer to get those problems sorted out if 32-bt
> > > > machines aren't even compiing the new code in.
> > > 
> > > The problem is going to be less if we dependedn on 
> > > CONFIG_PAGEFLAGS_EXTENDED instead of 64 bit. This means that only certain 
> > > 32bit NUMA/sparsemem configs cannot do this due to lack of page flags.
> > > 
> > > I did the pageflags rework in part because of Rik's project.
> > 
> > I think your pageflags work freed up a number of bits on 32
> > bit systems, unless someone compiles a 32 bit system with
> > support for 4 memory zones (2 bits ZONE_SHIFT) and 64 NUMA
> > nodes (6 bits NODE_SHIFT), in which case we should still
> > have 24 bits for flags.
> > 
> > Of course, having 64 NUMA nodes and a ZONE_SHIFT of 2 on
> > a 32 bit system is probably total insanity already.  I
> > suspect very few people compile 32 bit with NUMA at all,
> > except if it is an architecture that uses DISCONTIGMEM
> > instead of zones, in which case ZONE_SHIFT is 0, which
> > will free up space too :)
> 
> Maybe it's time to bite the bullet and kill i386 NUMA support.  afaik
> it's just NUMAQ and a 2-node NUMAish machine which IBM made (as400?)
> 
> arch/sh uses NUMA for 32-bit, I believe. But I don't know what its
> maximum node count is.  The default for sh NODES_SHIFT is 3.  

I think we can say that although NUMAQ can have up to 64 NUMA nodes, in
fact I don't think we have any more with more than 4 nodes left.  From
the other discussion it sounds like we have a maximum if 8 nodes on
other sub-arches.  So it would not be unreasonable to reduce the shift
to 3.  Which might allow us to reduce the size of the reserve.

The problem will come with SPARSEMEM as that stores the section number
in the reserved field.  Which can mean we need the whole reserve, and
there is currently no simple way to remove that.

I have been wondering whether we could make more use of the dynamic
nature of the page bits.  As bits only need to exist when used, whether
we could consider letting the page flags grow to 64 bits if necessary.
However, at a quick count we are still only using about 19 bits, and if
memory serves we have 23/24 after the reserve on 32 bit.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
