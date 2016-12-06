Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A68FA6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 00:52:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so422784138pgx.6
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 21:52:53 -0800 (PST)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id 90si17930987pla.214.2016.12.05.21.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 21:52:52 -0800 (PST)
Received: by mail-pg0-x22a.google.com with SMTP id 3so145421166pgd.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 21:52:52 -0800 (PST)
Date: Mon, 5 Dec 2016 21:52:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: change shmem_mapping() to test shmem_aops
Message-ID: <alpine.LSU.2.11.1612052148530.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

Callers of shmem_mapping() are interested in whether the mapping is
swap backed - except for uprobes, which is interested in whether it
should use shmem_read_mapping_page().  All these callers are better
served by a shmem_mapping() which checks for shmem_aops, than the
current version which goes through several indirections to find where
the inode lives - and has the surprising effect that a private mmap of
/dev/zero satisfies both vma_is_anonymous() and shmem_mapping(), when
that device node is on devtmpfs.  I don't think anything in the tree
suffers from that surprise, but it caught me out, and is better fixed.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- 4.9-rc8/mm/shmem.c	2016-11-13 11:44:43.052622519 -0800
+++ linux/mm/shmem.c	2016-12-05 18:54:25.348596732 -0800
@@ -2131,10 +2131,7 @@ static struct inode *shmem_get_inode(str
 
 bool shmem_mapping(struct address_space *mapping)
 {
-	if (!mapping->host)
-		return false;
-
-	return mapping->host->i_sb->s_op == &shmem_ops;
+	return mapping->a_ops == &shmem_aops;
 }
 
 #ifdef CONFIG_TMPFS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
