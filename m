Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAA4A6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:26:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so13053858pge.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:26:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x128si28142598pfd.87.2017.01.18.03.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 03:26:23 -0800 (PST)
Date: Wed, 18 Jan 2017 03:26:07 -0800
From: willy@bombadil.infradead.org
Subject: Re: [Lsf-pc] [ATTEND] many topics
Message-ID: <20170118112605.GC29472@bombadil.infradead.org>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118101343.GC24789@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118101343.GC24789@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 18, 2017 at 11:13:43AM +0100, Jan Kara wrote:
> On Tue 17-01-17 21:49:45, Matthew Wilcox wrote:
> > 1. Exploiting multiorder radix tree entries.  I believe we would do well
> > to attempt to allocate compound pages, insert them into the page cache,
> > and expect filesystems to be able to handle filling compound pages with
> > ->readpage.  It will be more efficient because alloc_pages() can return
> > large entries out of the buddy list rather than breaking them down,
> > and it'll help reduce fragmentation.
> 
> Kirill has patches to do this and I don't like the complexity it adds to
> pagecache handling code and each filesystem that would like to support
> this. I don't have objections to the general idea but the complexity of the
> current implementation just looks too big to me...

Interesting.  Dave Chinner opined to me today that it was about 20 lines
of code in XFS, so somebody is missing something.

> > 2. Supporting filesystem block sizes > page size.  Once we do the above
> > for efficiency, I think it then becomes trivial to support, eg 16k block
> > size filesystems on x86 machines with 4k pages.
> 
> Heh, you wish... :) There's a big difference between opportunistically
> allocating a huge page and reliably have to provide high order page. Memory
> fragmentation issues will be difficult to deal with...

If you're mixing a lot of order-0 allocations with a few order-4
allocations, then yes memory fragmentation may become a problem.  But if
you're doing a lot of order-4 allocations, then it should be possible
to free an order-4 allocation from the inactive list of one of the files
on the 64k filesystem.

Somewhat related, and this question was asked during my talk today so
I should have mentioned it in the email, should order-9 pages on the
inactive list be treated differently from order-0 entries?  I suspect
the answer is yes, because there's probably little point in freeing
order-9 page off the LRU list in order to satisfy a order-9 allocation;
we should just find an order-9 page and free it.  Likewise, freeing an
order-9 page in order to satisfy an order-0 allocation is going to lead
to fragmentation and should probably be avoided.

I suspect order-0 and order-9 entries can be profitably mixed on the
active list, but it might be better to have separate LRU lists for normal
and huge pages.  Does it make sense to have one LRU list per order?
Maybe not go quite that far, but organising the inactive list by size
seems to have some merit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
