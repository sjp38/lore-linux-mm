In-reply-to: <20070219004537.GB9289@think.oraclecorp.com> (message from Chris
	Mason on Sun, 18 Feb 2007 19:45:37 -0500)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu> <20070218125307.4103c04a.akpm@linux-foundation.org> <E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu> <20070218145929.547c21c7.akpm@linux-foundation.org> <E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org> <E1HIwLJ-0005N4-00@dorka.pomaz.szeredi.hu> <20070219004537.GB9289@think.oraclecorp.com>
Message-Id: <E1HIwnX-0005Sr-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 19 Feb 2007 01:54:31 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chris.mason@oracle.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > > If so, writes to B will decrease the dirty memory threshold.
> > > > 
> > > > Yes, but not by enough.  Say A dirties a 1100 pages, limit is 1000.
> > > > Some pages queued for writeback (doesn't matter how much).  B writes
> > > > back 1, 1099 dirty remain in A, zero in B.  balance_dirty_pages() for
> > > > B doesn't know that there's nothing more to write back for B, it's
> > > > just waiting there for those 1099, which'll never get written.
> > > 
> > > hm, OK, arguable.  I guess something like this..
> > 
> > Doesn't help the fuse case, but does seem to help the loopback mount
> > one.
> > 
> > For fuse it's worse with the patch: now the write triggered by the
> > balance recurses into fuse, with disastrous results, since the fuse
> > writeback is now blocked on the userspace queue.
> > 
> > fusexmp_fh_no D 40136678     0   505    494           506   504 (NOTLB)
> > 08982b78 00000001 00000000 08f9f9b4 0805d8cb 089a75f8 08982b78 08f98000
> >        08f98000 08f9f9dc 0805a38a 089a7100 08982680 08f9f9cc 08f98000 08f98000
> >        085d8300 08982680 089a7100 08f9fa34 08183006 089a7100 08982680 089a7100 Call Trace:
> > 08f9f9a0:  [<0805d8cb>] switch_to_skas+0x3b/0x83
> > 08f9f9b8:  [<0805a38a>] _switch_to+0x49/0x99
> > 08f9f9e0:  [<08183006>] schedule+0x246/0x547
> > 08f9fa38:  [<08103c7e>] fuse_get_req_wp+0xe9/0x14a
> > 08f9fa70:  [<08103d2e>] fuse_writepage+0x4f/0x12c
> 
> In general, writepage is supposed to do work without blocking on
> expensive locks that will get pdflush and dirty reclaim stuck in this
> fashion.  You'll probably have to take the same approach reiserfs does
> in data=journal mode, which is leaving the page dirty if fuse_get_req_wp
> is going to block without making progress.

Pdflush, and dirty reclaim set wbc->nonblocking to true.
balance_dirty_pages and fsync don't.  The problem here is that
Andrew's patch is wrong to let balance_dirty_pages() try to write back
pages from a different queue.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
