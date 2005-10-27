Date: Thu, 27 Oct 2005 16:22:04 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027202204.GA8989@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <1130438135.23729.111.camel@localhost.localdomain> <20051027115050.7f5a6fb7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027115050.7f5a6fb7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, ak@suse.de, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 11:50:50AM -0700, Andrew Morton wrote:
> > or memory hotplug/virtualization stuff.
> 
> Really?  Are you sure?  Is this the only means by which the memory hotplug
> developers can free up shmem pages?  I think not...
> 
> > madvise(DONTNEED) is not really releasing the pagecache pages. So 
> > they want madvise(DISCARD).
> >
> > (2) Jeff Dike wants to use this for UML.
> 
> Why?  For what purpose?   Will he only ever want it for shmem segments?

I want this for memory hotplug.  This isn't the only possible
mechanism.  Others that will work are
	sys_punch
	a special driver that frees memory when its map count goes to
zero

I kludged the second into shmfs, but I wouldn't recommend it to
anyone.

madvise(DONT_NEED) doesn't work because it only actually frees memory
when called on anonymous pages.  I need dirty file-backed pages to be
freed as though they are clean.

An shmem-only implementation would work for me.  tmpfs is noticably
faster as backing for UML memory than a disk-based filesystem.
However, if a disk-backed filesystem is faster than tmpfs, then I'll
start wanting something more like sys_punch :-)

Ted's comment about freeing oldmemory might also be interesting for
UML.  In that case, __free_pages might invoke some host mechanism to
free the pages on the host.  The mechanism would have to be fast, and
I'm not sure how well it would do in practice because freed pages are
pretty likely to be reallocated quickly.  This could help when a bunch
of dirty anonymous pages get freed when a large process exits.  But if
the system is under any kind of memory pressure, freed pages will just
get reused immediately, so freeing them on the host would be
pointless.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
