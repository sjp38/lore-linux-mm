Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC05C6B321D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 12:59:34 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h86-v6so5521794pfd.2
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:59:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3-v6si53519829plz.12.2018.11.23.09.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Nov 2018 09:59:33 -0800 (PST)
Date: Fri, 23 Nov 2018 09:59:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: Remove redundant test from find_get_pages_contig
Message-ID: <20181123175932.GV3065@bombadil.infradead.org>
References: <20181122213224.12793-1-willy@infradead.org>
 <20181122213224.12793-2-willy@infradead.org>
 <20181123104732.gvhdqyddbsiq3i42@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123104732.gvhdqyddbsiq3i42@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Fri, Nov 23, 2018 at 01:47:32PM +0300, Kirill A. Shutemov wrote:
> On Thu, Nov 22, 2018 at 01:32:23PM -0800, Matthew Wilcox wrote:
> > After we establish a reference on the page, we check the pointer continues
> > to be in the correct position in i_pages.  There's no need to check the
> > page->mapping or page->index afterwards; if those can change after we've
> > got the reference, they can change after we return the page to the caller.
> 
> Hm. IIRC, page->mapping can be set to NULL due truncation, but what about
> index? When it can be changed? Truncation doesn't touch it.

I think index can only be changed after the refcount has hit zero and
the page is safely out of the pagecache.  I agree that page->mapping can
be set to NULL after the call to xas_reload() ... but then it can also
happen after the check, so the check isn't really buying us anything
that the xas_reload() call doesn't already check.
