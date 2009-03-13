Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A21BD6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 22:20:58 -0400 (EDT)
Date: Fri, 13 Mar 2009 03:20:52 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] fs: fix page_mkwrite error cases in core code and btrfs
Message-ID: <20090313022051.GA18279@wotan.suse.de>
References: <20090311035318.GH16561@wotan.suse.de> <20090311035503.GI16561@wotan.suse.de> <1236895724.7179.71.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.0903121511300.30231@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903121511300.30231@cobra.newdream.net>
Sender: owner-linux-mm@kvack.org
To: Sage Weil <sage@newdream.net>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 04:03:57PM -0700, Sage Weil wrote:
> On Thu, 12 Mar 2009, Trond Myklebust wrote:
> > On Wed, 2009-03-11 at 04:55 +0100, Nick Piggin wrote:
> > > page_mkwrite is called with neither the page lock nor the ptl held. This
> > > means a page can be concurrently truncated or invalidated out from underneath
> > > it. Callers are supposed to prevent truncate races themselves, however
> > > previously the only thing they can do in case they hit one is to raise a
> > > SIGBUS. A sigbus is wrong for the case that the page has been invalidated
> > > or truncated within i_size (eg. hole punched). Callers may also have to
> > > perform memory allocations in this path, where again, SIGBUS would be wrong.
> > > 
> > > The previous patch made it possible to properly specify errors. Convert
> > > the generic buffer.c code and btrfs to return sane error values
> > > (in the case of page removed from pagecache, VM_FAULT_NOPAGE will cause the
> > > fault handler to exit without doing anything, and the fault will be retried 
> > > properly).
> > > 
> > > This fixes core code, and converts btrfs as a template/example. All other
> > > filesystems defining their own page_mkwrite should be fixed in a similar
> > > manner.
> > 
> > There appears to be another atomicity problem in the same area of
> > code...
> > 
> > The lack of locking between the call to ->page_mkwrite() and the
> > subsequent call to set_page_dirty_balance() means that the filesystem
> > may actually already have written out the page by the time you get round
> > to calling set_page_dirty_balance().
> 
> We were just banging our heads against this issue last week.

That's coming too:
http://marc.info/?l=linux-fsdevel&m=123555461816471&w=2

(we ended up deciding to call with page unlocked and return with locked,
as it solves locking problems in some filesystems).

I'll resend that patch soonish. Hopefully it will work for you two?


> Among other things, if ->set_page_dirty sets up anything in page->private, 
> you can get an ->invalidatepage on a non-dirty page (which confused the 
> hell out of me until I realized do_wp_page() was calling set_page_dirty 
> too).
> 
> > How then is the filesystem supposed to guarantee that whatever structure
> > it allocated in page_mkwrite() is still around when the page gets marked
> > as dirty a second time?
> 
> Can page_mkwrite() be made responsible for marking the page dirty, instead 
> of doing it from do_wp_page()?  That would allow the fs to do the dirtying 
> under the protection of the page lock, or whatever other internal locking 
> scheme it has.  That's how the regular write path works, and it would be 
> nice to be able to just call write_{begin,end} from ->page_mkwrite() (as 
> at least ext4 does) without being followed by a second racy call to 
> ->set_page_dirty()...

No because the VM also needs to cover races where the page is dirtied
after the pte is set made writable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
