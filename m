Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9FHNtBT008645
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 13:23:55 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FHGEkP245370
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 11:23:54 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FH0XWj012217
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 11:00:34 -0600
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <200710152225.11433.nickpiggin@yahoo.com.au>
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <200710141101.02649.nickpiggin@yahoo.com.au>
	 <20071014181929.GA19902@linux-os.sc.intel.com>
	 <200710152225.11433.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 15 Oct 2007 10:03:52 -0700
Message-Id: <1192467832.30128.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-15 at 22:25 +1000, Nick Piggin wrote:
..
> Here is something that is actually tested and works (not
> tested with hugepages yet, though).
> 
> However it's not 100% secure at the moment. It's actually
> not completely trivial; I think we need to use an extra bit
> in the present pte in order to exclude "not normal" pages,
> if we want fast_gup to work on small page mappings too. I
> think this would be possible to do on most architectures, but
> I haven't done it here obviously.
> 
> Still, it should be enough to test the design. I've added
> fast_gup and fast_gup_slow to /proc/vmstat, which count the
> number of times fast_gup was called, and the number of times
> it dropped into the slowpath. It would be interesting to know
> how it performs compared to your granular hugepage ptl...


+static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long
end, int write, struct page **pages, int *nr)
+{
+       pte_t pte = *(pte_t *)&pmd;
+       struct page *page;
+
+       if ((pte_val(pte) & _PAGE_USER) != _PAGE_USER)
+               return 0;
+
+       BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+       if (write && !pte_write(pte))
+               return 0;
+
+       page = pte_page(pte);
+       do {
+               unsigned long pfn_offset;
+               struct page *p;
+
+               pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
+               p = page + pfn_offset;
+               get_page(page);
+               pages[*nr] = page;
+               (*nr)++;
+
+       } while (addr += PAGE_SIZE, addr != end);
                         ^^^^^^^^^^

Shouldn't this be HPAGE_SIZE ?

Thanks,
Badari       

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
