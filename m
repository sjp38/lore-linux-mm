Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97AEBC761A8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D4C32238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D4C32238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA7946B0010; Thu, 25 Jul 2019 12:02:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0B666B026A; Thu, 25 Jul 2019 12:02:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5D466B026B; Thu, 25 Jul 2019 12:02:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64E396B0010
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:02:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so32398881edr.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=2GwpzrV+PsqSwM2Q5DY24zOCxeh8R2hXPbC9OI9gsOk=;
        b=DETyLGusUb55BqeLOfFIyrB1NllUqAbpp0itWCnYrWeBSb0alQNK94Ny90wBC9JSS5
         1mKx3BUwciMoNvf3qV5HXj+EFypIpFuTu7d/eDF65fa0P0uh5hXoggVK5fvIUSLI1WQq
         K6AkFR+QbhDMit3AzKgXT+YJhfsGZfzNfr+/gG81jmw8oMvRUhGSagzY9rgb8FCdF6XO
         6r2U1XGq6G8Fy5gW4CNgLKvGN45EVJHaBizudR2A/VhGuJXSF6NMu0AyOMIhDiqdq/J+
         GH/9ShmatfFPSjjAaG9o3FbMGWh8dyOI1xQJKUTshyYMjOaceBfHjtoSddFZUfazyDzx
         285g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW4TDtsuSs9CmdP6YBDPq89gt19AkefoWG0W2cGegLOFhy8hVSg
	l3ss+YzHHjsVR3WDrG35yPfZSGBZkw3CnaHcn0iI4WFlOnMs+c1oXDrhohBNrjjl++vrWQ6DF3A
	VfQ5g3O3oN/ia4Nb060seXiKe8E939NnZ3EqU8+r1d3kCUjWKrhOKQFXCyO1RelKTTw==
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr76432399edu.223.1564070538978;
        Thu, 25 Jul 2019 09:02:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfc5Ibbt5DPZ79IObwUUObEFwn4KiETWArV4S29z6gJnr1fVIb8TZ9GqwmUGawhgcKuQpG
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr76432315edu.223.1564070538127;
        Thu, 25 Jul 2019 09:02:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070538; cv=none;
        d=google.com; s=arc-20160816;
        b=NK0ON2Xc8vqcH1ellZXDTJr6pCqo6qPp23ZLsfFmCIYab+tzB+pn/ynSJVrhCLQEmo
         TqehqKJqdy0HOyZ4aQoPPN8+6c3F5i4pgRJrDOy4cVI2NzlNY9c1gUMIfKuKHQPbhYHM
         D23xed9O0dwLN86MlCZSq/8TUkLrEJCzHfXzPkZgcurh16Z/mAcroDUxjB5taxpz5Y3d
         AQgDEnxTMyAj0NJas3Lb44qjnB2dovj6eKC4mE8LCg+EQWXWZlLIaJdSvdNfVnQmIzsi
         AdFyaBlBl1dpnHGS37Cb2rkD+D2aOTwJbWSeZ2CtmRz38u+Wq47spvUx5kEnkVYRVG3B
         kJOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=2GwpzrV+PsqSwM2Q5DY24zOCxeh8R2hXPbC9OI9gsOk=;
        b=oQoBghLDyQAfldwvEWvj/a3vCxG/8+gKX5WOV9K+Yr+rYVg7l/Af5zlqE8Nqo+zYlM
         ESKaZyD5lanRgjA1dikDgCXPmFlgery5VUVQON46wtPyg4JdoSucO3DdnIwN/pMiK5CY
         Bw1OBsgTlwAL9VEyk6k9FCh7LpezGUATMwl+1aL4YV+s4yQDoeTz4+MYa1Y2XIHvFQ5w
         5Js6oPqjXoaZVIjNnXPVqVpHW6kEnDrtdBXhF6+RfUsJa74+ELOIKElB98o11UK8DIN0
         Rb56PxG6PNmvYIHqf1gxLIeIizg46gtE7WdekvbPRiSHrD+9yn+hMTSf4N7vwrZFSY74
         OXog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si9328567eja.80.2019.07.25.09.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:02:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AEB8DAFFB;
	Thu, 25 Jul 2019 16:02:17 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	anshuman.khandual@arm.com,
	Jonathan.Cameron@huawei.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3 5/5] mm,memory_hotplug: Allow userspace to enable/disable vmemmap
Date: Thu, 25 Jul 2019 18:02:07 +0200
Message-Id: <20190725160207.19579-6-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
References: <20190725160207.19579-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It seems that we have some users out there that want to expose all
hotpluggable memory to userspace, so this implements a toggling mechanism
for those users who want to disable it.

By default, vmemmap pages mechanism is enabled.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/memory.c          | 33 +++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h |  3 +++
 mm/memory_hotplug.c            |  7 +++++++
 3 files changed, 43 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index d30d0f6c8ad0..5ec6b80de9dd 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -578,6 +578,35 @@ static DEVICE_ATTR_WO(soft_offline_page);
 static DEVICE_ATTR_WO(hard_offline_page);
 #endif
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+static ssize_t vmemmap_hotplug_show(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	if (vmemmap_enabled)
+		return sprintf(buf, "enabled\n");
+	else
+		return sprintf(buf, "disabled\n");
+}
+
+static ssize_t vmemmap_hotplug_store(struct device *dev,
+			   struct device_attribute *attr,
+			   const char *buf, size_t count)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (sysfs_streq(buf, "enable"))
+		vmemmap_enabled = true;
+	else if (sysfs_streq(buf, "disable"))
+		vmemmap_enabled = false;
+	else
+		return -EINVAL;
+
+	return count;
+}
+static DEVICE_ATTR_RW(vmemmap_hotplug);
+#endif
+
 /*
  * Note that phys_device is optional.  It is here to allow for
  * differentiation between which *physical* devices each
@@ -794,6 +823,10 @@ static struct attribute *memory_root_attrs[] = {
 	&dev_attr_hard_offline_page.attr,
 #endif
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+	&dev_attr_vmemmap_hotplug.attr,
+#endif
+
 	&dev_attr_block_size_bytes.attr,
 	&dev_attr_auto_online_blocks.attr,
 	NULL
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e1e8abf22a80..03d227d13301 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -134,6 +134,9 @@ extern int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions);
 extern u64 max_mem_size;
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+extern bool vmemmap_enabled;
+#endif
 extern bool memhp_auto_online;
 /* If movable_node boot option specified */
 extern bool movable_node_enabled;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 09d41339cd11..5ffe5375b87c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -68,6 +68,10 @@ void put_online_mems(void)
 
 bool movable_node_enabled = false;
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+bool vmemmap_enabled __read_mostly = true;
+#endif
+
 #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
 bool memhp_auto_online;
 #else
@@ -1108,6 +1112,9 @@ static unsigned long mhp_check_flags(unsigned long flags)
 	if (!flags)
 		return 0;
 
+	if (!vmemmap_enabled)
+		return 0;
+
 	if (flags != MHP_MEMMAP_ON_MEMORY) {
 		WARN(1, "Wrong flags value (%lx). Ignoring flags.\n", flags);
 		return 0;
-- 
2.12.3

