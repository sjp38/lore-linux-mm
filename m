Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l6O0BqQ2003255
	for <linux-mm@kvack.org>; Tue, 24 Jul 2007 01:11:53 +0100
Received: from an-out-0708.google.com (andd33.prod.google.com [10.100.30.33])
	by zps75.corp.google.com with ESMTP id l6O0Bods003075
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:11:50 -0700
Received: by an-out-0708.google.com with SMTP id d33so572548and
        for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:11:50 -0700 (PDT)
Message-ID: <b040c32a0707231711p3ea6b213wff15e7a58ee48f61@mail.gmail.com>
Date: Mon, 23 Jul 2007 17:11:49 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] fix hugetlb page allocation leak
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dequeue_huge_page() has a serious memory leak upon hugetlb page
allocation.  The for loop continues on allocating hugetlb pages out of
all allowable zone, where this function is supposedly only dequeue one
and only one pages.

Fixed it by breaking out of the for loop once a hugetlb page is found.


Signed-off-by: Ken Chen <kenchen@google.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f127940..d7ca59d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -84,6 +84,7 @@ static struct page *dequeue_huge_page(st
 			list_del(&page->lru);
 			free_huge_pages--;
 			free_huge_pages_node[nid]--;
+			break;
 		}
 	}
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
