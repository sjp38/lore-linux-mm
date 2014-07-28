Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id B4B626B0035
	for <linux-mm@kvack.org>; Sun, 27 Jul 2014 21:28:11 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so6725656wes.34
        for <linux-mm@kvack.org>; Sun, 27 Jul 2014 18:28:11 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id fu18si31238081wjc.113.2014.07.27.18.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Jul 2014 18:28:09 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Mon, 28 Jul 2014 02:28:08 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id F354B17D8056
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:29:46 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6S1S5Q936176116
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 01:28:05 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6S1S4fe011316
	for <linux-mm@kvack.org>; Sun, 27 Jul 2014 19:28:04 -0600
Message-ID: <1406510881.2941.2.camel@TP-T420>
Subject: Re: [RFC PATCH]mm: fix potential infinite loop in
 dissolve_free_huge_pages()
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Mon, 28 Jul 2014 09:28:01 +0800
In-Reply-To: <20140724124511.GA14379@nhori>
References: <1406194585.2586.15.camel@TP-T420>
	 <20140724124511.GA14379@nhori>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2014-07-24 at 08:45 -0400, Naoya Horiguchi wrote:
> Hi Zhong,
> 
> On Thu, Jul 24, 2014 at 05:36:25PM +0800, Li Zhong wrote:
> > It is possible for some platforms, such as powerpc to set HPAGE_SHIFT to
> > 0 to indicate huge pages not supported. 
> > 
> > When this is the case, hugetlbfs could be disabled during boot time:
> > hugetlbfs: disabling because there are no supported hugepage sizes
> > 
> > Then in dissolve_free_huge_pages(), order is kept maximum (64 for
> > 64bits), and the for loop below won't end:
> > for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
> 
> At first I wonder that why could dissolve_free_huge_pages() is called
> if the platform doesn't support hugetlbfs. But I found that the function
> is called by memory hotplug code without checking hugepage support.
> 
> So it looks to me straightforward and self-descriptive to check
> hugepage_supported() just before calling dissolve_free_huge_pages().

Hi, Naoya,

Thank you for the review and suggestion.

I'll send a updated version. 

Thanks, Zhong

> 
> Thanks,
> Naoya Horiguchi
> 
> > The fix below returns directly if the order isn't set to a correct
> > value.
> > 
> > Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> > ---
> >  mm/hugetlb.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 2024bbd..a950817 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1093,6 +1093,10 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  	for_each_hstate(h)
> >  		if (order > huge_page_order(h))
> >  			order = huge_page_order(h);
> > +
> > +	if (order == 8 * sizeof(void *))
> > +		return;
> > +
> >  	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
> >  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
> >  		dissolve_free_huge_page(pfn_to_page(pfn));
> > 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
