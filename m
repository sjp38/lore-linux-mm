Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 36EA16B02D7
	for <linux-mm@kvack.org>; Fri, 25 May 2018 02:13:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 33-v6so3226966wrb.12
        for <linux-mm@kvack.org>; Thu, 24 May 2018 23:13:26 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y18-v6si19274985wrm.276.2018.05.24.23.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 23:13:22 -0700 (PDT)
Date: Fri, 25 May 2018 08:19:00 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180525061900.GA16409@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-23-hch@lst.de> <20180524145935.GA84959@bfoster.bfoster> <20180524165350.GA22675@lst.de> <20180524181356.GA89391@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524181356.GA89391@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 24, 2018 at 02:13:56PM -0400, Brian Foster wrote:
> Ok, so I guess writeback can see uptodate blocks over a hole if some
> other block in that page is dirty.

Yes.

> Perhaps we could make sure that a
> dirty page has at least one block that maps to an actual extent or
> otherwise the page has been truncated..?

We have the following comment near the end of xfs_writepage_map:

	/*
	 * We can end up here with no error and nothing to write if we
	 * race with a partial page truncate on a sub-page block sized
	 * filesystem. In that case we need to mark the page clean.
	 */

And I'm pretty sure I managed to hit that case easily in xfstests,
as my initial handling of it was wrong.  So I don't think we can
even check for that.

> I guess having another dirty block bitmap similar to
> iomap_page->uptodate could be required to tell for sure whether a
> particular block should definitely have a block on-disk or not. It may
> not be worth doing that just for additional error checks, but I still
> have to look into the last few patches to grok all the iomap_page stuff.

I don't think it's worth it.  The sub-page dirty tracking has been one
of the issues with the buffer head code that caused a lot of problems,
and that we want to get rid of.
