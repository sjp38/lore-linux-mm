Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C9A5F6B01F5
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 04:44:23 -0400 (EDT)
Date: Tue, 20 Apr 2010 09:44:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: error at compaction (Re: mmotm 2010-04-15-14-42 uploaded
Message-ID: <20100420084454.GD19264@csn.ul.ie>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org> <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com> <20100419181442.GA19264@csn.ul.ie> <20100419193919.GB19264@csn.ul.ie> <s2v28c262361004191939we64e5490ld59b21dc4fa5bc8d@mail.gmail.com> <20100420082057.GC19264@csn.ul.ie> <x2h28c262361004200132q39fe5d5ex79251643a80d28b3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <x2h28c262361004200132q39fe5d5ex79251643a80d28b3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 05:32:13PM +0900, Minchan Kim wrote:
> On Tue, Apr 20, 2010 at 5:20 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Tue, Apr 20, 2010 at 11:39:46AM +0900, Minchan Kim wrote:
> >> On Tue, Apr 20, 2010 at 4:39 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >> > On Mon, Apr 19, 2010 at 07:14:42PM +0100, Mel Gorman wrote:
> >> >> On Mon, Apr 19, 2010 at 07:01:33PM +0900, KAMEZAWA Hiroyuki wrote:
> >> >> >
> >> >> > mmotm 2010-04-15-14-42
> >> >> >
> >> >> > When I tried
> >> >> >  # echo 0 > /proc/sys/vm/compaction
> >> >> >
> >> >> > I see following.
> >> >> >
> >> >> > My enviroment was
> >> >> >   2.6.34-rc4-mm1+ (2010-04-15-14-42) (x86-64) CPUx8
> >> >> >   allocating tons of hugepages and reduce free memory.
> >> >> >
> >> >> > What I did was:
> >> >> >   # echo 0 > /proc/sys/vm/compact_memory
> >> >> >
> >> >> > Hmm, I see this kind of error at migation for the 1st time..
> >> >> > my.config is attached. Hmm... ?
> >> >> >
> >> >> > (I'm sorry I'll be offline soon.)
> >> >>
> >> >> That's ok, thanks you for the report. I'm afraid I made little progress
> >> >> as I spent most of the day on other bugs but I do have something for
> >> >> you.
> >> >>
> >> >> First, I reproduced the problem using your .config. However, the problem does
> >> >> not manifest with the .config I normally use which is derived from the distro
> >> >> kernel configuration (Debian Lenny). So, there is something in your .config
> >> >> that triggers the problem. I very strongly suspect this is an interaction
> >> >> between migration, compaction and page allocation debug.
> >> >
> >> > I unexpecedly had the time to dig into this. Does the following patch fix
> >> > your problem? It Worked For Me.
> >>
> >> Nice catch during shot time. Below is comment.
> >>
> >> >
> >> > ==== CUT HERE ====
> >> > mm,compaction: Map free pages in the address space after they get split for compaction
> >> >
> >> > split_free_page() is a helper function which takes a free page from the
> >> > buddy lists and splits it into order-0 pages. It is used by memory
> >> > compaction to build a list of destination pages. If
> >> > CONFIG_DEBUG_PAGEALLOC is set, a kernel paging request bug is triggered
> >> > because split_free_page() did not call the arch-allocation hooks or map
> >> > the page into the kernel address space.
> >> >
> >> > This patch does not update split_free_page() as it is called with
> >> > interrupts held. Instead it documents that callers of split_free_page()
> >> > are responsible for calling the arch hooks and to map the page and fixes
> >> > compaction.
> >>
> >> Dumb question. Why can't we call arch_alloc_page and kernel_map_pages
> >> as interrupt disabled?
> >
> > In theory, it isn't known what arch_alloc_page is going to do but more
> > practically kernel_map_pages() is updating mappings and should be
> > flushing all the TLBs. It can't do that with interrupts disabled.
> >
> > I checked X86 and it should be fine but only because it flushes the
> > local CPU and appears to just hope for the best that this doesn't cause
> > problems.
> 
> Okay.
> 
> >> And now compaction only uses split_free_page and it is exposed by mm.h.
> >> I think it would be better to map pages inside split_free_page to
> >> export others.(ie, making generic function).
> >
> > I considered that and it would not be ideal. It would have to disable and
> > reenable interrupts as each page is taken from the list or alternatively
> > require that the caller not have the zone lock taken. The latter of these
> > options is more reasonable but would still result in more interrupt enabling
> > and disabling.
> >
> > split_free_page() is extremely specialised and requires knowledge of the
> > page allocator internals to call properly. There is little pressure to
> > make this easier to use at the cost of increased locking.
> >
> >> If we can't do, how about making split_free_page static as static function?
> >> And only uses it in compaction.
> >>
> >
> > It pretty much has to be in page_alloc.c because it uses internal
> > functions of the page allocator - e.g. rmv_page_order. I could move it
> > to mm/internal.h because whatever about split_page, I can't imagine why
> > anyone else would need to call split_free_page.
> 
> Yes. Then, Let's add comment like split_page. :)
>  /*
>  * Note: this is probably too low level an operation for use in drivers.
>  * Please consult with lkml before using this in your driver.
>  */
> 

I can, but the comment that was there says it's like split_page except the
page is already free. This also covers not using it in a driver.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
