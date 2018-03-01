Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8AB46B000C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 07:53:23 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e74so3445295wmg.0
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 04:53:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k23sor2509102edb.7.2018.03.01.04.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 04:53:22 -0800 (PST)
Date: Thu, 1 Mar 2018 15:53:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 1/4] s390: Use _refcount for pgtables
Message-ID: <20180301125310.jx6c5dypk5axrmum@node.shutemov.name>
References: <20180228223157.9281-1-willy@infradead.org>
 <20180228223157.9281-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180228223157.9281-2-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org

On Wed, Feb 28, 2018 at 02:31:54PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> s390 borrows the storage used for _mapcount in struct page in order to
> account whether the bottom or top half is being used for 2kB page
> tables.  I want to use that for something else, so use the top byte of
> _refcount instead of the bottom byte of _mapcount.  _refcount may
> temporarily be incremented by other CPUs that see a stale pointer to
> this page in the page cache, but each CPU can only increment it by one,
> and there are no systems with 2^24 CPUs today, so they will not change
> the upper byte of _refcount.  We do have to be a little careful not to
> lose any of their writes (as they will subsequently decrement the
> counter).

Hm. I'm more worried about false-negative put_page_testzero().
Are you sure it won't lead to leaks. I cannot say from the code changes.

And for page-table pages should have planty space in other fields.
IIRC page->mapping is unused there.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
