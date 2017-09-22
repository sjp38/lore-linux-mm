Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E682C6B025F
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 15:52:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m30so3859195pgn.2
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 12:52:32 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id u1si294325plb.589.2017.09.22.12.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 12:52:31 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 1/2] tools: slabinfo: add "-U" option to show unreclaimable slabs only
Date: Sat, 23 Sep 2017 03:52:06 +0800
Message-Id: <1506109927-17012-2-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1506109927-17012-1-git-send-email-yang.s@alibaba-inc.com>
References: <1506109927-17012-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add "-U" option to show unreclaimable slabs only.

"-U" and "-S" together can tell us what unreclaimable slabs use the most
memory to help debug huge unreclaimable slabs issue.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 tools/vm/slabinfo.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index b9d34b3..de8fa11 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -83,6 +83,7 @@ struct aliasinfo {
 int sort_loss;
 int extended_totals;
 int show_bytes;
+int unreclaim_only;
 
 /* Debug options */
 int sanity;
@@ -132,6 +133,7 @@ static void usage(void)
 		"-L|--Loss              Sort by loss\n"
 		"-X|--Xtotals           Show extended summary information\n"
 		"-B|--Bytes             Show size in bytes\n"
+		"-U|--Unreclaim		Show unreclaimable slabs only\n"
 		"\nValid debug options (FZPUT may be combined)\n"
 		"a / A          Switch on all debug options (=FZUP)\n"
 		"-              Switch off all debug options\n"
@@ -568,6 +570,9 @@ static void slabcache(struct slabinfo *s)
 	if (strcmp(s->name, "*") == 0)
 		return;
 
+	if (unreclaim_only && s->reclaim_account)
+		return;
+
 	if (actual_slabs == 1) {
 		report(s);
 		return;
@@ -1346,6 +1351,7 @@ struct option opts[] = {
 	{ "Loss", no_argument, NULL, 'L'},
 	{ "Xtotals", no_argument, NULL, 'X'},
 	{ "Bytes", no_argument, NULL, 'B'},
+	{ "Unreclaim", no_argument, NULL, 'U'},
 	{ NULL, 0, NULL, 0 }
 };
 
@@ -1357,7 +1363,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXB",
+	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXBU",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1438,6 +1444,9 @@ int main(int argc, char *argv[])
 		case 'B':
 			show_bytes = 1;
 			break;
+		case 'U':
+			unreclaim_only = 1;
+			break;
 		default:
 			fatal("%s: Invalid option '%c'\n", argv[0], optopt);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
