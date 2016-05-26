Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1C26B025F
	for <linux-mm@kvack.org>; Wed, 25 May 2016 22:38:13 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so92345562pac.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 19:38:13 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id p65si3038028pfa.60.2016.05.25.19.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 19:38:12 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id g132so447013pfb.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 19:38:12 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 5/7] tools/vm/page_owner: increase temporary buffer size
Date: Thu, 26 May 2016 11:37:53 +0900
Message-Id: <1464230275-25791-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Page owner will be changed to store more deep stacktrace
so current temporary buffer size isn't enough. Increase it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 tools/vm/page_owner_sort.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/vm/page_owner_sort.c b/tools/vm/page_owner_sort.c
index 77147b4..f1c055f 100644
--- a/tools/vm/page_owner_sort.c
+++ b/tools/vm/page_owner_sort.c
@@ -79,12 +79,12 @@ static void add_list(char *buf, int len)
 	}
 }
 
-#define BUF_SIZE	1024
+#define BUF_SIZE	(128 * 1024)
 
 int main(int argc, char **argv)
 {
 	FILE *fin, *fout;
-	char buf[BUF_SIZE];
+	char *buf;
 	int ret, i, count;
 	struct block_list *list2;
 	struct stat st;
@@ -107,6 +107,11 @@ int main(int argc, char **argv)
 	max_size = st.st_size / 100; /* hack ... */
 
 	list = malloc(max_size * sizeof(*list));
+	buf = malloc(BUF_SIZE);
+	if (!list || !buf) {
+		printf("Out of memory\n");
+		exit(1);
+	}
 
 	for ( ; ; ) {
 		ret = read_block(buf, BUF_SIZE, fin);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
