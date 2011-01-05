Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A69DF6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 15:17:17 -0500 (EST)
Received: by pvc30 with SMTP id 30so3534557pvc.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 12:17:10 -0800 (PST)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH V2] Fix handling of parse errors in sysfs
Date: Wed,  5 Jan 2011 13:16:33 -0700
Message-Id: <1294258593-15009-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, caiqian@redhat.com, mhocko@suse.cz, Eric B Munson <emunson@mgebm.net>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

When parsing changes to the huge page pool sizes made from userspace
via the sysfs interface, bogus input values are being covered up
by nr_hugepages_store_common and nr_overcommit_hugepages_store
returning 0 when strict_strtoul returns an error.  This can cause an
infinite loop in the nr_hugepages_store code.  This patch changes
the return value for these functions to -EINVAL when strict_strtoul
returns an error.

Reported-by: CAI Qian <caiqian@redhat.com>

Signed-off-by: Eric B Munson <emunson@mgebm.net>
Cc: stable@kernel.org
---
Changes from V1
 Reword leader to show problem that is fixed by the patch
 Add stable@kernel.org as a CC to handle stable submission the right way

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
