In-reply-to: <alpine.LFD.1.10.0806250757150.4733@hp.linux-foundation.org>
	(message from Linus Torvalds on Wed, 25 Jun 2008 08:11:07 -0700 (PDT))
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in
 invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <alpine.LFD.1.10.0806250757150.4733@hp.linux-foundation.org>
Message-Id: <E1KBWwW-0006nf-Qp@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 25 Jun 2008 17:29:56 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > Clearing the uptodate page flag will cause page_cache_pipe_buf_confirm()
> > to return -ENODATA if that page was in the buffer.  This in turn will cause
> > splice() to return a short or zero count.
> 
> I really think we should just change splice itself at this point.

We discussed this yesterday.  My conclusion was (which I still think
is true) that it can't be fixed in page_cache_pipe_buf_confirm(),
because due to current practice of not setting PG_error for I/O errors
for read, it is impossible to distinguish between a never-been-uptodate
page and a was-uptodate-before-invalidation page.

And it's not just an nfsd issue.  Userspace might also expect that if
a zero count is returned, that means it went beyond EOF, and not that
it should retry the splice, maybe it has better luck this time.

So no, this is not just a fuse/nfsd issue, it applies to all
filesystems that do invalidate_inode_pages2 (there are 4-5 of them I
think).

And I don't see what I would be ignoring.  This is _not_ about
truncate(2), that is shared by all filesystems, and bugs wrt splice
would affect not just fuse.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
