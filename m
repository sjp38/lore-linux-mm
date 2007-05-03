Date: Thu, 3 May 2007 01:57:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-Id: <20070503015729.7496edff.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705030936120.5165@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
	<20070501125559.9ab42896.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
	<20070503011515.0d89082b.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705030936120.5165@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007 09:46:32 +0100 (BST) Hugh Dickins <hugh@veritas.com> wrote:

> On Thu, 3 May 2007, Andrew Morton wrote:
> > On Wed, 2 May 2007 10:25:47 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > +config ARCH_USES_SLAB_PAGE_STRUCT
> > > +	bool
> > > +	default y
> > > +	depends on SPLIT_PTLOCK_CPUS <= NR_CPUS
> > > +
> > 
> > That all seems to work as intended.
> > 
> > However with NR_CPUS=8 SPLIT_PTLOCK_CPUS=4, enabling SLUB=y crashes the
> > machine early in boot.  
> 
> I thought that if that worked as intended, you wouldn't even
> get the chance to choose SLUB=y?  That was how it was working
> for me (but I realize I didn't try more than make oldconfig).

Right.  This can be tested on x86 without a cross-compiler:

ARCH=powerpc make mrproper
ARCH=powerpc make fooconfig

> > 
> > Too early for netconsole, no serial console.  Wedges up uselessly with
> > CONFIG_XMON=n, does mysterious repeated uncontrollable exceptions with
> > CONFIG_XMON=y.  This is all fairly typical for a powerpc/G5 crash :(
> > 
> > However I was able to glimpse some stuff as it flew past.  Crash started in
> > flush_old_exec and ended in pgtable_free_tlb -> kmem_cache_free.  I don't know
> > how to do better than that I'm afraid, unless I'm to hunt down a PCIE serial
> > card, perhaps.
> 
> That sounds like what happens when SLUB's pagestruct use meets
> SPLIT_PTLOCK's pagestruct use.  Does your .config really show
> CONFIG_SLUB=y together with CONFIG_ARCH_USES_SLAB_PAGE_STRUCT=y?
> 

Nope.

g5:/usr/src/25> grep SLUB .config
CONFIG_SLUB=y
g5:/usr/src/25> grep SLAB .config
# CONFIG_SLAB is not set
g5:/usr/src/25> grep CPUS .config
CONFIG_NR_CPUS=8
# CONFIG_CPUSETS is not set
# CONFIG_IRQ_ALL_CPUS is not set
CONFIG_SPLIT_PTLOCK_CPUS=4

It's in http://userweb.kernel.org/~akpm/config-g5.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
