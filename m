Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E15E982F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 18:39:16 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so133783616pac.3
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 15:39:16 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id iv8si30149346pbc.11.2015.11.01.15.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 15:39:16 -0800 (PST)
Received: by pasz6 with SMTP id z6so128361216pas.2
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 15:39:15 -0800 (PST)
Date: Sun, 1 Nov 2015 15:39:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for
 uptodate
In-Reply-To: <5635E2B4.5070308@electrozaur.com>
Message-ID: <alpine.LSU.2.11.1511011513240.11427@eggly.anvils>
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <ooo@electrozaur.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benny Halevy <bhalevy@primarydata.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, osd-dev@open-osd.org

On Sun, 1 Nov 2015, Boaz Harrosh wrote:
> On 10/29/2015 08:43 PM, Hugh Dickins wrote:
> > Patch "mm: migrate dirty page without clear_page_dirty_for_io etc",
> > presently staged in mmotm and linux-next, simplifies the migration of
> > a PageDirty pagecache page: one stat needs moving from zone to zone
> > and that's about all.
> > 
> > It's convenient and safest for it to shift the PageDirty bit from old
> > page to new, just before updating the zone stats: before copying data
> > and marking the new PageUptodate.  This is all done while both pages
> > are isolated and locked, just as before; and just as before, there's
> > a moment when the new page is visible in the radix_tree, but not yet
> > PageUptodate.  What's new is that it may now be briefly visible as
> > PageDirty before it is PageUptodate.
> > 
> > When I scoured the tree to see if this could cause a problem anywhere,
> > the only places I found were in two similar functions __r4w_get_page():
> > which look up a page with find_get_page() (not using page lock), then
> > claim it's uptodate if it's PageDirty or PageWriteback or PageUptodate.
> > 
> > I'm not sure whether that was right before, but now it might be wrong
> > (on rare occasions): only claim the page is uptodate if PageUptodate.
> > Or perhaps the page in question could never be migratable anyway?
> > 
> 
> Hi Sir Hugh

Hi Boaz - please pardon my informality :)

> 
> I'm sorry, I admit the code is clear as mud, but your patch below is wrong.
> 
> The *uptodate return from __r4w_get_page is not really "up-to-date" at all
> actually it means: "do we need to read the page from storage" writable/dirty pages
> we do not read from storage but use the newest data in memory.
> 
> r4w means read-for-write which is when we need to bring in the full stripe to
> re-calculate raid5/6 . (when only the partial stripe is written)

Yes, that's what I understood from the code too, and how PageUptodate
is usually used: it allows the caller to bypass the overhead of locking
the page, rechecking PageUptodate, and reading it in if still necessary.

> 
> The scenario below of: "briefly visible as PageDirty before it is PageUptodate"
> is fine in this case because in both cases we do not need to read the page.

But when do you think you have a PageDirty (or PageWriteback) page which
is not PageUptodate?  We do not ClearPageUptodate when a page is modified.

PageUptodate normally remains set for as long as that page remains caching
that offset of the file.  I think it's true to say that PageUptodate is
only cleared when an error, or sometimes an invalidation, occurs (or of
course when the page is freed for reuse).

I was going to suggest that you check through the places which
ClearPageUptodate, but that is rather a confusing exercise, since I think
the majority of them are actually redundant - pages don't come from the
allocator with PageUptodate set, and a filesystem would already be in
trouble if it set PageUptodate before the page was initialized (usually
by reading its data in from disk).  So I think those ClearPageUptodates
on read error are redundant; though I'm not daring to remove them
(and they have no bearing on this patch at hand).

> 
> Thanks for looking
> Boaz
> 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> This patch is not correct!

I think you have actually confirmed that the patch is correct:
why bother to test PageDirty or PageWriteback when PageUptodate
already tells you what you need?

Or do these filesystems do something unusual with PageUptodate
when PageDirty is set?  I didn't find it.

Thanks,
Hugh

> 
> > ---
> > 
> >  fs/exofs/inode.c             |    5 +----
> >  fs/nfs/objlayout/objio_osd.c |    5 +----
> >  2 files changed, 2 insertions(+), 8 deletions(-)
> > 
> > --- 4.3-next/fs/exofs/inode.c	2015-08-30 11:34:09.000000000 -0700
> > +++ linux/fs/exofs/inode.c	2015-10-28 16:55:18.795554294 -0700
> > @@ -592,10 +592,7 @@ static struct page *__r4w_get_page(void
> >  			}
> >  			unlock_page(page);
> >  		}
> > -		if (PageDirty(page) || PageWriteback(page))
> > -			*uptodate = true;
> > -		else
> > -			*uptodate = PageUptodate(page);
> > +		*uptodate = PageUptodate(page);
> >  		EXOFS_DBGMSG2("index=0x%lx uptodate=%d\n", index, *uptodate);
> >  		return page;
> >  	} else {
> > --- 4.3-next/fs/nfs/objlayout/objio_osd.c	2015-10-21 18:35:07.620645439 -0700
> > +++ linux/fs/nfs/objlayout/objio_osd.c	2015-10-28 16:53:55.083686639 -0700
> > @@ -476,10 +476,7 @@ static struct page *__r4w_get_page(void
> >  		}
> >  		unlock_page(page);
> >  	}
> > -	if (PageDirty(page) || PageWriteback(page))
> > -		*uptodate = true;
> > -	else
> > -		*uptodate = PageUptodate(page);
> > +	*uptodate = PageUptodate(page);
> >  	dprintk("%s: index=0x%lx uptodate=%d\n", __func__, index, *uptodate);
> >  	return page;
> >  }
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
