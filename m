Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id l9FKL3R0030971
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 13:21:03 -0700
Received: from nz-out-0506.google.com (nzfn1.prod.google.com [10.36.190.1])
	by zps18.corp.google.com with ESMTP id l9FKL2Ix021321
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 13:21:02 -0700
Received: by nz-out-0506.google.com with SMTP id n1so935052nzf
        for <linux-mm@kvack.org>; Mon, 15 Oct 2007 13:21:01 -0700 (PDT)
Message-ID: <b040c32a0710151321s74799f0ax6e3e0c4042429c5b@mail.gmail.com>
Date: Mon, 15 Oct 2007 13:21:01 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
In-Reply-To: <200710152225.11433.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <200710141101.02649.nickpiggin@yahoo.com.au>
	 <20071014181929.GA19902@linux-os.sc.intel.com>
	 <200710152225.11433.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On 10/15/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> +static int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> +{
> +	pte_t pte = *(pte_t *)&pmd;
> +
> +	if (write && !pte_write(pte))
> +		return 0;
> +
> +	do {
> +		unsigned long pfn_offset;
> +		struct page *page;
> +
> +		pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
> +		page = pte_page(pte) + pfn_offset;
> +		get_page(page);
> +		pages[*nr] = page;
> +		(*nr)++;
> +
> +	} while (addr += PAGE_SIZE, addr != end);
> +
> +	return 1;
> +}

Since get_page() on compound page will reference back to the head
page, you can take a ref directly against the head page instead of
traversing to tail page and loops around back to the head page.  It is
especially beneficial for large hugetlb page size, i.e., 1 GB page
size so one does not have to pollute cache with tail page's struct
page. I prefer doing the following:

+		page = pte_page(pte);
+		get_page(page);
+		pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
+		pages[*nr] = page + pfn_offset;
+		(*nr)++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
