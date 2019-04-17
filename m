Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D939C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:02:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0D6C206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:02:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0D6C206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49D586B0003; Wed, 17 Apr 2019 08:02:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44B9F6B0006; Wed, 17 Apr 2019 08:02:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33AF26B0007; Wed, 17 Apr 2019 08:02:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14A616B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:02:13 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s70so20597806qka.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:02:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C1P0rpBJ7wl0XOwuJrerM17/6mon2qZPo7eocnyL9AE=;
        b=PXaOLcEYdHSUuxAb1VEnEBUnsHQVLcLMZVv7bmsk0XzmDUdm5xlkzECDww6Yt7VHOw
         xwZPAe+2YzDBF2O/MKSMHd+c68ZfjpiUNAKPa6WijOX8TAK2DPi6DNgNA8GDWkpjlpBl
         eK61XqrUYgnP354sTHChe7IveGCbElqCDAxsDuJLAGoyoFFDO+upkrYhEIRqxupFUNnY
         NN0PeHYPV6MKbm8sm10Mg/MldLjXWz5wIZbmKDoLSbIA/zWUbwKCfyPZRkRjAGBhMSzs
         BvO9zuoHHPOxzhbkInkAXX8zWEXHmiJabuPzZuq29fhpiHhGCS3nI8FAbvVIRii2OpWl
         zMDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX5Qzp1AnJsSYefsNOhUcIe9a9Bb1ixE2gVxfbQK9YTGB5KyoBs
	Wq69X2ihpDvo4ANxlI+S2V+od6ieM3uT9/nJjSwBl1BChciGGJoXkfFnCYB+OUl82kGYZMk3Xr0
	wHqT79zzwJ/ICpyir6uutBAdX4atofVGmRtOrE2xx+rhH78ANAjsT5clqxjbgQQc22w==
X-Received: by 2002:a05:620a:108f:: with SMTP id g15mr66607803qkk.61.1555502532764;
        Wed, 17 Apr 2019 05:02:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY/BUMrF3L/7/O1b5WtFlKSkbB/xXRCBa6anUd27LvjbU6hUwD727Dxpiv4Q1z0vLZr5Kk
X-Received: by 2002:a05:620a:108f:: with SMTP id g15mr66607660qkk.61.1555502531447;
        Wed, 17 Apr 2019 05:02:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555502531; cv=none;
        d=google.com; s=arc-20160816;
        b=YeGWDjMvZn3WdGmzohIQ0aWV6M2ZdAMJzLSARzsmLSTngYBlAluBxxIN0IbwgnZEaE
         +EX1imuCfOfrVWiVyhPDOpm770+nPnZz9LsnpzazQQ8gegW2n5ZiItmTmDZPVQe3Qomz
         nflA6e+vgWas+DOwWzrLuTmoJ6cPYGnr1MVRYJDNIvpD2zrUntejdCfvCodJmnXYct5D
         34sIOFfxKSqZpCc47ZPc+14/GuSR90ixOZRuEcNbGe9i26ccZj9jOZt7taUVaaIBFU3m
         M3VEpq4AJL6K/8gW8gARjtkAkXig+cBDgYCAtBaq+bv+v1T7ec2i4ORURX+CLFSqr1qN
         t1eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=C1P0rpBJ7wl0XOwuJrerM17/6mon2qZPo7eocnyL9AE=;
        b=LWIingrcK2StoCHjOzQKk+HflBuQEtCP/mlPlJ/hCC8sffaXVuEqnFXcVm7z+I/5M9
         uZzkWyO/U0w198MACfbdvqKOO76rOPLXmI6jeHatwyevzXBHEp5NZGbJ8Zv0bCPTvg0Z
         /kgLO5G+H0Kqx8S2eAJ9pdk1LxksCZ/YHkSnFC7lUyRRh0t9YpkpXjK0Vr+urV3IXveX
         Pq7SDwoLCPMVLJcETCjYoF6uWBz/bQDcYsrAHFNSxNibJduyghpMzbKMKkR9X4Largf1
         429FBx1cFJ454FHeKYoNYVLun5e4+OM71hN14vefUEe8e2IYnFfcIk1uyyZ965UZ/vkB
         +DoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z36si1153624qve.93.2019.04.17.05.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 05:02:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5DFB8C060200;
	Wed, 17 Apr 2019 12:02:10 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-141.ams2.redhat.com [10.36.117.141])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 216905D9E1;
	Wed, 17 Apr 2019 12:02:04 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] mm/memory_hotplug: Fixup "Release memory resource after arch_remove_memory()"
Date: Wed, 17 Apr 2019 14:02:04 +0200
Message-Id: <20190417120204.6997-1-david@redhat.com>
In-Reply-To: <20190409100148.24703-2-david@redhat.com>
References: <20190409100148.24703-2-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 17 Apr 2019 12:02:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pr_warn with "%pa" expects a pointer to phys_addr_t or resource_size_t.
So let's propery use resource_size_t for the start address and size,
we are dealing with resources after all.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 093f6dc66f46..328878b6799d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1800,7 +1800,8 @@ void try_offline_node(int nid)
 }
 EXPORT_SYMBOL(try_offline_node);
 
-static void __release_memory_resource(u64 start, u64 size)
+static void __release_memory_resource(resource_size_t start,
+				      resource_size_t size)
 {
 	int ret;
 
-- 
2.20.1

