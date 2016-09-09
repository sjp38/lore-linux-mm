Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87DDD6B0253
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 12:48:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so35534532pfb.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 09:48:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id pb1si4637512pac.1.2016.09.09.09.48.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 09:48:23 -0700 (PDT)
Date: Fri, 9 Sep 2016 10:48:08 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160909164808.GC18554@linux.intel.com>
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
> On Mon, Aug 29, 2016 at 12:41:16AM -0700, Christoph Hellwig wrote:
> > 
> > We're going to move forward killing buffer_heads in XFS.  I think ext4
> > would dramatically benefit from this a well, as would ext2 (although I
> > think all that DAX work in ext2 is a horrible idea to start with).
> 
> It's been on my todo list.  The only reason why I haven't done it yet
> is because I knew you were working on a solution, and I didn't want to
> do things one way for buffered I/O, and a different way for Direct
> I/O, and disentangling the DIO code and the different assumptions of
> how different file systems interact with the DIO code is a *mess*.
> 
> It may have gotten better more recently, but a few years ago I took a
> look at it and backed slowly away.....

Ted, what do you think of the idea of moving to struct iomap in ext2?

If ext2 stays with the current struct buffer_head + get_block_t interface,
then it looks like DAX basically has three options:

1) Support two I/O paths and two versions of each of the fault paths (PTE,
PMD, etc).  One of each of these would be based on struct iomap and would be
used by xfs and potentially ext4, and the other would be based on struct
buffer_head + get_block_t and would be used by ext2.

2) Only have a single struct iomap based I/O path and fault path, and add
shim/support code so that ext2 can use it, leaving the rest of ext2 to be
struct buffer_head + get_block_t based.

3) Only have a single struct buffer_head + get_block_t based DAX I/O and fault
path, and have XFS and potentially ext4 do the translation from their native
struct iomap interface.

It seems ideal for ext2 to switch along with everyone else, if getting rid of
struct buffer_head is a global goal.  If not, I guess barring technical issues
#2 above seems cleanest - move DAX to the new structure, and provide backwards
compatibility to ext2.  Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
