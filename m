Date: Thu, 24 Apr 2008 04:13:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-ID: <20080424021339.GA9393@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com> <20080422045205.GH21993@wotan.suse.de> <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com> <20080422094352.GB23770@wotan.suse.de> <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com> <20080423004804.GA14134@wotan.suse.de> <20080423114107.b8df779c.kamezawa.hiroyu@jp.fujitsu.com> <20080423025358.GA9751@wotan.suse.de> <Pine.LNX.4.64.0804231045540.12373@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804231045540.12373@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 10:47:04AM -0700, Christoph Lameter wrote:
> On Wed, 23 Apr 2008, Nick Piggin wrote:
> 
> > In the __set_page_dirty case in fs/buffer.c, we _do_ know that the page
> > has buffers and that it would be wrong to have a situation where the
> > page is !uptodate at this point.
> > 
> > Is that clear? Or have I explained it poorly?
> 
> In other words __set_page_dirty sets the page dirty and only warns
> if the page has no buffers and is not uptodate.

That's what __set_page_dirty_nobuffers does.

__set_page_dirty, when called from __set_page_dirty_buffers, will warn
even if the page does have buffers. That's because from that path we
know all our buffers are dirty, which implies they all must be uptodate,
which implies the page must be uptodate.

When called form mark_buffer_dirty, it does not warn because we may
have some buffers still not marked dirty in the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
