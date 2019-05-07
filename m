Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D48AC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E68AD214AE
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:40:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="s7CiKVYk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E68AD214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B3F16B0266; Tue,  7 May 2019 01:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 964776B0269; Tue,  7 May 2019 01:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82B556B026A; Tue,  7 May 2019 01:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9406B0266
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:40:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b8so8599598pls.22
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KC65gMo+rhH3SCCHdk5jtSbNLhJeS8STZkmSIu4KOvs=;
        b=oJsMkF3O8vPRKbO4Zvjp0L1VQ9JXGPnPnXMZqqVFTcAPykzCPEdoo27nMD2+07os3z
         irwYKMxT2t0W5e2AKTDq/TU/HqzgPLz02gdQhiAGb7az5jv6AZ1l+KkWe3Lk/RNPmhes
         zbv4pDXMz4eKojhIUDQcYs1E0VQSnygi5smubHZbvGi186G2JUqR7PJujekAG5itCwof
         7QKwH278Fkeug/beuHp5DsBkLFqS9VpbYKQQ2qUZaFzKQkOb9uohVmSl3AE/KXjOqvb9
         nA2dq+zkFEVoUQZgGxwp2LCVQVurLZSXKf5Xj3gySM+n40EbiYZtyw1Q5OaySUJCyT/N
         VXZw==
X-Gm-Message-State: APjAAAWTicJtbrJiqGD0YzdfIzCe2mB6cSf0DZYZ9Vb51VLIAgbmnevs
	LGscMbGPF+c9Q8aPc9pLQyJ67k44AwaIIqze5lbVdYzkpsrPCheXRyJWRBzdJLneXhPKjuBLW3G
	p/1BRHlM7g1S3ltbFwOfZQV2aZvbcrB7Vu+LreZgXjay+n175eAoJdBVrYgeCe9/oow==
X-Received: by 2002:a63:ee15:: with SMTP id e21mr37868649pgi.180.1557207623967;
        Mon, 06 May 2019 22:40:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVqEvF3RGstwjMGj5LgKRwlwtLVuCdxIzKHPt32OF78hxH9BeChSQigXek71mvbv4Vwtie
X-Received: by 2002:a63:ee15:: with SMTP id e21mr37868606pgi.180.1557207623319;
        Mon, 06 May 2019 22:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207623; cv=none;
        d=google.com; s=arc-20160816;
        b=Xc/FX3ZX1HDz+cSDGdSwYo9cPh2VHFMPOuscc9zlxbfOY+nj8h47iH+VN7QYplO3KA
         TIhI79ecUY2d6pThDIUMZEL+7wtIW1cfze95RkUsb3Cpbnqk0VmQUnpbG0LcnysZmZBI
         mpA1MVOYrT0v17AJQB0adK/vUWFZo5d1S1GOKK6q0JRRLzeGTGvjWIIG403Wf3gIbHxL
         GpXJo9sN/zh9tKgUjYO8TBMgCvksavTtxgMk8AARniw+6AWaaxP1/vMBFw10PSvMqc58
         Gu/zEKxrKrwzzD27owCGdK7JObvupiZ9VM0PNMFTixSh6QGEngfAXfcjCD08Xj2iYrjF
         k3ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KC65gMo+rhH3SCCHdk5jtSbNLhJeS8STZkmSIu4KOvs=;
        b=p94tevMgZHflj2g49iPCoHkpwiA8bIR5WF5lCzZ2ihVXHlgMNm70ZkZ6M4yrpk4Oa9
         +omHXoPDNBI8XDrj8hREtxU0qCJinDdkLbxEO6InUD478MJOTevq2dqN4YDUEZkCmq8M
         i//wA1KVGJ79RwahO3dz4AlRqFYr+0OAtdf8m3LxzhlQFlsZ3sajhtL8aS/LeFgtGIQT
         gbuleoDIv7geVyjzYfLpjOrf66zqvD/fUxqOwVCNR60CU2PfWzmkFnKPZfI2j9f/BwLv
         jNlPWj41m5wgvdSxuPYfqMc1eBEGsI+jCpa4GlfBLA5oK4YJr6Bx2Zm6n+Od5v/u4Xd6
         lQrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=s7CiKVYk;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z8si19194278pge.123.2019.05.06.22.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=s7CiKVYk;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5AD8C20B7C;
	Tue,  7 May 2019 05:40:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207623;
	bh=1hD+jyiWd7YHvDqUeKWSIvwnCseUwW7B6jDDJB43U8Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=s7CiKVYkNOfu0uro3pHOuAs8tpt44sSzVHUgoKe448X8peTRcelE8GT+H+ZnL5o1W
	 M+Sk+iY+39rMcDcjj6LnhlKMH6OfXmVC/0whLWtEKQ4o/sDoO667l8XnGE84+pcVbs
	 wLdEypiwpBc9yCWuxqaSJH+9ka/qjfRTzOxySVbw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Michal Hocko <mhocko@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct pages for the full memory section
