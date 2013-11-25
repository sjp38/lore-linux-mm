Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6B66B00DC
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 13:00:38 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so3101901yha.14
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:00:38 -0800 (PST)
Received: from mail-oa0-x22a.google.com (mail-oa0-x22a.google.com [2607:f8b0:4003:c02::22a])
        by mx.google.com with ESMTPS id o35si4615063yhp.291.2013.11.25.10.00.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 10:00:37 -0800 (PST)
Received: by mail-oa0-f42.google.com with SMTP id i4so4772007oah.1
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:00:36 -0800 (PST)
Date: Mon, 25 Nov 2013 12:00:30 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
Message-ID: <20131125180030.GA23396@cerebellum.variantweb.net>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
 <20131122172916.GB6477@cerebellum.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131122172916.GB6477@cerebellum.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Fri, Nov 22, 2013 at 11:29:16AM -0600, Seth Jennings wrote:
> On Wed, Nov 20, 2013 at 02:49:33PM -0500, Dan Streetman wrote:
> > Currently, zswap is writeback cache; stored pages are not sent
> > to swap disk, and when zswap wants to evict old pages it must
> > first write them back to swap cache/disk manually.  This avoids
> > swap out disk I/O up front, but only moves that disk I/O to
> > the writeback case (for pages that are evicted), and adds the
> > overhead of having to uncompress the evicted pages, and adds the
> > need for an additional free page (to store the uncompressed page)
> > at a time of likely high memory pressure.  Additionally, being
> > writeback adds complexity to zswap by having to perform the
> > writeback on page eviction.
> > 
> > This changes zswap to writethrough cache by enabling
> > frontswap_writethrough() before registering, so that any
> > successful page store will also be written to swap disk.  All the
> > writeback code is removed since it is no longer needed, and the
> > only operation during a page eviction is now to remove the entry
> > from the tree and free it.
> 
> I like it.  It gets rid of a lot of nasty writeback code in zswap.
> 
> I'll have to test before I ack, hopefully by the end of the day.
> 
> Yes, this will increase writes to the swap device over the delayed
> writeback approach.  I think it is a good thing though.  I think it
> makes the difference between zswap and zram, both in operation and in
> application, more apparent. Zram is the better choice for embedded where
> write wear is a concern, and zswap being better if you need more
> flexibility to dynamically manage the compressed pool.

One thing I realized while doing my testing was that making zswap
writethrough also impacts synchronous reclaim.  Zswap, as it is now,
makes the swapcache page clean during swap_writepage() which allows
shrink_page_list() to immediately reclaim it.  Making zswap writethrough
eliminates this advantage and swapcache pages must be scanned again
before they can be reclaimed, as is the case with normal swapping.

Just something I am thinking about.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
