Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070914085335.GA30407@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost>
	 <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	 <1189691837.5013.43.camel@localhost>
	 <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
	 <20070913182344.GB23752@skynet.ie>
	 <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
	 <20070913141704.4623ac57.akpm@linux-foundation.org>
	 <20070914085335.GA30407@skynet.ie>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 16:15:25 -0400
Message-Id: <1189800926.5315.76.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 09:53 +0100, Mel Gorman wrote:
> On (13/09/07 14:17), Andrew Morton didst pronounce:
> > On Thu, 13 Sep 2007 11:26:19 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > On Thu, 13 Sep 2007, Mel Gorman wrote:
> > > 
> > > > What do you see holding it up? Is it the fact we are no longer doing the
> > > > pointer packing and you don't want that structure to exist, or is it simply
> > > > a case that 2.6.23 is too close the door and it won't get adequate
> > > > coverage in -mm?
> > > 
> > > No its not the pointer packing. The problem is that the patches have not 
> > > been merged yet and 2.6.23 is close. We would need to merge it very soon 
> > > and get some exposure in mm. Andrew?
> > 
> > You rang?
> > 
> > To which patches do you refer?  "Memory Policy Cleanups and Enhancements"? 
> > That's still in my queue somewhere, but a) it has "RFC" in it which usually
> > makes me run away and b) we already have no fewer than 221 memory
> > management patches queued.
> > 
> 
> Christoph's question is in relation to the patchset "Use one zonelist per
> node instead of multiple zonelists v7" and whether one zonelist will be
> merged in 2.6.24 in your opinion. I am hoping "yes" because it removes that
> hack with ZONE_MOVABLE and policies. I had sent you a version (v5) but there
> were further suggestions on ways to improve it so we're up to v7 now. Lee
> will hopefully be able to determine if v7 regresses policy behaviour or not.
> 

I've been testing the "one zonelist patches" with various memtoy
scripts, and they seem to be working--i.e., pages ending up where I
expect.  The tests aren't exhaustive or even particularly stressful, but
I did test all of the policies.   I also measured the time to allocate
4G [256K pages] with several policies using memtoy.  Here are the
results--rough averages of 10 runs; very close grouping for each
test--smaller is better:

Test			23-rc4-mm1	+one zonelist patches
sys default policy	  2.768s	>	2.755s
task pol bind local(1)	  2.789s	~=	2.789s
task pol bind remote(2)	  3.774s	<	3.780s
vma pol bind local(3)	  2.794s	>	2.790s
vma pol bind remote(4)	  3.769s	<	3.777s
vma pol pref local(5)	  2.774s	>	2.770s
vma interleave 0-3	  3.446s	>	3.436s

Notes:
1) numactl -c3 -m3 
2) numactl -c1 -m3
3) memtoy bound to node 3, mbind MPOL_BIND to node 3
4) memtoy bound to node 1, mbind MPOL_BIND to node 3
5) mbind MPOL_PREFERRED, null nodemask [preferred_node == -1 internally]

The results are very close, but it looks like one-zonelist is a bit
faster for local allocations and a bit slower for remote allocations.
None of these tests overflowed the target node.

I've also run a moderate stress test [half an hour now] and it's holding
up.  

I'm still trying to absorb the patches, but so far they look good.
Perhaps Andrew can tack them onto the bottom of the next -mm so that if
someone else finds issues, they won't complicate merging earlier patches
upstream?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