Date: Tue,  7 May 2019 01:37:51 -0400
Message-Id: <20190507053826.31622-62-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053826.31622-1-sashal@kernel.org>
References: <20190507053826.31622-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mikhail Zaslonko <zaslonko@linux.ibm.com>

[ Upstream commit 2830bf6f05fb3e05bc4743274b806c821807a684 ]

If memory end is not aligned with the sparse memory section boundary,
the mapping of such a section is only partly initialized.  This may lead
to VM_BUG_ON due to uninitialized struct page access from
is_mem_section_removable() or test_pages_in_a_zone() function triggered
by memory_hotplug sysfs handlers:

Here are the the panic examples:
 CONFIG_DEBUG_VM=y
 CONFIG_DEBUG_VM_PGFLAGS=y

 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ( test_pages_in_a_zone+0xde/0x160)
   show_valid_zones+0x5c/0x190
   dev_attr_show+0x34/0x70
   sysfs_kf_seq_show+0xc8/0x148
   seq_read+0x204/0x480
   __vfs_read+0x32/0x178
   vfs_read+0x82/0x138
   ksys_read+0x5a/0xb0
   system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
   test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

 kernel parameter mem=3075M
 --------------------------
 page:000003d08300c000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ( is_mem_section_removable+0xb4/0x190)
   show_mem_removable+0x9a/0xd8
   dev_attr_show+0x34/0x70
   sysfs_kf_seq_show+0xc8/0x148
   seq_read+0x204/0x480
   __vfs_read+0x32/0x178
   vfs_read+0x82/0x138
   ksys_read+0x5a/0xb0
   system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
   is_mem_section_removable+0xb4/0x190
 Kernel panic - not syncing: Fatal exception: panic_on_oops

Fix the problem by initializing the last memory section of each zone in
memmap_init_zone() till the very end, even if it goes beyond the zone end.

Michal said:

: This has alwways been problem AFAIU.  It just went unnoticed because we
: have zeroed memmaps during allocation before f7f99100d8d9 ("mm: stop
: zeroing memory during allocation in vmemmap") and so the above test
: would simply skip these ranges as belonging to zone 0 or provided a
: garbage.
:
: So I guess we do care for post f7f99100d8d9 kernels mostly and
: therefore Fixes: f7f99100d8d9 ("mm: stop zeroing memory during
: allocation in vmemmap")

Link: http://lkml.kernel.org/r/20181212172712.34019-2-zaslonko@linux.ibm.com
Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Reported-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 mm/page_alloc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 923deb33bf34..16c20d9e771f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5348,6 +5348,18 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			__init_single_pfn(pfn, zone, nid);
 		}
 	}
+#ifdef CONFIG_SPARSEMEM
+	/*
+	 * If the zone does not span the rest of the section then
+	 * we should at least initialize those pages. Otherwise we
+	 * could blow up on a poisoned page in some paths which depend
+	 * on full sections being initialized (e.g. memory hotplug).
+	 */
+	while (end_pfn % PAGES_PER_SECTION) {
+		__init_single_page(pfn_to_page(end_pfn), end_pfn, zone, nid);
+		end_pfn++;
+	}
+#endif
 }
 
 static void __meminit zone_init_free_lists(struct zone *zone)
-- 
2.20.1

