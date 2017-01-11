Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEBA86B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:51:46 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so83499727wjb.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 03:51:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tj12si4366002wjb.134.2017.01.11.03.51.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 03:51:45 -0800 (PST)
Date: Wed, 11 Jan 2017 12:51:43 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] sharing pages between mappings
Message-ID: <20170111115143.GJ16116@quack2.suse.cz>
References: <CAJfpegv9EhT4Y3QjTZBHoMKSiVGtfmTGPhJp_rh3a7=rFCHu5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegv9EhT4Y3QjTZBHoMKSiVGtfmTGPhJp_rh3a7=rFCHu5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Wed 11-01-17 11:29:28, Miklos Szeredi wrote:
> I know there's work on this for xfs, but could this be done in generic mm
> code?
> 
> What are the obstacles?  page->mapping and page->index are the obvious
> ones.

Yes, these two are the main that come to my mind. Also you'd need to
somehow share the mapping->i_mmap tree so that unmap_mapping_range() works.

> If that's too difficult is it maybe enough to share mappings between
> files while they are completely identical and clone the mapping when
> necessary?

Well, but how would the page->mapping->host indirection work? Even if you
have identical contents of the mappings, you still need to be aware there
are several inodes behind them and you need to pick the right one
somehow...

> All COW filesystems would benefit, as well as layered ones: lots of
> fuse fs, and in some cases overlayfs too.
> 
> Related:  what can DAX do in the presence of cloned block?

For DAX handling a block COW should be doable if that is what you are
asking about. Handling of blocks that can be written to while they are
shared will be rather difficult (you have problems with keeping dirty bits
in the radix tree consistent if nothing else).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
