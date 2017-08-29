Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D759D6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 08:31:31 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q16so6069652pgc.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 05:31:31 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id 79si1226543pgb.647.2017.08.29.05.31.29
        for <linux-mm@kvack.org>;
        Tue, 29 Aug 2017 05:31:30 -0700 (PDT)
Date: Tue, 29 Aug 2017 22:31:26 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170829123126.GB10621@dastard>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170829081453.GA10196@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829081453.GA10196@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Tue, Aug 29, 2017 at 01:14:53AM -0700, Christoph Hellwig wrote:
> One thing I've been wondering is wether we should actually just
> get rid of the online area.  Compared to reading an inode from
> disk a single additional kmalloc is negligible, and not having the
> inline data / extent list would allow us to reduce the inode size
> significantly.

Probably should.  I've already been looking at killing the inline
extents array to simplify the management of the extent list (much
simpler to index by rbtree when we don't have direct/indirect
structures), so killing the inline data would get rid of the other
part of the union the inline data sits in.

OTOH, if we're going to have to dynamically allocate the memory for
the extent/inline data for the data fork, it may just be easier to
make the entire data fork a dynamic allocation (like the attr fork).

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
