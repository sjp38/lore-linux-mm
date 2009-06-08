Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7FF256B0055
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 07:32:22 -0400 (EDT)
Date: Mon, 8 Jun 2009 20:31:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in  the VM v3
Message-ID: <20090608123133.GA7944@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090528145021.GA5503@localhost> <ab418ea90906032325m302afbb6w6fa68f6b57f53e49@mail.gmail.com> <20090607160225.GA24315@localhost> <ab418ea90906080406y34981329y27d360624aa22f7c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ab418ea90906080406y34981329y27d360624aa22f7c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Nai Xia <nai.xia@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 07:06:12PM +0800, Nai Xia wrote:
> On Mon, Jun 8, 2009 at 12:02 AM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > On Thu, Jun 04, 2009 at 02:25:24PM +0800, Nai Xia wrote:
> >> On Thu, May 28, 2009 at 10:50 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> > On Thu, May 28, 2009 at 09:45:20PM +0800, Andi Kleen wrote:
> >> >> On Thu, May 28, 2009 at 02:08:54PM +0200, Nick Piggin wrote:
> >> >
> >> > [snip]
> >> >
> >> >> >
> >> >> > BTW. I don't know if you are checking for PG_writeback often enough?
> >> >> > You can't remove a PG_writeback page from pagecache. The normal
> >> >> > pattern is lock_page(page); wait_on_page_writeback(page); which I
> >> >>
> >> >> So pages can be in writeback without being locked? I still
> >> >> wasn't able to find such a case (in fact unless I'm misreading
> >> >> the code badly the writeback bit is only used by NFS and a few
> >> >> obscure cases)
> >> >
> >> > Yes the writeback page is typically not locked. Only read IO requires
> >> > to be exclusive. Read IO is in fact page *writer*, while writeback IO
> >> > is page *reader* :-)
> >>
> >> Sorry for maybe somewhat a little bit off topic,
> >> I am trying to get a good understanding of PG_writeback & PG_locked ;)
> >>
> >> So you are saying PG_writeback & PG_locked are acting like a read/write lock?
> >> I notice wait_on_page_writeback(page) seems always called with page locked --
> >
> > No. Note that pages are not locked in wait_on_page_writeback_range().
> 
> I see. This function seems mostly called  on the sync path,
> it just waits for data being synchronized to disk.
> No writers from the pages' POV, so no lock.
> I missed this case, but my argument about the role of read/write lock.
> seems still consistent. :)

It's more constrained. Normal read/write locks allow concurrent readers,
however fsync() must wait for previous IO to finish before starting
its own IO.

> >
> >> that is the semantics of a writer waiting to get the lock while it's
> >> acquired by
> >> some reader:The caller(e.g. truncate_inode_pages_range() A and
> >> invalidate_inode_pages2_range()) are the writers waiting for
> >> writeback readers (as you clarified ) to finish their job, right ?
> >
> > Sorry if my metaphor confused you. But they are not typical
> > reader/writer problems, but more about data integrities.
> 
> No, you didn't :)
> Actually, you make me clear about the mixed roles for
> those bits.
> 
> >
> > Pages have to be "not under writeback" when truncated.
> > Otherwise data lost is possible:
> >
> > 1) create a file with one page (page A)
> > 2) truncate page A that is under writeback
> > 3) write to file, which creates page B
> > 4) sync file, which sends page B to disk quickly
> >
> > Now if page B reaches disk before A, the new data will be overwritten
> > by truncated old data, which corrupts the file.
> 
> I fully understand this scenario which you had already clarified in a
> previous message. :)
> 
> 1. someone make index1-> page A
> 2. Path P1 is acting as a *reader* to a cache page at index1 by
>     setting PG_writeback on, while at the same time as a *writer* to
>     the corresponding file blocks.
> 3. Another path P2 comes in and  truncate page A, he is the writer
>     to the same cache page.
> 4. Yet another path P3 comes  as the writer to the cache page
>      making it points to page B: index1--> page B.
> 5. Path P4 comes writing back the cache page(and set PG_writeback).
>    He is the reader of the cache page and the writer to the file blocks.
> 
> The corrupts occur because P1 & P4 races when writing file blocks.
> But the _root_ of this racing is because nothing is used to serialize
> them on the side of writing the file blocks and above stream reading was
> inconsistent because of the writers(P2 & P3) to cache page at index1.
>
> Note that the "sync file" is somewhat irrelevant, even without "sync file",
> the racing still may exists. I know you must want to show me that this could
> make the corruption more easy to occur.
>
> So I think the simple logic is:
> 1) if you want to truncate/change the mapping from a index to a struct *page,
> test writeback bit because the writebacker to the file blocks is the reader
> of this mapping.
> 2) if a writebacker want to start a read of this mapping with
> test_set_page_writeback()
> or set_page_writeback(), he'd be sure this page is locked to keep out the
> writers to this mapping of index-->struct *page.
> 
> This is really behavior of a read/write lock, right ?

