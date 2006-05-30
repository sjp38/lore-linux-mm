From: David Howells <dhowells@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0605260825160.31609@schroedinger.engr.sgi.com> 
References: <Pine.LNX.4.64.0605260825160.31609@schroedinger.engr.sgi.com>  <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com> <20060525135534.20941.91650.sendpatchset@lappy> <20060525135555.20941.36612.sendpatchset@lappy> <24747.1148653985@warthog.cambridge.redhat.com> 
Subject: Re: [PATCH 1/3] mm: tracking shared dirty pages 
Date: Tue, 30 May 2006 09:00:35 +0100
Message-ID: <12042.1148976035@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:

> > page_mkwrite() is called just before the _PTE_ is dirtied.  Take
> > do_wp_page() for example, set_page_dirty() is called after a lot of stuff,
> > including some stuff that marks the PTE dirty... by which time it's too
> > late as another thread sharing the page tables can come along and modify
> > the page before the first thread calls set_page_dirty().
> 
> Since we are terminating the application with extreme prejudice on an 
> error (SIGBUS) it does not matter if another process has written to the 
> page in the meantime.

Erm... Yes, it does matter, at least for AFS or NFS using FS-Cache, and whether
or not we're generating a SIGBUS or just proceeding normally.  There are two
cases I've come across:

Firstly I use page_mkwrite() to make sure that the page is written to the cache
before we let anyone modify it, just so that we've got a reasonable idea of
what's in the cache.

What we currently have is:

	invoke page_mkwrite()
	  - wait for page to be written to the cache
	lock
	modify PTE
	unlock
	invoke set_page_dirty()

What your suggestion gives is:

	lock
	modify PTE
	unlock
	invoke set_page_dirty()
	  - wait for page to be written to the cache

But what can happen is:

	CPU 1			CPU 2
	=======================	=======================
	write to page (faults)
	lock
	modify PTE
	unlock
				write to page (succeeds)
	invoke set_page_dirty()
	  - wait for page to be written to the cache
	write to page (succeeds)

That potentially lets data of uncertain state into the cache, which means we
can't trust what's in the cache any longer.

Secondly some filesystems want to use page_mkwrite() to prevent a write from
occurring if a write to a shared writable mapping would require an allocation
from a filesystem that's currently in an ENOSPC state.  That means that we may
not change the PTE until we're sure that the allocation is guaranteed to
succeed, and that means that the kernel isn't left with dirty pages attached to
inodes it'd like to dispose of but can't because there's nowhere to write the
data.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
