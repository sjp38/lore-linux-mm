Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A44AC6B0261
	for <linux-mm@kvack.org>; Tue,  3 May 2016 01:23:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 4so18957580pfw.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:21 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id w63si2323520pfw.96.2016.05.02.22.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 22:23:21 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id 77so5068275pfv.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:20 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 5/6] tools/vm/page_owner: increase temporary buffer size
Date: Tue,  3 May 2016 14:23:03 +0900
Message-Id: <1462252984-8524-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
