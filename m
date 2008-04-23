Date: Wed, 23 Apr 2008 17:28:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-ID: <20080423152809.GA16769@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com> <20080422045205.GH21993@wotan.suse.de> <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com> <20080422094352.GB23770@wotan.suse.de> <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com> <20080423004804.GA14134@wotan.suse.de> <20080423114107.b8df779c.kamezawa.hiroyu@jp.fujitsu.com> <20080423025358.GA9751@wotan.suse.de> <20080423124425.5c80d3cf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423124425.5c80d3cf.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 12:44:25PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Apr 2008 04:53:58 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > > BTW, can I ask a question for understanding this change ?
> > > 
> > > ==this check==
> > >  WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
> > > 
> > > in __set_page_dirty_nobuffers() seems to check "the page should have buffer or
> > > be up-to-date when it calls this function."
> > > 
> > > When it comes to __set_page_dirty() (in fs/buffer.c)
> > > == this check==
> > >  WARN_ON_ONCE(warn && !PageUptodate(page));
> > > 
> > > is used and doesn't see page has buffers or not.
> > > What's difference between two functions's condition for WARNING ?
> > 
> > Yes, __set_page_dirty_nobuffers confusingly can also be called for pages
> > with buffers. In the case that the page has buffers (or any other private
> > metadata), then __set_page_dirty_nobuffers does not have enough information
> > to know whether the page should be uptodate before being marked dirty.
> > 
> > In the __set_page_dirty case in fs/buffer.c, we _do_ know that the page
> > has buffers and that it would be wrong to have a situation where the
> > page is !uptodate at this point.
> > 
> > Is that clear? Or have I explained it poorly?
> > 
> 
> Hmm...does that comes from difference of the purpose of the functions ?

Yes, well sometimes __set_page_dirty_nobuffers is actually called into
for a page which does have buffers or some private data (eg. via
redirty_page_for_writepage). If it was only called for pages that really
have no buffers, it could simply be WARN_ON(!PageUptodate(page))

 
> Is this correct ?
> ==
> set_page_dirty_buffers() (in fs/buffer.c) makes a page and _all_ buffers on it
> dirty. So, a page *must* be up-to-date when it calls set_page_dirty_buffers().
> This is used for mapped pages or some callers which requires the whole
> page containes valid data.
> 
> In set_page_dirty_nobuffers()case , it just makes a page to be dirty. We can't
> see whether a page is really up-to-date or not when PagePrivate(page) &&
> !PageUptodate(page). This is used for a page which contains some data
> to be written out. (part of buffers contains data.)
> 
> ==

Yes I think you have it correct. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
