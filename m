Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08BF66B000C
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:21:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v17so6201922pff.9
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:21:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i15sor2216253pgr.134.2018.03.29.20.20.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 20:20:59 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: check __highest_present_sectioin_nr directly in memory_dev_init()
Date: Fri, 30 Mar 2018 11:20:44 +0800
Message-Id: <20180330032044.21647-1-richard.weiyang@gmail.com>
In-Reply-To: <20180326081956.75275-2-richard.weiyang@gmail.com>
References: <20180326081956.75275-2-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

__highest_present_section_nr is a more strict boundary than
NR_MEM_SECTIONS. So check __highest_present_sectioin_nr directly is enough.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 drivers/base/memory.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index fe4b24f05f6a..e79e3361f632 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -833,11 +833,8 @@ int __init memory_dev_init(void)
 	 * during boot and have been initialized
 	 */
 	mutex_lock(&mem_sysfs_mutex);
-	for (i = 0; i < NR_MEM_SECTIONS; i += sections_per_block) {
-		/* Don't iterate over sections we know are !present: */
-		if (i > __highest_present_section_nr)
-			break;
-
+	for (i = 0; i <= __highest_present_section_nr;
+		i += sections_per_block) {
 		err = add_memory_block(i);
 		if (!ret)
 			ret = err;
-- 
2.15.1
