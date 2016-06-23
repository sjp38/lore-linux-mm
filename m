Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCEFD828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:03:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so19319701wme.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:03:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10si5958960wjc.95.2016.06.23.02.03.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 02:03:52 -0700 (PDT)
Date: Thu, 23 Jun 2016 10:03:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm, vmstat: add infrastructure for per-node vmstats -fix
Message-ID: <20160623090348.GB1800@suse.de>
References: <201606230905.nsZvjT96%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201606230905.nsZvjT96%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>

The kbuild test robot reported the following

All warnings (new ones prefixed by >>):

   drivers/base/node.c: In function 'node_read_meminfo':
>> drivers/base/node.c:126:31: warning: passing argument 1 of 'node_page_state' makes pointer from integer without a cast [-Wint-conversion]
             nid, node_page_state(nid, NR_KERNEL_STACK) *
                                  ^~~
   In file included from include/linux/mm.h:991:0,
                    from drivers/base/node.c:7:
   include/linux/vmstat.h:184:22: note: expected 'struct pglist_data *' but argument is of type 'int'
    extern unsigned long node_page_state(struct pglist_data *pgdat,

This may be a problem due to a merge conflict. This is a fix for the mmotm
patch mm-vmstat-add-infrastructure-for-per-node-vmstats.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/base/node.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a3ae3ae34593..0a1b6433a76c 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -123,7 +123,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(sum_zone_node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(sum_zone_node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(i.sharedram),
-		       nid, node_page_state(nid, NR_KERNEL_STACK) *
+		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
 		       nid, K(sum_zone_node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(sum_zone_node_page_state(nid, NR_UNSTABLE_NFS)),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
