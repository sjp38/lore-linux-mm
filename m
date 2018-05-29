Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41D026B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 13:04:09 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x134-v6so9034453oif.19
        for <linux-mm@kvack.org>; Tue, 29 May 2018 10:04:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 62-v6si11821776otw.195.2018.05.29.10.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 10:04:08 -0700 (PDT)
Date: Tue, 29 May 2018 13:04:04 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180529170403.GA107867@bfoster.bfoster>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-23-hch@lst.de>
 <20180524145935.GA84959@bfoster.bfoster>
 <20180524165350.GA22675@lst.de>
 <20180524181356.GA89391@bfoster.bfoster>
 <20180525061900.GA16409@lst.de>
 <20180525113532.GA92036@bfoster.bfoster>
 <20180528071543.GA5428@lst.de>
 <20180529112630.GA107328@bfoster.bfoster>
 <20180529130846.GA8205@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529130846.GA8205@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Tue, May 29, 2018 at 03:08:46PM +0200, Christoph Hellwig wrote:
> On Tue, May 29, 2018 at 07:26:31AM -0400, Brian Foster wrote:
> > What exactly is the trivial check? Can you show the code please?
> 
> ASSERT(file_offset > i_size_read(inode)) in the !count block
> at the end of xfs_writepage_map.
> 
> (file_offset replaced with page_offset(page) + offset for the mainline
> code).

Ok, so we (mainline) somehow or another end up in writeback with a page
(inside EOF) with a combination of (!mapped && !uptodate) and (!mapped
&& uptodate) (unwritten?) buffers, none of them actually being dirty.
I'm not quite sure how that happens, but I think it does rule out the
count == 0 && at least one uptodate segment logic I proposed earlier.

Fair enough. Given that, I'm not sure there's a good way to trigger such
error detection without actual dirty state, and it's certainly not worth
complicating the design just for that. Thanks for trying, at least.

Hmm, that does have me wondering a bit if/how we'd end up writing back
zeroed blocks over unwritten extents with no other dirty user data in
the page (since the initial xfs_writepage_map() rework patch factors out
the uptodate && !mapped skipping logic).

Brian

> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
