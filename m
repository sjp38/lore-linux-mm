Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id CA6306B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 01:05:07 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] Fix wrong EOF compare
Date: Thu, 10 Jan 2013 15:05:04 +0900
Message-Id: <1357797904-11194-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>

getc returns "int" so EOF could be -1 but storing getc's return
value to char directly makes the vaule to 255 so below condition
is always false.

It happens in my ARM system so loop is not ended, then segfaulted.
This patch fixes it.

                *curr = getc(fin); // *curr = 255
                if (*curr == EOF) return -1; // if ( 255 == -1)

Cc: Mel Gorman <mgorman@suse.de>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Alexander Nyberg <alexn@dsv.su.se>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/page_owner.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
index f0156e1..b777fb6 100644
--- a/Documentation/page_owner.c
+++ b/Documentation/page_owner.c
@@ -32,12 +32,14 @@ int read_block(char *buf, FILE *fin)
 {
 	int ret = 0;
 	int hit = 0;
+	int vaule;
 	char *curr = buf;
 
 	for (;;) {
-		*curr = getc(fin);
-		if (*curr == EOF) return -1;
+		value = getc(fin);
+		if (value == EOF) return -1;
 
+		*curr = value;
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
