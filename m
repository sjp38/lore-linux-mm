Date: Thu, 8 Jun 2000 15:19:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Contention on ->i_shared_lock in dup_mmap()
Message-ID: <20000608151951.H3886@redhat.com>
References: <Pine.GSO.4.10.10006072235360.10800-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10006072235360.10800-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Wed, Jun 07, 2000 at 11:45:58PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 11:45:58PM -0400, Alexander Viro wrote:
> 
> 	In effect it's COW for ->mmap. Comments?

Sounds plausible, definitely.  However, for the lock to be shared by
mm's which share the mmap list, we need the mmap semaphore to be in
the shared structure.  What then locks the pointer from the mm to the
mmap struct?  In other words, if two tasks share the mmap list and
one blocks on the lock in the mmap list, there's no guarantee that it
still owns the lock when it wakes up.

Think about mm A (with threads X, Y, and Z):

	X forks
	Y starts a mmap COW
	Y goes for the mmap lock (still shared between X, Y and Z)
	Z goes for the mmap lock (still shared between X, Y and Z) 
	X does COW, goes for the mmap lock
	Y finishes, unlocks the two mmaps

Y and Z now have a different mmap, but Z is still waiting
for the old mmap lock on X's mmap list!

If the next thing X does is to exit, that exit may get the lock
before Z gets scheduled, so the mmap lock is deallocated while Z
is still waiting for it.

In other words, to make it work I think you also need to bump up the
refcount on the mmap struct when you wait on the mmap semaphore.  Is
there a danger, then, that we'll be doing unnecessary COW due to the
temporarily-raised refcount?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
