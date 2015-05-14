Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 564616B006C
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:10:33 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so92965520pdb.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:10:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id hm2si33362483pdb.83.2015.05.14.10.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:10:32 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 01/11] mm: debug: format flags in a buffer
Date: Thu, 14 May 2015 13:10:04 -0400
Message-Id: <1431623414-1905-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name, Sasha Levin <sasha.levin@oracle.com>

Format various flags to a string buffer rather than printing them. This is
a helper for later.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/debug.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2..decebcf 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -80,6 +80,41 @@ static void dump_flags(unsigned long flags,
 	pr_cont(")\n");
 }
 
+static char *format_flags(unsigned long flags,
+			const struct trace_print_flags *names, int count,
+			char *buf, char *end)
+{
+	const char *delim = "";
+	unsigned long mask;
+	int i;
+
+	buf += snprintf(buf, (buf > end ? 0 : end - buf),
+				"flags: %#lx(", flags);
+
+	/* remove zone id */
+	flags &= (1UL << NR_PAGEFLAGS) - 1;
+
+	for (i = 0; i < count && flags; i++) {
+                mask = names[i].mask;
+                if ((flags & mask) != mask)
+                        continue;
+
+                flags &= ~mask;
+		buf += snprintf(buf, (buf > end ? 0 : end - buf),
+				"%s%s", delim, names[i].name);
+                delim = "|";
+        }
+
+        /* check for left over flags */
+        if (flags)
+		buf += snprintf(buf, (buf > end ? 0 : end - buf),
+                		"%s%#lx", delim, flags);
+
+	buf += snprintf(buf, (buf > end ? 0 : end - buf), ")\n");
+
+	return buf;
+}
+
 void dump_page_badflags(struct page *page, const char *reason,
 		unsigned long badflags)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
