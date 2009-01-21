Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F30D06B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 13:10:53 -0500 (EST)
Date: Wed, 21 Jan 2009 18:10:12 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090121143008.GV24891@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jan 2009, Nick Piggin wrote:
> 
> Since last posted, I've cleaned up a few bits and pieces, (hopefully)
> fixed a known bug where it wouldn't boot on memoryless nodes (I don't
> have a system to test with), and improved performance and reduced
> locking somewhat for node-specific and interleaved allocations.

I haven't reviewed your postings, but I did give the previous version
of your patch a try on all my machines.  Some observations and one patch.

I was initially _very_ impressed by how well it did on my venerable
tmpfs loop swapping loads, where I'd expected next to no effect; but
that turned out to be because on three machines I'd been using SLUB,
without remembering how default slub_max_order got raised from 1 to 3
in 2.6.26 (hmm, and Documentation/vm/slub.txt not updated).

That's been making SLUB behave pretty badly (e.g. elapsed time 30%
more than SLAB) with swapping loads on most of my machines.  Though
oddly one seems immune, and another takes four times as long: guess
it depends on how close to thrashing, but probably more to investigate
there.  I think my original SLUB versus SLAB comparisons were done on
the immune one: as I remember, SLUB and SLAB were equivalent on those
loads when SLUB came in, but even with boot option slub_max_order=1,
SLUB is still slower than SLAB on such tests (e.g. 2% slower).
FWIW - swapping loads are not what anybody should tune for.

So in fact SLQB comes in very much like SLAB, as I think you'd expect:
slightly ahead of it on most of the machines, but probably in the noise.
(SLOB behaves decently: not a winner, but no catastrophic behaviour.)

What I love most about SLUB is the way you can reasonably build with
CONFIG_SLUB_DEBUG=y, very little impact, then switch on the specific
debugging you want with a boot option when you want it.  That was a
great stride forward, which you've followed in SLQB: so I'd have to
prefer SLQB to SLAB (on debuggability) and to SLUB (on high orders).

I do hate the name SLQB.  Despite having no experience of databases,
I find it almost impossible to type, coming out as SQLB most times.
Wish you'd invented a plausible vowel instead of the Q; but probably
too late for that.

init/Kconfig describes it as "Qeued allocator": should say "Queued".

Documentation/vm/slqbinfo.c gives several compilation warnings:
I'd rather leave it to you to fix them, maybe the unused variables
are about to be used, or maybe there's much worse wrong with it
than a few compilation warnings, I didn't investigate.

The only bug I found (but you'll probably want to change the patch
- which I've rediffed to today's slqb.c, but not retested).

On fake NUMA I hit kernel BUG at mm/slqb.c:1107!  claim_remote_free_list()
is doing several things without remote_free.lock: that VM_BUG_ON is unsafe
for one, and even if others are somehow safe today, it will be more robust
to take the lock sooner.

I moved the prefetchw(head) down to where we know it's going to be the head,
and replaced the offending VM_BUG_ON by a later WARN_ON which you'd probably
better remove altogether: once we got the lock, it's hardly interesting.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/slqb.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

--- slqb/mm/slqb.c.orig	2009-01-21 15:23:54.000000000 +0000
+++ slqb/mm/slqb.c	2009-01-21 15:32:44.000000000 +0000
@@ -1115,17 +1115,12 @@ static void claim_remote_free_list(struc
 	void **head, **tail;
 	int nr;
 
-	VM_BUG_ON(!l->remote_free.list.head != !l->remote_free.list.tail);
-
 	if (!l->remote_free.list.nr)
 		return;
 
+	spin_lock(&l->remote_free.lock);
 	l->remote_free_check = 0;
 	head = l->remote_free.list.head;
-	/* Get the head hot for the likely subsequent allocation or flush */
-	prefetchw(head);
-
-	spin_lock(&l->remote_free.lock);
 	l->remote_free.list.head = NULL;
 	tail = l->remote_free.list.tail;
 	l->remote_free.list.tail = NULL;
@@ -1133,9 +1128,15 @@ static void claim_remote_free_list(struc
 	l->remote_free.list.nr = 0;
 	spin_unlock(&l->remote_free.lock);
 
-	if (!l->freelist.nr)
+	WARN_ON(!head + !tail != !nr + !nr);
+	if (!nr)
+		return;
+
+	if (!l->freelist.nr) {
+		/* Get head hot for likely subsequent allocation or flush */
+		prefetchw(head);
 		l->freelist.head = head;
-	else
+	} else
 		set_freepointer(s, l->freelist.tail, head);
 	l->freelist.tail = tail;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
