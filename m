Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9366B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 13:05:43 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b22so768530287pfd.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:05:43 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e5si6486434pgd.111.2017.01.11.10.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 10:05:42 -0800 (PST)
Date: Wed, 11 Jan 2017 10:05:37 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] sharing pages between mappings
Message-ID: <20170111180537.GA10498@birch.djwong.org>
References: <CAJfpegv9EhT4Y3QjTZBHoMKSiVGtfmTGPhJp_rh3a7=rFCHu5A@mail.gmail.com>
 <20170111115143.GJ16116@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111115143.GJ16116@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Wed, Jan 11, 2017 at 12:51:43PM +0100, Jan Kara wrote:
> On Wed 11-01-17 11:29:28, Miklos Szeredi wrote:
> > I know there's work on this for xfs, but could this be done in generic mm
> > code?
> > 
> > What are the obstacles?  page->mapping and page->index are the obvious
> > ones.
> 
> Yes, these two are the main that come to my mind. Also you'd need to
> somehow share the mapping->i_mmap tree so that unmap_mapping_range() works.
> 
> > If that's too difficult is it maybe enough to share mappings between
> > files while they are completely identical and clone the mapping when
> > necessary?
> 
> Well, but how would the page->mapping->host indirection work? Even if you
> have identical contents of the mappings, you still need to be aware there
> are several inodes behind them and you need to pick the right one
> somehow...
> 
> > All COW filesystems would benefit, as well as layered ones: lots of
> > fuse fs, and in some cases overlayfs too.
> > 
> > Related:  what can DAX do in the presence of cloned block?
> 
> For DAX handling a block COW should be doable if that is what you are
> asking about. Handling of blocks that can be written to while they are
> shared will be rather difficult (you have problems with keeping dirty bits
> in the radix tree consistent if nothing else).

I'm also interested in this topic, though I haven't gotten any further
than a hand-wavy notion of handling cow by allocating new blocks, memcpy
the contents to the new blocks (how?), then update the mappings to point
to the new blocks (how?).  It looks a lot easier now with the iomap
stuff, but that's as far as I got. :)

(IOWs it basically took all the time since the last LSF to get reflink
polished enough to handle regular files reasonably well.)

--D

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
