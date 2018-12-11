Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1AD08E004D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 22:51:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so11579875pfj.15
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 19:51:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor19929557pgp.80.2018.12.10.19.51.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 19:51:35 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, sparse: remove check with __highest_present_section_nr in for_each_present_section_nr()
Date: Tue, 11 Dec 2018 11:51:28 +0800
Message-Id: <20181211035128.43256-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, Wei Yang <richard.weiyang@gmail.com>

A valid present section number is in [0, __highest_present_section_nr].
And the return value of next_present_section_nr() meets this
requirement. This means it is not necessary to check it with
__highest_present_section_nr again in for_each_present_section_nr().

Since we pass an unsigned long *section_nr* to
for_each_present_section_nr(), we need to cast it to int before
comparing.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/sparse.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index a4fdbcb21514..9eaa8f98a3d2 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -197,8 +197,7 @@ static inline int next_present_section_nr(int section_nr)
 }
 #define for_each_present_section_nr(start, section_nr)		\
 	for (section_nr = next_present_section_nr(start-1);	\
-	     ((section_nr >= 0) &&				\
-	      (section_nr <= __highest_present_section_nr));	\
+	     (int)section_nr >= 0;				\
 	     section_nr = next_present_section_nr(section_nr))
 
 static inline unsigned long first_present_section_nr(void)
-- 
2.15.1
