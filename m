Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D39226B0033
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:58:06 -0400 (EDT)
Message-ID: <5212E910.7030609@asianux.com>
Date: Tue, 20 Aug 2013 11:57:04 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm/mempolicy.c: still fill buffer as full as possible
 when buffer space is not enough in mpol_to_str()
References: <5212E8DF.5020209@asianux.com>
In-Reply-To: <5212E8DF.5020209@asianux.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, Cyrill Gorcunov <gorcunov@openvz.org>, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>hughd@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Need still try to fill buffer as full as possible if the buffer space
is not enough, commonly, the caller can bear of it (e.g. print warning
and still continue).

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/mempolicy.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 27022ca..c81b64f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2800,6 +2800,8 @@ out:
  * Convert a mempolicy into a string.
  * Returns the number of characters in buffer (if positive)
  * or an error (negative)
+ * If the buffer space is not enough, it will return -ENOSPC,
+ * and try to fill the buffer as full as possible.
  */
 int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
@@ -2842,11 +2844,10 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 		return -EINVAL;
 	}
 
+	strlcpy(p, policy_modes[mode], maxlen);
 	l = strlen(policy_modes[mode]);
 	if (buffer + maxlen < p + l + 1)
 		return -ENOSPC;
-
-	strcpy(p, policy_modes[mode]);
 	p += l;
 
 	if (flags & MPOL_MODE_FLAGS) {
@@ -2857,10 +2858,15 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 		/*
 		 * Currently, the only defined flags are mutually exclusive
 		 */
-		if (flags & MPOL_F_STATIC_NODES)
+		if (flags & MPOL_F_STATIC_NODES) {
 			p += snprintf(p, buffer + maxlen - p, "static");
-		else if (flags & MPOL_F_RELATIVE_NODES)
+			if (buffer + maxlen <= p)
+				return -ENOSPC;
+		} else if (flags & MPOL_F_RELATIVE_NODES) {
 			p += snprintf(p, buffer + maxlen - p, "relative");
+			if (buffer + maxlen <= p)
+				return -ENOSPC;
+		}
 	}
 
 	if (!nodes_empty(nodes)) {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
