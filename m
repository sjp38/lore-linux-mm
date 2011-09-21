Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ACDBA9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:08:07 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8LClI7f010820
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 08:47:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8LE84uD185072
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:08:05 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8LE7kkW021718
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:07:51 -0400
Subject: Re: [PATCH 2/8] mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.v15tv0183l0zgt@mnazarewicz-glaptop>
References: <1313764064-9747-1-git-send-email-m.szyprowski@samsung.com>
	 <1313764064-9747-3-git-send-email-m.szyprowski@samsung.com>
	 <1315505152.3114.9.camel@nimitz>  <op.v15tv0183l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Sep 2011 07:07:36 -0700
Message-ID: <1316614056.16137.278.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Wed, 2011-09-21 at 15:17 +0200, Michal Nazarewicz wrote:
> > This 'struct page *'++ stuff is OK, but only for small, aligned areas.
> > For at least some of the sparsemem modes (non-VMEMMAP), you could walk
> > off of the end of the section_mem_map[] when you cross a MAX_ORDER
> > boundary.  I'd feel a little bit more comfortable if pfn_to_page() was
> > being done each time, or only occasionally when you cross a section
> > boundary.
> 
> I'm fine with that.  I've used pointer arithmetic for performance reasons
> but if that may potentially lead to bugs then obviously pfn_to_page()  
> should be used

pfn_to_page() on x86 these days is usually:

	#define __pfn_to_page(pfn)      (vmemmap + (pfn))

Even for the non-vmemmap sparsemem it stays pretty quick because the
section array is in cache as you run through the loop.

There are ways to _minimize_ the number of pfn_to_page() calls by
checking when you cross a section boundary, or even at a
MAX_ORDER_NR_PAGES boundary.  But, I don't think it's worth the trouble.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
