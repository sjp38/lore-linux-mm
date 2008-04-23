Date: Wed, 23 Apr 2008 04:53:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-ID: <20080423025358.GA9751@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com> <20080422045205.GH21993@wotan.suse.de> <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com> <20080422094352.GB23770@wotan.suse.de> <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com> <20080423004804.GA14134@wotan.suse.de> <20080423114107.b8df779c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423114107.b8df779c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:41:07AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Apr 2008 02:48:04 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> > KAMEZAWA Hiroyuki found a warning message in the buffer dirtying code that
> > is coming from page migration caller.
> > 
> > WARNING: at fs/buffer.c:720 __set_page_dirty+0x330/0x360()
> > Call Trace:
> >  [<a000000100015220>] show_stack+0x80/0xa0
> >  [<a000000100015270>] dump_stack+0x30/0x60
> >  [<a000000100089ed0>] warn_on_slowpath+0x90/0xe0
> >  [<a0000001001f8b10>] __set_page_dirty+0x330/0x360
> >  [<a0000001001ffb90>] __set_page_dirty_buffers+0xd0/0x280
> >  [<a00000010012fec0>] set_page_dirty+0xc0/0x260
> >  [<a000000100195670>] migrate_page_copy+0x5d0/0x5e0
> >  [<a000000100197840>] buffer_migrate_page+0x2e0/0x3c0
> >  [<a000000100195eb0>] migrate_pages+0x770/0xe00
> > 
> > What was happening is that migrate_page_copy wants to transfer the PG_dirty
> > bit from old page to new page, so what it would do is set_page_dirty(newpage).
> > However set_page_dirty() is used to set the entire page dirty, wheras in
> > this case, only part of the page was dirty, and it also was not uptodate.
> > 
> > Marking the whole page dirty with set_page_dirty would lead to corruption or
> > unresolvable conditions -- a dirty && !uptodate page and dirty && !uptodate
> > buffers.
> > 
> > Possibly we could just ClearPageDirty(oldpage); SetPageDirty(newpage);
> > however in the interests of keeping the change minimal...
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Tested and seems to work well. thank you!

Thanks very much!

 
> BTW, can I ask a question for understanding this change ?
> 
> ==this check==
>  WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
> 
> in __set_page_dirty_nobuffers() seems to check "the page should have buffer or
> be up-to-date when it calls this function."
> 
> When it comes to __set_page_dirty() (in fs/buffer.c)
> == this check==
>  WARN_ON_ONCE(warn && !PageUptodate(page));
> 
> is used and doesn't see page has buffers or not.
> What's difference between two functions's condition for WARNING ?

Yes, __set_page_dirty_nobuffers confusingly can also be called for pages
with buffers. In the case that the page has buffers (or any other private
metadata), then __set_page_dirty_nobuffers does not have enough information
to know whether the page should be uptodate before being marked dirty.

In the __set_page_dirty case in fs/buffer.c, we _do_ know that the page
has buffers and that it would be wrong to have a situation where the
page is !uptodate at this point.

Is that clear? Or have I explained it poorly?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
