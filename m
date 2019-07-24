Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF620C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:23:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BDA821738
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:23:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BDA821738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CFDA8E000A; Wed, 24 Jul 2019 10:23:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37FAA8E0002; Wed, 24 Jul 2019 10:23:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BD8B8E000A; Wed, 24 Jul 2019 10:23:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4C18E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:23:31 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so41623907qtn.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:23:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=CVKfqHfpVnrUAnB13+Kf5Y+drW1xRbhqQx3c51C/G5I=;
        b=bjGuD0uNYXk6rUWrZZ6rduxKNGol9G+Ymd87iEq52Dehck5xohBJR2aVpBD7yeQvX/
         H6NkMDOuKjjli8iJIzzcV0bozO18TF/Lij6lMa+wLM7CBi1MxOtEPfydySn2W4sEokHT
         1ZTCpNXz4nqkp9Iy9UwSUx/eKmxu8nYhG81Rkr+kD9vr8mOM5+XQffpIo6X7lHqYtqOk
         kz0o+6/H6hqKMfagbGEg65GkQ+wwdKyJlC2kewdDJY2CPDOwIp8Cf4TR8TAZGcDQG7Dc
         scbWhTYr9+jjIjca1mR8vdPwcR0pdDLsO+NHTgE0bXG3Ih8+RtEigt409txLY9k5bG05
         nj7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVdAHJF/syfE8twJ++VXdg0wP64nI7jwCR/sovhG0KcDFNAB4tA
	CbvPWitFsJ3zWDH1CqTLUgRcXplautDIhU3ttiItsBj6VJLtYQ6WxA5F5VWq1ZcSB1OOKZ0DQKO
	Ixjb66EAvPDtqR5EmIKV104EdsnIAUP9MjbHc8xSbzQsIddZJfSo/9ZQ0hQsNJbC7oQ==
X-Received: by 2002:ac8:2734:: with SMTP id g49mr58582368qtg.228.1563978210804;
        Wed, 24 Jul 2019 07:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1TgoPfLc72FjM+3jeV86na36vXZPxtyOwOEUVmf/eCoe1VPDjfx6fLR7L8spVDKGEpoVF
X-Received: by 2002:ac8:2734:: with SMTP id g49mr58582328qtg.228.1563978210272;
        Wed, 24 Jul 2019 07:23:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563978210; cv=none;
        d=google.com; s=arc-20160816;
        b=fFN73ChdDf7jmncRNrC5PC8wJRHKiRtdkTdS4eJKPRjZfz97LtSnv9k+bJSoSF2Duy
         vDR1xM9TOyTWWMFCS1j3PcnF0JyjezZ9CAiVdn+HI5W4l1+7nJduuK56KTvp26RxRIMH
         FSpjK/u08G3Jsn67/S3utZljr3EK4FjSCjnNSdImYeIs5JYWeppN8hQ/xJs8v75NIt0D
         SwGQVSjNGg3IhdsWTW3tsem20743I8VeNrUwkE4yI8bKA+4P6+Cv48HThGAozck653MG
         xDwhCz2E53EKNso2Zm1hyGdOdtHzI8ruXJPNVBOOWS0TbZkfxJNLZTrcC8dQnAL+GOL2
         SInQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=CVKfqHfpVnrUAnB13+Kf5Y+drW1xRbhqQx3c51C/G5I=;
        b=C34Ln4gYRGmGOpms9tOYF+bfr2ESxnu08TuZVcItgZsmkPj0vTCFtMxqtCgdOD9qQR
         YPNgYmEN2b3vKF7j1/Zp9nZqoP9wBOFAjUafZSUCrmkFPKMxQ4tcg7l7gPefhkFIO5Zr
         pVZzKQWkjnVy1d3Ldx6V9h3b/4G8+9e5J9XYRYKj/9ehJgVu+Q7TEF0XsupWrGdgkvxt
         8ivDu37SbOnvVzHx7K933c36fBydoPs0s1acFl/ElLKvruZt4vgOCNisfC1NsSMMeqdp
         0+6b+OppHvvLp1tnACYOhldGm8iaZb15MjZ4TEcdUPQ/xbDTuo/4bSOf1B0lD8bwV65C
         Ar4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p55si17783526qte.120.2019.07.24.07.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:23:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8D300307D851;
	Wed, 24 Jul 2019 14:23:29 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-47.ams2.redhat.com [10.36.117.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 06CCB600C4;
	Wed, 24 Jul 2019 14:23:24 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v1] mm/memory_hotplug: Remove move_pfn_range()
Date: Wed, 24 Jul 2019 16:23:24 +0200
Message-Id: <20190724142324.3686-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 24 Jul 2019 14:23:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's remove this indirection. We need the zone in the caller either
way, so let's just detect it there. Add some documentation for
move_pfn_range_to_zone() instead.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index efa5283be36c..e7c3b219a305 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -715,7 +715,11 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
 
 	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
 }
-
+/*
+ * Associate the pfn range with the given zone, initializing the memmaps
+ * and resizing the pgdat/zone data to span the added pages. After this
+ * call, all affected pages are PG_reserved.
+ */
 void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap)
 {
@@ -804,20 +808,6 @@ struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
 	return default_zone_for_pfn(nid, start_pfn, nr_pages);
 }
 
-/*
- * Associates the given pfn range with the given node and the zone appropriate
- * for the given online type.
- */
-static struct zone * __meminit move_pfn_range(int online_type, int nid,
-		unsigned long start_pfn, unsigned long nr_pages)
-{
-	struct zone *zone;
-
-	zone = zone_for_pfn_range(online_type, nid, start_pfn, nr_pages);
-	move_pfn_range_to_zone(zone, start_pfn, nr_pages, NULL);
-	return zone;
-}
-
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long flags;
@@ -840,7 +830,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	put_device(&mem->dev);
 
 	/* associate pfn range with the zone */
-	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
+	zone = zone_for_pfn_range(online_type, nid, pfn, nr_pages);
+	move_pfn_range_to_zone(zone, pfn, nr_pages, NULL);
 
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
-- 
2.21.0

