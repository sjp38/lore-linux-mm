Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3938B6B0088
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 17:20:33 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so15339046wiv.2
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 14:20:32 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id m10si6287390wia.3.2015.02.13.14.20.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 14:20:32 -0800 (PST)
From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH 2/3] mm: slub: parse slub_debug O option in switch statement
Date: Fri, 13 Feb 2015 16:19:36 -0600
Message-Id: <1423865980-10417-2-git-send-email-chris.j.arges@canonical.com>
In-Reply-To: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com>
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Chris J Arges <chris.j.arges@canonical.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

By moving the O option detection into the switch statement, we allow this
parameter to be combined with other options correctly. Previously options like
slub_debug=OFZ would only detect the 'o' and use DEBUG_DEFAULT_FLAGS to fill
in the rest of the flags.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 mm/slub.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 06cdb18..88482f8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1112,15 +1112,6 @@ static int __init setup_slub_debug(char *str)
 		 */
 		goto check_slabs;
 
-	if (tolower(*str) == 'o') {
-		/*
-		 * Avoid enabling debugging on caches if its minimum order
-		 * would increase as a result.
-		 */
-		disable_higher_order_debug = 1;
-		goto out;
-	}
-
 	slub_debug = 0;
 	if (*str == '-')
 		/*
@@ -1151,6 +1142,13 @@ static int __init setup_slub_debug(char *str)
 		case 'a':
 			slub_debug |= SLAB_FAILSLAB;
 			break;
+		case 'o':
+			/*
+			 * Avoid enabling debugging on caches if its minimum
+			 * order would increase as a result.
+			 */
+			disable_higher_order_debug = 1;
+			break;
 		default:
 			pr_err("slub_debug option '%c' unknown. skipped\n",
 			       *str);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
