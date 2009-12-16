Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E8E3B6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 07:16:28 -0500 (EST)
Date: Wed, 16 Dec 2009 20:14:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] print symbolic page flag names in bad_page()
Message-ID: <20091216121446.GA11618@localhost>
References: <20091204212606.29258.98531.stgit@bob.kio> <20091206034636.GA7109@localhost> <20091207093045.GA2107@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091207093045.GA2107@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Mel,

Sorry for the delay!

On Mon, Dec 07, 2009 at 05:30:45PM +0800, Mel Gorman wrote:
> On Sun, Dec 06, 2009 at 11:46:36AM +0800, Wu Fengguang wrote:
> > Hi Alex,
> > 
> > On Sat, Dec 05, 2009 at 05:29:48AM +0800, Alex Chiang wrote:
> > [...]
> > > Teach page-types the -k mode, which parses and describes the bits in
> > > the internal kernel order:
> > > 
> > >   # ./Documentation/vm/page-types -k 0x4000
> > >   0x0000000000004000  ______________H_________  compound_head
> > [...]
> > > The implication is that attempting to use page-types -k on a kernel
> > > with different CONFIG_* settings may lead to surprising and misleading
> > > results. To retain sanity, always use the page-types built out of the
> > > kernel tree you are actually testing.
> > 
> > This is useful feature, however not as convenient if the kernel can
> > print its page flag names directly :)
> > (especially when the dmesg comes from some end user)
> > 
> > So how about this patch?
> 
> There is a neat way of declaring strings that are used for the symbolic
> printing of flags in a bitfield. It's orientated around ftrace so not
> immediately usable for printk. Maybe the approaches can be merged but
> minimally, it'd be nice to match the declaration style. An example is
> show_gfp_flags in include/event/trace/kmem.h

Good tip, thanks!

Converting to the (mask, name) array almost doubles the space,
however that makes it usable to ftrace users, so I converted the
plain string array page_flag_names[] to "struct trace_print_flags *".

> > ---
> > 
> > mm: introduce dump_page()
> > 
> > - introduce dump_page() to print the page info for debugging some error condition.
> > - print an extra field: the symbolic names of page->flags
> > - convert three mm users: bad_page(), print_bad_pte() and memory offline failure. 
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/internal.h       |    2 +
> >  mm/memory.c         |    8 +---
> >  mm/memory_hotplug.c |    6 +--
> >  mm/page_alloc.c     |   75 +++++++++++++++++++++++++++++++++++++++---
> >  4 files changed, 78 insertions(+), 13 deletions(-)
> > 
> > --- linux-mm.orig/mm/page_alloc.c	2009-12-06 10:11:08.000000000 +0800
> > +++ linux-mm/mm/page_alloc.c	2009-12-06 11:22:58.000000000 +0800
> > @@ -48,6 +48,7 @@
> >  #include <linux/page_cgroup.h>
> >  #include <linux/debugobjects.h>
> >  #include <linux/kmemleak.h>
> > +#include <linux/kernel-page-flags.h>
> >  #include <trace/events/kmem.h>
> >  
> >  #include <asm/tlbflush.h>
> > @@ -262,10 +263,7 @@ static void bad_page(struct page *page)
> >  
> >  	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
> >  		current->comm, page_to_pfn(page));
> > -	printk(KERN_ALERT
> > -		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
> > -		page, (void *)page->flags, page_count(page),
> > -		page_mapcount(page), page->mapping, page->index);
> > +	dump_page(page);
> >  
> >  	dump_stack();
> >  out:
> > @@ -5106,3 +5104,72 @@ bool is_free_buddy_page(struct page *pag
> >  	return order < MAX_ORDER;
> >  }
> >  #endif
> > +
> > +static char *page_flag_names[] = {
> > +	[KPF_LOCKED]		= "L:locked",
> > +	[KPF_ERROR]		= "E:error",
> > +	[KPF_REFERENCED]	= "R:referenced",
> > +	[KPF_UPTODATE]		= "U:uptodate",
> > +	[KPF_DIRTY]		= "D:dirty",
> > +	[KPF_LRU]		= "l:lru",
> > +	[KPF_ACTIVE]		= "A:active",
> > +	[KPF_SLAB]		= "S:slab",
> > +	[KPF_WRITEBACK]		= "W:writeback",
> > +	[KPF_RECLAIM]		= "I:reclaim",
> > +	[KPF_BUDDY]		= "B:buddy",
> > +
> > +	[KPF_MMAP]		= "M:mmap",
> > +	[KPF_ANON]		= "a:anonymous",
> > +	[KPF_SWAPCACHE]		= "s:swapcache",
> > +	[KPF_SWAPBACKED]	= "b:swapbacked",
> > +	[KPF_COMPOUND_HEAD]	= "H:compound_head",
> > +	[KPF_COMPOUND_TAIL]	= "T:compound_tail",
> > +	[KPF_HUGE]		= "G:huge",
> > +	[KPF_UNEVICTABLE]	= "u:unevictable",
> > +	[KPF_HWPOISON]		= "X:hwpoison",
> > +	[KPF_NOPAGE]		= "n:nopage",
> > +	[KPF_KSM]		= "V:shared",
> > +
> > +	[KPF_RESERVED]		= "r:reserved",
> > +	[KPF_MLOCKED]		= "m:mlocked",
> > +	[KPF_MAPPEDTODISK]	= "d:mappedtodisk",
> > +	[KPF_PRIVATE]		= "P:private",
> > +	[KPF_PRIVATE_2]		= "p:private_2",
> > +	[KPF_OWNER_PRIVATE]	= "O:owner_private",
> > +	[KPF_ARCH]		= "h:arch",
> > +	[KPF_UNCACHED]		= "c:uncached",
> > +};
> > +
> > +static char *page_flags_longname(struct page *page, char *buf, int buflen)
> > +{
> > +	int i, n;
> > +	u64 flags;
> > +
> > +	flags = stable_page_flags(page);
> > +
> 
> I don't see where this is defined. I assume there is a patch dependency
> I'm not seeing.

It's posted several days ago:
        http://lkml.org/lkml/2009/12/1/470

It's effectively the internal page flags plus some useful fake ones,
eg. PageAnon(), PageKsm(), PageHuge().

It's not a big deal - developers can more or less deduce that for
themselves. And there are two problems:
- stable_page_flags() currently depends on CONFIG_PROC_PAGE_MONITOR
- stable_page_flags() uses u64 flags, which is incompatible with
  struct trace_print_flags.

So I'll use plain page flags instead.

> > +	for (i = 0, n = 0; i < ARRAY_SIZE(page_flag_names); i++) {
> > +		if (!page_flag_names[i])
> > +			continue;
> 
> How it is possible to get flags that are not recognised? Surely that
> that spark some sort of warning.

OK. I'll print the remained raw bits just like ftrace_print_flags_seq().
(In fact I copied the main logic from ftrace_print_flags_seq() :)

> > +		if ((flags >> i) & 1)
> > +			n += snprintf(buf + n, buflen - n, "%s,",
> > +					page_flag_names[i] + 2);
> 
> Why page_flag_names[i] + 2?

Sorry, the code (and string array) is copied from the user space tool
Documentation/vm/page-types.c ... now completed rewritten based on the
ftrace function.

> Should that be | instead of , ?

page-types chose "," because the pipe symbol "|" is not that user
friendly.  "|" is more developer friendly though, so will use it.

> > +	}
> > +	if (n)
> > +		n--;
> > +	buf[n] = '\0';
> > +
> > +	return buf;
> > +}
> 
> As the symbolic long name is always going to printk(), why buffer it?
> It's slower to call printk() multiple times but it's hardly a
> performance-critical path and it avoids the declaration of buf.
> 
> > +
> > +void dump_page(struct page *page)
> > +{
> > +	char buf[1024];
> > +
> 
> Ingo flagged this already.

Removed now.

> > +	printk(KERN_ALERT
> > +	"page:%p flags:%p(%s) count:%d mapcount:%d mapping:%p index:%lx\n",
> > +		page, (void *)page->flags,
> > +		page_flags_longname(page, buf, sizeof(buf)),
> 
> This can push things like count, mapcount and the like beyond the edge
> of 80 columns. While it rarely matters, it can get truncated on serial
> consoles depending on how they are being recorded. Can the string go to
> a line of it's own?

OK, I make a standalone line for flags (showing both hex and string).

> > +		page_count(page), page_mapcount(page),
> > +		page->mapping, page->index);
> > +}
> > +EXPORT_SYMBOL(dump_page);
> 
> Ingo pointed out that this is exported GPL but I'm confused as to why
> it's exported at all. What module needs it?

