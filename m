Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2B16B0036
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 03:42:50 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so284237yho.2
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 00:42:50 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id z21si174871yhb.199.2014.01.08.00.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 00:42:49 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 01:42:48 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E18F33E40040
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 01:42:45 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s088gj9W10223940
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 09:42:45 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s088gjpm032007
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 01:42:45 -0700
Date: Wed, 8 Jan 2014 16:42:42 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: [RFC] mm: prevent set a value less than 0 to min_free_kbytes
Message-ID: <20140108084242.GA10485@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

If echo -1 > /proc/vm/sys/min_free_kbytes, the system will hang.
Changing proc_dointvec() to proc_dointvec_minmax() in the
min_free_kbytes_sysctl_handler() can prevent this to happen.

Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>
---
 mm/page_alloc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77937e0..a9dcfd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5692,7 +5692,12 @@ module_init(init_per_zone_wmark_min)
 int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
 	if (write) {
 		user_min_free_kbytes = min_free_kbytes;
 		setup_per_zone_wmarks();
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
