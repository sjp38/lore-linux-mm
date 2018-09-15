Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A51C8E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 01:25:07 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 20-v6so11813235ois.21
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 22:25:07 -0700 (PDT)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id x143-v6si4386104oia.376.2018.09.14.22.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 22:25:05 -0700 (PDT)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: use match_string() helper to simplify the code
Date: Sat, 15 Sep 2018 13:12:45 +0800
Message-ID: <1536988365-50310-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, aryabinin@virtuozzo.com, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

match_string() returns the index of an array for a matching string,
which can be used intead of open coded implementation.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/mempolicy.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2e76a8f..cfd26d7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2711,12 +2711,11 @@ void numa_default_policy(void)
 int mpol_parse_str(char *str, struct mempolicy **mpol)
 {
 	struct mempolicy *new = NULL;
-	unsigned short mode;
 	unsigned short mode_flags;
 	nodemask_t nodes;
 	char *nodelist = strchr(str, ':');
 	char *flags = strchr(str, '=');
-	int err = 1;
+	int err = 1, mode;
 
 	if (nodelist) {
 		/* NUL-terminate mode or flags string */
@@ -2731,12 +2730,8 @@ int mpol_parse_str(char *str, struct mempolicy **mpol)
 	if (flags)
 		*flags++ = '\0';	/* terminate mode string */
 
-	for (mode = 0; mode < MPOL_MAX; mode++) {
-		if (!strcmp(str, policy_modes[mode])) {
-			break;
-		}
-	}
-	if (mode >= MPOL_MAX)
+	mode = match_string(policy_modes, MPOL_MAX, str);
+	if (mode < 0)
 		goto out;
 
 	switch (mode) {
-- 
1.7.12.4
