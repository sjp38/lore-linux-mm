Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D3E7A6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 21:02:31 -0400 (EDT)
Date: Fri, 3 Jun 2011 17:54:20 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: [PATCH] ksm: fix NULL pointer dereference in scan_get_next_rmap_item
Message-ID: <20110604005420.GR23047@sequoia.sous-sol.org>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602141927.GA2011@thinkpad>
 <20110602164841.GK23047@sequoia.sous-sol.org>
 <20110602173549.GL23047@sequoia.sous-sol.org>
 <alpine.LSU.2.00.1106030934130.1810@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106030934130.1810@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wright <chrisw@sous-sol.org>, Andrea Righi <andrea@betterlinux.com>, CAI Qian <caiqian@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Hugh Dickins (hughd@google.com) wrote:
> On Thu, 2 Jun 2011, Chris Wright wrote:
> > Close this race by revalidating that the new slot is not simply the list
> > head again.
> 
> Remarkably similar to my patch: it must be good!

Indeed ;)

> But yours appears to be more popular - thanks, Chris.

But I like the comment in yours better...

Andrew, here's a refresh w/ the acks/tested-bys/etc + AndreaR's test case
in the changelog.

thanks,
-chris
--

Subject: [PATCH] ksm: fix NULL pointer dereference in scan_get_next_rmap_item

From: Hugh Dickins <hughd@google.com>

Andrea Righi reported a case where an exiting task can race against
ksmd::scan_get_next_rmap_item (http://lkml.org/lkml/2011/6/1/742)
easily triggering a NULL pointer dereference in ksmd.

ksm_scan.mm_slot == &ksm_mm_head with only one registered mm

CPU 1 (__ksm_exit)		CPU 2 (scan_get_next_rmap_item)
 				list_empty() is false
lock				slot == &ksm_mm_head
list_del(slot->mm_list)		
(list now empty)
unlock
				lock
				slot = list_entry(slot->mm_list.next)
				(list is empty, so slot is still ksm_mm_head)
				unlock
				slot->mm == NULL ... Oops

Close this race by revalidating that the new slot is not simply the list
head again.

Andrea's test case:

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>

#define BUFSIZE getpagesize()

int main(int argc, char **argv)
{
	void *ptr;

	if (posix_memalign(&ptr, getpagesize(), BUFSIZE) < 0) {
		perror("posix_memalign");
		exit(1);
	}
	if (madvise(ptr, BUFSIZE, MADV_MERGEABLE) < 0) {
		perror("madvise");
		exit(1);
	}
	*(char *)NULL = 0;

	return 0;
}

Reported-by: Andrea Righi <andrea@betterlinux.com>
Tested-by: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: stable@kernel.org
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 mm/ksm.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index d708b3e..9a68b0c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1302,6 +1302,12 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
 		ksm_scan.mm_slot = slot;
 		spin_unlock(&ksm_mmlist_lock);
+		/*
+		 * Although we tested list_empty() above, a racing __ksm_exit
+		 * of the last mm on the list may have removed it since then.
+		 */
+		if (slot == &ksm_mm_head)
+			return NULL;
 next_mm:
 		ksm_scan.address = 0;
 		ksm_scan.rmap_list = &slot->rmap_list;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
