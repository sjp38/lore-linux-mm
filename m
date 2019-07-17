Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C903C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 20:25:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BCFA21851
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 20:25:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BCFA21851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 102826B0006; Wed, 17 Jul 2019 16:25:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08AEE6B0007; Wed, 17 Jul 2019 16:25:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFA618E0001; Wed, 17 Jul 2019 16:25:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE5AB6B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 16:25:33 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id v126so11737952vkv.20
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:25:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=BmEkLpst5kwPlKSI7S772IcYubMF0CrXoZA4uNUVPgY=;
        b=szpRPwuJpLVvsbSRpomSnrutHcziYD7wFzupSQ+GDmH8G4CT7EeP3eGu0KvTCHmKcp
         1VmoczWsW0OcvnYYPR8jC5jOok5MqbOxVFkAS9gj0vKbqNAIpeKdgl0ysDJzdL3YtGTV
         M1EuJmHfxBqwsjA2zGVsPgw0GhkgaWAtkxpcKJamIIs/+rVPaEKgqNhpmmRZ3Bcvz/yK
         KA1MTVPS2bL+JnwI+zbUh4pqlEZQbeCTAGTvzV65BUax7GG5JdRWTBSiM83pzKsAqsC8
         LMG9dcnQr+SpSKq99CNxe56LsnDBRcK4FcZ9rMyNYDxHf8zrJTzasLue+eePsCuc2vQj
         Akrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWSWhmQpubr8TRlcBV29/10gkGmA8qXGnjwofpKajiwixJi1q+I
	G8VNoXFfuVjJCf8ZBxkr50xGWJ1gis7vkpm/KyZspep8JcDGXpdFDMTn303BvqAf2lv3ZdK+poF
	moix4T71tVrmTFOP428E6JhhT4yZCewVYvWQNacAzLxKzHnhq1/YIGKsV6kECtD+VAw==
X-Received: by 2002:ab0:1391:: with SMTP id m17mr22470816uae.90.1563395133507;
        Wed, 17 Jul 2019 13:25:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUvnqZXQIdjG1YYq2vl8iptbxTcpz/Qi8zPMDzlgHV1N2xj8bMCI8aAucjlKQY/zN51UTJ
X-Received: by 2002:ab0:1391:: with SMTP id m17mr22470715uae.90.1563395132445;
        Wed, 17 Jul 2019 13:25:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563395132; cv=none;
        d=google.com; s=arc-20160816;
        b=JHNbb/iwMtC2KP7DgKk8KUjkyDphFKDhuZ6XdBxml2HZULc5umarMn+Zdo72Hxsu6r
         9Aoj2+qj1MygTFc7QJwhv4Tg+O2Da626q+eoPC6EUxXpLqqlKjdzYh9o1e0muSVlMe2e
         B3snET/XhFos4gBzzmRN+3PifNE+2Kr5ehm6N0WHMRig/oQ0twtRE2XmSZvuuhC5U9Mk
         fSJBkOFRWss6cqP4QGRPxMLjcNaUtko5AblvQtDGbLI/xOjKp0VHVAwsg9zdGd8zRB6f
         O2Muy6YMhm3iUXaf2QuPY90r5CMzAmRPRkPRGMVOJYXraoGIzyPG3g59oDSB3a/jyS5L
         egqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=BmEkLpst5kwPlKSI7S772IcYubMF0CrXoZA4uNUVPgY=;
        b=VP5yB6gQ4NTuQoE+7Kdk3d+vX6at5RA5C0np3EKfFMfDnQFbSvCmEHYzHHeQeZr6fK
         kv8OcsjhwnC6Thhxjz44k5ZVl1BGSwwrmXMkseDPHNAVQGB9d8i9lqHGgKFJKUbpY5H5
         KKdbKD3EZPKyt0l4ps58Y9G/uWjwcbYQiKDoJLcreG3RBHaeArAOKP21Z8uRfMDbrj59
         CNTaqG4iaJshg5MRlszgKBhGEhmHkH4H9NFkmY26m0NrS6KWzq68Q5aAs4cg/63W1Z6B
         XZvoGa88f1hYb4wa6WXumTTk2+iPhYATWggs1FOpgTRHAz5q6C/ZwusKv97CS9E9sEad
         ltrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u62si10059368vsu.198.2019.07.17.13.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 13:25:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 88D4A308FBAC;
	Wed, 17 Jul 2019 20:25:31 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 39D5D5C220;
	Wed, 17 Jul 2019 20:25:30 +0000 (UTC)
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
Subject: [PATCH v2 1/2] mm, slab: Extend slab/shrink to shrink all memcg caches
Date: Wed, 17 Jul 2019 16:24:12 -0400
Message-Id: <20190717202413.13237-2-longman@redhat.com>
In-Reply-To: <20190717202413.13237-1-longman@redhat.com>
References: <20190717202413.13237-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 17 Jul 2019 20:25:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
file to shrink the slab by flushing out all the per-cpu slabs and free
slabs in partial lists. This can be useful to squeeze out a bit more memory
under extreme condition as well as making the active object counts in
/proc/slabinfo more accurate.

