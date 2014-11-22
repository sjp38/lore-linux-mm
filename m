Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 25CAA6B0069
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 15:04:02 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7122897pab.0
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 12:04:01 -0800 (PST)
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com. [209.85.220.41])
        by mx.google.com with ESMTPS id ug5si14803083pac.3.2014.11.22.12.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 12:04:00 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7055542pab.14
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 12:04:00 -0800 (PST)
Date: Sat, 22 Nov 2014 12:03:57 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 5/5] btrfs: enable swap file support
Message-ID: <20141122200357.GA15189@mew>
References: <cover.1416563833.git.osandov@osandov.com>
 <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com>
 <20141121180045.GF8568@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121180045.GF8568@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Sterba <dsterba@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On Fri, Nov 21, 2014 at 07:00:45PM +0100, David Sterba wrote:
> > +			pr_err("BTRFS: swapfile has holes");
> > +			ret = -EINVAL;
> > +			goto out;
> > +		}
> > +		if (em->block_start == EXTENT_MAP_INLINE) {
> > +			pr_err("BTRFS: swapfile is inline");
> 
> While the test is valid, this would mean that the file is smaller than
> the inline limit, which is now one page. I think the generic swap code
> would refuse such a small file anyway.
> 
Sure. This test doesn't really cost us anything, so I think I'd feel a little
better just leaving it in. I'll add a comment for the next close reader.

Besides that and Filipe's response, I'll address everything you mentioned here
and in your other email in the next version, thanks.

> > +			ret = -EINVAL;
> > +			goto out;
> > +		}
> > +		if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags)) {
> > +			pr_err("BTRFS: swapfile is compresed");
> > +			ret = -EINVAL;
> > +			goto out;
> > +		}
> 
> I think the preallocated extents should be refused as well. This means
> the filesystem has enough space to hold the data but it would still have
> to go through the allocation and could in turn stress the memory
> management code that triggered the swapping activity in the first place.
> 
> Though it's probably still possible to reach such corner case even with
> fully allocated nodatacow file, this should be reviewed anyway.
> 
I'll definitely take a closer look at this. In particular,
btrfs_get_blocks_direct and btrfs_get_extent do allocations in some cases which
I'll look into.

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
