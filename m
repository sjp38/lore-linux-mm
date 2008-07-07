From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Date: Mon, 7 Jul 2008 16:38:31 +1000
References: <20080625124038.103406301@szeredi.hu> <20080625173837.GA10005@shareable.org> <E1KBZqG-0008OZ-Pw@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KBZqG-0008OZ-Pw@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807071638.32955.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thursday 26 June 2008 04:35, Miklos Szeredi wrote:
> > > I also really don't think this even fixes the problems you have with
> > > FUSE/NFSD - because you'll still be reading zeroes for a truncated
> > > file. Yes, you get the rigth counts, but you don't get the right data.
> >
> > ...
> >
> > > That's "correct" from a splice() kind of standpoint (it's essentially a
> > > temporary mmap() with MAP_PRIVATE), but the thing is, it just sounds
> > > like the whole "page went away" thing is a more fundamental issue. It
> > > sounds like nfds should hold a read-lock on the file while it has any
> > > IO in flight, or something like that.
> >
> > I'm thinking any kind of user-space server using splice() will not
> > want to transmit zeros either, when another process truncates the file.
> > E.g. Apache, Samba, etc.
> >
> > Does this problem affect sendfile() users?
>
> AFAICS it does.
>
> And I agree, that splice should handle truncation better.  But as I
> said, this affects every single filesystem out there.  And yes, my
> original patch wouldn't solve this (although it wouldn't make it
> harder to solve either).
>
> However the page invalidation issue is completely orthogonal, and only
> affects a few filesystems which call invalidate_complete_page2(),
> namely: 9p, afs, fuse and nfs.

I don't know what became of this thread, but I agree with everyone else
you should not skip clearing PG_uptodate here. If nothing else, it
weakens some important assertions in the VM. But I agree that splice
should really try harder to work with it and we should be a little
careful about just changing things like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
