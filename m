Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 316906B01F2
	for <linux-mm@kvack.org>; Wed, 12 May 2010 13:42:00 -0400 (EDT)
Date: Wed, 12 May 2010 13:38:15 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 0/5] always lock the root anon_vma
Message-ID: <20100512133815.0d048a86@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This patch series implements Linus's suggestion of always locking the
root anon_vma.  Because the lock in other anon_vmas no longer protects
anything at all, we cannot do the "lock dance" that Mel's earlier
patches implements and instead need a root pointer in the anon_vma.

The only subtlety these patches rely on is that the same_vma list
is ordered from new to old, with the root anon_vma at the very end.

This, together with the forward list walking in unlink_anon_vmas,
ensures that the root anon_vma is the last one freed.

The KSM refcount adds some additional complexity, because an anon_vma
can stick around after the processes it was attached to have already
exited.  Patch 5/5 deals with that issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
