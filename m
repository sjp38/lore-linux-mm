Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF0916B0078
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 12:49:18 -0400 (EDT)
Date: Thu, 2 Jun 2011 09:48:41 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602164841.GK23047@sequoia.sous-sol.org>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602141927.GA2011@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602141927.GA2011@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: CAI Qian <caiqian@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

* Andrea Righi (andrea@betterlinux.com) wrote:
> mmh.. I can reproduce the bug also with the standard ubuntu (11.04)
> kernel. Could you post your .config?

Andrea (Righi), can you tell me if this WARN fires?  This looks
like a pure race between removing from list and checking list, i.e.
insufficient locking.

ksm_scan.mm_slot == the only registered mm

CPU 1 (bug program)		CPU 2 (ksmd)
				list_empty() is false
lock
ksm_scan.mm_slot
list_del
unlock
				slot == &ksm_mm_head (but list is now empty_)


diff --git a/mm/ksm.c b/mm/ksm.c
index 942dfc7..ab79a92 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1301,6 +1301,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
 		ksm_scan.mm_slot = slot;
 		spin_unlock(&ksm_mmlist_lock);
+		WARN_ON(slot == &ksm_mm_head);
 next_mm:
 		ksm_scan.address = 0;
 		ksm_scan.rmap_list = &slot->rmap_list;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
