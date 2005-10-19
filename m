Date: Wed, 19 Oct 2005 18:56:59 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
In-Reply-To: <1129651502.23632.63.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
References: <1129570219.23632.34.camel@localhost.localdomain>
 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
 <1129651502.23632.63.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Chris Wright <chrisw@osdl.org>, Jeff Dike <jdike@addtoit.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Oct 2005, Badari Pulavarty wrote:
> 
> As you suggested, here is the patch to add SHM_NORESERVE which does 
> same thing as MAP_NORESERVE. This flag is ignored for OVERCOMMIT_NEVER.
> I decided to do SHM_NORESERVE instead of IPC_NORESERVE - just to limit
> its scope.

Good, yes, SHM_NORESERVE is a better name.

> BTW, there is a call to security_shm_alloc() earlier, which could
> be modified to reject shmget() if it needs to.

Excellent.  But it can only see shp, and the
	shp->shm_flags = (shmflg & S_IRWXUGO);
will conceal SHM_NORESERVE from it.

Since nothing in security/ is worrying about MAP_NORESERVE at present,
perhaps you need not bother about this for now.  But easily overlooked
later if MAP_NORESERVE rejection is added.

> Is this reasonable ? Please review.

Looks fine as far as it goes, except for the typos in the comment
+		 * Do not allow no accouting for OVERCOMMIT_NEVER, even
+	 	 * its asked for.
should be
		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
		 * if it's asked for.
(rather a lot of negatives, but okay there I think!)

I say "as far as it goes" because I don't think it's actually going to
achieve the effect you said you wanted in your original post.

As you've probably noticed, switching off VM_ACCOUNT here will mean that
the shm object is accounted page by page as it's instantiated, and I
expect you're okay with that.  But you want madvise(DONTNEED) to free
up those reservations: it'll unmap the pages from userspace, but it
won't free the pages from the shm object, so the reservations will
still be in force, and accumulate.

To achieve the effect you want, along these lines, there needs to be
a way to truncate pages out of the middle of the shm object: I believe
"punch holes" is the phrase that's been used when this kind of behaviour
has been discussed (not particularly in relation to tmpfs) before.
Some have proposed a sys_punch syscall to the VFS.

Jeff Dike had a patch for like functionality for UML, via a /dev/anon
to tmpfs, nearly two years ago.  I've kept his mail in my TODO folder
ever since, ambivalent about it, and never got around to giving it the
review needed.  I've a feeling time has moved on so far that Jeff may
now be achieving the effect he needs by other means (remap_file_pages?).

Is /dev/anon still of interest to you, Jeff?  Not that I'm any closer
to the point of thinking about it now than then, just want to factor
your idea in with what Badari is thinking of.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
