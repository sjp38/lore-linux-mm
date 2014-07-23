Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CD8236B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 00:03:17 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so811031pdb.19
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 21:03:17 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id gz9si1029277pbc.144.2014.07.22.21.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 21:03:16 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 757843EE0B6
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 13:03:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 88982AC06F9
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 13:03:14 +0900 (JST)
Received: from s00.gw.fujitsu.co.jp (s00.gw.nic.fujitsu.com [133.161.11.15])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C3E7E08003
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 13:03:14 +0900 (JST)
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [PATCH] slab: fix the alias count(via sysfs) of slab cache
Date: Wed, 23 Jul 2014 11:49:41 +0800
Message-Id: <1406087381-21400-1-git-send-email-guz.fnst@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

We mark some slabs(e.g. kmem_cache_node) as unmergeable via setting
refcount to -1, and their alias should be 0, not refcount-1, so correct
it here.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7300480..ac1a20a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4509,7 +4509,7 @@ SLAB_ATTR_RO(ctor);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->refcount - 1);
+	return sprintf(buf, "%d\n", s->refcount < 0 ? 0 : s->refcount - 1);
 }
 SLAB_ATTR_RO(aliases);
 
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
