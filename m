Date: Wed, 25 Jun 2008 09:30:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in
 invalidate_complete_page2()
In-Reply-To: <E1KBWwW-0006nf-Qp@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0806250928460.4769@hp.linux-foundation.org>
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <alpine.LFD.1.10.0806250757150.4733@hp.linux-foundation.org> <E1KBWwW-0006nf-Qp@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>


On Wed, 25 Jun 2008, Miklos Szeredi wrote:
> 
> We discussed this yesterday.  My conclusion was (which I still think
> is true) that it can't be fixed in page_cache_pipe_buf_confirm(),
> because due to current practice of not setting PG_error for I/O errors
> for read, it is impossible to distinguish between a never-been-uptodate
> page and a was-uptodate-before-invalidation page.

Umm. The regular read does this quite well. If something isn't up-to-date, 
it tries a synchronous read. Once.

> And it's not just an nfsd issue.  Userspace might also expect that if
> a zero count is returned, that means it went beyond EOF, and not that
> it should retry the splice, maybe it has better luck this time.

You're totally ignoring the real issue - user space that uses splice() 
*knows* that it uses splice(). It's a private mmap(). 

NFSD, on the other hand, is supposed to act as NFSD. I think that 
currently it assumes that nobody else modifies the files, which is 
reasonable, but breaks with FUSE.

But do you see? That's a NFSD/FUSE issue, not a splice one!

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
