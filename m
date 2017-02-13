Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDAF6B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 09:32:50 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u63so248866wmu.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:32:50 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id o92si14081766wrb.25.2017.02.13.06.32.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 06:32:49 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id c85so19855239wmi.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:32:49 -0800 (PST)
Date: Mon, 13 Feb 2017 17:32:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 05/37] thp: try to free page's buffers before attempt
 split
Message-ID: <20170213143247.GC20394@node.shutemov.name>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-6-kirill.shutemov@linux.intel.com>
 <20170209201416.GS2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209201416.GS2267@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Feb 09, 2017 at 12:14:16PM -0800, Matthew Wilcox wrote:
> On Thu, Jan 26, 2017 at 02:57:47PM +0300, Kirill A. Shutemov wrote:
> > @@ -2146,6 +2146,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
> >  			goto out;
> >  		}
> >  
> > +		/* Try to free buffers before attempt split */
> > +		if (!PageSwapBacked(head) && PagePrivate(page)) {
> > +			/*
> > +			 * We cannot trigger writeback from here due possible
> > +			 * recursion if triggered from vmscan, only wait.
> > +			 *
> > +			 * Caller can trigger writeback it on its own, if safe.
> > +			 */
> 
> It took me a few reads to get this.  May I suggest:
> 
> 		/*
> 		 * Cannot split a page with buffers.  If the caller has
> 		 * already started writeback, we can wait for it to finish,
> 		 * but we cannot start writeback if we were called from vmscan
> 		 */

Yeah, that's better.

> > +		if (!PageSwapBacked(head) && PagePrivate(page)) {
> 
> Also, it looks weird to test PageSwapBacked of *head* and PagePrivate
> of *page*.  I think it's correct, but it still looks weird.

I'll change this.

> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

Thanks!

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
