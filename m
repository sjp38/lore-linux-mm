Date: Wed, 1 Aug 2007 14:36:42 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Message-ID: <20070801053642.GA7581@linux-sh.org>
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070727194322.18614.68855.sendpatchset@localhost> <20070731192241.380e93a0.akpm@linux-foundation.org> <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com> <20070731200522.c19b3b95.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com> <20070731203203.2691ca59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070731203203.2691ca59.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 31, 2007 at 08:32:03PM -0700, Andrew Morton wrote:
> On Tue, 31 Jul 2007 20:14:08 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> > Andi wants to drop support for NUMAQ again. Is that possible? NUMA only on 
> > 64 bit?
> 
> umm, that would need wide circulation.  I have a feeling that some
> implementations of some of the more obscure 32-bit architectures can (or
> will) have numa characteristics.  Looks like mips might already.
> 
> And doesn't i386 summit do numa?
> 
> We could do it, but it would take some chin-scratching.  It'd be good if we
> could pull it off.
> 
No, SH also requires this due to the abundance of multiple memories with
varying costs, both in UP and SMP configurations. This was the motivation
behind SLOB + NUMA and the mempolicy work.

In the SMP case we have 4 CPUs and system memory + 5 SRAM blocks,
those blocks not only have differing access costs, there are also
implications for bus and cache controller contention. This works out to
6 nodes in practice, as each one has a differing cost.

More and more embedded processors are shipping with both on-chip and
external SRAM blocks in increasingly larger sizes (from 128kB - 1MB
on-chip, and more shared between CPUs). These often have special
characteristics, like bypassing the cache completely, so it's possible to
map workloads with certain latency constraints there while alleviating
pressure from the snoop controller. Some folks also opt for the SRAM
instead of an L2 due to die constraints, for example. In any event,
current processes make this sort of thing quite common, and I expect
there will be more embedded CPUs with blocks of memory they can't really
do a damn thing with otherwise besides statically allocating it all for a
single application.

As of -rc1, using SLOB on a 128kB SRAM node, I'm left with 124kB usable.
Since we give up a node-local pfn for the pgdat, this is what's expected.
There's still some work to be done in this area, but the current scheme
works well enough. If anything, we should be looking at ways to make it
more light-weight, rather than simply trying to push it all off.

I would expect other embedded platforms with similar use cases to start
adding support as well in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
