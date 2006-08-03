From: David Howells <dhowells@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com> 
References: <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>  <44CF3CB7.7030009@yahoo.com.au> 
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate race? 
Date: Thu, 03 Aug 2006 17:34:54 +0100
Message-ID: <11315.1154622894@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:

> >  
> >  	/*
> >  	 * Should we do an early C-O-W break?
> 
> Somewhere below here you're missing a hunk to deal with a failed
> page_mkwrite, needing to unlock_page(locked_page).  We don't have
> an example of a page_mkwrite in tree at present, but it seems
> reasonable to suppose that we not it should unlock the page.
> 
> Hmm, David Howells has an afs_file_page_mkwrite which sits waiting
> for an FsMisc page flag to be cleared: might that deadlock with the
> page lock held?  If so, it may need to unlock and relock the page,
> rechecking for truncation.
> 
> Hmmm, page_mkwrite when called from do_wp_page would not expect to
> be holding page lock: we don't want it called with in one case and
> without in the other.  Maybe do_no_page needs to unlock_page before
> calling page_mkwrite, lock_page after, and check page->mapping when
> VM_NOPAGE_LOCKED??

For what I'm using page_mkwrite() and PG_fs_misc for, there shouldn't be a
deadlock:

 (1) PG_fs_misc has to be set whilst we are holding the page lock after
     reading the page, since the VM could race with page release otherwise.

 (2) If the cache refuses to store the page, PG_fs_misc is cleared immediately
     before the page lock is released.

 (3) If the cache agrees to store the page, it will start the process of
     storing the page to disk, and doesn't require the page to remain locked.

     When the I/O is complete, the cache will call back into the netfs (AFS or
     NFS, for example) and the netfs will clear PG_fs_misc and wake up anyone
     waiting for it.  It will not attempt to lock the page.

 (4) If page_mkwrite() is called, it will simply call wait_on_page_fs_misc(),
     and will not attempt to lock the page.

I don't think the caller of page_mkwrite() ever has the page locked
currently.  It's possible someone else has the page locked, and that
page_mkwrite() might have to wait for it to become unlocked, depending on what
it wants to do.

But for the page being locked during reading, do_no_page() makes sure the page
is unlocked before page_mkwrite() can be called.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