Please, that's a dangerous idea. A page can be written to at any time
when writeback to disk is under way. Does PG_writeback (your reader
lock) prevents page data writers?  NO.

Thanks,
Fengguang

> wait_on_page_writeback_range() looks different only because "sync"
> operates on "struct page", it's not sensitive to index-->struct *page mapping.
> It does care about if pages returned by pagevec_lookup_tag() are
> still maintains the mapping when wait_on_page_writeback(page).
> Here, PG_writeback is only a status flag for "struct page" not a lock bit for
> index->struct *page mapping.
> 
> >
> >> So do you think the idea is sane to group the two bits together
> >> to form a real read/write lock, which does not care about the _number_
> >> of readers ?
> >
> > We don't care number of readers here. So please forget about it.
> Yeah, I meant number of readers is not important.
> 
> I still hold that these two bits in some way act like a _sparse_
> read/write lock.
> But I am going to drop the idea of making them a pure lock, since PG_writeback
> does has other meaning -- the page is being writing back: for sync
> path, it's only
> a status flag.
> Making a pure read/write lock definitely will lose that or at least distort it.
> 
> 
> Hoping I've made my words understandable, correct me if wrong, and
> many thanks for your time and patience. :-)
> 
> 
> Nai Xia
> 
> >
> > Thanks,
> > Fengguang
> >
> >> > The writeback bit is _widely_ used. A test_set_page_writeback() is
> >> > directly used by NFS/AFS etc. But its main user is in fact
> >> > set_page_writeback(), which is called in 26 places.
> >> >
> >> >> > think would be safest
> >> >>
> >> >> Okay. I'll just add it after the page lock.
> >> >>
> >> >> > (then you never have to bother with the writeback bit again)
> >> >>
> >> >> Until Fengguang does something fancy with it.
> >> >
> >> > Yes I'm going to do it without wait_on_page_writeback().
> >> >
> >> > The reason truncate_inode_pages_range() has to wait on writeback page
> >> > is to ensure data integrity. Otherwise if there comes two events:
> >> > A  A  A  A truncate page A at offset X
> >> > A  A  A  A populate page B at offset X
> >> > If A and B are all writeback pages, then B can hit disk first and then
> >> > be overwritten by A. Which corrupts the data at offset X from user's POV.
> >> >
> >> > But for hwpoison, there are no such worries. If A is poisoned, we do
> >> > our best to isolate it as well as intercepting its IO. If the interception
> >> > fails, it will trigger another machine check before hitting the disk.
> >> >
> >> > After all, poisoned A means the data at offset X is already corrupted.
> >> > It doesn't matter if there comes another B page.
> >> >
> >> > Thanks,
> >> > Fengguang
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at A http://vger.kernel.org/majordomo-info.html
> >> > Please read the FAQ at A http://www.tux.org/lkml/
> >> >
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
