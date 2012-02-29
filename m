Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 8C42C6B007E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:17:52 -0500 (EST)
Date: Wed, 29 Feb 2012 10:17:31 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] sparsemem/bootmem: catch greater than section size
 allocations
Message-ID: <20120229091731.GA1673@cmpxchg.org>
References: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
 <20120228135326.GE1702@cmpxchg.org>
 <20120228201151.GC5136@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228201151.GC5136@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>, Anton Blanchard <anton@au1.ibm.com>, Paul Mackerras <paulus@samba.org>, Ben Herrenschmidt <benh@kernel.crashing.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, Feb 28, 2012 at 12:11:51PM -0800, Nishanth Aravamudan wrote:
> On 28.02.2012 [14:53:26 +0100], Johannes Weiner wrote:
> > On Fri, Feb 24, 2012 at 11:33:58AM -0800, Nishanth Aravamudan wrote:
> > > While testing AMS (Active Memory Sharing) / CMO (Cooperative Memory
> > > Overcommit) on powerpc, we tripped the following:
> > > 
> > > kernel BUG at mm/bootmem.c:483!
> > > cpu 0x0: Vector: 700 (Program Check) at [c000000000c03940]
> > >     pc: c000000000a62bd8: .alloc_bootmem_core+0x90/0x39c
> > >     lr: c000000000a64bcc: .sparse_early_usemaps_alloc_node+0x84/0x29c
> > >     sp: c000000000c03bc0
> > >    msr: 8000000000021032
> > >   current = 0xc000000000b0cce0
> > >   paca    = 0xc000000001d80000
> > >     pid   = 0, comm = swapper
> > > kernel BUG at mm/bootmem.c:483!
> > > enter ? for help
> > > [c000000000c03c80] c000000000a64bcc
> > > .sparse_early_usemaps_alloc_node+0x84/0x29c
> > > [c000000000c03d50] c000000000a64f10 .sparse_init+0x12c/0x28c
> > > [c000000000c03e20] c000000000a474f4 .setup_arch+0x20c/0x294
> > > [c000000000c03ee0] c000000000a4079c .start_kernel+0xb4/0x460
> > > [c000000000c03f90] c000000000009670 .start_here_common+0x1c/0x2c
> > > 
> > > This is
> > > 
> > >         BUG_ON(limit && goal + size > limit);
> > > 
> > > and after some debugging, it seems that
> > > 
> > > 	goal = 0x7ffff000000
> > > 	limit = 0x80000000000
> > > 
> > > and sparse_early_usemaps_alloc_node ->
> > > sparse_early_usemaps_alloc_pgdat_section -> alloc_bootmem_section calls
> > > 
> > > 	return alloc_bootmem_section(usemap_size() * count, section_nr);
> > > 
> > > This is on a system with 8TB available via the AMS pool, and as a quirk
> > > of AMS in firmware, all of that memory shows up in node 0. So, we end up
> > > with an allocation that will fail the goal/limit constraints. In theory,
> > > we could "fall-back" to alloc_bootmem_node() in
> > > sparse_early_usemaps_alloc_node(), but since we actually have HOTREMOVE
> > > defined, we'll BUG_ON() instead. A simple solution appears to be to
> > > disable the limit check if the size of the allocation in
> > > alloc_bootmem_secition exceeds the section size.
> > 
> > It makes sense to allow the usemaps to spill over to subsequent
> > sections instead of panicking, so FWIW:
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > That being said, it would be good if check_usemap_section_nr() printed
> > the cross-dependencies between pgdats and sections when the usemaps of
> > a node spilled over to other sections than the ones holding the pgdat.
> > 
> > How about this?
> > 
> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: sparsemem/bootmem: catch greater than section size allocations fix
> > 
> > If alloc_bootmem_section() no longer guarantees section-locality, we
> > need check_usemap_section_nr() to print possible cross-dependencies
> > between node descriptors and the usemaps allocated through it.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> > 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 61d7cde..9e032dc 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -359,6 +359,7 @@ static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
> >  				continue;
> >  			usemap_map[pnum] = usemap;
> >  			usemap += size;
> > +			check_usemap_section_nr(nodeid, usemap_map[pnum]);
> >  		}
> >  		return;
> >  	}
> 
> This makes sense to me -- ok if I fold it into the re-worked patch
> (based upon Mel's comments)?

Sure thing!

> > Furthermore, I wonder if we can remove the sparse-specific stuff from
> > bootmem.c as well, as now even more so than before, calculating the
> > desired area is really none of bootmem's business.
> > 
> > Would something like this be okay?
> > 
> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: [patch] mm: remove sparsemem allocation details from the bootmem allocator
> > 
> > alloc_bootmem_section() derives allocation area constraints from the
> > specified sparsemem section.  This is a bit specific for a generic
> > memory allocator like bootmem, though, so move it over to sparsemem.
> > 
> > Since __alloc_bootmem_node() already retries failed allocations with
> > relaxed area constraints, the fallback code in sparsemem.c can be
> > removed and the code becomes a bit more compact overall.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I've not tested it, but the intention seems sensible. I think it should
> remain a separate change.

Yes, I agree.  I'll resend it in a bit as stand-alone patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
