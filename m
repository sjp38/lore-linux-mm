Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D16FCC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95C2A20848
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95C2A20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399556B0007; Mon, 24 Jun 2019 13:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3225B8E0003; Mon, 24 Jun 2019 13:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 175A98E0002; Mon, 24 Jun 2019 13:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBD236B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:43:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so17837458qtj.6
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JSpF2NUCMDbG/5aaSELxhrMmYwoGB8rBkLI1jEMCSKk=;
        b=gxBUDDOZHlbb5bwHVPFSQkeg6WKq4NrrKdx8pKTeR/403pJtSmCN3LCwWPJ9Zn5WHT
         q0LWlKhdaNuWFNzrKBGfWNZyqJ4lcFVeOq83Y+91SXCwP3qQknx5uoPfUTelMVM9UZp2
         /dC4SUiO7n4drY951xg9d/SeH8q3l4/lqgDW9rfU5vFC9dQhEGRnGVtjXFMB1vNz/Ksn
         r1xi6NDXXxTVuXjjgqxBO2XhKIn8nd3SGPMXFyU1C1ZmKlHQWwlXrhiQQw6699hJ6Cd4
         NQHxA2YOG57eyMI3GPCXNMZ91MD0KceFGMUWJU3tkamyBuYk0shB7bkeyWh+QjRwGXN4
         gOyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV4s6WWZFs08YpTyx7/6NjJNTnYNTsmUGgQjzkyv9ljj7Od4wnr
	LPgLqJgpa6iom3oZTTzbbCvJygnrBZjmr6LtBDu384myN1CCDYIrOvNmzMRk5vwFhzjcQlM0Z9j
	CG+H2yoFIqXQ3Eqv6xPiMbXj/Yk18chZj2QwSyZW40+f7NV6oyWl0kSAta6mF8b6VKA==
X-Received: by 2002:ac8:3098:: with SMTP id v24mr81732124qta.47.1561398222717;
        Mon, 24 Jun 2019 10:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDx1IWpyQ14uz3xq159NgFAEN2ILKNvNmoU6P4YACahkfUG5R7bhQZC/ZIAxcaZcNBMFzC
X-Received: by 2002:ac8:3098:: with SMTP id v24mr81732068qta.47.1561398221757;
        Mon, 24 Jun 2019 10:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398221; cv=none;
        d=google.com; s=arc-20160816;
        b=QO1tzNDqXczSOl34J9TIhNRK2LjAGh+a9n6bLxlNQNWZQSSIOBnKuTluce1A1gb0Vq
         yOVxwxPFT1CIgiL90+xjD4LA8Q3p06Tp3tOEYyekLyMVli+x6kkw6vUhHxOWevzGJkFc
         YKISMWqqFDEVlaqFi1KBXTAiwvDSK2cZzey1/vDhsN0suGkxnBy9iuDKZp34ostfYD7o
         horiVs+9ZbgZKOvC+UC2hQD6Yg45jfuw8lg2IkvhKdXPb6Z/jrZGfdv3A/eHJTdrzNj3
         DgNtrA215vDQRdZ9zU0rUX1aC5munCvCU+KpSmVQFrWzF05vu3cDMbL/7qArrt+CdbgY
         PfgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JSpF2NUCMDbG/5aaSELxhrMmYwoGB8rBkLI1jEMCSKk=;
        b=m8814+CPBQ+htVeZxJvPKbePVfnUgtA53CWqv8TJPfMo9UaqfSRRWs8UHaWMzMHnnH
         UrnatCA0tllFaPTywgyjTUedvnf+vFAzl5H2Mvl3B3aRo5YxrGkY2Hnlg5TQKnEn9Cb6
         Qh01pmeNS/toifdUZEBi0bA3xX2lFna+U+KF0XEcveR/xjAn/fVf2VzaXPm0/xuF5pc7
         +Kb+bDJJL/aoZWnhue2dgVXH4RZ9AiMvxrTWsokcjR+UeXwsfofvXFM1gJveKg8Apeyl
         FTzc6jW/aq+EzDcJZgo6hUd8huQ11WFqDP4CezG3G6p8wFQu2ZybXItLXbhRA7QY8LLC
         Q0hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v27si5171063qtb.140.2019.06.24.10.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 10:43:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EEC937FDE5;
	Mon, 24 Jun 2019 17:43:22 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0D47B5D9D5;
	Mon, 24 Jun 2019 17:43:17 +0000 (UTC)
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
Subject: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Date: Mon, 24 Jun 2019 13:42:19 -0400
Message-Id: <20190624174219.25513-3-longman@redhat.com>
In-Reply-To: <20190624174219.25513-1-longman@redhat.com>
References: <20190624174219.25513-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 24 Jun 2019 17:43:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With the slub memory allocator, the numbers of active slab objects
reported in /proc/slabinfo are not real because they include objects
that are held by the per-cpu slab structures whether they are actually
used or not.  The problem gets worse the more CPUs a system have. For
instance, looking at the reported number of active task_struct objects,
one will wonder where all the missing tasks gone.

