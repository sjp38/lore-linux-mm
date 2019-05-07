Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86BC3C04AAE
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FE25206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FE25206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 019F56B000E; Tue,  7 May 2019 14:38:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE8AB6B0010; Tue,  7 May 2019 14:38:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DACCC6B0266; Tue,  7 May 2019 14:38:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDB326B000E
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t51so3409075qtb.11
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jwqamueXeySfeFxINzjppTw9mQ9ehliTYQXoU7pLAas=;
        b=Js/v6wjZjJM6kFy4wcqudp7ElYv09az+lKp+Ka1laccdW+C3oxCPdXQxWouYglMMaP
         1GwA9uR0pjDspPdG0UZLhjRQtlqi0PLacOnvKpYn19k5uyqDv25aia/JvW9YaA7z2MfK
         hkangk+FUMAOzilBTyZOD9XYisThhTts1KSpHUNgKjPTCC3/jFqvmSrWO3PlyHrK6FZZ
         IBf+jOOZYpahXJw+w9kejSq13n64syn500kATQOM99vODoWwgMg2QrSRSa0ZHErP7dZK
         clXySxZ/C1GSoLbF/avDUL5M8GdAf3yg39CAguO2iXo/v8xINihEZvVxuHoL3ggqbbI9
         OhSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViirLW+1KqPWYr8h6z6nmSzzzkEK/D6dWNr98/AXHxnrjInYP8
	sRGCUJW+CyoQQE6ixhDPS314COtNs2DFdfnlWyVt3wtzkajhKl1FtBJydeVVYq4WG93o5oxcNo9
	2USyLWIUvnvHtnStzet2acSk3Ze9mVSkMgKk82hpphnee17jzZB3HVprpX5doakyjrw==
X-Received: by 2002:ac8:3884:: with SMTP id f4mr24711250qtc.300.1557254337502;
        Tue, 07 May 2019 11:38:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAc8O/3oNyx6TLQl5VNGoqa3IMmOy31uUeWvWKVRU5TtcNc9ojWEyu2x1xf+fCqxbieg/X
X-Received: by 2002:ac8:3884:: with SMTP id f4mr24711190qtc.300.1557254336455;
        Tue, 07 May 2019 11:38:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254336; cv=none;
        d=google.com; s=arc-20160816;
        b=kpzH+Br6+eXpmrFSDFfUK0U91WwZ5Abalhk8lYCJfxibc/adyBnoee7rH3Uma0muVH
         ehF12OTQWK0bMd6gdHjOyRwpyOxkgamHr6Nojxf2U/maKucmKfduhVer5tbp1aiG/JVa
         ps4cE+DYVeb4JRX/7joVeHAPDApFlwbu6OTiCsUGTM9djhuFAyO6bHecW5mqVfdcQ7RB
         W81g3UjjpI1qjw8OPcFpy5QBF2prayWSe7yJdX3jY4Ha3gKDX+HbdVs/uAhqUaz5lUHk
         uHRWNC6Ab3eOn4Y0c2XBBJQ1Mz133i0jUYmcMck7zSav5ovXwj091OygCM6QLo8/VQ7I
         XtOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jwqamueXeySfeFxINzjppTw9mQ9ehliTYQXoU7pLAas=;
        b=Eb7Pm+4Pk+qR6JR1inVRUGP4XSk2ZqQlmfjkF0kFcJDA5VRhF4KIbpuCoey2gxcKw9
         WOc3tP+S7L/FfeH3FinwWGt7hYS3X7Vh6vdiHzUWtml3pc74m8IjTJ/VDv6drw7YMRIa
         aTsCAEy8Sq1crhCg0K9P2gO/XboHmDEFuQwAgI0L7+FShBT9moQeehCacPNvaOk+TTdA
         w0Dr6GVHa7IIcpuMPyukpBg+FnwPKrHy5abNWGX1weU4px2vEsO8JpGhUoNLfFELaYZ4
         HuRhpyrBvSZPYji01rDahiyEX7CxSmTo+4EFUPSyC9M17eoJwCz5f797fzy61/TFTfdw
         gUug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o37si4358957qte.143.2019.05.07.11.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8C55C309B15B;
	Tue,  7 May 2019 18:38:55 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 663664123;
	Tue,  7 May 2019 18:38:52 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH v2 7/8] mm/memory_hotplug: Make unregister_memory_block_under_nodes() never fail
Date: Tue,  7 May 2019 20:38:03 +0200
Message-Id: <20190507183804.5512-8-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 07 May 2019 18:38:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We really don't want anything during memory hotunplug to fail.
We always pass a valid memory block device, that check can go. Avoid
allocating memory and eventually failing. As we are always called under
lock, we can use a static piece of memory. This avoids having to put
the structure onto the stack, having to guess about the stack size
of callers.

Patch inspired by a patch from Oscar Salvador.

In the future, there might be no need to iterate over nodes at all.
mem->nid should tell us exactly what to remove. Memory block devices
with mixed nodes (added during boot) should properly fenced off and never
removed.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mark Brown <broonie@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c  | 18 +++++-------------
 include/linux/node.h |  5 ++---
 2 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 04fdfa99b8bc..9be88fd05147 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 
 /*
  * Unregister memory block device under all nodes that it spans.
+ * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
  */
-int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
+void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
+	static nodemask_t unlinked_nodes;
 
-	if (!mem_blk) {
-		NODEMASK_FREE(unlinked_nodes);
-		return -EFAULT;
-	}
-	if (!unlinked_nodes)
-		return -ENOMEM;
-	nodes_clear(*unlinked_nodes);
-
+	nodes_clear(unlinked_nodes);
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
@@ -827,15 +821,13 @@ int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 			continue;
 		if (!node_online(nid))
 			continue;
-		if (node_test_and_set(nid, *unlinked_nodes))
+		if (node_test_and_set(nid, unlinked_nodes))
 			continue;
 		sysfs_remove_link(&node_devices[nid]->dev.kobj,
 			 kobject_name(&mem_blk->dev.kobj));
 		sysfs_remove_link(&mem_blk->dev.kobj,
 			 kobject_name(&node_devices[nid]->dev.kobj));
 	}
-	NODEMASK_FREE(unlinked_nodes);
-	return 0;
 }
 
 int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
diff --git a/include/linux/node.h b/include/linux/node.h
index 02a29e71b175..548c226966a2 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -139,7 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						void *arg);
-extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
+extern void unregister_memory_block_under_nodes(struct memory_block *mem_blk);
 
 extern int register_memory_node_under_compute_node(unsigned int mem_nid,
 						   unsigned int cpu_nid,
@@ -175,9 +175,8 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
+static inline void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	return 0;
 }
 
 static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
-- 
2.20.1

