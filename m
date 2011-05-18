Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCE36B0024
	for <linux-mm@kvack.org>; Wed, 18 May 2011 17:14:47 -0400 (EDT)
Date: Wed, 18 May 2011 23:14:43 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap chain locking v2
Message-ID: <20110518211443.GB12317@one.firstfloor.org>
References: <1305330384-19540-1-git-send-email-andi@firstfloor.org> <1305330384-19540-2-git-send-email-andi@firstfloor.org> <20110518132547.24d665e1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518132547.24d665e1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, May 18, 2011 at 01:25:47PM -0700, Andrew Morton wrote:
> On Fri, 13 May 2011 16:46:21 -0700
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > In fork and exit it's quite common to take same rmap chain locks
> > again and again when the whole address space is processed  for a
> > address space that has a lot of sharing. Also since the locking
> > has changed to always lock the root anon_vma this can be very
> > contended.
> > 
> > This patch adds a simple wrapper to batch these lock acquisitions
> > and only reaquire the lock when another is needed. The main
> > advantage is that when multiple processes are doing this in
> > parallel they will avoid a lot of communication overhead
> > on the lock cache line.
> > 
> > v2: Address review feedback. Drop lockbreak. Rename init function.
> 
> Doesn't compile:
> 
> include/linux/rmap.h: In function 'anon_vma_unlock_batch':
> include/linux/rmap.h:146: error: 'struct anon_vma' has no member named 'lock'
> mm/rmap.c: In function '__anon_vma_lock_batch':
> mm/rmap.c:1737: error: 'struct anon_vma' has no member named 'lock'
> mm/rmap.c:1739: error: 'struct anon_vma' has no member named 'lock'
> 
> I think I reported this against the v1 patches.

Hmm is that against -mm? Which tree exactly?

Both in Linus' latest and in -next I have

include/linux/rmap.h:

struct anon_vma {
        struct anon_vma *root;  /* Root of this anon_vma tree */
        spinlock_t lock;        /* Serialize access to vma list */

So it should compile. And it compiles here of course.

To be honest I forgot where the -mm tree is, so I can't check. 
It's not in its old place on kernel.org anymore?

I'll look into checkpatch.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
