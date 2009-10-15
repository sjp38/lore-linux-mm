Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B5596B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:44:13 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:44:10 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/9] swap_info and swap_map patches
Message-ID: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a series of nine patches around the swap_info_struct: against
2.6.32-rc4, but intended for mmotm, which is currently similar here.

They start out with some old and not very important cleanups, but get
around to solving the swap count overflow problem: our handling above
32765 has depended on hoping that it won't coincide with other races.

That problem exists in theory today (when pid_max is raised from its
default), though never reported in practice; but the motivation for
solving it now comes from the impending KSM swapping patches - it
becomes very easy for anyone to overflow the maximum that way.

But most people will never have a swap count overflow in their life:
the benefit for them is that the vmalloc'ed swap_map halves in size.

This is all internal housekeeping: no change to actual swapping and
page reclaim.

 include/linux/swap.h |   66 ++-
 mm/memory.c          |   19 
 mm/page_io.c         |   19 
 mm/rmap.c            |    6 
 mm/shmem.c           |   11 
 mm/swapfile.c        |  834 +++++++++++++++++++++++++----------------
 6 files changed, 599 insertions(+), 356 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
