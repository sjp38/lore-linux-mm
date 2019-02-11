Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39620C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0294B218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:50:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0294B218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A87CB8E0119; Mon, 11 Feb 2019 12:50:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0E238E0115; Mon, 11 Feb 2019 12:50:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B0098E0119; Mon, 11 Feb 2019 12:50:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F90A8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:50:54 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so10211817edq.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:50:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=veawUBnl7JE/3ERhcQmuKCHTaYi8q6QzreDQa3Uf5PE=;
        b=eenir7Vb44ntLosokipBuHU4e0ZBWRryee639t8FJM+okud4EgHB88872VMd0oV8Rf
         b9vXYBUs+pic8iygqoNTtv5mRP2NmlVsbaiQcy2t6hGgkQgYArOOH2lkAdnUmKFlpat5
         ca70aBjPD7AXQetdRqOxosyPEhs+Sq7ctVmqsJHJ4H5xNf6O4kfjPn6e04RucjACCdT1
         +eu+Aj6h+j9NejcX6N55tC7QMLg+6YOeTo4ptrvMxXkNtvPcO0FumhG1gv6hF/A11N/z
         9sSx6+erFpqwmP0sJJOtNPO4i+F8rlVtAgMJMVLCjqyY/FcxiziVpu0gOqIyZxI6Yh2g
         0nEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAua/su3rN5X5B4xZzZrA0U/PYQ5SbxA7lEvbtHcV9uOy5WRcH80e
	oks7JZyK1iRNwQpshz6GZ4dC6R9X9hT8tcqhB9fgzPc3aDmVatRgKd95JUv45H7zVnWa32hQ/xR
	8wNANCKTp736iNrXG2tbZHCMynrb5BARQ6g/c6YYwxU8M9s5/1Hhs/6ohOjXXoheWCg==
X-Received: by 2002:a50:f141:: with SMTP id z1mr29947421edl.44.1549907453649;
        Mon, 11 Feb 2019 09:50:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQtAVw87WP7DV25KIlHS9lwU5AEYFbCH7p+bV/pbUxG06DJKk2McDgUU0KTsTcqxXQMlXr
X-Received: by 2002:a50:f141:: with SMTP id z1mr29947358edl.44.1549907452521;
        Mon, 11 Feb 2019 09:50:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549907452; cv=none;
        d=google.com; s=arc-20160816;
        b=RZQ13ROAvIxSMzpGJDxwNu+36E+AO4ZTwYmJ36x7fUN4kI4ss2qIJhQ8lT/BCKbJ3b
         Czn/RKg2dogaWzA9gPHMb4WdRQb3lcoCcZDz0xij1lkvJ1K7kR6p3Jm4VF5xPIbZTNCg
         5GzA5ENRohKchlsFHkDQrY4xSTGM0FTrsNHkOe3cB3Ss5d5eNSfy4uegmUtIXqicZbpD
         Ev922rUCSWMvBgVSDLiedIEm4aus7By8w/qWDdAi3/jyPQjjV4JYAhtLGlECyARRczgx
         v+LaVTFwh2AEw7W4ywG1GmuXKAcsKlgNNBGheYTmGghK+ZKdZa+/z2okRoJ6+q0Xg4QT
         W47g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=veawUBnl7JE/3ERhcQmuKCHTaYi8q6QzreDQa3Uf5PE=;
        b=pnFuY7hGZuUqi9S6QdSsdRjjaSrs8yGQHhhSWbi4vTA6wRXNm5OCg+kAUYt+IuljvG
         rKeGZmw9bjgX7sJL/mq4j+lcaWg8whKOXQ9j/NKURzvkdDxJtSMZ3RfF6rguauxiTiNU
         bTZgmUTQoB3EyQfYdxTTzFoWPr/60JqLF61L83bx16jiikPE0OaW52GuUXY+HLx/meAH
         nnhMyreUnk3+yyxyjGTHvfAhGPRq0iMqmU8CZD1bAVALmK5ZXAET5I8LjlJsboAP6E4j
         lwkrZ6YIByM5nTfwuBUvjUXykX4Ilzwk5bim1qvr2P6cKqnBhZX9O2x3EU7IYG5Ic/68
         9h2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m2si134349edm.389.2019.02.11.09.50.52
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 09:50:52 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4CBD7EBD;
	Mon, 11 Feb 2019 09:50:51 -0800 (PST)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id EA2C33F675;
	Mon, 11 Feb 2019 09:50:49 -0800 (PST)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org,
	rafael@kernel.org,
	mhocko@kernel.org,
	akpm@linux-foundation.org,
	osalvador@suse.de
