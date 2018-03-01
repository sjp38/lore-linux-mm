Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 777C16B000C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 09:29:08 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 5so4251073wrb.15
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 06:29:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor2851327edj.56.2018.03.01.06.29.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 06:29:06 -0800 (PST)
Date: Thu, 1 Mar 2018 17:28:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 1/4] s390: Use _refcount for pgtables
Message-ID: <20180301142855.emaa5x65oj2hkwsm@node.shutemov.name>
References: <20180228223157.9281-1-willy@infradead.org>
 <20180228223157.9281-2-willy@infradead.org>
 <20180301125310.jx6c5dypk5axrmum@node.shutemov.name>
 <20180301150420.19a14fd3@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301150420.19a14fd3@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Thu, Mar 01, 2018 at 03:04:20PM +0100, Martin Schwidefsky wrote:
> On Thu, 1 Mar 2018 15:53:10 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Wed, Feb 28, 2018 at 02:31:54PM -0800, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > s390 borrows the storage used for _mapcount in struct page in order to
> > > account whether the bottom or top half is being used for 2kB page
> > > tables.  I want to use that for something else, so use the top byte of
> > > _refcount instead of the bottom byte of _mapcount.  _refcount may
> > > temporarily be incremented by other CPUs that see a stale pointer to
> > > this page in the page cache, but each CPU can only increment it by one,
> > > and there are no systems with 2^24 CPUs today, so they will not change
> > > the upper byte of _refcount.  We do have to be a little careful not to
> > > lose any of their writes (as they will subsequently decrement the
> > > counter).  
> > 
> > Hm. I'm more worried about false-negative put_page_testzero().
> > Are you sure it won't lead to leaks. I cannot say from the code changes.
> > 
> > And for page-table pages should have planty space in other fields.
> > IIRC page->mapping is unused there.
>  
> 2^^24 put_page_testzero calls for page table pages? I don't think so.

No, I mean oposite: we don't free the page when we should. 2^24 is not
zero and page won't be freed if the acctual refcount (without the flag in
upper bits) drops to zero.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
