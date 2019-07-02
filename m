Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32B35C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCE8F21721
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:38:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCE8F21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478AB6B0003; Tue,  2 Jul 2019 14:38:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429BC8E0003; Tue,  2 Jul 2019 14:38:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318828E0001; Tue,  2 Jul 2019 14:38:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12EF96B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 14:38:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so17211677qtm.17
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 11:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=AEW55TgtVi2BKt6wgfN3muW8kwr4Eo/kHBzKeJce5lA=;
        b=P0DXch09oiIjseKpoU8v9XVpP1r2MALwvT8QOuMNADyH3uYeyIfZdbCCM3Y470j6B6
         QmsdbSKh6F1FsHt8+imHvsGhZR7auYqW/12qKahaAjPRlfVvpzCgauqyuTH22GevDiZD
         xPyU0i6A5oQX3vKuUn3uQHk651sC3z3S3MDi7H7y8UMiHQF9V63A+EMQY31uQ6IteYos
         eVFxb7AviMsFXSBDo/9MvLPaEQtDS+Kpxu5vCf0w9WaJoZsb8suk48J8f3+YKFbV9Hej
         j4DNzAD9a46CijWkemLygQPh86mopthaQXSWHiAdmWOo1Mt8X1k79tksMcILtr9LzQdP
         uRYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV/8vmyiIBgDexn7SHCSpM5/km9q55teEe5r8lM8UBjlmDigLlE
	If8vNibxk8179ZOauA+y7aRMzM7DaJpE+ntkkdt95EQXs7sQRDyqk8cxpUqC81TNd/p4gCm2JKp
	ZuGn+eLNnmmQ+67VF0jR1qZiFrPNnAotD8rOuRgSOJOkXno+7Gxq6fWTSpLANwcl1gw==
X-Received: by 2002:ac8:458d:: with SMTP id l13mr27222530qtn.165.1562092699733;
        Tue, 02 Jul 2019 11:38:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5ocso3s1MRmNmEC6R08a2rsTsXuxc/Smj0VhqloAfS7VDsLP5ulIPM4pP3CBto6DuvPP4
X-Received: by 2002:ac8:458d:: with SMTP id l13mr27222483qtn.165.1562092698926;
        Tue, 02 Jul 2019 11:38:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562092698; cv=none;
        d=google.com; s=arc-20160816;
        b=viPUPxS/x4Ubzpi04mY2TSb1d+3yLny8p3UjOgX2JglvX01Dj0cqEm3mVFkfg2Hsd4
         wWSwLzXZVpt4JhJ5ZptvQ7I8yn4sYF0By/F7COTbssEm1pOj2hJm1haZzs7PyV6e2Bi/
         Usw1Z+lYyqBQoTHWpi/GtzM7MjsmExTC4vp1xNXAomVWYtF9jJgZ+0Z3zAMyO6CxfiDZ
         OotK+idLFzRm/0ER4RDgZsdlBdke0b/cICejgT5rlBmWTkQy1qVFV5sqoc06xArYxg+J
         5Jr0A0XSYOB+fx4Ig8xuxlcFs3/eFcJBpItZF68fPWmylmZyf4AKZgpB3D3hXmX7B+Lp
         jKvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=AEW55TgtVi2BKt6wgfN3muW8kwr4Eo/kHBzKeJce5lA=;
        b=IuH3vZjUQ52qaChxby2Xi+C4oVtU7lw6WMXllIMHlCh7uodtj64BaVe8hgJhJ0hXkO
         a4K9ZVipwHrUsP7MewaHqxhon9MoLy8nV5WTqM/2nym92mND9BYdo+Yvys5jjsBfrG1J
         3XkU43S+TJA37OQk62P4+UWim6b/QxWUNnMk/X5dHMx6CSeJTxvt3pEKABBH3lhAfUtP
         aERfsSgfev31qHWkmx066WnuerkguBf6MhMx8E1sHjUDICj4Hb9tUwX2djyAfyzaJ6nw
         NndPlllAekg2xoyWIScywJ4cktOBCZWSmiDPrnQcYeaW3HwBDtlGif/vjcaeeMT+rP/h
         yl+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 73si1884298qkd.255.2019.07.02.11.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 11:38:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F1A6B81F31;
	Tue,  2 Jul 2019 18:37:54 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 599AA5D968;
	Tue,  2 Jul 2019 18:37:44 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg caches
