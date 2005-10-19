Date: Wed, 19 Oct 2005 14:32:02 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
Message-ID: <20051019183202.GA8120@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain> <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com> <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com> <1129651502.23632.63.camel@localhost.localdomain> <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Chris Wright <chrisw@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 19, 2005 at 06:56:59PM +0100, Hugh Dickins wrote:
> To achieve the effect you want, along these lines, there needs to be
> a way to truncate pages out of the middle of the shm object: I believe
> "punch holes" is the phrase that's been used when this kind of behaviour
> has been discussed (not particularly in relation to tmpfs) before.
> Some have proposed a sys_punch syscall to the VFS.
> 
> Jeff Dike had a patch for like functionality for UML, via a /dev/anon
> to tmpfs, nearly two years ago.  I've kept his mail in my TODO folder
> ever since, ambivalent about it, and never got around to giving it the
> review needed.  I've a feeling time has moved on so far that Jeff may
> now be achieving the effect he needs by other means (remap_file_pages?).
> 
> Is /dev/anon still of interest to you, Jeff?  Not that I'm any closer
> to the point of thinking about it now than then, just want to factor
> your idea in with what Badari is thinking of.

Yes, either sys_punch or something like /dev/anon is still needed.  I need to
be able to dirty file-backed pages and tell the host to drop them as though
they were clean.  Punching a hole in the middle of the file, effectively
sparsing it, or having a special driver that drops pages when their map count
goes to zero will both work for me.  This will avoid having the host swap out
pages that are clean from the UML point of view (but dirty from the host's
point of view).  It will also allow me to free memory back to the host, 
allowing memory to be added and removed dynamically from UML instances.

remap_file_pages is entirely different.  That decreases the number of vmas,
which, for some reason that is mysterious to me, dramatically increases UML
performance.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
