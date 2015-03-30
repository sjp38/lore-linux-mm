Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C42166B0073
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:45:55 -0400 (EDT)
Received: by pacgg7 with SMTP id gg7so41447558pac.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:45:55 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id ex2si15281834pbb.31.2015.03.30.08.45.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 08:45:55 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 21:15:51 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 32C14E0045
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:18:06 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2UFjl5F29884648
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:15:47 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2UFjke1007718
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:15:47 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 19/24] thp, mm: use migration entries to freeze page counts on split
In-Reply-To: <20150330152652.GC5849@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com> <87h9t2le07.fsf@linux.vnet.ibm.com> <20150330152652.GC5849@node.dhcp.inet.fi>
Date: Mon, 30 Mar 2015 21:15:47 +0530
Message-ID: <87bnjalc9g.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Mon, Mar 30, 2015 at 08:38:08PM +0530, Aneesh Kumar K.V wrote:
>> ....
>> ....
>>  +static void freeze_page(struct anon_vma *anon_vma, struct page *page)
>> > +{
>> > +	struct anon_vma_chain *avc;
>> > +	struct vm_area_struct *vma;
>> > +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>> 
>> So this get called only with head page, We also do
>> BUG_ON(PageTail(page)) in the caller.  But
>> 
>> 
>> > +	unsigned long addr, haddr;
>> > +	unsigned long mmun_start, mmun_end;
>> > +	pgd_t *pgd;
>> > +	pud_t *pud;
>> > +	pmd_t *pmd;
>> > +	pte_t *start_pte, *pte;
>> > +	spinlock_t *ptl;
>> ......
>> 
>> 
>> > +
>> > +static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
>> > +{
>> > +	struct anon_vma_chain *avc;
>> > +	pgoff_t pgoff = page_to_pgoff(page);
>> 
>> Why ? Can this get called for tail pages ?
>
> It cannot. pgoff is offset of head page (and therefore whole compound
> page) within rmapping.
>

This we can use 

	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
        
similar to what we do in freeze_page(). The difference between
freeze/unfreeze confused me.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
