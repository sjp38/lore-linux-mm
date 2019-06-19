Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14241C31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE650214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE650214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70DC56B0005; Wed, 19 Jun 2019 10:46:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BEBB8E0002; Wed, 19 Jun 2019 10:46:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ACDA8E0001; Wed, 19 Jun 2019 10:46:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2EF6B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:46:27 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p43so16068122qtk.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:46:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=M+R122FaPt3TpA/EM9AbhNexUXSmxCHfgU+Ubvs8s98=;
        b=M+bkpevGuJ++3/suVsJPN9vMosJS1LW4mlyYHRhdF6jmCaKf794qDI0LkGXta4urAc
         tNcJzjbkQrKIep5Wsntt9x2+4v3/n8gNvVUUbLF8VjW4d5vvLJ2KoYCLnySDCq83rmog
         efnoOHTtJDC9oI8ob2ZaOgCeXvNyupo03V7OF1AbKbsMlRor73rpQUnE1OjK7sir04pq
         OUAE17A0QK2C2KoXwZgszmhoJZGEAozhQmKvInxVu2ZzmVUJCxUnzT6JX7jii3IYfngF
         6Z5iDNcbJpsekPaNHNhoL+vWK6sLWYeqODoycb0gCVJ1rVBSHF5wraYLuEuLCLyJ7oUm
         HE/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0LJTb9QxprRE8O+B0Z3L19i0gW/XRHPuzT13rZSgkaVpyB7DR
	5+QoSkQHrylncKkEEy0Aycg2FVkzmUfWF5dPLc2gq0iMMkoTCcK1yJo+/SObYJ3HcJsP44qBPTL
	JU75JDWvq3saDSHkU7GoaXt8XCxZpnk6sG265jLKvaciqCp7OEGM+ZhgsITmAtOBabA==
X-Received: by 2002:a37:ef01:: with SMTP id j1mr30358972qkk.163.1560955586859;
        Wed, 19 Jun 2019 07:46:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPC1mljn2urqb7KmjRV188K62K38wmrf1Pz1VyWeWy67oVeLQnl6422aC9BPSxtafGHA2b
X-Received: by 2002:a37:ef01:: with SMTP id j1mr30358877qkk.163.1560955586086;
        Wed, 19 Jun 2019 07:46:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560955586; cv=none;
        d=google.com; s=arc-20160816;
        b=vtv8NEp0FbVQ3z6mQA3aDrlmMlTO3pEf3RKqZjt+MSh21b4SeWO/UgPeSPL8aVJ6WG
         aUk5av0CoKB6gVr0utX2/FX4N2Ii7LkionX4Ml04hfWW57lMAOCgecwRjkAtvyGAFFuT
         MIK+cfVWXP7uiYr47ncKhtq3HGRaJH9lyWCc/3lrPB408sXTfGryDJVrEms3LxlJU9Qq
         0Zu3rIUhAeKVSZVBxiq3YFcSmDvQFARhGcseD/kRu/IOXOXo2w/fGPV+tVVe1vT+uWBQ
         dmvEOCAp3Sm9FDBGxubFqno1R0UfsnVFcQyizQvhh1vyAAN4t54QkiHBLpZxZvw8lNG1
         9htQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=M+R122FaPt3TpA/EM9AbhNexUXSmxCHfgU+Ubvs8s98=;
        b=xUE0BsnSAxCuHXLIHSpHw8kyG+ggYHr+l2fo//vKEpcxPow4jwjLgfoxqJuhd/Qtpm
         IMUVpgpSSEH5P34IErN++lrWA3shMjWVeXjtOWjnrT6lAQEBQGqyMXRDyWrfakCjfyWo
         R4oNT0dtjFFJJb8dyNFrqISF58uFetDOq2DJhplum1dUixh9Ce63D1SsVKqRFQrI69LO
         4Hqprrdu+9IqEUsEbI6JYb3x/t9nXn9wbwlJjp+VhOiTgZUPewZrl/SY5E6moOsJxL8c
         HJ+hRKi1klVekuxCvH5AYv4weCAN2vr9KqghiX1gLYUxqDzI6Lp5fwrgRWezb/EezxrR
         ug/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si2790384qth.373.2019.06.19.07.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 07:46:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0B90730BBE9A;
	Wed, 19 Jun 2019 14:46:25 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 92848608A7;
	Wed, 19 Jun 2019 14:46:22 +0000 (UTC)
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
Subject: [PATCH] mm, memcg: Add a memcg_slabinfo debugfs file
Date: Wed, 19 Jun 2019 10:46:10 -0400
Message-Id: <20190619144610.12520-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 19 Jun 2019 14:46:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are concerns about memory leaks from extensive use of memory
cgroups as each memory cgroup creates its own set of kmem caches. There
is a possiblity that the memcg kmem caches may remain even after the
memory cgroup removal. Therefore, it will be useful to show how many
memcg caches are present for each of the kmem caches.

