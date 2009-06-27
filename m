Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6E7F16B009B
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 03:12:53 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <3901.1245848839@redhat.com>
References: <3901.1245848839@redhat.com> <20090624023251.GA16483@localhost> <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com>
Subject: Found the commit that causes the OOMs
Date: Sat, 27 Jun 2009 08:12:49 +0100
Message-ID: <26537.1246086769@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


I've managed to bisect things to find the commit that causes the OOMs.  It's:

	commit 69c854817566db82c362797b4a6521d0b00fe1d8
	Author: MinChan Kim <minchan.kim@gmail.com>
	Date:   Tue Jun 16 15:32:44 2009 -0700

	    vmscan: prevent shrinking of active anon lru list in case of no swap space V3

	    shrink_zone() can deactivate active anon pages even if we don't have a
	    swap device.  Many embedded products don't have a swap device.  So the
	    deactivation of anon pages is unnecessary.

	    This patch prevents unnecessary deactivation of anon lru pages.  But, it
	    don't prevent aging of anon pages to swap out.

	    Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
	    Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	    Cc: Johannes Weiner <hannes@cmpxchg.org>
	    Acked-by: Rik van Riel <riel@redhat.com>
	    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
	    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

This exhibits the problem.  The previous commit:

	commit 35282a2de4e5e4e173ab61aa9d7015886021a821
	Author: Brice Goglin <Brice.Goglin@ens-lyon.org>
	Date:   Tue Jun 16 15:32:43 2009 -0700

	    migration: only migrate_prep() once per move_pages()

survives 16 iterations of the LTP syscall testsuite without exhibiting the
problem.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
