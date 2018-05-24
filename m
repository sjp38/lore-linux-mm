Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAFE86B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 03:56:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e26-v6so620988wmh.7
        for <linux-mm@kvack.org>; Thu, 24 May 2018 00:56:14 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m18-v6si18050014wrm.146.2018.05.24.00.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 00:56:13 -0700 (PDT)
Date: Thu, 24 May 2018 10:01:43 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 19/34] xfs: simplify xfs_bmap_punch_delalloc_range
Message-ID: <20180524080143.GA11149@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-20-hch@lst.de> <20180523161710.GA33498@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523161710.GA33498@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 12:17:11PM -0400, Brian Foster wrote:
> Mostly looks Ok, but I'm not following what this get_extent() call is
> for..? It also doesn't look like it would always do the right thing with
> sub-page blocks. Consider a page with a couple discontig delalloc blocks
> that happen to be the first extents in the file. The first
> xfs_bmap_del_extent_delay() would do:
> 
> 	xfs_iext_remove(ip, icur, state);
> 	xfs_iext_prev(ifp, icur);
> 
> ... which I think sets cur->pos to -1, causes the get_extent() to fail
> and thus fails to remove the subsequent delalloc blocks. Hm?

True.  This function should probably walk the extent list backwards
like xfs_bunmapi as that is the model that xfs_bmap_del_extent_* is
built around.
