Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6C846B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 16:25:54 -0400 (EDT)
Date: Wed, 18 May 2011 13:25:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking v2
Message-Id: <20110518132547.24d665e1.akpm@linux-foundation.org>
In-Reply-To: <1305330384-19540-2-git-send-email-andi@firstfloor.org>
References: <1305330384-19540-1-git-send-email-andi@firstfloor.org>
	<1305330384-19540-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, 13 May 2011 16:46:21 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> In fork and exit it's quite common to take same rmap chain locks
> again and again when the whole address space is processed  for a
> address space that has a lot of sharing. Also since the locking
> has changed to always lock the root anon_vma this can be very
> contended.
> 
> This patch adds a simple wrapper to batch these lock acquisitions
> and only reaquire the lock when another is needed. The main
> advantage is that when multiple processes are doing this in
> parallel they will avoid a lot of communication overhead
> on the lock cache line.
> 
> v2: Address review feedback. Drop lockbreak. Rename init function.

Doesn't compile:

include/linux/rmap.h: In function 'anon_vma_unlock_batch':
include/linux/rmap.h:146: error: 'struct anon_vma' has no member named 'lock'
mm/rmap.c: In function '__anon_vma_lock_batch':
mm/rmap.c:1737: error: 'struct anon_vma' has no member named 'lock'
mm/rmap.c:1739: error: 'struct anon_vma' has no member named 'lock'

I think I reported this against the v1 patches.


Please fix up the checkpatch errors?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
