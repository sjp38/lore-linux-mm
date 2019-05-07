Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39406C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:37:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC053216C8
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:37:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="v2neQjX7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC053216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87EDE6B000E; Tue,  7 May 2019 01:37:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 806F96B0010; Tue,  7 May 2019 01:37:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9346B0266; Tue,  7 May 2019 01:37:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 312DD6B000E
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:37:56 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so9509341pfa.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:37:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+QEIknlCFvT17/sqGD/BDjZLgPDR7jDQVJKHvhM11tQ=;
        b=P0bOe1/e1DKBeU+lCOoPBjf7oT//py3SZ+6Cm52LueG9vhdiT1EcAuD1LPJq0B+sO8
         TGttgWju+haCGpGXwVa0KCxZB5DNOXxLZWuXPKgeMAhficIiFfgD3Xkx2bZv97lmbMaK
         +Y6zm0/V9mu7wf2lCZjIaIih4Mxmzs0MmLzURCm4X0+7bqQBuVGd/cQaRpHnpGPl/6Tp
         38vfpex7+ureMs8M1CgzYM44hgxaQIld5Cz7LzYsnRF4P4mDS4jDDJd0Y4k892RKA9WA
         XB1MFX7DC/0rDUnLRRQzFcAvkAqAQmj3LP0F5KPURYqbiyI1hEXkIZJ7GYn7X4Krg7UA
         UjAg==
X-Gm-Message-State: APjAAAX6qGTBtoh7KVasebIUe2A2S26dcMZaRRwRDJGSDGEroArBAwu9
	WPk6xTKCeIqVmrlrrn+PxqDLlAtLpXmE4/vbIA7DpI0bExpICL4AV7Hs/SjmOsnoRgWKefb9G+A
	CE+KkOV6gFqWWk8mlCfA5UKVNajzZN2frbcUF3lw3yOM1CA9I0QhSaIQRAk1CVUpJtQ==
X-Received: by 2002:a62:160b:: with SMTP id 11mr38508052pfw.88.1557207475883;
        Mon, 06 May 2019 22:37:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUK0+4tddtlC3dyYzEi6pZJkUCp8vG7Cv8yuk/qDBdzr0K5ddp4WSxmRiCktqE1kg4y/Ht
X-Received: by 2002:a62:160b:: with SMTP id 11mr38507998pfw.88.1557207475203;
        Mon, 06 May 2019 22:37:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207475; cv=none;
        d=google.com; s=arc-20160816;
        b=S+RdJvTqaRO8uH0lspTO8iL6CuevWv+1SMymrT2KZddmIzsROdy7IjCi09J3DfSYHQ
         mQtNQuVJOdtdtF30THvHFmC1zdAPiH3UOOTFTe8gL4KAZJKSY7sKKqR06GfSkVfh+LT/
         aqWgtr3xmzptsRWBbf2FBwJn4/itn9IY8ZjeagXPP4EraLzUABzWzW9SNV64g1rWCmBk
         tWy1UHrcav/ILSL2lNK3JzuN7qgdq0CEG/Efc6mnZrwzdz0bTDIT435urOoXGGWyLPDN
         yP9ARVdh1DNRmBgT5K/u9AWchoe6LU7f5XcAKOCPb0OFCqoVjHOxODMIfJzsw8op+3tJ
         +I3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+QEIknlCFvT17/sqGD/BDjZLgPDR7jDQVJKHvhM11tQ=;
        b=vjtGKeGz6rLE4oZrbx7w0DlsltC/to4L/8OT1B+YaUm30wWHNKheZB2y35gd+Oikzq
         xEoyNEfJAUj+SA/M8b4gJFf1NZMT1CFG19w4jBww4ALak8Q1f4xHPM6mMTHgxLajkQK0
         kcl84rL/OVD4m3TliNCzTVinDbRXsZf2GrERBscZYTj0IBV1nv6UlM7oOm/v/HfhNlU/
         QWqSnYQbjMHivRnkD1j8LXKEen/m135ojrq9/0XlSPMZ7Rms6JP9IL1VHoXH4xYBP4u4
         BI3cE1YRTJG5JRs1bvJ5m7dExmV3vWGUci8qQ0BhudrJ8dH5yudrc9jgHgUe1HuoG6Nt
         +Kcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=v2neQjX7;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d185si12131194pfa.182.2019.05.06.22.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:37:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=v2neQjX7;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 56E8720578;
	Tue,  7 May 2019 05:37:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207474;
	bh=itR4g2WKHerLiXBWp4LPWTXItI1Mg4Qe2yr2sz5HZKU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=v2neQjX7kj2u9VkKRpbKe1RyuhamhyfXKUpbT0d1YURnaU+lO9s/LjTSdliNbxVqN
	 x5R8uRj4VSzISl5V+ApPuA0nrYlVb4//fha5tRn5Wq42tp7L2I2Ol3w5d2Jf24TJPu
	 l9F+6puP1sO182pRL8/zVOpRwHVoZ7xajKUBRO4g=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 63/81] mm/memory_hotplug.c: drop memory device reference after find_memory_block()
Date: Tue,  7 May 2019 01:35:34 -0400
Message-Id: <20190507053554.30848-63-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053554.30848-1-sashal@kernel.org>
References: <20190507053554.30848-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: David Hildenbrand <david@redhat.com>

[ Upstream commit 89c02e69fc5245f8a2f34b58b42d43a737af1a5e ]

Right now we are using find_memory_block() to get the node id for the
pfn range to online.  We are missing to drop a reference to the memory
block device.  While the device still gets unregistered via
device_unregister(), resulting in no user visible problem, the device is
never released via device_release(), resulting in a memory leak.  Fix
that by properly using a put_device().

Link: http://lkml.kernel.org/r/20190411110955.1430-1-david@redhat.com
Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Signed-off-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Pankaj Gupta <pagupta@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 156991edec2a..af6735562215 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -901,6 +901,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	mem = find_memory_block(__pfn_to_section(pfn));
 	nid = mem->nid;
+	put_device(&mem->dev);
 
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
-- 
2.20.1

