In-reply-to: <200807080028.00642.nickpiggin@yahoo.com.au> (message from Nick
	Piggin on Tue, 8 Jul 2008 00:28:00 +1000)
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <200807072217.57509.nickpiggin@yahoo.com.au> <E1KFqD4-0001vq-3F@pomaz-ex.szeredi.hu> <200807080028.00642.nickpiggin@yahoo.com.au>
Message-Id: <E1KFsKI-0002IN-ES@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 07 Jul 2008 17:08:26 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: miklos@szeredi.hu, jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jul 2008, Nick Piggin wrote:
> If dirty can't happen, the caller should just use the truncate.
> The creation of this "invalidate 2" thing was just papering over
> problems in the callers.

Dirty *can* happen.  The difference between truncate_inode_pages() and
invalidate_inode_pages2() is that the former just throws away dirty
pages, while the latter can do something about them through
->launder_page().

> But anyway your point is taken -- caller doesn't really handle failure.

Yes.

> > Right.  I think leaving PG_uptodate on invalidation is actually a
> > rather clean solution compared to the alternatives.
> 
> Note that files can be truncated in the middle too, so you can't
> just fix one case that happens to hit you, you'd have to fix things
> consistently.

Hmm, OK.

> But...
> 
> 
> > Well, other than my original proposal, which would just have reused
> > the do_generic_file_read() infrastructure for splice.  I still don't
> > see why we shouldn't use that, until the whole async splice-in thing
> > is properly figured out.
> 
> Given the alternatives, perhaps this is for the best, at least for
> now.

Yeah.  I'm not at all opposed to improving splice to be able to do all
sorts of fancy things like async splice-in, and stealing of pages.
But it's unlikely that I will have the motivation to implement any of
them just to fix this bug.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
