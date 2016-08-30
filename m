Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43AF26B029B
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 03:21:35 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vd14so23929352pab.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 00:21:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id g79si43813684pfb.219.2016.08.30.00.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 00:21:33 -0700 (PDT)
Date: Tue, 30 Aug 2016 00:21:29 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160830072129.GA10997@infradead.org>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829125741.cdnbb2uaditcmnw2@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Mon, Aug 29, 2016 at 08:57:41AM -0400, Theodore Ts'o wrote:
> It's been on my todo list.  The only reason why I haven't done it yet
> is because I knew you were working on a solution, and I didn't want to
> do things one way for buffered I/O, and a different way for Direct
> I/O, and disentangling the DIO code and the different assumptions of
> how different file systems interact with the DIO code is a *mess*.

It is.  I have an almost working iomap direct I/O implementation, which
simplifies a lot of this.  Partially because it expects sane locking
(a shared lock should be held over read, fortunately we now have i_rwsem
for that) and allows less opt-in/out behavior, and partially just
because we have so much better infrastructure now (iomap, bio chaining,
iov_iters, ...).

The iomap version is still work in progress, but I'm about to post
a cut down version for block devices which reduces I/O latency by
20%.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
