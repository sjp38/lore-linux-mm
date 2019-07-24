Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCBE0C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:30:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE7AD217F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:30:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE7AD217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B3E76B0269; Wed, 24 Jul 2019 10:30:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4653C6B026A; Wed, 24 Jul 2019 10:30:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32DA98E0002; Wed, 24 Jul 2019 10:30:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 12D556B0269
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:30:24 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d26so41669653qte.19
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:30:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=hEdsblRXavxgNL4+vv2aVGd468HasV0V05R+owPw+HQ=;
        b=SwQWYynenDMfR5l7LAcX2XB65OfiDD5OChrU1ZNnPbxhFO6+zffVUwMC5dV3OLk9Gc
         S1wKri7MAtS9ojt5mx9y43msRqw3Jws5VkAX3KGPk2ct8d6pHWJeLBI3Yc/PO3MMw0E1
         0RgOzI2eEzEOaA4N62hXX/fjxCkcapO5m3bHLY9SBqdLAHbo2LvkX5EBbPAweB8/LTob
         FqOzUoQS2d0xI2oJLfGewD09E+5jgBDCuL1WYWKTTgrwjon+mqCiKVdYwvJWAaXR/+/o
         tGXI+GGdam3VadPZV0+BVq934xqhxKRK/E6W+gdA1Qs9U4klADjgYPrJhXrBUBOWrc60
         WUmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRskwMJtJw8D9VUY3VIFSUQ3Fl3fXQD6Ec7ORjnubq7oRzrxxk
	qflucUFh4HgYt2C2eR9h/CwoWG9JS5CswXX+TZ8xtA5JkfgMJaVacZjCNMH3Hd6qVV8TavS1vLP
	7awHzeB4f5GmWzmhCgH3jSCsY7YVrzrvLZ1hBCiNIuOY5XPuhqeImybupkagqLpJ5/w==
X-Received: by 2002:ac8:2ae8:: with SMTP id c37mr58369982qta.267.1563978623832;
        Wed, 24 Jul 2019 07:30:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx34BkyYaCKc+/9/hscExlkQDu5YROvztd/zAilPpAqJIYp6VXzpEercF0XZIOVwmc2gaqc
X-Received: by 2002:ac8:2ae8:: with SMTP id c37mr58369894qta.267.1563978622767;
        Wed, 24 Jul 2019 07:30:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563978622; cv=none;
        d=google.com; s=arc-20160816;
        b=bZKlfnelFxxaAGp5E4Ku6bQqsJUn8Ln3Uh2E93fIK5QX4unQlMrqpdNh57wO84SeRG
         wLK4WUmBfkGN5B5DOWbl43XZARPfT7nRWKMLiUtcK7RKRzfjkMGhm+6HZY57N/+/VRWo
         Qh6/44MMgZwusviSAZdC9X3lbczpMp7xSpxJVsfTjbgxpPYciTL3kIwBwOvvPh8HNIVE
         1m9U3sBKFLtAmux23vgs2ueRtFFjGGDKYuvvA4Btqd950kSN/UfAA0J6tX1evYx7c8k9
         XTpE4q8QCEXgdAiIJf6/nQBFgM9/UAsMed6c7SvNeljDPsA6BurUZ2a3SH+/l+dsSH7o
         L+Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=hEdsblRXavxgNL4+vv2aVGd468HasV0V05R+owPw+HQ=;
        b=cGTfFHuomZvx9dV9OLf3xi3l6OdVns65GSeHGEL4Vn5feFisZIaz6sKRV6FjZJhSau
         j3+/x6FRGIcNxhrqBaGs9tRhuci+ee9iZpyZzeN347y3YT4pi9kKPuXsGZFyJ/7d1YgT
         LYJ+LgbiupLeEVi6wGu77L/yYcU9X3ntemCAoTA1tcV7sckpi0x8oYy8XWfckr2RefA2
         9BhWTb1oPbbRJ5yrZP2uCbx9sFuZSOyFawxlvnIzeP4lsD3rynDBvLPWqzGaQuNsrr+I
         FQAfgJnG4BNKGv7eJDNVruuywjU10h+Hnu8DyOG3MMmNA6gOAH3d7SKE1Gbt2QOybak0
         ew5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f40si30051426qtf.181.2019.07.24.07.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:30:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E9CCEC055673;
	Wed, 24 Jul 2019 14:30:21 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-47.ams2.redhat.com [10.36.117.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CE2B060A9F;
	Wed, 24 Jul 2019 14:30:17 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in acpi_scan_init()
Date: Wed, 24 Jul 2019 16:30:17 +0200
Message-Id: <20190724143017.12841-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 24 Jul 2019 14:30:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We end up calling __add_memory() without the device hotplug lock held.
(I used a local patch to assert in __add_memory() that the
 device_hotplug_lock is held - I might upstream that as well soon)

[   26.771684]        create_memory_block_devices+0xa4/0x140
[   26.772952]        add_memory_resource+0xde/0x200
[   26.773987]        __add_memory+0x6e/0xa0
[   26.775161]        acpi_memory_device_add+0x149/0x2b0
[   26.776263]        acpi_bus_attach+0xf1/0x1f0
[   26.777247]        acpi_bus_attach+0x66/0x1f0
[   26.778268]        acpi_bus_attach+0x66/0x1f0
[   26.779073]        acpi_bus_attach+0x66/0x1f0
[   26.780143]        acpi_bus_scan+0x3e/0x90
[   26.780844]        acpi_scan_init+0x109/0x257
[   26.781638]        acpi_init+0x2ab/0x30d
[   26.782248]        do_one_initcall+0x58/0x2cf
[   26.783181]        kernel_init_freeable+0x1bd/0x247
[   26.784345]        kernel_init+0x5/0xf1
[   26.785314]        ret_from_fork+0x3a/0x50

So perform the locking just like in acpi_device_hotplug().

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/acpi/scan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 0e28270b0fd8..cbc9d64b48dd 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -2204,7 +2204,9 @@ int __init acpi_scan_init(void)
 	acpi_gpe_apply_masked_gpes();
 	acpi_update_all_gpes();
 
+	lock_device_hotplug();
 	mutex_lock(&acpi_scan_lock);
+
 	/*
 	 * Enumerate devices in the ACPI namespace.
 	 */
@@ -2232,6 +2234,7 @@ int __init acpi_scan_init(void)
 
  out:
 	mutex_unlock(&acpi_scan_lock);
+	unlock_device_hotplug();
 	return result;
 }
 
-- 
2.21.0

