Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F021B6B0274
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 22:11:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g66so8847522pfj.11
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 19:11:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f6si6553940pgr.690.2018.03.30.19.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Mar 2018 19:11:19 -0700 (PDT)
Date: Fri, 30 Mar 2018 19:11:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v10 43/62] memfd: Convert shmem_tag_pins to XArray
Message-ID: <20180331021111.GB13332@bombadil.infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
 <20180330034245.10462-44-willy@infradead.org>
 <39ea3393-c3d7-07c3-a072-344f3a65cef3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39ea3393-c3d7-07c3-a072-344f3a65cef3@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>

On Fri, Mar 30, 2018 at 05:05:05PM -0700, Mike Kravetz wrote:
> On 03/29/2018 08:42 PM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Simplify the locking by taking the spinlock while we walk the tree on
> > the assumption that many acquires and releases of the lock will be
> > worse than holding the lock for a (potentially) long time.
> 
> I see this change made in several of the patches and do not have a
> specific issue with it.  As part of the XArray implementation you
> have XA_CHECK_SCHED = 4096.   So, we drop locks and do a cond_resched
> after XA_CHECK_SCHED iterations.  Just curious how you came up with
> that number.  Apologies in advance if this was discussed in a previous
> round of reviews.

It comes from two places, the current implementations of
tag_pages_for_writeback() and find_swap_entry().  I have no idea if it's
the optimal number for anybody, but it's the only number that anyone
was using.  I'll have no problem if somebody suggests we tweak the number
in the future.

> I did not do a detailed review of the XArray implementation.  Only looked
> at the provided interfaces and their intended uses.  If the interfaces work
> as specified, the changes here are fine.
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

That is all I can ask for, and it's the most valuable thing.  Thanks,
Mike!
