Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap(2) [1/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <413501DC.2050409@jp.fujitsu.com>
References: <413455BE.6010302@jp.fujitsu.com>
	 <1093969857.26660.4816.camel@nighthawk>  <413501DC.2050409@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093993935.28787.416.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 31 Aug 2004 16:12:15 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-31 at 15:55, Hiroyuki KAMEZAWA wrote:
> Dave Hansen wrote:
> 
> > On Tue, 2004-08-31 at 03:41, Hiroyuki KAMEZAWA wrote:
> > 
> >>+static void __init calculate_aligned_end(struct zone *zone,
> >>+					 unsigned long start_pfn,
> >>+					 int nr_pages)
> > 
> > ...
> > 
> >>+		end_address = (zone->zone_start_pfn + end_idx) << PAGE_SHIFT;
> >>+#ifndef CONFIG_DISCONTIGMEM
> >>+		reserve_bootmem(end_address,PAGE_SIZE);
> >>+#else
> >>+		reserve_bootmem_node(zone->zone_pgdat,end_address,PAGE_SIZE);
> >>+#endif
> >>+	}
> >>+	return;
> >>+}
> > 
> > 
> > What if someone has already reserved that address?  You might not be
> > able to grow the zone, right?
> > 
> 1) If someone has already reserved that address,  it (the page) will not join to
>    buddy allocator and it's no problem.
> 
> 2) No, I can grow the zone.
>    A reserved page is the last page of "not aligned contiguous mem_map", not zone.
> 
> I answer your question ?

If the end of the zone isn't aligned, you simply waste memory until it becomes aligned, right?

> I know this patch contains some BUG, if a page is allocateed when calculate_alinged_end()
> is called, and is freed after calling this, it is never reserved and join to buddy system.

If you adjust the zone_spanned pages properly, this shouldn't happen.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
