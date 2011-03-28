Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2F38D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:26:57 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2SGLTgp014235
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:21:29 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p2SGQoUW112814
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:26:50 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2SGQm1W022514
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:26:49 -0600
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 28 Mar 2011 09:25:24 -0700
Message-ID: <1301329524.31700.8440.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-03-28 at 11:25 +0200, Daniel Kiper wrote:
> This patch contains online_page_chain and apropriate functions
> for registering/unregistering online page notifiers. It allows
> to do some machine specific tasks during online page stage which
> is required to implement memory hotplug in virtual machines.
> Additionally, __online_page_increment_counters() and
> __online_page_free() function was add to ease generic
> hotplug operation.

I really like that you added some symbolic constants there.  It makes it
potentially a lot more readable.

My worry is that the next person who comes along is going to _really_
scratch their head asking why they would use:
OP_DO_NOT_INCREMENT_TOTAL_COUNTERS or: OP_INCREMENT_TOTAL_COUNTERS.
There aren't any code comments about it, and the patch description
doesn't really help.

In the end, we're only talking about a couple of lines of code for each
case (reordering the function a bit too):

        void online_page(struct page *page)
        {
        // 1. pfn-based bits upping the max physical address markers:
                unsigned long pfn = page_to_pfn(page);
                if (pfn >= num_physpages)
                        num_physpages = pfn + 1;
        #ifdef CONFIG_FLATMEM
                max_mapnr = max(page_to_pfn(page), max_mapnr);
        #endif
        
        // 2. number of pages counters:
                totalram_pages++;
        #ifdef CONFIG_HIGHMEM
                if (PageHighMem(page))
                        totalhigh_pages++;
        #endif
        
        // 3. preparing 'struct page' and freeing:
                ClearPageReserved(page);
                init_page_count(page);
                __free_page(page);
        }
        
Your stuff already extracted the free stuff very nicely.  I think now we
just need to separate out the totalram_pages/totalhigh_pages bits from
the num_physpages/max_mapnr ones.

If done right, this should also help the totalram_pages/totalhigh_pages
go away balloon_retrieve(), and make Xen less likely to break in the
future.  It also makes it immediately obvious why Xen skips incrementing
those counters: it does it later.

I also note that Xen has a copy of a part of online_page() in its
increase_reservation(): 

                /* Relinquish the page back to the allocator. */
                ClearPageReserved(page);
                init_page_count(page);
                __free_page(page);

That means that Xen is basically carrying an open-coded copy of
online_page() all by itself today.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
