Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 762C76B0047
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 03:15:26 -0400 (EDT)
In-reply-to: <1240519320.5602.9.camel@heimdal.trondhjem.org> (message from
	Trond Myklebust on Thu, 23 Apr 2009 16:42:00 -0400)
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org>
Message-Id: <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 24 Apr 2009 09:15:22 +0200
Sender: owner-linux-mm@kvack.org
To: trond.myklebust@fys.uio.no
Cc: miklos@szeredi.hu, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Apr 2009, Trond Myklebust wrote:
> On Thu, 2009-04-23 at 21:52 +0200, Miklos Szeredi wrote:
> > Now this is mostly done at page fault time, and the pte's are always
> > being re-protected whenever the PG_dirty flag is cleared (see
> > page_mkclean()).
> > 
> > But in some cases (shmfs being the example I know) pages are not write
> > protected and so zap_pte_range(), and other functions, still need to
> > transfer the pte dirtyness to the page flag.
> 
> My main worry is that this is all happening at munmap() time. There
> shouldn't be any more page faults after that completes (am I right?), so
> what other mechanism would transfer the pte dirtyness?

After munmap() a page fault will result in SIGSEGV.  A write access
during munmap(), when the vma has been removed but the page table is
still intact is more interesting.  But in that case the write fault
should also result in a SEGV, because it won't be able to find the
matching VMA.

Now lets see what happens if writeback is started against the page
during this limbo period.  page_mkclean() is called, which doesn't
find the vma, so it doesn't re-protect the pte.  But the PG_dirty will
be cleared regadless.  So AFAICS it can happen that the pte remains
dirty but the page is clean.

And in that case that set_page_dirty() in zap_pte_range() is
important, since the page could have been dirtied through the mapping
after the writeback finished.

> > Not sure how this matters to NFS though.  If the above is correct,
> > then the set_page_dirty() call in zap_pte_range() should always result
> > in a no-op, since the PG_dirty flag would already have been set by the
> > page fault...
> 
> If I can ignore the dirty flag on these occasions, then that would be
> great. That would enable me to get rid of that BUG_ON(PG_CLEAN) in
> write.c, and close the bug...

I don't think you can ignore the dirty flag...  

Hmm, I guess this is a bit nasty: the VM promises filesystems that
->page_mkwrite() will be called when the page is dirtied through a
mapping, _almost_ all of the time.  Except when munmap happens to race
with clear_page_dirty_for_io().

I don't have any ideas how this could be fixed, CC-ing linux-mm...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
