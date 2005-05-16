Date: Mon, 16 May 2005 12:43:17 -0700 (PDT)
From: christoph <christoph@scalex86.org>
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in node
 memory alignment
In-Reply-To: <1116274451.1005.106.camel@localhost>
Message-ID: <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw> <1116274451.1005.106.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, shai@scalex86.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 May 2005, Dave Hansen wrote:

> On Mon, 2005-05-16 at 12:05 -0700, christoph wrote:
> > Memory for nodes on i386 is currently aligned on 2 MB boundaries.
> > However, the buddy allocator needs pages to be aligned on
> > PAGE_SIZE << MAX_ORDER which is 8MB if MAX_ORDER = 11.
> 
> Why do you need this?  Are you planning on allowing NUMA KVA remap pages
> to be handed over to the buddy allocator?  That would be a major
> departure from what we do now, and I'd be very interested in seeing how
> that is implemented before a infrastructure for it goes in.

Because the buddy allocator is complaining about wrongly allocated zones!

in page_alloc.c:

static void __init free_area_init_core(struct pglist_data *pgdat,
                unsigned long *zones_size, unsigned long *zholes_size)
{
...

  const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);

...

             if ((zone_start_pfn) & (zone_required_alignment-1))
                        printk(KERN_CRIT "BUG: wrong zone alignment, it will crash\n");


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
