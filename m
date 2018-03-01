Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9196B000D
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 10:03:11 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id f143so4893312qke.12
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 07:03:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e56si4644433qtk.321.2018.03.01.07.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 07:03:10 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w21F0qWg112602
	for <linux-mm@kvack.org>; Thu, 1 Mar 2018 10:03:09 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gek14th8e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Mar 2018 10:03:08 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 1 Mar 2018 15:03:03 -0000
Date: Thu, 1 Mar 2018 16:02:58 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3 0/4] Split page_type out from mapcount
In-Reply-To: <20180301145058.GA19662@bombadil.infradead.org>
References: <20180228223157.9281-1-willy@infradead.org>
	<20180301081750.42b135c3@mschwideX1>
	<20180301124412.gm6jxwzyfskzxspa@node.shutemov.name>
	<20180301145058.GA19662@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20180301160258.6a619212@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Thu, 1 Mar 2018 06:50:58 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> On Thu, Mar 01, 2018 at 03:44:12PM +0300, Kirill A. Shutemov wrote:
> > On Thu, Mar 01, 2018 at 08:17:50AM +0100, Martin Schwidefsky wrote:  
> > > Yeah, that is a nasty bit of code. On s390 we have 2K page tables (pte)
> > > but 4K pages. If we use full pages for the pte tables we waste 2K of
> > > memory for each of the tables. So we allocate 4K and split it into two
> > > 2K pieces. Now we have to keep track of the pieces to be able to free
> > > them again.  
> > 
> > Have you considered to use slab for page table allocation instead?
> > IIRC some architectures practice this already.  
> 
> You're not allowed to do that any more.  Look at pgtable_page_ctor(),
> or rather ptlock_init().

Oh yes, I forgot about the ptl. This takes up some fields in struct page
which the slab/slub cache want to use as well.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
