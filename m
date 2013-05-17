Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9AB6B6B0033
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:26:04 -0400 (EDT)
Message-ID: <519621A6.3010809@asianux.com>
Date: Fri, 17 May 2013 20:25:10 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/nommu.c: add additional check for vread() just like vwrite()
 has done.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>, walken@google.com, riel@redhat.com, khlebnikov@openvz.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


Since vwrite() has already check whether overflow, as a pair function,
vread() also need do the same thing.

Since vwrite() check the source buffer address, vread() should check
the destination buffer address.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/nommu.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 886e07c..0614ee1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -282,6 +282,10 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 
 long vread(char *buf, char *addr, unsigned long count)
 {
+	/* Don't allow overflow */
+	if ((unsigned long) buf + count < count)
+		count = -(unsigned long) buf;
+
 	memcpy(buf, addr, count);
 	return count;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
