In-reply-to: <20081022131648.GA20625@wotan.suse.de> (message from Nick Piggin
	on Wed, 22 Oct 2008 15:16:48 +0200)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081022131648.GA20625@wotan.suse.de>
Message-Id: <E1Ksk1B-00027N-Ju@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 22:09:21 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Nick Piggin wrote:
> Invalidate I guess is covered now (I don't exactly like the solution,
> but it's what we have for now). Truncate hmm, I thought that still
> clears PageUptodate, but it doesn't seem to either?

Right.  Linus's reasons for this change:

  "But I'd really like to get that PG_uptodate bit just fixed - both
   wrt writeout errors and wrt truncate/holepunch. We had some similar
   issues wrt ext3 (?) inode buffers, where removing the uptodate bit
   actually ended up being a mistake."

My thoughts are:

 a) clearing both PG_uptodate *and* page->mapping is redundant

 b) the page contents do not actually change in either the whole-page
    truncate or the invalidate case, so the up-to-date state shouldn't
    change either.

> Maybe we can use !PageUptodate, with care, for read errors. It might 
> actually be a bit preferable in the sense that PageError can just be
> used for write errors only.

That's fine by me, some filesystems do set PageError even on read, but
it doesn't matter, since they obviously won't set PageUptodate in that
case.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