I'm testing dump_page() in a kernel module ;)  Will remove the export for now.

> > --- linux-mm.orig/mm/memory.c	2009-12-06 10:37:47.000000000 +0800
> > +++ linux-mm/mm/memory.c	2009-12-06 10:57:25.000000000 +0800
> > @@ -430,12 +430,8 @@ static void print_bad_pte(struct vm_area
> >  		"BUG: Bad page map in process %s  pte:%08llx pmd:%08llx\n",
> >  		current->comm,
> >  		(long long)pte_val(pte), (long long)pmd_val(*pmd));
> > -	if (page) {
> > -		printk(KERN_ALERT
> > -		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
> > -		page, (void *)page->flags, page_count(page),
> > -		page_mapcount(page), page->mapping, page->index);
> > -	}
> > +	if (page)
> > +		dump_page(page);
> >  	printk(KERN_ALERT
> >  		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
> >  		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
> > --- linux-mm.orig/mm/internal.h	2009-12-06 10:47:37.000000000 +0800
> > +++ linux-mm/mm/internal.h	2009-12-06 11:03:53.000000000 +0800
> > @@ -264,6 +264,8 @@ int __get_user_pages(struct task_struct 
> >  #define ZONE_RECLAIM_SUCCESS	1
> >  #endif
> >  
> > +void dump_page(struct page *page);
> > +
> >  extern int hwpoison_filter(struct page *p);
> >  
> >  extern u32 hwpoison_filter_dev_major;
> > --- linux-mm.orig/mm/memory_hotplug.c	2009-12-06 11:01:20.000000000 +0800
> > +++ linux-mm/mm/memory_hotplug.c	2009-12-06 11:01:23.000000000 +0800
> > @@ -678,9 +678,9 @@ do_migrate_range(unsigned long start_pfn
> >  			if (page_count(page))
> >  				not_managed++;
> >  #ifdef CONFIG_DEBUG_VM
> > -			printk(KERN_INFO "removing from LRU failed"
> > -					 " %lx/%d/%lx\n",
> > -				pfn, page_count(page), page->flags);
> > +			printk(KERN_INFO "removing pfn %lx from LRU failed\n",
> > +				pfn);
> > +			dump_page(page);
> 
> The message is printed at KERN_INFO and the dump at KERN_ALERT. Is this
> intentional?

Good catch, it looks more consistent to convert the original KERN_INFO
to KERN_ALERT.

Updated patch follows, thanks for the helpful review!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
