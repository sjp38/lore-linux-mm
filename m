Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB956B002E
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 14:02:09 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 18 Oct 2011 13:50:19 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9IHmsmJ174224
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 13:48:54 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9IHmrNb024379
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 15:48:54 -0200
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.v3j5ent03l0zgt@mpn-glaptop>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	 <1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
	 <20111018122109.GB6660@csn.ul.ie>  <op.v3j5ent03l0zgt@mpn-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 18 Oct 2011 10:48:46 -0700
Message-ID: <1318960126.4465.249.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tue, 2011-10-18 at 10:26 -0700, Michal Nazarewicz wrote:
> > You can do this in a more general fashion by checking the
> > zone boundaries and resolving the pfn->page every MAX_ORDER_NR_PAGES.
> > That will not be SPARSEMEM specific.
> 
> I've tried doing stuff that way but it ended up with much more code.

I guess instead of:

>> +static inline bool zone_pfn_same_memmap(unsigned long pfn1, unsigned long pfn2)
>> +{
>> +    return pfn_to_section_nr(pfn1) == pfn_to_section_nr(pfn2);
>> +}

You could do:

static inline bool zone_pfn_same_maxorder(unsigned long pfn1, unsigned long pfn2)
{
	unsigned long mask = MAX_ORDER_NR_PAGES-1;
	return (pfn1 & mask) == (pfn2 & mask);
}

I think that works.  Should be the same code you have now, basically.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
