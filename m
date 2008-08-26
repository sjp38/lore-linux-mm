Subject: Re: oom-killer why ?
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
In-Reply-To: <48B2EB37.2000200@iplabs.de>
References: <48B296C3.6030706@iplabs.de>
	 <48B2D615.4060509@linux-foundation.org> <48B2DB58.2010304@iplabs.de>
	 <48B2DDDA.5010200@linux-foundation.org>  <48B2EB37.2000200@iplabs.de>
Content-Type: text/plain
Date: Tue, 26 Aug 2008 06:45:59 -0400
Message-Id: <1219747559.6705.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-25 at 19:26 +0200, Marco Nietz wrote:
> It's should be possible to reproduce the oom, but it's a Production Server.

>   [<c014290b>] out_of_memory+0x25/0x13a
>   [<c0143d74>] __alloc_pages+0x1f5/0x275
>   [<c014a439>] __pte_alloc+0x11/0x9e
>   [<c014a576>] __handle_mm_fault+0xb0/0xa1f

> pagetables:152485

> Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
> inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes

If it is allocating lowmem for ptepages CONFIG_HIGHPTE is not set so it
exhausts the Normal zone with wired pte pages and eventually OOM kills.

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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
