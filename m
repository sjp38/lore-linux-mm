Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PGqjBH008195
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:52:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PGqjeL136532
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:52:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PGqi2X020274
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:52:44 -0400
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 09:52:42 -0700
Message-Id: <1193331162.4039.141.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 08:55 -0700, Badari Pulavarty wrote:
> 
> +static ssize_t show_mem_type(struct sys_device *dev, char *buf)
> +{
> +       struct page *page;
> +       int type;
> +       int i = pageblock_nr_pages;
> +       struct memory_block *mem =
> +               container_of(dev, struct memory_block, sysdev);
> +
> +       /*
> +        * Get the type of first page in the block
> +        */
> +       page = pfn_to_page(section_nr_to_pfn(mem->phys_index));
> +       type = get_pageblock_migratetype(page);
> +
> +       /*
> +        * Check the migrate type of other pages in this section.
> +        * If the type doesn't match, report it.
> +        */
> +       while (i < PAGES_PER_SECTION) {
> +               if (type != get_pageblock_migratetype(page + i))
> +                       return sprintf(buf, "Multiple\n");
> +               i += pageblock_nr_pages;
> +       } 

I might change this to be a bit more generic.  The odds are that the
existence of a "pageblock" or the types of "pageblocks" will either
change or go away over time.

But, a simple boolean "yes you have a good shot of removing this memory"
or "you have a snowball's chance in hell" on removability is likely
generic enough to stand the test of time.

That is, after all, what you're after here, right?

So, I'd rewrite that loop to look for the removable pageblock types and
see if the entire section is make up of removable pageblocks, or if it
has some party crashing non-removable pageblocks in ther.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
