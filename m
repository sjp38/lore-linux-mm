Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f41.google.com (mail-vn0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 64A2D6B006E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:44 -0400 (EDT)
Received: by vnbg7 with SMTP id g7so8120497vnb.10
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:44 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 25si1176043yhq.140.2015.04.14.13.56.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 13:56:41 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 01/11] mm: debug: format flags in a buffer
Date: Tue, 14 Apr 2015 16:56:23 -0400
Message-Id: <1429044993-1677-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

Format various flags to a string buffer rather than printing them. This is
a helper for later.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/debug.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2..c9f7dd7 100644
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
+                		"%s%s", delim, names[i].name);
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
