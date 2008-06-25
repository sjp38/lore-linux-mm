In-reply-to: <20080625153025.GB21579@2ka.mipt.ru> (message from Evgeniy
	Polyakov on Wed, 25 Jun 2008 19:30:25 +0400)
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <20080625131117.GA28136@2ka.mipt.ru> <E1KBV7H-0005nv-Gl@pomaz-ex.szeredi.hu> <20080625141654.GA4803@2ka.mipt.ru> <E1KBWBK-0006Lp-03@pomaz-ex.szeredi.hu> <20080625153025.GB21579@2ka.mipt.ru>
Message-Id: <E1KBXOs-00074q-NU@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 25 Jun 2008 17:59:14 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > > > > Like __block_prepare_write()?
> > > > 
> > > > That's called with the page locked and page->mapping verified.
> > > 
> > > Only when called via standard codepath.
> > 
> > It would be a grave error to call it without the page lock.
> 
> Page is locked of course, but invalidated, removed from all trees and
> caches, i.e. grab, lock, check, unlock... invalidate, write into that
> page should fail, but it will not, since page is uptodate and
> prepare_write does not check mapping at all.

But callers do check after having locked the page.

> > > Instead of returning error when reading from invalid page, now you
> > > return old content of it?
> > 
> > No, instead of returning a short count, it is now returning old
> > content.
> 
> Or instead of returning error or zero and relookup page eventually,
> which can already contain new data, we get old data.

Umm, it doesn't make any sense to try to always get fresh data.  If
you do read() on a file, the data may become old and invalid a
millisecond after the read finished.  We can't and needn't do anything
about this.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
