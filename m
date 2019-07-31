Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50432C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:32:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F42C20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:32:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F42C20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9EF28E000A; Wed, 31 Jul 2019 08:32:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A751D8E0001; Wed, 31 Jul 2019 08:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98AFF8E000A; Wed, 31 Jul 2019 08:32:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7668E8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:32:09 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so57947588qkd.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=5I2KeQRUKTlfavYrqikDS7TJ6FeQP4IReFyVz5PwfaE=;
        b=MVxqfajhZ9zpUsn1HVIk1z4VOpa1HQBon9AnfmiWYGL430xlraRweYWszsFHbnYOJq
         1YUhVKuDhjmpoG2SQroECIFux3lmDaNrhTrOd0YLk6IOk07R5kXDXdwl5c5rpEOF0hXm
         RIW1NRGZpQbCECBJuSgi/hUDDSR5dBetsHYLYvYgv9F+pZAdUQtT2gny2BhnKMkFlTy+
         fjNBc/fVxBdV86jVW+7sjGjwBTtLTWHPOkCuJ3dlNa/PlgRj+3r+fBKx/kIkV+f6aUJt
         XgY/7HoQ8Ivvu35yyc2YaG58A1vSBgQ2DU7UJe5/FXcR+Krb2JotfNYzdBRGbHSNzgyU
         +pDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWW2qZo1LN9caTT/S4IDUMiib53DJW7cFXbmPKOL3uhv5fu03Dp
	jC4EicUsUmasQLBG+wcUEClQuG68fHLB86qgOZliMfQzhjhMz0MhYIjl8le8OEi0nZxKtm698lC
	WJO1/5/OruKSjzATyLCq9CngItPlZcn0mV6amYKpjyoN4fcgEA5c9Cg7zGe80/Pk5rg==
X-Received: by 2002:ac8:282b:: with SMTP id 40mr86223763qtq.49.1564576329223;
        Wed, 31 Jul 2019 05:32:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydpLDYrj/J2+j4ToDk8Q7IFHIsw7b1hp72HXnGH7wgugGHTcRg6d+aZlwksRxmqDx0Xzwq
X-Received: by 2002:ac8:282b:: with SMTP id 40mr86223701qtq.49.1564576328438;
        Wed, 31 Jul 2019 05:32:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564576328; cv=none;
        d=google.com; s=arc-20160816;
        b=l5KpGJ5pIc6kL2Dktx8GCA1Yz4cBcIGXV8NGGAthRVHXKnb+q1U3967s/H4DdOv5+q
         kUIqRvis7qIOe9LA6X07KwB7fsCmUGXSAzjLHtkzVZ3/Y+RhfxDsXIFh6Zh45eiE/rl/
         75O6xxUM1bmFBjol+LDh/4j+/kOErFujyXcCHbdh50LDKQXNBcnpgXzPC+t1z/iyKRbb
         N40pTz5A7Ga3YK+HSCBTLr8Wx5o3Wr/zlEHO165mOILkMEiFTY0ScoqD64UZGJJRe2i4
         vd3p1GbvPFqxUMxjT60H79muYpog8OI9MSNCwOBkQnV9znBmNksvHTpEetP04O9O83m0
         IgTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=5I2KeQRUKTlfavYrqikDS7TJ6FeQP4IReFyVz5PwfaE=;
        b=IBZaV4zV+fw1v4n3xPonfeDL4qYIJOsMLS6EpqYTXeEWcZV4UMOHnCbIUSDf7vvg1Q
         xd7afP0rh9i6YZuhguZoFjyc4KivVbm7bOotIzJr/r4TKWwTbBAyyF+naejydMYj5/Bx
         1kAPu3XMHWsMg0n9Fub+6XVkVqWEaAIjgeO3BIdvttyt8oSFB1l+3+SQAB55yaeYOvRS
         7PrEVrYyJtim1ZoY2O+bfChVmbvtOyvSgCPsDV9zVb9shjybaHm8lQh+fczmB9RYYc2S
         FaMOCiG578f9pUMwu/ChGk4t3Oo/VlQFpcZ9G7F56PimULvKj6UnuJ7SHv+oB3CZDyT3
         tCNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si24559017qtm.15.2019.07.31.05.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:32:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9348185542;
	Wed, 31 Jul 2019 12:32:07 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 792775C1B5;
	Wed, 31 Jul 2019 12:32:02 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v1] drivers/acpi/scan.c: Fixup "acquire device_hotplug_lock in acpi_scan_init()"
Date: Wed, 31 Jul 2019 14:32:01 +0200
Message-Id: <20190731123201.13893-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 31 Jul 2019 12:32:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's document why we take the lock here. If we're going to overhaul
memory hotplug locking, we'll have to touch many places - this comment
will help to clairfy why it was added here.

Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/acpi/scan.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index cbc9d64b48dd..9193f1d46148 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -2204,6 +2204,11 @@ int __init acpi_scan_init(void)
 	acpi_gpe_apply_masked_gpes();
 	acpi_update_all_gpes();
 
+	/*
+	 * We end up calling __add_memory(), which expects the
+	 * device_hotplug_lock to be held. Races with userspace and other
+	 * hotplug activities are not really possible - lock for consistency.
+	 */
 	lock_device_hotplug();
 	mutex_lock(&acpi_scan_lock);
 
-- 
2.21.0

