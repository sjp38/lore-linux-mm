Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D2EEF6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 07:00:19 -0500 (EST)
Date: Mon, 22 Nov 2010 12:00:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] scripts: Fix gfp-translate for recent changes to gfp.h
Message-ID: <20101122120002.GB1890@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The recent changes to gfp.h to satisfy sparse broke
scripts/gfp-translate. This patch fixes it up to work with old and new
versions of gfp.h .

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 scripts/gfp-translate |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/scripts/gfp-translate b/scripts/gfp-translate
index d81b968..128937e 100644
--- a/scripts/gfp-translate
+++ b/scripts/gfp-translate
@@ -63,7 +63,12 @@ fi
 
 # Extract GFP flags from the kernel source
 TMPFILE=`mktemp -t gfptranslate-XXXXXX` || exit 1
-grep "^#define __GFP" $SOURCE/include/linux/gfp.h | sed -e 's/(__force gfp_t)//' | sed -e 's/u)/)/' | grep -v GFP_BITS | sed -e 's/)\//) \//' > $TMPFILE
+grep ___GFP $SOURCE/include/linux/gfp.h > /dev/null
+if [ $? -eq 0 ]; then
+	grep "^#define ___GFP" $SOURCE/include/linux/gfp.h | sed -e 's/u$//' | grep -v GFP_BITS > $TMPFILE
+else
+	grep "^#define __GFP" $SOURCE/include/linux/gfp.h | sed -e 's/(__force gfp_t)//' | sed -e 's/u)/)/' | grep -v GFP_BITS | sed -e 's/)\//) \//' > $TMPFILE
+fi
 
 # Parse the flags
 IFS="

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
