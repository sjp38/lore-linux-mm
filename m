Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8C5C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:08:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6A98218BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:08:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hRi655oh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6A98218BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E2808E0002; Tue, 23 Jul 2019 09:08:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B00A6B000C; Tue, 23 Jul 2019 09:08:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 582668E0002; Tue, 23 Jul 2019 09:08:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA776B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:08:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d6so21902547pls.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:08:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=mMJGMBwbdv3BuUIrB2fh3trkXMpns9zS+fKqqtIDYso=;
        b=FVzM9WKtorRVnYXe+DdYWc+8Lhd9cvqlBrKoIGnnIp6XZ/JBuuFOsLZPXGPywG7PAE
         ld1ExKXk4usHudrhGscN6PZ2n64B0IlPWk6aAjIoA1ljBz27sW/+ZtKE4/MCEbx55q/d
         hByxo6Q44hXS8P86QisWLiY8Noai0Cviidu0ZC12f2h+YzuzhrYWiRbXUEwr+dV9FQhd
         j+poZ0OtJXaFu8f1pYSCwq5ja4YAo1z0+kMbv7MT0De2frzbPh8Mnd+2uQ+cpppjVyUF
         qdoLTmXP+Yc7IvfbZwdxjR3G2/1mlL8xN747fTABxjcx+dzzNzOXtt9DKJjF1/6zC5OP
         h9UQ==
X-Gm-Message-State: APjAAAX5e6YkU2Jk4Ncs6rP9FC0ze7u5qZBZe4iS5HN4Fg262wvMiWdo
	T+BJV+4oUlK+JTvyQ5ZRyE4o+9xBU7depIOyCVfzZZr2ETrSbOBVgI5Rf5V34XDN8l34rGFt0bQ
	/HNM6IXog8clugYDJLY6DoGM3YaYSLKevNeJvD/4WYgFW6DPNNgpbsnisu7WJyZIuDA==
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr76488633pls.341.1563887301863;
        Tue, 23 Jul 2019 06:08:21 -0700 (PDT)
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr76488551pls.341.1563887300730;
        Tue, 23 Jul 2019 06:08:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563887300; cv=none;
        d=google.com; s=arc-20160816;
        b=P5WT1Feghk1fszvtL+xxtgCLfTFOFqitknf/h1mr9K+y76Wsw61JDMt2V3NSP7Xk/r
         KwCoMvp9FHTwu+H7OjgLvuMTB5I7eYQOKtIQXciF8+hUdzvLyrD19EyJ345R+mU37YQS
         zKsg8+8TEWlIzJX+Wu5/bhh889WcXQm3NenUMeRJjI9UeCuz/QFxkr1f9dOe27U5T8Wb
         SxI2dFDJDw2vQY8sXTBDOfiHYln0VI5RqqNs2UyEjhLKrQoUX6HEwNEoc77jU/mfDhBq
         CKoXOO45mN2U8ZPAyEcP0rJruTAOJmP0U5Y2tVLWgZVTSRz3FgoY86rnFjjpjjWMCsxX
         qUqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=mMJGMBwbdv3BuUIrB2fh3trkXMpns9zS+fKqqtIDYso=;
        b=qz1/o/pl80YxONFJirLdg+4P3l+dN5CsS9hTRevLvi8bypUYDjthdKPLLRN1r6CJrU
         +YqO/uWqGy/Uix2jPyrAI7QKuu8TnjM13MAz5Qi6oDdzPToaJO6QHpEzuiJGrdSxEKXH
         YRhIPuP8VgzJAEPuAdr3QsnOJRT9xhuiDpqZXJhHqdgCBxHPGUlUsY7OBqZBiII0F+pB
         R4v3Ws+6lu+5UrejGCGmryiXDJvnkwZuxtDqbe0kXLNXSbth7mpHI2gbffRCoDEG+JKi
         GKFYpFIQgOkZqyv2HqW7RPRyZckmzRAknTsMm08d7TW5b7JUUiHQMXQjhkuuBuBesATV
         KRTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hRi655oh;
       spf=pass (google.com: domain of houweitaoo@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=houweitaoo@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor52069431plr.53.2019.07.23.06.08.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 06:08:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of houweitaoo@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hRi655oh;
       spf=pass (google.com: domain of houweitaoo@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=houweitaoo@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=mMJGMBwbdv3BuUIrB2fh3trkXMpns9zS+fKqqtIDYso=;
        b=hRi655ohdlnFYbeJACxTYv4WXDTzYM6muo+fQ0W+9swzRbEC7whe7L3x9g32g/hhgs
         FOFAtZGhZ7Br9Gn+HA0jF78wSvG99IiJ3YuANkCoB7L5DbI91alE1V0JI4ZkQJfFBq5Y
         k/k2hEvsSaom9j+dXabOqm14XrLUCDPWGkPhDV0fLeuQzdi/Aa2cPG4m+i5XDM9Z3RES
         zgaGcscpo3/b589RlE8M5NazmIvL0BTxFYRKmU+8NZaT/IMzpVeQXj8F+/kksyCZ3dEj
         qyQwY1ixuMDC0Y97X2wxJ0nxggbFTKck4L2WG9UqymiYN/KL91OpdcwcBP0tOH2FIer9
         rUAg==
X-Google-Smtp-Source: APXvYqwmCu4VygQO+Rx9bAtrtscNWk4NIlhSZPtvsVz1VJIBxtoVYfY0lrSZLTcdwQEQ3YSz/ESs3w==
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr41262500plb.19.1563887300481;
        Tue, 23 Jul 2019 06:08:20 -0700 (PDT)
Received: from localhost ([43.224.245.179])
        by smtp.gmail.com with ESMTPSA id r2sm58250026pfl.67.2019.07.23.06.08.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 06:08:19 -0700 (PDT)
From: Weitao Hou <houweitaoo@gmail.com>
To: akpm@linux-foundation.org,
	osalvador@suse.de,
	mhocko@suse.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	dan.j.williams@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Weitao Hou <houweitaoo@gmail.com>
Subject: [PATCH] mm/hotplug: remove unneeded return for void function
Date: Tue, 23 Jul 2019 21:08:14 +0800
Message-Id: <20190723130814.21826-1-houweitaoo@gmail.com>
X-Mailer: git-send-email 2.18.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

return is unneeded in void function

Signed-off-by: Weitao Hou <houweitaoo@gmail.com>
---
 mm/memory_hotplug.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2a9bbddb0e55..c73f09913165 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -132,7 +132,6 @@ static void release_memory_resource(struct resource *res)
 		return;
 	release_resource(res);
 	kfree(res);
-	return;
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
@@ -979,7 +978,6 @@ static void rollback_node_hotadd(int nid)
 	arch_refresh_nodedata(nid, NULL);
 	free_percpu(pgdat->per_cpu_nodestats);
 	arch_free_nodedata(pgdat);
-	return;
 }
 
 
-- 
2.18.0

