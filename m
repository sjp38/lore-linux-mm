Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB6B6B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 02:17:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j14-v6so592250wro.7
        for <linux-mm@kvack.org>; Tue, 29 May 2018 23:17:20 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b4-v6si8483277wra.300.2018.05.29.23.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 23:17:19 -0700 (PDT)
Date: Wed, 30 May 2018 08:23:37 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 15/34] iomap: add an iomap-based readpage and readpages
	implementation
Message-ID: <20180530062337.GA25732@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-16-hch@lst.de> <20180530061146.GD30110@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530061146.GD30110@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 29, 2018 at 11:11:46PM -0700, Darrick J. Wong wrote:
> > +		list_del(&page->lru);
> > +		if (!add_to_page_cache_lru(page, inode->i_mapping, page->index,
> > +				GFP_NOFS))
> 
> I'm curious about this line -- if add_to_page_cache_lru returns an
> error, why don't we want to send that back up the stack?  Is the idea
> that the page doesn't become uptodate and something else notices?   It
> seems a little odd that on error we just skip to the next page.
> 
> (If this /is/ correct then comment is needed here.)

readpages is only used for read-ahead, so the upper layers literally
don't care as long as we don't mess up the page refcount.  This logic
is taken straight from mpage_readpages, but I'll add a comment anyway.