Date: Tue,  2 Jul 2019 14:37:30 -0400
Message-Id: <20190702183730.14461-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 02 Jul 2019 18:38:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
file to shrink the slab by flushing all the per-cpu slabs and free
slabs in partial lists. This applies only to the root caches, though.

Extends this capability by shrinking all the child memcg caches and
the root cache when a value of '2' is written to the shrink sysfs file.

On a 4-socket 112-core 224-thread x86-64 system after a parallel kernel
build, the the amount of memory occupied by slabs before shrinking
slabs were:

 # grep task_struct /proc/slabinfo
 task_struct         7114   7296   7744    4    8 : tunables    0    0
 0 : slabdata   1824   1824      0
 # grep "^S[lRU]" /proc/meminfo
 Slab:            1310444 kB
 SReclaimable:     377604 kB
 SUnreclaim:       932840 kB

After shrinking slabs:

 # grep "^S[lRU]" /proc/meminfo
 Slab:             695652 kB
 SReclaimable:     322796 kB
 SUnreclaim:       372856 kB
 # grep task_struct /proc/slabinfo
 task_struct         2262   2572   7744    4    8 : tunables    0    0
 0 : slabdata    643    643      0

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/ABI/testing/sysfs-kernel-slab | 10 +++--
 mm/slab.h                                   |  1 +
 mm/slab_common.c                            | 43 +++++++++++++++++++++
 mm/slub.c                                   |  2 +
 4 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 29601d93a1c2..2a3d0fc4b4ac 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -429,10 +429,12 @@ KernelVersion:	2.6.22
 Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
 		Christoph Lameter <cl@linux-foundation.org>
 Description:
-		The shrink file is written when memory should be reclaimed from
-		a cache.  Empty partial slabs are freed and the partial list is
-		sorted so the slabs with the fewest available objects are used
-		first.
+		A value of '1' is written to the shrink file when memory should
+		be reclaimed from a cache.  Empty partial slabs are freed and
+		the partial list is sorted so the slabs with the fewest
+		available objects are used first.  When a value of '2' is
+		written, all the corresponding child memory cgroup caches
+		should be shrunk as well.  All other values are invalid.
 
 What:		/sys/kernel/slab/cache/slab_size
 Date:		May 2007
diff --git a/mm/slab.h b/mm/slab.h
index 3b22931bb557..a16b2c7ff4dd 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -174,6 +174,7 @@ int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
 void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
+int kmem_cache_shrink_all(struct kmem_cache *s);
 
 struct seq_file;
 struct file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 464faaa9fd81..493697ba1da5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -981,6 +981,49 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+/**
+ * kmem_cache_shrink_all - shrink a cache and all its memcg children
+ * @s: The root cache to shrink.
+ *
+ * Return: 0 if successful, -EINVAL if not a root cache
+ */
+int kmem_cache_shrink_all(struct kmem_cache *s)
+{
+	struct kmem_cache *c;
+
+	if (!IS_ENABLED(CONFIG_MEMCG_KMEM)) {
+		kmem_cache_shrink(s);
+		return 0;
+	}
+	if (!is_root_cache(s))
+		return -EINVAL;
+
+	/*
+	 * The caller should have a reference to the root cache and so
+	 * we don't need to take the slab_mutex. We have to take the
+	 * slab_mutex, however, to iterate the memcg caches.
+	 */
+	get_online_cpus();
+	get_online_mems();
+	kasan_cache_shrink(s);
+	__kmem_cache_shrink(s);
+
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
+	return 0;
+}
+
 bool slab_is_available(void)
 {
 	return slab_state >= UP;
diff --git a/mm/slub.c b/mm/slub.c
index a384228ff6d3..5d7b0004c51f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5298,6 +5298,8 @@ static ssize_t shrink_store(struct kmem_cache *s,
 {
 	if (buf[0] == '1')
 		kmem_cache_shrink(s);
+	else if (buf[0] == '2')
+		kmem_cache_shrink_all(s);
 	else
 		return -EINVAL;
 	return length;
-- 
2.18.1

