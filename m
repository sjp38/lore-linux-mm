Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DD52C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:53:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E09720693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:53:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E09720693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECDB48E0003; Wed, 31 Jul 2019 09:53:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7DC18E0001; Wed, 31 Jul 2019 09:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D46978E0003; Wed, 31 Jul 2019 09:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B6C708E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:53:10 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x11so57103722qto.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=gTYnWhFY2Y8ySXDBBhKlyYnBsXqdAcapyLryjibiR6U=;
        b=UInMYTVYzx9Y/BVVWCB+5D0ikT3SYJmCAPLsZeR4GW3GHTlklDI1NArQSWZ5BBgdiE
         VbuvV8yMWE9liyPwxO5FpdXmxE7yog2pMoxh8Su9QhVK26yt3tx03y2NCScy2H8cFp29
         Z5mQhNPJiG8tX9RU5L2Glp7GiO2QQ92GF/vpkSLPJcb2/4akA0WXHUjScuPrakC28hQO
         fqMihDI5M7tg544yWmufayUezdKbgvXj3ydRiEZYHTRp+ZLxQFQ4H0zaQnKWArmHfdCS
         Vky2JHPfb6OpSyWkThA8+CLMSetLVITrXtvUg9x6tRigm5Ply9JXPRdPsONw+Tpys01w
         6Mdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9S/JwruW/MSwLmtMhPTruX11DtW4o/2PnukBXRAXeT9gu7pzc
	s1vfE4F0gKDtGK5Tu4pTJv3V7H/6XhiXzj2/36c7XTS78zUH2YeVd3ndSDigedJEJ+flJK6SczT
	f71Rmxa5vqdQPOEKc3Eian+4Wv+skfuyxU62YOd8i7FFy5JVBZA01T/aCg8T/FNUxEA==
X-Received: by 2002:ac8:3907:: with SMTP id s7mr88352967qtb.374.1564581190521;
        Wed, 31 Jul 2019 06:53:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySmPrmKxnTtDd3NKgiW1VECnDphI5fsAjiihyDhay8UbnRqrLAoQBiMOsB8y2YiKVmo4PZ
X-Received: by 2002:ac8:3907:: with SMTP id s7mr88352914qtb.374.1564581189689;
        Wed, 31 Jul 2019 06:53:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564581189; cv=none;
        d=google.com; s=arc-20160816;
        b=mW/4keNmevXtLD2wi0cf/ZNzIF6GStgYG5OkhiLvD4c/SwuClIRsUzf9baGUKiU4pK
         QI/bId4MMyiYx2725D1KiSqQhcWo0iImASzM4Hpi8CYMzWbZfkiPNI7DjimtvX+ScJwq
         NbgVJlB541DslY5WaKgach+jbYXcQ5tLmn77v6S95a4DNljG9Na9/NbEV+ELEWA2PeYo
         UZV1ULOA+EHu7cL/853piY4adwhAP2F5xP18Bs6eR/KPrceGYCe40sLd/MFWb5jmX4CV
         tZ9gB3HJGeTnY9A3HebK6JrLlkZkGkjupY4R+xRZSmjW2HXdlo5BPee62ma7nes9X6id
         NXIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=gTYnWhFY2Y8ySXDBBhKlyYnBsXqdAcapyLryjibiR6U=;
        b=gJm3gB7q8Di+X+QiH03VILssb8ywLPIP/sVM0WQR1AqB5/rNSiwWITdalQUJbHFKxF
         wOHcViMOu0MK/9XwnH+9rQwd7bHJ+Haaa47f3eFPWQxor2/WAV0iCYo+cvZl+6waS/og
         r/1CFizIAXnkY/cQH922MLFw4aAp/yVmNi7135BbAeroM7mJW/jnr82yxHWUojkst/DE
         cDryMvp2KCFjlIY4vXOLDDUm5pmpe1nmLqYKK4DUHLIoW//rWuxVgxkIoKBhIhHiOjsL
         hR6JYdetd0aP7RMqckohIFuXTob124Fvh+n04YBYwovU47aRXQRel+ft8O6dwi1FuNu2
         IMDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z36si452495qtz.405.2019.07.31.06.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:53:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CCEAB3079B62;
	Wed, 31 Jul 2019 13:53:08 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2C5081001959;
	Wed, 31 Jul 2019 13:53:07 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v1] drivers/acpi/scan.c: Document why we don't need the device_hotplug_lock
Date: Wed, 31 Jul 2019 15:53:06 +0200
Message-Id: <20190731135306.31524-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 31 Jul 2019 13:53:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's document why the lock is not needed in acpi_scan_init(), right now
this is not really obvious.

Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---

@Andrew, can you drop "drivers/acpi/scan.c: acquire device_hotplug_lock in
acpi_scan_init()" and add this patch instead? Thanks

---
 drivers/acpi/scan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 0e28270b0fd8..8444af6cd514 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -2204,6 +2204,12 @@ int __init acpi_scan_init(void)
 	acpi_gpe_apply_masked_gpes();
 	acpi_update_all_gpes();
 
+	/*
+	 * Although we call__add_memory() that is documented to require the
+	 * device_hotplug_lock, it is not necessary here because this is an
+	 * early code when userspace or any other code path cannot trigger
+	 * hotplug/hotunplug operations.
+	 */
 	mutex_lock(&acpi_scan_lock);
 	/*
 	 * Enumerate devices in the ACPI namespace.
-- 
2.21.0

