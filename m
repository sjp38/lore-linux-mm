Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8388FC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 17:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EC9C2075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 17:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EC9C2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E836B0005; Fri, 21 Jun 2019 13:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BEB98E0002; Fri, 21 Jun 2019 13:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 683DD8E0001; Fri, 21 Jun 2019 13:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473E36B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 13:30:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z5so8626255qth.15
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:30:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Aqt1EhZBKrmIdyDRXu7n5fZ8WqANYvWfAN+xOyfvpDk=;
        b=IrQvln9YPI7i+QJtQgTZG3VZ1Cejrno6ygJzX26ET92h7D/QZyIA4BUDjRb713CEb4
         FudS/d5lIeP82aPqdrDOl0Qkjm/GZ3+BNQRPca6SafwfhBsqMe9A1qw2YNWowFX8u1C8
         EXrcxwOSa9/GxpbreAJVyZq8Kia0KBMl0Vm/5p0o0y+kpU2Ir4jtmhDID8D7+J4G2xOE
         8BnRAsGFsLLhk2kYpmfNkPxc9sDbsJJ+LTedXLa7z7maXq/w4N+bQp3Zi4WOX+imwNkz
         XhErXk3hdrFC39VSpUbPEmPjoCIzX2tUJaKv4FF7e4LW2TuNXG07jlU5V0c2QSbbIJA1
         Sb/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzuzb2+KhtS85QAVRmiSe8otskBDGXKLnXWTpkWQ0Zw3jg2qST
	y5rCxQZV0hOGZ2/H4hhd6cugwq6kEp37fP2z5OEzePsxzD5LLQW4rm3/7H9/0ZQ+sH41Fz0vBid
	xwN/1d1M2OqduGA1vRoKkhxiGbRfneY+WD/yg7Mu5NeZQhYvSvBPwH5E2ncbEueRaZw==
X-Received: by 2002:a0c:ae31:: with SMTP id y46mr46335625qvc.172.1561138241025;
        Fri, 21 Jun 2019 10:30:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN43aXzMvxlnlx7sp5q8aOngsQHo+aPxPmpNDz5jBuJ3J4QWvIBgnriuxKnZwUlKtze85M
X-Received: by 2002:a0c:ae31:: with SMTP id y46mr46335551qvc.172.1561138240143;
        Fri, 21 Jun 2019 10:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561138240; cv=none;
        d=google.com; s=arc-20160816;
        b=KHMNsrZhfpeaxLifOxMlkcysqysj3wLOQJRCGI4qHpyKfXPpqyjYFaq05+raXa1u1N
         JPsWjL8C455Yl7yMPRff+Wxasw1ew4iVqfurYI0+Fm4BtKyMhg8XGKLHTia6p1bXMMg8
         BmlrKL+rsNKox63lkpGfa4437zAfJwEIlWqXrWMoVmclW1zQtPPpizmqWebH9z448jri
         FkQxTrcLiTHwhCoc3B0VgLAlle6DeKzb/2KoTjo+Q8wm/o9LdV9Z+hr1fgkj1YqcCyc/
         XhnmgTZb/20xEQLWelZhUJCaegH5cBQ/ktZFcWBCFb0tZfDpbbL4mQSBdV9+qY2VsAL7
         aOJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Aqt1EhZBKrmIdyDRXu7n5fZ8WqANYvWfAN+xOyfvpDk=;
        b=JXUSx71uPcnssCC2YhAn72w0/jm7YkapBuIBxnX7dr9iNB18RICE7gmnPCdYV37Zaf
         XliNYrXIpfE/9tIXsJBSJvF/asqhmmtrmpz+8AMa0kZGp7H/mj7zPfDm8hXxVlR51osF
         1SldXfCP8yN9rSthLHhJt7sn+3UWydR/O9i802UuiofYi5qatkS6HRYBIdGyCNVSHSUo
         0v6QL2JIf2uzUWkmHNb6QoD/fYLBP4Fn8tHfCfnQ+2pQenCPotQt2uZgzKweOgFn8j4J
         h8jDN1oCllf+VrV1oGFTIwk5YuFuaj57UaM7Yp5I0kRTvKNDiTilorL+IfOjIodVuxzM
         TehQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v29si2214319qtj.132.2019.06.21.10.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 10:30:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2D41D308FC5F;
	Fri, 21 Jun 2019 17:30:29 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DDD0519C68;
	Fri, 21 Jun 2019 17:30:22 +0000 (UTC)
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
Subject: [PATCH-next] mm, memcg: Add ":deact" tag for reparented kmem caches in memcg_slabinfo
Date: Fri, 21 Jun 2019 13:30:05 -0400
Message-Id: <20190621173005.31514-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 21 Jun 2019 17:30:34 +0000 (UTC)
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

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/slab.h |  4 ++++
 mm/slab.c            |  1 +
 mm/slab_common.c     | 14 ++++++++------
 mm/slub.c            |  1 +
 4 files changed, 14 insertions(+), 6 deletions(-)

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
diff --git a/mm/slab.c b/mm/slab.c
index a2e93adf1df0..e8c7743fc283 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2245,6 +2245,7 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
 #ifdef CONFIG_MEMCG
 void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
 {
+	cachep->flags |= SLAB_DEACTIVATED;
 	__kmem_cache_shrink(cachep);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 146d8eaa639c..85cf0c374303 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1533,7 +1533,7 @@ static int memcg_slabinfo_show(struct seq_file *m, void *unused)
 	struct slabinfo sinfo;
 
 	mutex_lock(&slab_mutex);
-	seq_puts(m, "# <name> <css_id[:dead]> <active_objs> <num_objs>");
+	seq_puts(m, "# <name> <css_id[:dead|deact]> <active_objs> <num_objs>");
 	seq_puts(m, " <active_slabs> <num_slabs>\n");
 	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
 		/*
@@ -1544,22 +1544,24 @@ static int memcg_slabinfo_show(struct seq_file *m, void *unused)
 
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
diff --git a/mm/slub.c b/mm/slub.c
index a384228ff6d3..c965b4413658 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4057,6 +4057,7 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slub_set_cpu_partial(s, 0);
 	s->min_partial = 0;
+	s->flags |= SLAB_DEACTIVATED;
 }
 #endif	/* CONFIG_MEMCG */
 
-- 
2.18.1

