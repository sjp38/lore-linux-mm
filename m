Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8CC6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:43:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b75so20412872lfg.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:43:57 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 100si3136910lfx.27.2016.10.11.14.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 14:43:55 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l131so2705931lfl.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:43:55 -0700 (PDT)
Date: Wed, 12 Oct 2016 00:43:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 11/41] thp: try to free page's buffers before attempt
 split
Message-ID: <20161011214353.GA27110@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-12-kirill.shutemov@linux.intel.com>
 <20161011154031.GK6952@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011154031.GK6952@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Oct 11, 2016 at 05:40:31PM +0200, Jan Kara wrote:
> On Thu 15-09-16 14:54:53, Kirill A. Shutemov wrote:
> > We want page to be isolated from the rest of the system before spliting
> > it. We rely on page count to be 2 for file pages to make sure nobody
> > uses the page: one pin to caller, one to radix-tree.
> > 
> > Filesystems with backing storage can have page count increased if it has
> > buffers.
> > 
> > Let's try to free them, before attempt split. And remove one guarding
> > VM_BUG_ON_PAGE().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ...
> > @@ -2041,6 +2041,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
> > +			wait_on_page_writeback(head);
> > +
> > +			if (page_has_buffers(head) &&
> > +					!try_to_free_buffers(head)) {
> > +				ret = -EBUSY;
> > +				goto out;
> > +			}
> 
> Shouldn't you rather use try_to_release_page() here? Because filesystems
> have their ->releasepage() callbacks for freeing data associated with a
> page. It is not guaranteed page private data are buffers although it is
> true for ext4...

Fair enough. Will fix this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
