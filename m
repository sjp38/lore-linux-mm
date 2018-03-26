Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 872BB6B0022
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 04:21:03 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t10-v6so607083ply.13
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 01:21:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r27sor4522668pfi.60.2018.03.26.01.21.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 01:21:02 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm/sparse: check __highest_present_section_nr only for a present section
Date: Mon, 26 Mar 2018 16:19:56 +0800
Message-Id: <20180326081956.75275-2-richard.weiyang@gmail.com>
In-Reply-To: <20180326081956.75275-1-richard.weiyang@gmail.com>
References: <20180326081956.75275-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

When searching a present section, there are two boundaries:

    * __highest_present_section_nr
    * NR_MEM_SECTIONS

And it is konwn, __highest_present_section_nr is a more strict boundary
than NR_MEM_SECTIONS. This means it would be necessary to check
__highest_present_section_nr only.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/sparse.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 505050346249..b6560029a16c 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -190,15 +190,13 @@ static inline int next_present_section_nr(int section_nr)
 		section_nr++;
 		if (present_section_nr(section_nr))
 			return section_nr;
-	} while ((section_nr < NR_MEM_SECTIONS) &&
-		 (section_nr <= __highest_present_section_nr));
+	} while ((section_nr <= __highest_present_section_nr));
 
 	return -1;
 }
 #define for_each_present_section_nr(start, section_nr)		\
 	for (section_nr = next_present_section_nr(start-1);	\
 	     ((section_nr >= 0) &&				\
-	      (section_nr < NR_MEM_SECTIONS) &&			\
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
-- 
2.15.1
