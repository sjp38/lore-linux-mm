Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32146C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE3C7218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE3C7218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 405CD8E000A; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 189248E0008; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B52CD8E000F; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 631098E0003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so13992674ple.19
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=YdkPR857z2QJHU+MTdQBAeYrLi5HPVsYANWKLt6w3ss=;
        b=G54udu2YyIp5vDKKwGj7Jdn2oeUSXeHf6ldcMBY6pdbGF4m4qH54r4PfhDH6VShhL4
         RAIvJ8mGaGBefvWl8b8rJZ5PnQfZ+scVQc9M1LJisZKqEH1KLvRctMvCAVe5gnj3zHSW
         1ksu0JIiD5ps5OV61K9L5XZf/rI8IK6UEo8dYNA4KdZnv38ocaY0QeRdAeC6cOgQZwxf
         5vhRfzYVL6ME6YbHqT6/+yE5C7KSetSHTg9T4vJYy5IENEz0IQB2g6N+q33SPEuTBvCQ
         LOt6Ej/BFgB5cpqWDMd7xH685EBS2RSsRoT8zix+Upfw5RyYRH9ykyqB+JSfj9f1Xtbw
         pEHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukc13LA1IyWvwhnYagEl01D5mAW4p/Nd44hUGD3d+N5O21JcqPVy
	XXdoJxGgo8OKuX/BblnWF/B35JWKn6P06hlBlBI2kx5gsFCuNyF+tl02+R2LGc8fLZHWoihz2IO
	le4BEf+XybPIs0s6UOHJx3+gxawo1OJf0OrWl2pjTod98H07V+vXCrHmwql5zFjM3CQ==
X-Received: by 2002:a63:4101:: with SMTP id o1mr18777694pga.447.1545831427100;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7WMQyJsGwJiGqWnZtHzwEaOER8RGzX96D4MxG23CjFqXoGuSE7aHEaUZ+Gy+VnYTzKo+G3
X-Received: by 2002:a63:4101:: with SMTP id o1mr18777656pga.447.1545831426513;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=j2jauWEOVwWfGoRPtNDwgIo3tgtIIWN+FCM8JH/Vm9X2YXHi0AnHbZvosJ3ihDKT0T
         uzE0iWellzxIE6giSHC58TUKXob3GEuB5t+gBBF/Dqc/CKb2jJvGM0ZLGTt1rSpHVZDW
         dO3CqSZ2VqWtE2s3UH57d5vyiQweuwuoZ6SFGEYz1MsSGattV7wiAYIfWkii2+VB8gcD
         VXiI3NyMWO2E04jwDHWM6z+AR88dBq5NcKcaAV7yiShhkc73jFxKqGgiP10jROF+veKf
         JOsdlzVw7vSJcQNXhiNrd1CzEos0VvFcyWbrAAJiLNgluK/mDXTBvhOzh+hNUWG/uIja
         VPTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=YdkPR857z2QJHU+MTdQBAeYrLi5HPVsYANWKLt6w3ss=;
        b=W4WuyoP/5PUGym5RG4MRfTAzG6BrhKAYpkp6MQMY6kBQiBZRKrz81tleEsks4cl1wc
         ugpKH5HWm5AN+mwyxNEzn/u0y5xgJk8rxfA/3OcZr5Rlp/DzD6KRP7mZqWO/M58ns+bx
         3+vI+eoZHBczxCkkMkqin447zMzBK0T6Heb4xp4NtySEB2/gZY9xnSXcECDbVD+3GHZ5
         SHLh85BYB+WVYh8gfStWlHuRJ3j0ad/VW2ZyV00QeFheVbUpOPABVmRJo91POcZtORYo
         ty9JdTjD9HyLBvT8QbJ5YVk30pUxb/qeXGlKha+6wdxiVHO13KHod5jFrvVI6AjtZX3r
         ggvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c7si33395890pgg.339.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185462"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005OT-CD; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.521151384@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:54 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 08/21] mm: introduce and export pgdat peer_node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0019-mm-Introduce-and-export-peer_node-for-pgdat.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131454.NtYzYcEOzXKJRvg0xNHrwnjhw5oNyLscQV7yP_fiWT8@z>

