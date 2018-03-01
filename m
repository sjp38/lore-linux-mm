Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62BDF6B0008
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 09:40:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 26so4816176qkx.11
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 06:40:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 21si1157732qtz.64.2018.03.01.06.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 06:40:01 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w21Ecc29030277
	for <linux-mm@kvack.org>; Thu, 1 Mar 2018 09:40:01 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gek14sdvk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Mar 2018 09:40:00 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 1 Mar 2018 14:39:58 -0000
Date: Thu, 1 Mar 2018 15:39:52 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3 1/4] s390: Use _refcount for pgtables
In-Reply-To: <20180301142855.emaa5x65oj2hkwsm@node.shutemov.name>
References: <20180228223157.9281-1-willy@infradead.org>
	<20180228223157.9281-2-willy@infradead.org>
	<20180301125310.jx6c5dypk5axrmum@node.shutemov.name>
	<20180301150420.19a14fd3@mschwideX1>
	<20180301142855.emaa5x65oj2hkwsm@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20180301153952.668bfdc7@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Thu, 1 Mar 2018 17:28:55 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Thu, Mar 01, 2018 at 03:04:20PM +0100, Martin Schwidefsky wrote:
> > On Thu, 1 Mar 2018 15:53:10 +0300
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >   
> > > On Wed, Feb 28, 2018 at 02:31:54PM -0800, Matthew Wilcox wrote:  
> > > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > > 
> > > > s390 borrows the storage used for _mapcount in struct page in order to
> > > > account whether the bottom or top half is being used for 2kB page
> > > > tables.  I want to use that for something else, so use the top byte of
> > > > _refcount instead of the bottom byte of _mapcount.  _refcount may
> > > > temporarily be incremented by other CPUs that see a stale pointer to
> > > > this page in the page cache, but each CPU can only increment it by one,
> > > > and there are no systems with 2^24 CPUs today, so they will not change
> > > > the upper byte of _refcount.  We do have to be a little careful not to
> > > > lose any of their writes (as they will subsequently decrement the
> > > > counter).    
> > > 
> > > Hm. I'm more worried about false-negative put_page_testzero().
> > > Are you sure it won't lead to leaks. I cannot say from the code changes.
> > > 
> > > And for page-table pages should have planty space in other fields.
> > > IIRC page->mapping is unused there.  
> >  
> > 2^^24 put_page_testzero calls for page table pages? I don't think so.  
> 
> No, I mean oposite: we don't free the page when we should. 2^24 is not
> zero and page won't be freed if the acctual refcount (without the flag in
> upper bits) drops to zero.

Ah, ok. But this is not a problem as the page is freed after both bits for
the two 2K pieces havbe been set to zero.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
