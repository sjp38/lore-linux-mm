Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage
	of	some key caches
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <487DFFBE.5050407@linux-foundation.org>
References: <1216211371.3122.46.camel@castor.localdomain>
	 <487DF5D4.9070101@linux-foundation.org>
	 <1216216730.3122.60.camel@castor.localdomain>
	 <487DFFBE.5050407@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 18 Jul 2008 10:57:05 +0100
Message-Id: <1216375025.3082.7.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-16 at 09:03 -0500, Christoph Lameter wrote:
> Richard Kennedy wrote:
> 
> > before
> > dentry             82136  82137    208   19    1 : tunables    0    0    0 : slabdata   4323   4323      0
> > after
> > dentry             79482  79482    208   39    2 : tunables    0    0    0 : slabdata   2038   2038      0
> 
> 19 objects with an order 1 alloc and 208 byte size? Urgh. 8192/208 = 39 and not 19.
> 
> Kmemcheck or something else active? We seem to be loosing 50% of our memory.
> 
> Pekka: Is the slabinfo emulation somehow broken?
> 
> I'd really like to see the output of slabinfo dentry.
> 

here's that slabinfo for dentry

on 2.6.26
after booting & starting X

Slabcache: dentry                Aliases:  0 Order :  0 Objects: 22553
** Reclaim accounting active

Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     208  Total  :    1188   Sanity Checks : Off  Total: 4866048
SlabObj:     208  Full   :    1186   Redzoning     : Off  Used : 4691024
SlabSiz:    4096  Partial:       0   Poisoning     : Off  Loss :  175024
Loss   :       0  CpuSlab:       2   Tracking      : Off  Lalig:       0
Align  :       8  Objects:      19   Tracing       : Off  Lpadd:  171072

and after a make kernel & a small delay

dentry: No NUMA information available.

Slabcache: radix_tree_node       Aliases:  0 Order :  1 Objects: 33564
** Reclaim accounting active

Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     552  Total  :    2399   Sanity Checks : Off  Total: 19652608
SlabObj:     560  Full   :    2391   Redzoning     : Off  Used : 18527328
SlabSiz:    8192  Partial:       6   Poisoning     : Off  Loss : 1125280
Loss   :       8  CpuSlab:       2   Tracking      : Off  Lalig:  268512
Align  :       0  Objects:      14   Tracing       : Off  Lpadd:  844448

*************
on 2.6.26 + my patch

Slabcache: dentry                Aliases:  0 Order :  1 Objects: 22581
** Reclaim accounting active

Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     208  Total  :     579   Sanity Checks : Off  Total: 4743168
SlabObj:     208  Full   :     577   Redzoning     : Off  Used : 4696848
SlabSiz:    8192  Partial:       0   Poisoning     : Off  Loss :   46320
Loss   :       0  CpuSlab:       2   Tracking      : Off  Lalig:       0
Align  :       8  Objects:      39   Tracing       : Off  Lpadd:   46320

after the make
Slabcache: dentry                Aliases:  0 Order :  1 Objects: 80168
** Reclaim accounting active

Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     208  Total  :    2056   Sanity Checks : Off  Total: 16842752
SlabObj:     208  Full   :    2043   Redzoning     : Off  Used : 16674944
SlabSiz:    8192  Partial:      11   Poisoning     : Off  Loss :  167808
Loss   :       0  CpuSlab:       2   Tracking      : Off  Lalig:       0
Align  :       8  Objects:      39   Tracing       : Off  Lpadd:  164480


Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
