Date: Fri, 2 Jun 2006 13:06:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] hugetlb: powerpc: Actively close unused htlb regions on
 vma close
In-Reply-To: <1149257287.9693.6.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0606021301300.5492@schroedinger.engr.sgi.com>
References: <1149257287.9693.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jun 2006, Adam Litke wrote:

> The following patch introduces a architecture-specific vm_ops.close()
> hook.  For all architectures besides powerpc, this is a no-op.  On
> powerpc, the low and high segments are scanned to locate empty hugetlb
> segments which can be made available for normal mappings.  Comments?

IA64 has similar issues and uses the hook suggested by Hugh. However, we 
have a permanently reserved memory area. I am a bit surprised about the 
need to make address space available for normal mappings. Is this for 32 
bit powerpc support?

void hugetlb_free_pgd_range(struct mmu_gather **tlb,
                        unsigned long addr, unsigned long end,
                        unsigned long floor, unsigned long ceiling)
{
        /*
         * This is called to free hugetlb page tables.
         *
         * The offset of these addresses from the base of the hugetlb
         * region must be scaled down by HPAGE_SIZE/PAGE_SIZE so that
         * the standard free_pgd_range will free the right page tables.
         *
         * If floor and ceiling are also in the hugetlb region, they
         * must likewise be scaled down; but if outside, left unchanged.
         */

        addr = htlbpage_to_page(addr);
        end  = htlbpage_to_page(end);
        if (REGION_NUMBER(floor) == RGN_HPAGE)
                floor = htlbpage_to_page(floor);
        if (REGION_NUMBER(ceiling) == RGN_HPAGE)
                ceiling = htlbpage_to_page(ceiling);

        free_pgd_range(tlb, addr, end, floor, ceiling);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
