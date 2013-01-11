Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4FE8F6B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 21:30:04 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/2] Fix wrong EOF compare
Date: Fri, 11 Jan 2013 11:30:00 +0900
Message-Id: <1357871401-7075-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>, Michal Nazarewicz <mina86@mina86.com>, Randy Dunlap <rdunlap@infradead.org>

The C standards allows the character type char to be singed or unsinged,
depending on the platform and compiler. Most of systems uses signed char,
but those based on PowerPC and ARM processors typically use unsigned char.
This can lead to unexpected results when the variable is used to compare
with EOF(-1). It happens my ARM system and this patch fixes it.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Alexander Nyberg <alexn@dsv.su.se>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/page_owner.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
index f0156e1..43dde96 100644
--- a/Documentation/page_owner.c
+++ b/Documentation/page_owner.c
@@ -32,12 +32,13 @@ int read_block(char *buf, FILE *fin)
 {
 	int ret = 0;
 	int hit = 0;
+	int val;
 	char *curr = buf;
 
 	for (;;) {
-		*curr = getc(fin);
-		if (*curr == EOF) return -1;
-
+		val = getc(fin);
+		if (val == EOF) return -1;
+		*curr = val;
 		ret++;
 		if (*curr == '\n' && hit == 1)
 			return ret - 1;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