From: Fan Du <fan.du@intel.com>

Each CPU socket can have 1 DRAM and 1 PMEM node, we call them "peer nodes".
Migration between DRAM and PMEM will by default happen between peer nodes.

It's a temp solution. In multiple memory layers, a node can have both
promotion and demotion targets instead of a single peer node. User space
may also be able to infer promotion/demotion targets based on future
HMAT info.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/base/node.c    |   11 +++++++++++
 include/linux/mmzone.h |   12 ++++++++++++
 mm/page_alloc.c        |   29 +++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+)

--- linux.orig/drivers/base/node.c	2018-12-23 19:39:51.647261099 +0800
+++ linux/drivers/base/node.c	2018-12-23 19:39:51.643261112 +0800
@@ -242,6 +242,16 @@ static ssize_t type_show(struct device *
 }
 static DEVICE_ATTR(type, S_IRUGO, type_show, NULL);
 
+static ssize_t peer_node_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+
+	return sprintf(buf, "%d\n", pgdat->peer_node);
+}
+static DEVICE_ATTR(peer_node, S_IRUGO, peer_node_show, NULL);
+
 static struct attribute *node_dev_attrs[] = {
 	&dev_attr_cpumap.attr,
 	&dev_attr_cpulist.attr,
@@ -250,6 +260,7 @@ static struct attribute *node_dev_attrs[
 	&dev_attr_distance.attr,
 	&dev_attr_vmstat.attr,
 	&dev_attr_type.attr,
+	&dev_attr_peer_node.attr,
 	NULL
 };
 ATTRIBUTE_GROUPS(node_dev);
--- linux.orig/include/linux/mmzone.h	2018-12-23 19:39:51.647261099 +0800
+++ linux/include/linux/mmzone.h	2018-12-23 19:39:51.643261112 +0800
@@ -713,6 +713,18 @@ typedef struct pglist_data {
 	/* Per-node vmstats */
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
+
+	/*
+	 * Points to the nearest node in terms of latency
+	 * E.g. peer of node 0 is node 2 per SLIT
+	 * node distances:
+	 * node   0   1   2   3
+	 *   0:  10  21  17  28
+	 *   1:  21  10  28  17
+	 *   2:  17  28  10  28
+	 *   3:  28  17  28  10
+	 */
+	int	peer_node;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
--- linux.orig/mm/page_alloc.c	2018-12-23 19:39:51.647261099 +0800
+++ linux/mm/page_alloc.c	2018-12-23 19:39:51.643261112 +0800
@@ -6926,6 +6926,34 @@ static void check_for_memory(pg_data_t *
 	}
 }
 
+/*
+ * Return the nearest peer node in terms of *locality*
+ * E.g. peer of node 0 is node 2 per SLIT
+ * node distances:
+ * node   0   1   2   3
+ *   0:  10  21  17  28
+ *   1:  21  10  28  17
+ *   2:  17  28  10  28
+ *   3:  28  17  28  10
+ */
+static int find_best_peer_node(int nid)
+{
+	int n, val;
+	int min_val = INT_MAX;
+	int peer = NUMA_NO_NODE;
+
+	for_each_online_node(n) {
+		if (n == nid)
+			continue;
+		val = node_distance(nid, n);
+		if (val < min_val) {
+			min_val = val;
+			peer = n;
+		}
+	}
+	return peer;
+}
+
 /**
  * free_area_init_nodes - Initialise all pg_data_t and zone data
  * @max_zone_pfn: an array of max PFNs for each zone
@@ -7012,6 +7040,7 @@ void __init free_area_init_nodes(unsigne
 		if (pgdat->node_present_pages)
 			node_set_state(nid, N_MEMORY);
 		check_for_memory(pgdat, nid);
+		pgdat->peer_node = find_best_peer_node(nid);
 	}
 }
 


