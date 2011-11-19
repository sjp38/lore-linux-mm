Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7B56B0072
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 14:54:38 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/5] Reduce compaction-related stalls...
Date: Sat, 19 Nov 2011 20:54:12 +0100
Message-Id: <1321732460-14155-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

Hi Mel,

these are the last compaction/MM related patches I'm using, to me it
looks like the latest changes regressed the reliability of compaction,
and with the below I seem to get good reliability instead.

The __GFP_NO_KSWAPD would also definitely regress it by preventing
sync compaction to run which is fundamental to make the movable
pageblock really movable. This further improves it by making sure sync
compaction is always run (see patch 4/8) but it also reduces the
migration overhead (see patch 5/8).

I think it'd be good to test 5/8 and see if it reduces the stalls a
bit with the usb stick writes. Probably it won't be enough but it
still worth a try and it sounds good idea anyway.

The direction in allowing async compaction to migrate all type of
pages (so we don't screw the movable pageblock) is good, but the
version you posted had blocker bugs so I think this is safer as a
start and you can hack it on top of this if you want. Until we have
that working really well, the __GFP_NO_KSWAPD patch isn't good idea
IMHO.

[PATCH 1/8] mm: compaction: Allow compaction to isolate dirty pages
[PATCH 2/8] mm: compaction: Use synchronous compaction for /proc/sys/vm/compact_memory
[PATCH 3/8] mm: check if we isolated a compound page during lumpy scan
[PATCH 4/8] mm: compaction: defer compaction only with sync_migration
[PATCH 5/8] mm: compaction: avoid overwork in migrate sync mode
[PATCH 6/8] Revert "mm: compaction: make isolate_lru_page() filter-aware"
[PATCH 7/8] Revert "vmscan: abort reclaim/compaction if compaction can proceed"
[PATCH 8/8] Revert "vmscan: limit direct reclaim for higher order allocations"

btw, my aa tree on git.kernel.org includes the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
