Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F72C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:04:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1966C2186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:04:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1966C2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A12BA8E00D6; Wed,  6 Feb 2019 12:04:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C2718E00D1; Wed,  6 Feb 2019 12:04:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B1568E00D6; Wed,  6 Feb 2019 12:04:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3288D8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:04:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so3130829edc.6
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:04:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=h92w6RNrc+4BYz/QfjOPER05BHZvqz2dovit0m9ehss=;
        b=etSBPuglKwdBJ1oI/k7VqWAgPOnLKJ8r6RRdt56ohH3BuvTzsLCh09NSumOgoEu8+L
         YGlVteO5p9WWohmXTfjmrbzRXP+p8neReCtqFkWc5trTmBfjjkp/rAc5UamRFLkJLHxN
         h5KioB7m1EhxNRzgmXFvswgwxz2zbpKk88Nv99FBgjybqjF5d65CI/CzGhV5ngF42U/i
         boD5feDQP3XVLGMwGRNBgrkkpVVm+ZIJLYR3fgef59C7wZnCYMPzqxApMUYsKihCz6UX
         9ySsgqa1VKF36Zxd+CBWsmHINedMRzWX5fjUedhBnptHfYBWmEo2oHHTzxMPKmOGcPWD
         QCKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAuYHHhowTl2F8SGkb7SazP4BCcLItEUYEFA0RBP1eqJSPY3jmM4l
	/lvBMOaiFp/BlVZ72rC4yES0D+nmUzIW5qKd9GtoBVqWlV9k9M/ZyA3AmVhGc2p9Nc2n91QWfnP
	oOgoYad/oofh2FeRUgSG6hLj+E58Bql6ZtgJSc9ns96oV+SthhfklfwCndy/cF1Xj9Q==
X-Received: by 2002:a50:81e3:: with SMTP id 90mr8855659ede.67.1549472640704;
        Wed, 06 Feb 2019 09:04:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYzcgU5t+w9vjCstlDh03PT2t1XlBNKGothTTE7VQZAsYXFTYUNTprgEwOXcjtk1Ze9H74u
X-Received: by 2002:a50:81e3:: with SMTP id 90mr8855584ede.67.1549472639654;
        Wed, 06 Feb 2019 09:03:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549472639; cv=none;
        d=google.com; s=arc-20160816;
        b=kRncqCSmsu5/p/qCYvB+CIBUlhmq37SeYkr10GGeiHM0kUtpH4Eux71IKr6T7MoeWm
         6cKfMhKfiVHsE/zHnDfrcTlqw3j7x/lqVSGmz+xF4s0U8owRs7yHE8JaJ1GNvnnl7ISt
         GDTHXd60O8rIGNsmEXN8T/n0LiA9P110xHNSOESm9rqcM8SE7wGUbNiNVCiYrWeZ4sk8
         ieZ2hSuVFJtwTgj/QCRX0aY6B4CfSGROsRlsT+D/HeHR2+4Bt2tJtw9yaTqMAoeWwGU8
         HIAUKMc2/4xDgM/kXPKXVmc05tCdtz8I+Ql1+l33GfOsxlkLlZsqWLWtsmLlrEXmFU8m
         czPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=h92w6RNrc+4BYz/QfjOPER05BHZvqz2dovit0m9ehss=;
        b=g/28di/eje/hha2e8vBjCzLe9chS2PKW8eMs1OC3RTCnz7Pxx4xFI+I5lQjPeVJ+p7
         deajYOdPTBEYkpEGNCAFuS4EZyC1Xv5QCKmhoNnIXEXk4jU7hpBm+NxM1wgFjEhNnjbQ
         d5/InsNrkFYkgCwa/wHHmvATXDcInHRCWcbH8XhRYLfF9Wj7EaDHb0bYIbNvcUtFfswQ
         eXVmQBy5p5hk4BgMdTSfovD8ZNidiTHbcbfF52dZHEg0ILdlnVyQa4il/oYcd9aDagcq
         3BKFDGp+yZyFuWI/dSz4zEIUrNTn5ehBkuQF+HlmF6wLh1IpeqOt4lef13vLExZdY/Sv
         0L1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x47si5685148edb.265.2019.02.06.09.03.59
        for <linux-mm@kvack.org>;
        Wed, 06 Feb 2019 09:03:59 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 74766EBD;
	Wed,  6 Feb 2019 09:03:58 -0800 (PST)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 40E853F675;
	Wed,  6 Feb 2019 09:03:57 -0800 (PST)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org,
	rafael@kernel.org,
	mhocko@kernel.org,
	akpm@linux-foundation.org
Subject: [PATCH] mm/memory-hotplug: Add sysfs hot-remove trigger
Date: Wed,  6 Feb 2019 17:03:53 +0000
Message-Id: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
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

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---

This is inspired by a previous proposal[1], but in coming up with a
more robust interface I ended up rewriting the whole thing from
scratch. The lack of documentation is semi-deliberate, since I don't
like the idea of anyone actually relying on this interface as ABI, but
as a handy tool it felt useful enough to be worth sharing :)

Robin.

[1] https://lore.kernel.org/lkml/22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com/

 drivers/base/memory.c | 42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 048cbf7d5233..26344cb9f045 100644
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
+	if (mem->state != MEM_OFFLINE)
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

