Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 48FCD6B0062
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:53:45 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:12:59 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 4/12] ksm: break cow once unshared
In-Reply-To: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908031311590.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We kept agreeing not to bother about the unswappable shared KSM pages
which later become unshared by others: observation suggests they're not
a significant proportion.  But they are disadvantageous, and it is easier
to break COW to replace them by swappable pages, than offer statistics
to show that they don't matter; then we can stop worrying about them.

Doing this in ksm_do_scan, they don't go through cmp_and_merge_page on
this pass: give them a good chance of getting into the unstable tree
on the next pass, or back into the stable, by computing checksum now.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- ksm3/mm/ksm.c	2009-08-02 13:49:51.000000000 +0100
+++ ksm4/mm/ksm.c	2009-08-02 13:49:59.000000000 +0100
@@ -1275,6 +1275,14 @@ static void ksm_do_scan(unsigned int sca
 			return;
 		if (!PageKsm(page) || !in_stable_tree(rmap_item))
 			cmp_and_merge_page(page, rmap_item);
+		else if (page_mapcount(page) == 1) {
+			/*
+			 * Replace now-unshared ksm page by ordinary page.
+			 */
+			break_cow(rmap_item->mm, rmap_item->address);
+			remove_rmap_item_from_tree(rmap_item);
+			rmap_item->oldchecksum = calc_checksum(page);
+		}
 		put_page(page);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