Subject: [PATCH v2] mm/memory-hotplug: Add sysfs hot-remove trigger
Date: Mon, 11 Feb 2019 17:50:46 +0000
Message-Id: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.20.1.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
but being able to exercise the (arguably trickier) hot-remove path would
be even more useful. Extend the feature to allow removal of offline
sections to be triggered manually to aid development.

Since process dictates the new sysfs entry be documented, let's also
document the existing probe entry to match - better 13-and-a-half years
late than never, as they say...

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---

v2: Use is_memblock_offlined() helper, write up documentation

 .../ABI/testing/sysfs-devices-memory          | 25 +++++++++++
 drivers/base/memory.c                         | 42 ++++++++++++++++++-
 2 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
index deef3b5723cf..02a4250964e0 100644
--- a/Documentation/ABI/testing/sysfs-devices-memory
+++ b/Documentation/ABI/testing/sysfs-devices-memory
@@ -91,3 +91,28 @@ Description:
 		memory section directory.  For example, the following symbolic
 		link is created for memory section 9 on node0.
 		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
+
+What:		/sys/devices/system/memory/probe
+Date:		October 2005
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		The file /sys/devices/system/memory/probe is write-only, and
+		when written will simulate a physical hot-add of a memory
+		section at the given address. For example, assuming a section
+		of unused memory exists at physical address 0x80000000, it can
+		be introduced to the kernel with the following command:
+		# echo 0x80000000 > /sys/devices/system/memory/probe
+Users:		Memory hotplug testing and development
+
+What:		/sys/devices/system/memory/memoryX/remove
+Date:		February 2019
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		The file /sys/devices/system/memory/memoryX/remove is
+		write-only, and when written with a boolean 'true' value will
+		simulate a physical hot-remove of that memory section. For
+		example, assuming a 1GB section size, the section added by the
+		above "probe" example could be removed again with the following
+		command:
+		# echo 1 > /sys/devices/system/memory/memory2/remove
+Users:		Memory hotplug testing and development
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 048cbf7d5233..1ba9d1a6ba5e 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -521,7 +521,44 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
 }
 
 static DEVICE_ATTR_WO(probe);
-#endif
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static ssize_t remove_store(struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t count)
+{
+	struct memory_block *mem = to_memory_block(dev);
+	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
+	bool remove;
+	int ret;
+
+	ret = kstrtobool(buf, &remove);
+	if (ret)
+		return ret;
+	if (!remove)
+		return count;
+
+	if (!is_memblock_offlined(mem))
+		return -EBUSY;
+
+	ret = lock_device_hotplug_sysfs();
+	if (ret)
+		return ret;
+
+	if (device_remove_file_self(dev, attr)) {
+		__remove_memory(pfn_to_nid(start_pfn), PFN_PHYS(start_pfn),
+				MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+		ret = count;
+	} else {
+		ret = -EBUSY;
+	}
+
+	unlock_device_hotplug();
+	return ret;
+}
+
+static DEVICE_ATTR_WO(remove);
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+#endif /* CONFIG_ARCH_MEMORY_PROBE */
 
 #ifdef CONFIG_MEMORY_FAILURE
 /*
@@ -615,6 +652,9 @@ static struct attribute *memory_memblk_attrs[] = {
 	&dev_attr_removable.attr,
 #ifdef CONFIG_MEMORY_HOTREMOVE
 	&dev_attr_valid_zones.attr,
+#ifdef CONFIG_ARCH_MEMORY_PROBE
+	&dev_attr_remove.attr,
+#endif
 #endif
 	NULL
 };
-- 
2.20.1.dirty

