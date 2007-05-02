Date: Wed, 2 May 2007 19:36:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705021924200.24456@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, haveblue@ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Christoph Lameter wrote:
> On Wed, 2 May 2007, Hugh Dickins wrote:
> 
> > I presume the answer is just to extend your quicklist work to
> > powerpc's lowest level of pagetables.  The only other architecture
> > which is using kmem_cache for them is arm26, which has
> > "#error SMP is not supported", so won't be giving this problem.
> 
> In the meantime we would need something like this to disable SLUB in this 
> particular configuration. Note that I have not tested this and the <= for
> the comparision with SPLIT_PTLOCK_CPUS may not work (Never seen such a
> construct in a Kconfig file but it is needed here).

I'm astonished and impressed, both with Kconfig and your use of it:
that does seem to work.  Though I don't dare go so far as to give
the patch an ack, and don't like this way out at all.  It needs a
proper (quicklist) solution, and by the time that solution comes
along, all the powerpc people will have CONFIG_SLAB=y in their
.config, and "make oldconfig" will just perpetuate that status quo,
instead of the switching over to CONFIG_SLUB=y.  I think.  Unless
we keep changing the config option names, or go through a phase
with no option.

I'd much rather be testing a quicklist patch:
I'd better give that a try.

Hugh

> 
> 
> 
> PowerPC: Disable SLUB for configurations in which slab page structs are modified
> 
> PowerPC uses the slab allocator to manage the lowest level of the page table.
> In high cpu configurations we also use the page struct to split the page
> table lock. Disallow the selection of SLUB for that case.
> 
> [Not tested: I am not familiar with powerpc build procedures etc]
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.21-rc7-mm2/arch/powerpc/Kconfig
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/arch/powerpc/Kconfig	2007-05-02 10:07:34.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/arch/powerpc/Kconfig	2007-05-02 10:13:37.000000000 -0700
> @@ -117,6 +117,19 @@ config GENERIC_BUG
>  	default y
>  	depends on BUG
>  
> +#
> +# Powerpc uses the slab allocator to manage its ptes and the
> +# page structs of ptes are used for splitting the page table
> +# lock for configurations supporting more than SPLIT_PTLOCK_CPUS.
> +#
> +# In that special configuration the page structs of slabs are modified.
> +# This setting disables the selection of SLUB as a slab allocator.
> +#
> +config ARCH_USES_SLAB_PAGE_STRUCT
> +	bool
> +	default y
> +	depends on SPLIT_PTLOCK_CPUS <= NR_CPUS
> +
>  config DEFAULT_UIMAGE
>  	bool
>  	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
