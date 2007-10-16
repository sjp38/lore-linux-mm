Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9G0EmJV020886
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 20:14:48 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9G0EmmT430116
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 18:14:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9G0ElOZ029088
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 18:14:48 -0600
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200710161215.33284.nickpiggin@yahoo.com.au>
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <200710152225.11433.nickpiggin@yahoo.com.au>
	 <b040c32a0710151321s74799f0ax6e3e0c4042429c5b@mail.gmail.com>
	 <200710161215.33284.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 15 Oct 2007 17:14:47 -0700
Message-Id: <1192493687.6118.138.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ken Chen <kenchen@google.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

> +static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
> +{
> +       pte_t *ptep;
> +
> +       /* XXX: this won't work for 32-bit (must map pte) */
> +       ptep = (pte_t *)pmd_page_vaddr(pmd) + pte_index(addr);
> +       do {
> +               pte_t pte = *ptep;
> +               unsigned long pfn;
> +               struct page *page;
> +
> +               if ((pte_val(pte) & (_PAGE_PRESENT|_PAGE_USER)) != (_PAGE_PRESENT|_PAGE_USER))
> +                       return 0;
> +
> +               if (write && !pte_write(pte))
> +                       return 0;
> +
> +               /* XXX: really need new bit in pte to denote normal page */
> +               pfn = pte_pfn(pte);
> +               if (unlikely(!pfn_valid(pfn)))
> +                       return 0;

Is that little pfn_valid() nugget to help detect VM_IO and VM_PFNMAP
areas?  Does that work 100% of the time?  Is it for anything else?

If that is all that you want a bit in the pte for, I guess we could get
a bitfield or a simple flag in the mm to say whether there are any
VM_IO/PFNMAP areas around.  If we used the same IPI/RCU rules as
pagetables to manage such a flag, I think it would be sufficient to dump
us into the slow path when we hit those areas.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
