Date: Thu, 8 Feb 2007 15:13:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Drop PageReclaim()
Message-Id: <20070208151341.7e27ca59.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
	<20070208140338.971b3f53.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
	<20070208142431.eb81ae70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>
	<20070208143746.79c000f5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007 14:40:52 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 8 Feb 2007, Andrew Morton wrote:
> 
> > > Those sleeping on the page must have their own process context
> > > to do so.
> > 
> > You've lost me.  I don't see what that sort of thing has to do with
> > end_page_writeback() and rotate_reclaimable_page().
> 
> One could replace the PageReclaim bit with a process waiting on the 
> writeback bit to clear. The process would then do the rotation. But that 
> would require too many processes.

Yeah, we'd need to queue the pages somehow to do that.

> Hmmm... Does not look as if I can get that bit freed up. It was always a 
> mystery to me what the thing did. At least I know now.

well hmm.  Maybe we can just remove PG_reclaim.

The current situation is that we'll rotate a written-back page to the tail
of the inactive list if

	a) the page looks like it'll be reclaimable and
	b) the vm scanner recently encountered that page and wanted to
	   reclaim it.

if we remove PG_reclaim then condition b) just goes away.

I expect that'll be OK for pages which were written back by the vm scanner.
 But it also means that pages which were written back by
pdflush/balance_dirty_pages/fsync/etc will now all also be eligible for
rotation.  ie: the vast majority of written-back pages.

Whether that will make much difference to page aging I don't know.  But it
will cause more lru->lock traffic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
