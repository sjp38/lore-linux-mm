Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA248E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:12:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z18-v6so3152904pfe.19
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:12:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y83-v6sor3370458pfa.107.2018.09.19.11.12.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 11:12:05 -0700 (PDT)
Date: Wed, 19 Sep 2018 11:12:02 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v7 1/6] mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
Message-ID: <20180919181202.GJ479@vader>
References: <cover.1536704650.git.osandov@fb.com>
 <6d63d8668c4287a4f6d203d65696e96f80abdfc7.1536704650.git.osandov@fb.com>
 <20180919180232.GB18068@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919180232.GB18068@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Wed, Sep 19, 2018 at 02:02:32PM -0400, Johannes Weiner wrote:
> On Tue, Sep 11, 2018 at 03:34:44PM -0700, Omar Sandoval wrote:
> > @@ -2411,8 +2412,10 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
> >  
> >  	if (mapping->a_ops->swap_activate) {
> >  		ret = mapping->a_ops->swap_activate(sis, swap_file, span);
> > +		if (ret >= 0)
> > +			sis->flags |= SWP_ACTIVATED;
> >  		if (!ret) {
> > -			sis->flags |= SWP_FILE;
> > +			sis->flags |= SWP_FS;
> >  			ret = add_swap_extent(sis, 0, sis->max, 0);
> 
> Won't this single, linear extent be in conflict with the discontiguous
> extents you set up in your swap_activate callback in the last patch?

That's only in the case that ->swap_activate() returned 0, which only
nfs_swap_activate() will do. btrfs_swap_activate() and
iomap_swapfile_activate() both return the number of extents they set up.
