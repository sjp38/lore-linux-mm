Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PH3x12021428
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:03:59 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PH3w4w119482
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:03:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PH3vLB006527
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:03:58 -0600
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1193331162.4039.141.camel@localhost>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
	 <1193331162.4039.141.camel@localhost>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 10:07:22 -0700
Message-Id: <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 09:52 -0700, Dave Hansen wrote:
> On Thu, 2007-10-25 at 08:55 -0700, Badari Pulavarty wrote:
> > 
> > +static ssize_t show_mem_type(struct sys_device *dev, char *buf)
> > +{
> > +       struct page *page;
> > +       int type;
> > +       int i = pageblock_nr_pages;
> > +       struct memory_block *mem =
> > +               container_of(dev, struct memory_block, sysdev);
> > +
> > +       /*
> > +        * Get the type of first page in the block
> > +        */
> > +       page = pfn_to_page(section_nr_to_pfn(mem->phys_index));
> > +       type = get_pageblock_migratetype(page);
> > +
> > +       /*
> > +        * Check the migrate type of other pages in this section.
> > +        * If the type doesn't match, report it.
> > +        */
> > +       while (i < PAGES_PER_SECTION) {
> > +               if (type != get_pageblock_migratetype(page + i))
> > +                       return sprintf(buf, "Multiple\n");
> > +               i += pageblock_nr_pages;
> > +       } 
> 
> I might change this to be a bit more generic.  The odds are that the
> existence of a "pageblock" or the types of "pageblocks" will either
> change or go away over time.
> 
> But, a simple boolean "yes you have a good shot of removing this memory"
> or "you have a snowball's chance in hell" on removability is likely
> generic enough to stand the test of time.
> 
> That is, after all, what you're after here, right?
> 
> So, I'd rewrite that loop to look for the removable pageblock types and
> see if the entire section is make up of removable pageblocks, or if it
> has some party crashing non-removable pageblocks in ther.


I agree with you that all I care about are the "movable" sections 
for remove. But what we are doing here is, exporting the migrate type
to user-space and let the user space make a decision on what type
of sections to use for its use. For now, we can migrate/remove ONLY
"movable" sections. But in the future, we may be able to migrate/remove
"Reclaimable" ones. I don't know.

I don't want to make decisions in the kernel for removability - as
it might change depending on the situation. All I want is to export
the info and let user-space deal with the decision making.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
