Date: Mon, 28 Jul 2008 21:00:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: + mm-remove-find_max_pfn_with_active_regions.patch added to -mm tree
Message-ID: <20080728200054.GB5352@csn.ul.ie>
References: <200807280313.m6S3DHDk017400@imap1.linux-foundation.org> <20080728091655.GC7965@csn.ul.ie> <86802c440807280415j5605822brb8836412a5c95825@mail.gmail.com> <20080728113836.GE7965@csn.ul.ie> <86802c440807281125g7d424f17v4b7c512929f45367@mail.gmail.com> <20080728191518.GA5352@csn.ul.ie> <86802c440807281238u63770318s8e665754f666c602@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <86802c440807281238u63770318s8e665754f666c602@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (28/07/08 12:38), Yinghai Lu didst pronounce:
> On Mon, Jul 28, 2008 at 12:15 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On (28/07/08 11:25), Yinghai Lu didst pronounce:
> >> On Mon, Jul 28, 2008 at 4:38 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >> > On (28/07/08 04:15), Yinghai Lu didst pronounce:
> >> >> On Mon, Jul 28, 2008 at 2:16 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >> >> > On (27/07/08 20:13), akpm@linux-foundation.org didst pronounce:
> >> >> >>
> >> >> >> The patch titled
> >> >> >>      mm: remove find_max_pfn_with_active_regions
> >> >> >> has been added to the -mm tree.  Its filename is
> >> >> >>      mm-remove-find_max_pfn_with_active_regions.patch
> >> >> >>
> >> >> >> Before you just go and hit "reply", please:
> >> >> >>    a) Consider who else should be cc'ed
> >> >> >>    b) Prefer to cc a suitable mailing list as well
> >> >> >>    c) Ideally: find the original patch on the mailing list and do a
> >> >> >>       reply-to-all to that, adding suitable additional cc's
> >> >> >>
> >> >> >> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> >> >> >>
> >> >> >> See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
> >> >> >> out what to do about this
> >> >> >>
> >> >> >> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> >> >> >>
> >> >> >> ------------------------------------------------------
> >> >> >> Subject: mm: remove find_max_pfn_with_active_regions
> >> >> >> From: Yinghai Lu <yhlu.kernel@gmail.com>
> >> >> >>
> >> >> >> It has no user now
> >> >> >>
> >> >> >> Also print out info about adding/removing active regions.
> >> >> >>
> >> >> >> Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
> >> >> >> Cc: Mel Gorman <mel@csn.ul.ie>
> >> >> >> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >> >> >> ---
> >> >> >>
> >> >> >>  include/linux/mm.h |    1 -
> >> >> >>  mm/page_alloc.c    |   22 ++--------------------
> >> >> >>  2 files changed, 2 insertions(+), 21 deletions(-)
> >> >> >>
> >> >> >> diff -puN include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions include/linux/mm.h
> >> >> >> --- a/include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions
> >> >> >> +++ a/include/linux/mm.h
> >> >> >> @@ -1041,7 +1041,6 @@ extern unsigned long absent_pages_in_ran
> >> >> >>  extern void get_pfn_range_for_nid(unsigned int nid,
> >> >> >>                       unsigned long *start_pfn, unsigned long *end_pfn);
> >> >> >>  extern unsigned long find_min_pfn_with_active_regions(void);
> >> >> >> -extern unsigned long find_max_pfn_with_active_regions(void);
> >> >> >>  extern void free_bootmem_with_active_regions(int nid,
> >> >> >>                                               unsigned long max_low_pfn);
> >> >> >>  typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
> >> >> >> diff -puN mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions mm/page_alloc.c
> >> >> >> --- a/mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions
> >> >> >> +++ a/mm/page_alloc.c
> >> >> >> @@ -3572,8 +3572,7 @@ void __init add_active_range(unsigned in
> >> >> >>  {
> >> >> >>       int i;
> >> >> >>
> >> >> >> -     mminit_dprintk(MMINIT_TRACE, "memory_register",
> >> >> >> -                     "Entering add_active_range(%d, %#lx, %#lx) "
> >> >> >> +     printk(KERN_INFO "Adding active range (%d, %#lx, %#lx) "
> >> >> >>                       "%d entries of %d used\n",
> >> >> >>                       nid, start_pfn, end_pfn,
> >> >> >>                       nr_nodemap_entries, MAX_ACTIVE_REGIONS);
> >> >> >
> >> >> > Why are the mminit_dprintk() calls being converted to printk(KERN_INFO)?  On
> >> >> > some machines, this will be very noisy. For example, some POWER configurations
> >> >> > will print out one line for every 16MB of memory with this patch.
> >> >>
> >> >> I don't know, on x86 esp the first node, that is some informative.
> >> >> or change that back to printk(KERN_DEBUG) ?
> >> >>
> >> >> hope the user put debug on command_line to get enough info.
> >> >>
> >> >> otherwise without "mminit_loglevel=" will get that debug info.
> >> >>
> >> >
> >> > It's the type of information that is only useful when debugging memory
> >> > initialisation problems. The more friendly information can be found at
> >> > the lines starting with
> >> >
> >> > early_node_map[1] active PFN ranges
> >> >
> >> > and this is already logged. The fact that mminit_loglevel needs loglevel
> >> > needs to be at KERN_DEBUG level is already documented for the mminit_loglevel=
> >> > parameter. I still am not convinced that these needs to be logged at
> >> > KERN_INFO level.
> >>
> >> I hope: when ask user to append "debug" we can get enough debug info
> >> without other extra ...
> >>
> >
> > I disagree. The memory init output is very verbose, which is why the
> > mminit_debug framework was made quiet by default.  In the event it is useful,
> > it is because memory initialisation broken and at that point, it's simple
> > enough to request the user to add the necessary options. It shouldn't be
> > visible by default. This is similar in principal to acpi.debug_level for
> > example.
> 
> not that verbose,  on my 8 sockets system
> 

Sure, on that system it's fine, but on others it is noisy. As I pointed
out already, on certain PPC64 machines (all LPARS for example), this will
output one line per 16MB of memory in the system which is excessive for a
system that is booting correctly.  On IA-64, it'll be at least 1 line per
node which gets noisy. This http://lkml.org/lkml/2006/4/18/206 is a log of
an IA-64 machine with an early version of arch-independent zone-sizing. See
how it is outputting 4 lines per node on the system.

> <dmesg log snipped>
> 

I'm not sure what I'm meant to be getting from this log. Glancing through,
it appeared to be printing out what was expected with the mminit_loglevel
settings.

> BTW, please check if mminit_loglevel=3 and mminit_loglevel=4 is the same?
> 

Based on this definition,

enum mminit_level {
        MMINIT_WARNING,
        MMINIT_VERIFY,
        MMINIT_TRACE
};

I'd expect it to be the same. I guess the documentation should have said
"3" and not "4" although it doesn't make much of a difference in terms of
what the user gets with either value.

> suggest to switch to mminit_debug, and that will be used in addition
> to "debug" to print out spew info for ...
> 

I'm not seeing what different a rename of the parameter will do. Even if
the parameter was renamed, it does not mean current trace information during
memory initialisation needs to be outputted as KERN_INFO which is what this
patch is doing. I am still failing to understand why you want this information
to be generally available.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
