Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0118D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:32:59 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1580192Ab1C2Scm (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 29 Mar 2011 20:32:42 +0200
Date: Tue, 29 Mar 2011 20:32:42 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory hotplug in virtual machines
Message-ID: <20110329183242.GE30387@router-fw-old.local.net-space.pl>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl> <1301329524.31700.8440.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301329524.31700.8440.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 09:25:24AM -0700, Dave Hansen wrote:
> On Mon, 2011-03-28 at 11:25 +0200, Daniel Kiper wrote:
> > This patch contains online_page_chain and apropriate functions
> > for registering/unregistering online page notifiers. It allows
> > to do some machine specific tasks during online page stage which
> > is required to implement memory hotplug in virtual machines.
> > Additionally, __online_page_increment_counters() and
> > __online_page_free() function was add to ease generic
> > hotplug operation.
>
> I really like that you added some symbolic constants there.  It makes it
> potentially a lot more readable.
>
> My worry is that the next person who comes along is going to _really_
> scratch their head asking why they would use:
> OP_DO_NOT_INCREMENT_TOTAL_COUNTERS or: OP_INCREMENT_TOTAL_COUNTERS.
> There aren't any code comments about it, and the patch description
> doesn't really help.
>
> In the end, we're only talking about a couple of lines of code for each
> case (reordering the function a bit too):
>
>         void online_page(struct page *page)
>         {
>         // 1. pfn-based bits upping the max physical address markers:
>                 unsigned long pfn = page_to_pfn(page);
>                 if (pfn >= num_physpages)
>                         num_physpages = pfn + 1;
>         #ifdef CONFIG_FLATMEM
>                 max_mapnr = max(page_to_pfn(page), max_mapnr);
>         #endif
>
>         // 2. number of pages counters:
>                 totalram_pages++;
>         #ifdef CONFIG_HIGHMEM
>                 if (PageHighMem(page))
>                         totalhigh_pages++;
>         #endif
>
>         // 3. preparing 'struct page' and freeing:
>                 ClearPageReserved(page);
>                 init_page_count(page);
>                 __free_page(page);
>         }
>
> Your stuff already extracted the free stuff very nicely.  I think now we
> just need to separate out the totalram_pages/totalhigh_pages bits from
> the num_physpages/max_mapnr ones.

What do you think about __online_page_increment_counters()
(totalram_pages and totalhigh_pages) and
__online_page_set_limits() (num_physpages and max_mapnr) ???

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
