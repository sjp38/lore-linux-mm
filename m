In-reply-to: <20081021150948.GB28279@fogou.chygwyn.com> (steve@chygwyn.com)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <E1KsIHV-0006JW-65@pomaz-ex.szeredi.hu> <20081021150948.GB28279@fogou.chygwyn.com>
Message-Id: <E1KsJr2-0006jT-1R@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 21 Oct 2008 18:13:08 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: miklos@szeredi.hu, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, steve@chygwyn.co wrote:
> Well I'm not sure why we'd need to distinguish between "page has not
> been read" and "page has been read but no longer valid". I guess I
> don't understand why those two cases are not the same from the vfs
> and filesystem points of view.

In the first case the page contains random bytes, in the second case
it contains actual file data, which has become stale, but at some
point in time it _was_ the contents of the file.

This is a very important distinction for splice(2) for example.
Splice does not actually copy data into the pipe buffer, only
references the pages.  And it can reference pages which are not yet
up-to-date.  So when the buffers are consumed from the pipe, the
splice code needs to know if the page contains random junk (never
brought up-to-date) or data that is, or once was, valid.

> I'm sure it should be documented :-) it certainly seems confusing and if we
> want to keep this scheme, can we change PG_uptodate to PG_wasread or
> PG_usedonce or something like that which more clearly reflects its
> purpose in that case,

I'm not going to argue about the name :)

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