This patch introduces a new <debugfs>/memcg_slabinfo file which is
somewhat similar to /proc/slabinfo in format, but lists only slabs that
are in memcg kmem caches. Information available in /proc/slabinfo are
not repeated in memcg_slabinfo.

A portion of a sample output of the file was:

  # <name> <active_objs> <num_objs> <active_slabs> <num_slabs> <num_caches> <num_empty_caches>
  rpc_inode_cache        0      0      0      0   1   1
  xfs_inode           6342   7888    232    232  59  13
  RAWv6                  0      0      0      0   2   2
  UDPv6                100    100      4      4   5   3
  TCPv6                  0      0      0      0   1   1
  UNIX                4864   4864    152    152  53  35
  RAW                    0      0      0      0   1   1
  TCP                   14     14      1      1   2   1

Besides the number of objects and slabs in the memcg kmem caches only,
it also shows the total number of memcg kmem caches associated with each
root kmem cache as well as the number memcg kmem caches that are empty.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/slab_common.c | 53 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..63fb18f4f811 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -17,6 +17,7 @@
 #include <linux/uaccess.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
+#include <linux/debugfs.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/page.h>
@@ -1498,6 +1499,58 @@ static int __init slab_proc_init(void)
 	return 0;
 }
 module_init(slab_proc_init);
+
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_MEMCG)
+/*
+ * Display information about slabs that are in memcg kmem caches, but not
+ * in the root kmem caches.
+ */
+static int memcg_slabinfo_show(struct seq_file *m, void *unused)
+{
+	struct kmem_cache *s, *c;
+	struct slabinfo sinfo, cinfo;
+
+	mutex_lock(&slab_mutex);
+	seq_puts(m, "# <name> <active_objs> <num_objs> <active_slabs>");
+	seq_puts(m, " <num_slabs> <num_caches> <num_empty_caches>\n");
+	memset(&sinfo, 0, sizeof(sinfo));
+	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
+		int scnt = 0;	/* memcg kmem cache count */
+		int ecnt = 0;	/* # of empty kmem caches */
+
+		for_each_memcg_cache(c, s) {
+			memset(&cinfo, 0, sizeof(cinfo));
+			get_slabinfo(c, &cinfo);
+
+			sinfo.active_slabs += cinfo.active_slabs;
+			sinfo.num_slabs += cinfo.num_slabs;
+			sinfo.active_objs += cinfo.active_objs;
+			sinfo.num_objs += cinfo.num_objs;
+			scnt++;
+			if (!cinfo.num_slabs)
+				ecnt++;
+		}
+		if (!scnt)
+			continue;
+		seq_printf(m, "%-17s %6lu %6lu %6lu %6lu %3d %3d\n",
+			   cache_name(s), sinfo.active_objs, sinfo.num_objs,
+			   sinfo.active_slabs, sinfo.num_slabs, scnt, ecnt);
+		memset(&sinfo, 0, sizeof(sinfo));
+	}
+	mutex_unlock(&slab_mutex);
+	return 0;
+}
+DEFINE_SHOW_ATTRIBUTE(memcg_slabinfo);
+
+static int __init memcg_slabinfo_init(void)
+{
+	debugfs_create_file("memcg_slabinfo", S_IFREG | S_IRUGO,
+			    NULL, NULL, &memcg_slabinfo_fops);
+	return 0;
+}
+
+late_initcall(memcg_slabinfo_init);
+#endif /* CONFIG_DEBUG_FS && CONFIG_MEMCG */
 #endif /* CONFIG_SLAB || CONFIG_SLUB_DEBUG */
 
 static __always_inline void *__do_krealloc(const void *p, size_t new_size,
-- 
2.18.1