This usually applies only to the root caches, as the SLUB_MEMCG_SYSFS_ON
option is usually not enabled and "slub_memcg_sysfs=1" not set. Even
if memcg sysfs is turned on, it is too cumbersome and impractical to
manage all those per-memcg sysfs files in a real production system.

So there is no practical way to shrink memcg caches.  Fix this by
enabling a proper write to the shrink sysfs file of the root cache
to scan all the available memcg caches and shrink them as well. For a
non-root memcg cache (when SLUB_MEMCG_SYSFS_ON or slub_memcg_sysfs is
on), only that cache will be shrunk when written.

On a 2-socket 64-core 256-thread arm64 system with 64k page after
a parallel kernel build, the the amount of memory occupied by slabs
before shrinking slabs were:

 # grep task_struct /proc/slabinfo
 task_struct        53137  53192   4288   61    4 : tunables    0    0
 0 : slabdata    872    872      0
 # grep "^S[lRU]" /proc/meminfo
 Slab:            3936832 kB
 SReclaimable:     399104 kB
 SUnreclaim:      3537728 kB

After shrinking slabs:

 # grep "^S[lRU]" /proc/meminfo
 Slab:            1356288 kB
 SReclaimable:     263296 kB
 SUnreclaim:      1092992 kB
 # grep task_struct /proc/slabinfo
 task_struct         2764   6832   4288   61    4 : tunables    0    0
 0 : slabdata    112    112      0

Signed-off-by: Waiman Long <longman@redhat.com>
Acked-by: Roman Gushchin <guro@fb.com>
---
 Documentation/ABI/testing/sysfs-kernel-slab | 12 ++++---
 mm/slab.h                                   |  1 +
 mm/slab_common.c                            | 37 +++++++++++++++++++++
 mm/slub.c                                   |  2 +-
 4 files changed, 47 insertions(+), 5 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 29601d93a1c2..94ffd47fc8d7 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -429,10 +429,14 @@ KernelVersion:	2.6.22
 Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
 		Christoph Lameter <cl@linux-foundation.org>
 Description:
-		The shrink file is written when memory should be reclaimed from
-		a cache.  Empty partial slabs are freed and the partial list is
-		sorted so the slabs with the fewest available objects are used
-		first.
+		The shrink file is used to enable some unused slab cache
+		memory to be reclaimed from a cache.  Empty per-cpu
+		or partial slabs are freed and the partial list is
+		sorted so the slabs with the fewest available objects
+		are used first.  It only accepts a value of "1" on
+		write for shrinking the cache. Other input values are
+		considered invalid.  If it is a root cache, all the
+		child memcg caches will also be shrunk, if available.
 
 What:		/sys/kernel/slab/cache/slab_size
 Date:		May 2007
diff --git a/mm/slab.h b/mm/slab.h
index 9057b8056b07..5bf615cb3f99 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -174,6 +174,7 @@ int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
 void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
+void kmem_cache_shrink_all(struct kmem_cache *s);
 
 struct seq_file;
 struct file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 807490fe217a..6491c3a41805 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -981,6 +981,43 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+/**
+ * kmem_cache_shrink_all - shrink a cache and all memcg caches for root cache
+ * @s: The cache pointer
+ */
+void kmem_cache_shrink_all(struct kmem_cache *s)
+{
+	struct kmem_cache *c;
+
+	if (!IS_ENABLED(CONFIG_MEMCG_KMEM) || !is_root_cache(s)) {
+		kmem_cache_shrink(s);
+		return;
+	}
+
+	get_online_cpus();
+	get_online_mems();
+	kasan_cache_shrink(s);
+	__kmem_cache_shrink(s);
+
+	/*
+	 * We have to take the slab_mutex to protect from the memcg list
+	 * modification.
+	 */
+	mutex_lock(&slab_mutex);
+	for_each_memcg_cache(c, s) {
+		/*
+		 * Don't need to shrink deactivated memcg caches.
+		 */
+		if (s->flags & SLAB_DEACTIVATED)
+			continue;
+		kasan_cache_shrink(c);
+		__kmem_cache_shrink(c);
+	}
+	mutex_unlock(&slab_mutex);
+	put_online_mems();
+	put_online_cpus();
+}
+
 bool slab_is_available(void)
 {
 	return slab_state >= UP;
diff --git a/mm/slub.c b/mm/slub.c
index e6c030e47364..9736eb10dcb8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5294,7 +5294,7 @@ static ssize_t shrink_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
 	if (buf[0] == '1')
-		kmem_cache_shrink(s);
+		kmem_cache_shrink_all(s);
 	else
 		return -EINVAL;
 	return length;
-- 
2.18.1

