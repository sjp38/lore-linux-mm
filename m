Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9312AC48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AD0E2075E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:44:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AD0E2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 061086B0003; Thu, 27 Jun 2019 14:44:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2CD08E0003; Thu, 27 Jun 2019 14:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1A898E0002; Thu, 27 Jun 2019 14:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDA726B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:44:09 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id z13so3445295qka.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:44:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=5eXF8HrcHLv0bUZt40sU/7oY+axHQovPmK50YAhtR10=;
        b=Ij7ra0yl1Zeed/YLVYYbqwDDg5fa3yDQ51NeCjgGbdZ0WC+aCwc+at00yP4T2Sjpju
         qzkek2/NPHo0JYe7zCQ33BCRIaH2mFwYXIseNenLFe2ZtFX0Qiu7uJqt2bbRg9+6vZx9
         5mKXlYCVaw0FboA072mq6sHIC6f9TX0Pk9PX71r7P+u5+J/SGvVdN7Q5PDRRt62TvCCt
         sZ12+5CwqPnjfZ2jwm0hkrNibKiWI1Or2e6gyTnHdadTtXki1HqpdVBG0IbRVEnIBRzA
         NzTXLu/HdWUw5yneBLPUmZ7wCIsDBRpCZLVpk4FvkKOpLqnS8btYfhwJn+I+VLVF5NFm
         yqwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4D1i8f5WBZYc6yw/jusGvUUlOx74eaKRlIjy8MnN/LPazJT4X
	uZHnDNveq8PSh3253mJtQbX5aewfRPZG24di9hP2w/g1x1WIF1s5RjOBkQKyT5w3S9F+a2PhFu3
	5dtFQBYG7eiC3NcjdI8LE8k7mS4WXiChhC1KPP+8iiq7+RkNMDh/djWxKmB8j9ywCdQ==
X-Received: by 2002:a37:96c4:: with SMTP id y187mr4855524qkd.462.1561661049564;
        Thu, 27 Jun 2019 11:44:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDMO5GH/6GE98aWtDM+fnrNSDJ+qAG5wp9pUSM+KS7jPlWdKrg0AHZyREWe9bk1I8fomkE
X-Received: by 2002:a37:96c4:: with SMTP id y187mr4855453qkd.462.1561661048304;
        Thu, 27 Jun 2019 11:44:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561661048; cv=none;
        d=google.com; s=arc-20160816;
        b=egVAB+r0DRRPJ8wrSDQU0XGxoOzsxLDvzPE515CCbCXNttIH97Z8d77FeNA8zqM4p+
         v4TjFMuhgfeoinX8Yrv/er4ldZZ7VWjIRlgRHPh0P6/XJ8qBL4QvoMq6+o5IZLHi2PBl
         G47XzfnPTnD7zbXld4oE58qvIDU0SD2XKzGZ7E9eKtDsYq6ssyrFcc/MDAQ9Ncr8Bhxl
         NGQ/TdTYm6XnKQ+ITrM0PhSC3Yqb6+YfpIjZlnfLrHb6a7azWYalRlh1eMGNEViKCMxn
         i9z6m2sDHIQFTjP2GTMbZkm8WIUE+gtZ8/QbAhz74l0EAQuzOFvUnQtMpKR1zSLcRQOS
         c0lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=5eXF8HrcHLv0bUZt40sU/7oY+axHQovPmK50YAhtR10=;
        b=FlJiYim0YMs9uqwyDs/mFyG+/VB33RfPgi0nx4ZFsYSZRIvlnevbeDwrw+JNghaEgq
         MFYbhA5lYVwmUZcgBz7vdKRlB0hcyTSsFktW+/6UhJE+UK5Is04yI0spJXREzTwWCo96
         5omXMtbppbYxCxMmLk0Pv6u0M+Vz2LSgm7m/gJ765pe3d+dfsLi4Uqg88fpnKNFi3Niw
         xVRl2hydDGutzTA238kqKmhelkIvVzuAAtPYwnBvrE3lNZys+c86e2+dQvvuKB90bqUV
         eWP5628I7LpXMKRbauEes4fHLUD1cYxa/k9P2HQhp/a53+k0w/KdJzfs0ec4Z6xMii8u
         xRUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d30si16956qve.15.2019.06.27.11.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 11:44:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 64712C05B1CD;
	Thu, 27 Jun 2019 18:43:46 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8CCD160126;
	Thu, 27 Jun 2019 18:43:37 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH-next v2] mm, memcg: Add ":deact" tag for reparented kmem caches in memcg_slabinfo
