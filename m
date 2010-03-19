Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A41046B01AE
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:51:00 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 14:59:46 -0400
Message-Id: <20100319185946.21430.26966.sendpatchset@localhost.localdomain>
In-Reply-To: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/6] Mempolicy: Lose unnecessary loop variable in mpol_parse_str()
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

We don't really need the extra variable 'i' in mpol_parse_str().
The only use is as the the loop variable.  Then, it's assigned
to 'mode'.  Just use mode, and loose the 'uninitialized_var()'
macro.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c
===================================================================
--- linux-2.6.34-rc1-mmotm-100311-1313.orig/mm/mempolicy.c	2010-03-19 09:03:17.000000000 -0400
+++ linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c	2010-03-19 09:03:21.000000000 -0400
@@ -2154,12 +2154,11 @@ static const char * const policy_types[]
 int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 {
 	struct mempolicy *new = NULL;
-	unsigned short uninitialized_var(mode);
+	unsigned short mode;
 	unsigned short uninitialized_var(mode_flags);
 	nodemask_t nodes;
 	char *nodelist = strchr(str, ':');
 	char *flags = strchr(str, '=');
-	int i;
 	int err = 1;
 
 	if (nodelist) {
@@ -2175,13 +2174,12 @@ int mpol_parse_str(char *str, struct mem
 	if (flags)
 		*flags++ = '\0';	/* terminate mode string */
 
-	for (i = 0; i <= MPOL_LOCAL; i++) {
-		if (!strcmp(str, policy_types[i])) {
-			mode = i;
+	for (mode = 0; mode <= MPOL_LOCAL; mode++) {
+		if (!strcmp(str, policy_types[mode])) {
 			break;
 		}
 	}
-	if (i > MPOL_LOCAL)
+	if (mode > MPOL_LOCAL)
 		goto out;
 
 	switch (mode) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