I know it is hard and costly to get a real count of active objects. So
I am not advocating for that. Instead, this patch extends the
/proc/sys/vm/drop_caches sysctl parameter by using a new bit (bit 3)
to shrink all the kmem slabs which will flush out all the slabs in the
per-cpu structures and give a more accurate view of how much memory are
really used up by the active slab objects. This is a costly operation,
of course, but it gives a way to have a clearer picture of the actual
number of slab objects used, if the need arises.

The upper range of the drop_caches sysctl parameter is increased to 15
to allow all possible combinations of the lowest 4 bits.

On a 2-socket 64-core 256-thread ARM64 system with 64k page size after
a parallel kernel build, the amount of memory occupied by slabs before
and after echoing to drop_caches were:

 # grep task_struct /proc/slabinfo
 task_struct        48376  48434   4288   61    4 : tunables    0    0
 0 : slabdata    794    794      0
 # grep "^S[lRU]" /proc/meminfo
 Slab:            3419072 kB
 SReclaimable:     354688 kB
 SUnreclaim:      3064384 kB
 # echo 3 > /proc/sys/vm/drop_caches
 # grep "^S[lRU]" /proc/meminfo
 Slab:            3351680 kB
 SReclaimable:     316096 kB
 SUnreclaim:      3035584 kB
 # echo 8 > /proc/sys/vm/drop_caches
 # grep "^S[lRU]" /proc/meminfo
 Slab:            1008192 kB
 SReclaimable:     126912 kB
 SUnreclaim:       881280 kB
 # grep task_struct /proc/slabinfo
 task_struct         2601   6588   4288   61    4 : tunables    0    0
 0 : slabdata    108    108      0

Shrinking the slabs saves more than 2GB of memory in this case. This
new feature certainly fulfills the promise of dropping caches.

Unlike counting objects in the per-node caches done by /proc/slabinfo
which is rather light weight, iterating all the per-cpu caches and
shrinking them is much more heavy weight.

For this particular instance, the time taken to shrinks all the root
caches was about 30.2ms. There were 73 memory cgroup and the longest
time taken for shrinking the largest one was about 16.4ms. The total
shrinking time was about 101ms.

Because of the potential long time to shrinks all the caches, the
slab_mutex was taken multiple times - once for all the root caches
and once for each memory cgroup. This is to reduce the slab_mutex hold
time to minimize impact to other running applications that may need to
acquire the mutex.

The slab shrinking feature is only available when CONFIG_MEMCG_KMEM is
defined as the code need to access slab_root_caches to iterate all the
root caches.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/vm.txt | 11 ++++++++--
 fs/drop_caches.c            |  4 ++++
 include/linux/slab.h        |  1 +
 kernel/sysctl.c             |  4 ++--
 mm/slab_common.c            | 44 +++++++++++++++++++++++++++++++++++++
 5 files changed, 60 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 749322060f10..b643ac8968d2 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -207,8 +207,8 @@ Setting this to zero disables periodic writeback altogether.
 drop_caches
 
 Writing to this will cause the kernel to drop clean caches, as well as
