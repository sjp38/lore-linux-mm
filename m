Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C63986B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 11:26:31 -0400 (EDT)
Date: Mon, 8 Jun 2009 00:02:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in  the VM v3
Message-ID: <20090607160225.GA24315@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090528145021.GA5503@localhost> <ab418ea90906032325m302afbb6w6fa68f6b57f53e49@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ab418ea90906032325m302afbb6w6fa68f6b57f53e49@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Nai Xia <nai.xia@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 02:25:24PM +0800, Nai Xia wrote:
> On Thu, May 28, 2009 at 10:50 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Thu, May 28, 2009 at 09:45:20PM +0800, Andi Kleen wrote:
> >> On Thu, May 28, 2009 at 02:08:54PM +0200, Nick Piggin wrote:
> >
> > [snip]
> >
> >> >
> >> > BTW. I don't know if you are checking for PG_writeback often enough?
> >> > You can't remove a PG_writeback page from pagecache. The normal
> >> > pattern is lock_page(page); wait_on_page_writeback(page); which I
> >>
> >> So pages can be in writeback without being locked? I still
> >> wasn't able to find such a case (in fact unless I'm misreading
> >> the code badly the writeback bit is only used by NFS and a few
> >> obscure cases)
> >
> > Yes the writeback page is typically not locked. Only read IO requires
> > to be exclusive. Read IO is in fact page *writer*, while writeback IO
> > is page *reader* :-)
> 
> Sorry for maybe somewhat a little bit off topic,
> I am trying to get a good understanding of PG_writeback & PG_locked ;)
> 
> So you are saying PG_writeback & PG_locked are acting like a read/write lock?
> I notice wait_on_page_writeback(page) seems always called with page locked --

No. Note that pages are not locked in wait_on_page_writeback_range().

> that is the semantics of a writer waiting to get the lock while it's
> acquired by
> some reader:The caller(e.g. truncate_inode_pages_range()  and
> invalidate_inode_pages2_range()) are the writers waiting for
> writeback readers (as you clarified ) to finish their job, right ?

Sorry if my metaphor confused you. But they are not typical
reader/writer problems, but more about data integrities.

Pages have to be "not under writeback" when truncated. 
Otherwise data lost is possible:

1) create a file with one page (page A)
2) truncate page A that is under writeback
3) write to file, which creates page B
4) sync file, which sends page B to disk quickly

Now if page B reaches disk before A, the new data will be overwritten
by truncated old data, which corrupts the file.

> So do you think the idea is sane to group the two bits together
> to form a real read/write lock, which does not care about the _number_
> of readers ?

We don't care number of readers here. So please forget about it.

Thanks,
Fengguang

> > The writeback bit is _widely_ used. A test_set_page_writeback() is
> > directly used by NFS/AFS etc. But its main user is in fact
> > set_page_writeback(), which is called in 26 places.
> >
> >> > think would be safest
> >>
> >> Okay. I'll just add it after the page lock.
> >>
> >> > (then you never have to bother with the writeback bit again)
> >>
> >> Until Fengguang does something fancy with it.
> >
> > Yes I'm going to do it without wait_on_page_writeback().
> >
> > The reason truncate_inode_pages_range() has to wait on writeback page
> > is to ensure data integrity. Otherwise if there comes two events:
> > A  A  A  A truncate page A at offset X
> > A  A  A  A populate page B at offset X
> > If A and B are all writeback pages, then B can hit disk first and then
> > be overwritten by A. Which corrupts the data at offset X from user's POV.
> >
> > But for hwpoison, there are no such worries. If A is poisoned, we do
> > our best to isolate it as well as intercepting its IO. If the interception
> > fails, it will trigger another machine check before hitting the disk.
> >
> > After all, poisoned A means the data at offset X is already corrupted.
> > It doesn't matter if there comes another B page.
> >
> > Thanks,
> > Fengguang
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at A http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at A http://www.tux.org/lkml/
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
