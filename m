Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 662AF6B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 20:11:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b13-v6so11159439pgw.1
        for <linux-mm@kvack.org>; Wed, 02 May 2018 17:11:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f28-v6si13520569plj.255.2018.05.02.17.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 17:11:15 -0700 (PDT)
Date: Wed, 2 May 2018 17:11:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 13/16] mm: Add pt_mm to struct page
Message-ID: <20180503001111.GA21199@bombadil.infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-14-willy@infradead.org>
 <20180502081217.guqf6phmwnnw5t2q@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502081217.guqf6phmwnnw5t2q@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Wed, May 02, 2018 at 11:12:17AM +0300, Kirill A. Shutemov wrote:
> On Mon, Apr 30, 2018 at 01:22:44PM -0700, Matthew Wilcox wrote:
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index e0e74e91f3e8..0e6117123737 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -134,7 +134,7 @@ struct page {
> >  			unsigned long _pt_pad_1;	/* compound_head */
> >  			pgtable_t pmd_huge_pte; /* protected by page->ptl */
> >  			unsigned long _pt_pad_2;	/* mapping */
> > -			unsigned long _pt_pad_3;
> > +			struct mm_struct *pt_mm;
> 
> I guess it worth to have a comment that this field is only used of pgd
> page tables and therefore doesn't conflict with pmd_huge_pte.

Actually, it doesn't conflict with pmd_huge_pte -- it's in different
bits (both before and after this patch).  What does 'conflict' with
pmd_huge_pte is the use of page->lru in the pgd.  I have a plan to
eliminate that use of pgd->lru, but I need to do a couple of other
things first.
