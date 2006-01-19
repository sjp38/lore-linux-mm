Date: Fri, 20 Jan 2006 08:42:31 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [PATCH 1/2] Add the pzone
In-Reply-To: <43CFD4BB.4070704@shadowen.org>
References: <20060119080408.24736.13148.sendpatchset@debian>
	<20060119080413.24736.27946.sendpatchset@debian>
	<43CFD4BB.4070704@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20060119234257.0DB4A7402D@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jan 2006 18:04:43 +0000
Andy Whitcroft <apw@shadowen.org> wrote:

> > -/* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
> > -#define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
> > +/* Page flags: | [PZONE] | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
> > +#define PZONE_BIT_PGOFF		((sizeof(unsigned long)*8) - PZONE_BIT_WIDTH)
> > +#define SECTIONS_PGOFF		(PZONE_BIT_PGOFF - SECTIONS_WIDTH)
> >  #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
> >  #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
> 
> In general this PZONE bit is really a part of the zone number.  Much of
> the order of these bits is chosen to obtain the cheapest extraction of
> the most used bits, particularly the node/zone conbination or section
> number on the left.  I would say put the PZONE_BIT next to ZONE
> probabally to the right of it?  [See below for more reasons to put it
> there.]

Thanks for the comments.  It looks much better to put PZONE_BIT to
that place.

> > @@ -431,6 +438,7 @@ void put_page(struct page *page);
> >   * sections we define the shift as 0; that plus a 0 mask ensures
> >   * the compiler will optimise away reference to them.
> >   */
> > +#define PZONE_BIT_PGSHIFT	(PZONE_BIT_PGOFF * (PZONE_BIT_WIDTH != 0))
> >  #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
> >  #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
> >  #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
> > @@ -443,10 +451,11 @@ void put_page(struct page *page);
> >  #endif
> >  #define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
> >  
> > -#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> > -#error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> > +#if PZONE_BIT_WIDTH+SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> > +#error PZONE_BIT_WIDTH+SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> >  #endif
> 
> Do we have any bits left in the reserve on 32 bit machines?  The reserve
> at last look was only 8 bits and there was little if any headroom in the
> rest of the flags word to extend it; if memory serves at least 22 of the
> 24 remaining bits was accounted for.  Has this been tested on any such
> machines?

At least it does compile and work on non-NUMA i386 configuration.
But I haven't tested with CONFIG_NUMA or CONFIG_SPARSEMEM enabled.

> > +
> > +static inline unsigned long page_to_nid(struct page *page)
> > +{
> > +	return page_zone(page)->zone_pgdat->node_id;
> > +}
> [...]
> > +#ifdef CONFIG_PSEUDO_ZONE
> > +#define MAX_NR_PZONES		1024
> 
> You seem to be allowing for 1024 pzone's here?  But in
> pzone_setup_page_flags() you place the pzone_idx (an offset into the
> pzone_table) into the ZONE field of the page flags.  This field is
> typically only two bits wide?  I don't see this being increased in this
> patch, nor is there space for it generally to get much bigger not on 32
> bit kernels anyhow (see comments about bits earlier)?

pzone_idx isn't placed on the ZONE field.  The flags field of pzone pages
is as follows:

 Page flags: | [PZONE] | [pzone-idx] | ZONE | ... | FLAGS |

For pzones, the node number should be obtained from parent zone.

Thanks,

-- 
KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
