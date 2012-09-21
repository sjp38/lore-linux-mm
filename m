Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 68F7E6B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 23:28:44 -0400 (EDT)
Message-ID: <505BDF34.3080905@oracle.com>
Date: Fri, 21 Sep 2012 11:29:56 +0800
From: Zhenzhong Duan <zhenzhong.duan@oracle.com>
Reply-To: zhenzhong.duan@oracle.com
MIME-Version: 1.0
Subject: mm: frontswap: fix a wrong if condition in frontswap_shrink
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, levinsasha928@gmail.com, Feng Jin <joe.jin@oracle.com>

pages_to_unuse is set to 0 to unuse all frontswap pages
But that doesn't happen since a wrong condition in frontswap_shrink
cancels it.

Signed-off-by: Zhenzhong Duan <zhenzhong.duan@oracle.com>
---
 mm/frontswap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 6b3e71a..db2a86f 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -275,7 +275,7 @@ static int __frontswap_shrink(unsigned long target_pages,
 	if (total_pages <= target_pages) {
 		/* Nothing to do */
 		*pages_to_unuse = 0;
-		return 0;
+		return 1;
 	}
 	total_pages_to_unuse = total_pages - target_pages;
 	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
@@ -302,7 +302,7 @@ void frontswap_shrink(unsigned long target_pages)
 	spin_lock(&swap_lock);
 	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
 	spin_unlock(&swap_lock);
-	if (ret == 0 && pages_to_unuse)
+	if (ret == 0)
 		try_to_unuse(type, true, pages_to_unuse);
 	return;
 }
-- 
1.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
