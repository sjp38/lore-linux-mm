Subject: Re: oom-killer why ?
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <48B2D615.4060509@linux-foundation.org>
References: <48B296C3.6030706@iplabs.de>
	 <48B2D615.4060509@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 25 Aug 2008 13:36:38 -0400
Message-Id: <1219685798.24829.37.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Marco Nietz <m.nietz-mm@iplabs.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-25 at 10:56 -0500, Christoph Lameter wrote:
> Marco Nietz wrote:
> 
> > DMA32: empty
> > Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB
> > 1*1024kB 1*2048kB 0*4096kB = 3664kB
> 
> If the flags are for a regular allocation then you have had a something that
> leaks kernel memory (device driver?). Can you get us the output of
> /proc/meminfo and /proc/vmstat?

Unless CONFIG_HIGHPTE is not set the allocation should be using highmem:

-----------------------------------------------------------------------
pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
{
        struct page *pte;

#ifdef CONFIG_HIGHPTE
        pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|
__GFP_ZERO, 0);
#else
        pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
#endif
        if (pte)
                pgtable_page_ctor(pte);
        return pte;
}
-----------------------------------------------------------------------
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