Date: Thu, 27 Jun 2019 14:43:24 -0400
Message-Id: <20190627184324.5875-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 27 Jun 2019 18:44:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With Roman's kmem cache reparent patch, multiple kmem caches of the same
type can be seen attached to the same memcg id. All of them, except
maybe one, are reparent'ed kmem caches. It can be useful to tag those
reparented caches by adding a new slab flag "SLAB_DEACTIVATED" to those
kmem caches that will be reparent'ed if it cannot be destroyed completely.

For the reparent'ed memcg kmem caches, the tag ":deact" will now be
shown in <debugfs>/memcg_slabinfo.

[v2: Set the flag in the common code as suggested by Roman.]

Signed-off-by: Waiman Long <longman@redhat.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  4 ++++
 mm/slab_common.c     | 15 +++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index fecf40b7be69..19ab1380f875 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,6 +116,10 @@
 /* Objects are reclaimable */
 #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
+/* Slab deactivation flag */
+#define SLAB_DEACTIVATED	((slab_flags_t __force)0x10000000U)
+
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 146d8eaa639c..464faaa9fd81 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -771,6 +771,7 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 		return;
 
 	__kmemcg_cache_deactivate(s);
+	s->flags |= SLAB_DEACTIVATED;
 
 	/*
 	 * memcg_kmem_wq_lock is used to synchronize memcg_params.dying
@@ -1533,7 +1534,7 @@ static int memcg_slabinfo_show(struct seq_file *m, void *unused)
 	struct slabinfo sinfo;
 
 	mutex_lock(&slab_mutex);
-	seq_puts(m, "# <name> <css_id[:dead]> <active_objs> <num_objs>");
+	seq_puts(m, "# <name> <css_id[:dead|deact]> <active_objs> <num_objs>");
 	seq_puts(m, " <active_slabs> <num_slabs>\n");
 	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
 		/*
@@ -1544,22 +1545,24 @@ static int memcg_slabinfo_show(struct seq_file *m, void *unused)
 
 		memset(&sinfo, 0, sizeof(sinfo));
 		get_slabinfo(s, &sinfo);
-		seq_printf(m, "%-17s root      %6lu %6lu %6lu %6lu\n",
+		seq_printf(m, "%-17s root       %6lu %6lu %6lu %6lu\n",
 			   cache_name(s), sinfo.active_objs, sinfo.num_objs,
 			   sinfo.active_slabs, sinfo.num_slabs);
 
 		for_each_memcg_cache(c, s) {
 			struct cgroup_subsys_state *css;
-			char *dead = "";
+			char *status = "";
 
 			css = &c->memcg_params.memcg->css;
 			if (!(css->flags & CSS_ONLINE))
-				dead = ":dead";
+				status = ":dead";
+			else if (c->flags & SLAB_DEACTIVATED)
+				status = ":deact";
 
 			memset(&sinfo, 0, sizeof(sinfo));
 			get_slabinfo(c, &sinfo);
-			seq_printf(m, "%-17s %4d%5s %6lu %6lu %6lu %6lu\n",
-				   cache_name(c), css->id, dead,
+			seq_printf(m, "%-17s %4d%-6s %6lu %6lu %6lu %6lu\n",
+				   cache_name(c), css->id, status,
 				   sinfo.active_objs, sinfo.num_objs,
 				   sinfo.active_slabs, sinfo.num_slabs);
 		}
-- 
2.18.1

