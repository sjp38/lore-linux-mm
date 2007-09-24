Date: Mon, 24 Sep 2007 13:11:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <alpine.DEB.0.9999.0709241211240.16397@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709241309120.30222@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709241202280.29673@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709241211240.16397@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Sep 2007, David Rientjes wrote:

> > > +static inline int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)
> > > +{
> > > +	return test_and_set_bit(flag, &zone->flags);
> > > +}
> > 
> > Missing blank line.
> > 
> 
> The only blank line for inlined functions added to mmzone.h for zone 
> flag support is between the generic flavors that set, test and set, or 
> clear the flags and the explicit flavors that test specific bits; so this 
> newline behavior is correct as written.
> 
> I was hoping to avoid doing things like
> 
> 	#define ZoneSetReclaimLocked(zone)	zone_set_flag((zone),	\
> 							ZONE_RECLAIM_LOCKED)

Not sure what the #define is supposed to tell me.

Please add the corresponding blank lines at the end of functions. One 
function seems to be running into the next.

It should look like the rest of mmzone.h:

static inline struct page *__section_mem_map_addr(struct mem_section *section)
{
        unsigned long map = section->section_mem_map;
        map &= SECTION_MAP_MASK;
        return (struct page *)map;
}

static inline int valid_section(struct mem_section *section)
{
        return (section && (section->section_mem_map & SECTION_MARKED_PRESENT));
}

static inline int section_has_mem_map(struct mem_section *section)
{
        return (section && (section->section_mem_map & SECTION_HAS_MEM_MAP));
}

static inline int valid_section_nr(unsigned long nr)
{
        return valid_section(__nr_to_section(nr));
}

static inline struct mem_section *__pfn_to_section(unsigned long pfn)
{
        return __nr_to_section(pfn_to_section_nr(pfn));
}

static inline int pfn_valid(unsigned long pfn)
{
        if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
                return 0;
        return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
}

Note that there is a empty line at the end of each function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
