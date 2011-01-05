Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 885336B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 12:14:52 -0500 (EST)
Received: by pzk27 with SMTP id 27so3869383pzk.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 09:09:02 -0800 (PST)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH] Fix handling of parse errors in sysctl
Date: Wed,  5 Jan 2011 10:08:49 -0700
Message-Id: <1294247329-11682-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, caiqian@redhat.com, stable@kernel.org, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

This patch is a candidate for stable.

==== CUT HERE ====

When parsing changes to the huge page pool sizes made from userspace
via the sysctl interface, bogus input values are being covered up
by nr_hugepages_store_common and nr_overcommit_hugepages_store
returning 0 when strict_strtoul returns an error.  This patch changes
the return value for these functions to -EINVAL when strict_strtoul
returns an error.

Reported-by: CAI Qian <caiqian@redhat.com>

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
 mm/hugetlb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8585524..5cb71a9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1440,7 +1440,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 
 	err = strict_strtoul(buf, 10, &count);
 	if (err)
-		return 0;
+		return -EINVAL;
 
 	h = kobj_to_hstate(kobj, &nid);
 	if (nid == NUMA_NO_NODE) {
@@ -1519,7 +1519,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 
 	err = strict_strtoul(buf, 10, &input);
 	if (err)
-		return 0;
+		return -EINVAL;
 
 	spin_lock(&hugetlb_lock);
 	h->nr_overcommit_huge_pages = input;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