-reclaimable slab objects like dentries and inodes.  Once dropped, their
-memory becomes free.
+reclaimable slab objects like dentries and inodes.  It can also be used
+to shrink the slabs.  Once dropped, their memory becomes free.
 
 To free pagecache:
 	echo 1 > /proc/sys/vm/drop_caches
@@ -216,6 +216,8 @@ To free reclaimable slab objects (includes dentries and inodes):
 	echo 2 > /proc/sys/vm/drop_caches
 To free slab objects and pagecache:
 	echo 3 > /proc/sys/vm/drop_caches
+To shrink the slabs:
+	echo 8 > /proc/sys/vm/drop_caches
 
 This is a non-destructive operation and will not free any dirty objects.
 To increase the number of objects freed by this operation, the user may run
@@ -223,6 +225,11 @@ To increase the number of objects freed by this operation, the user may run
 number of dirty objects on the system and create more candidates to be
 dropped.
 
+Shrinking the slabs can reduce the memory footprint used by the slabs.
+It also makes the number of active objects reported in /proc/slabinfo
+more representative of the actual number of objects used for the slub
+memory allocator.
+
 This file is not a means to control the growth of the various kernel caches
 (inodes, dentries, pagecache, etc...)  These objects are automatically
 reclaimed by the kernel when memory is needed elsewhere on the system.
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index d31b6c72b476..633b99e25dab 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -9,6 +9,7 @@
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
+#include <linux/slab.h>
 #include "internal.h"
 
 /* A global variable is a bit ugly, but it keeps the code simple */
@@ -65,6 +66,9 @@ int drop_caches_sysctl_handler(struct ctl_table *table, int write,
 			drop_slab();
 			count_vm_event(DROP_SLAB);
 		}
+		if (sysctl_drop_caches & 8) {
+			kmem_cache_shrink_all();
+		}
 		if (!stfu) {
 			pr_info("%s (%d): drop_caches: %d\n",
 				current->comm, task_pid_nr(current),
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..f7c1626b2aa6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -149,6 +149,7 @@ struct kmem_cache *kmem_cache_create_usercopy(const char *name,
 			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+void kmem_cache_shrink_all(void);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 1beca96fb625..feeb867dabd7 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -129,7 +129,7 @@ static int __maybe_unused neg_one = -1;
 static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
-static int __maybe_unused four = 4;
+static int __maybe_unused fifteen = 15;
 static unsigned long zero_ul;
 static unsigned long one_ul = 1;
 static unsigned long long_max = LONG_MAX;
@@ -1455,7 +1455,7 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= drop_caches_sysctl_handler,
 		.extra1		= &one,
-		.extra2		= &four,
+		.extra2		= &fifteen,
 	},
 #ifdef CONFIG_COMPACTION
 	{
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..b3c5b64f9bfb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -956,6 +956,50 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+#ifdef CONFIG_MEMCG_KMEM
+static void kmem_cache_shrink_memcg(struct mem_cgroup *memcg,
+				    void __maybe_unused *arg)
+{
+	struct kmem_cache *s;
+
+	if (memcg == root_mem_cgroup)
+		return;
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(s, &memcg->kmem_caches,
+			    memcg_params.kmem_caches_node) {
+		kmem_cache_shrink(s);
+	}
+	mutex_unlock(&slab_mutex);
+	cond_resched();
+}
+
+/*
+ * Shrink all the kmem caches.
+ *
+ * If there are a large number of memory cgroups outstanding, it may take
+ * a while to shrink all of them. So we may need to release the lock, call
+ * cond_resched() and reacquire the lock from time to time.
+ */
+void kmem_cache_shrink_all(void)
+{
+	struct kmem_cache *s;
+
+	/* Shrink all the root caches */
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(s, &slab_root_caches, root_caches_node)
+		kmem_cache_shrink(s);
+	mutex_unlock(&slab_mutex);
+	cond_resched();
+
+	/*
+	 * Flush each of the memcg individually
+	 */
+	memcg_iterate_all(kmem_cache_shrink_memcg, NULL);
+}
+#else
+void kmem_cache_shrink_all(void) { }
+#endif
+
 bool slab_is_available(void)
 {
 	return slab_state >= UP;
-- 
2.18.1

