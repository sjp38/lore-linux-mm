In-reply-to: <20080625141654.GA4803@2ka.mipt.ru> (message from Evgeniy
	Polyakov on Wed, 25 Jun 2008 18:16:55 +0400)
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <20080625131117.GA28136@2ka.mipt.ru> <E1KBV7H-0005nv-Gl@pomaz-ex.szeredi.hu> <20080625141654.GA4803@2ka.mipt.ru>
Message-Id: <E1KBWBK-0006Lp-03@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 25 Jun 2008 16:41:10 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > > Like __block_prepare_write()?
> > 
> > That's called with the page locked and page->mapping verified.
> 
> Only when called via standard codepath.

It would be a grave error to call it without the page lock.

> > I want the page fully invalidated, and I also want splice and nfs
> > exporting to work as for other filesystems.
> 
> Fully invalidated page can not be uptodate, doesnt' it? :)

That's just a question of how we interpret PG_uptodate.  If it means:
the page contains data that is valid, or was valid at some point in
time, then an invalidated or truncated page can be uptodate.

> You destroy existing functionality just because there are some obscure
> places, where it is used, so instead of fixing that places, you treat
> the symptom. After writing previous mail I found a way to workaround it
> even with your changes, but the whole approach of changing
> invalidate_complete_page2() is not correct imho.

You rely on page being !PageUptodate() after being invalidated?  Why
can't you check page->mapping instead (as everything else does)?

> Is this nfs/fuse problem you described:
> http://marc.info/?l=linux-fsdevel&m=121396920822693&w=2

Yes.

> Instead of returning error when reading from invalid page, now you
> return old content of it?

No, instead of returning a short count, it is now returning old
content.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
