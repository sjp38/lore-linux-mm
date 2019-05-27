Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71660C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ECA220883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ECA220883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB47D6B0274; Mon, 27 May 2019 07:12:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C66866B0275; Mon, 27 May 2019 07:12:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB82B6B0276; Mon, 27 May 2019 07:12:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8439D6B0274
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:15 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id d62so6345252otb.4
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZzVHyKxsaFuN8jNqoGwUqAgqRnUraSka3HiY2u0A+MY=;
        b=aSnouf9RyDOvoQKFgLhLC+3AM5xHrHUGLDGuxFn7W6tPegk7OzKRuFlFkTEv9Y6pvQ
         QwVquFZdQcYKWwMxSUUK9fWJEAIITgBO1Vo+bw+9QULYtAJHb6wqlYgwGur38HSbng4o
         61CVgvcJlIn0xHLggpLdFGTTiHBmCYRsXRPutA99xz3Vxg0Q4cCup74LS9XAXNAGa9Kd
         YR0HzXCuQpnCQC/iw6eoXvBrTt98EDiR+GsaB2hVriNtFKtviPgDYOg3c+oEzilzpLlg
         vE9a/6oMKn6d+nOJtTaqU7lYU9CUSsaX2n3JK2wvcZCgNA7LgbiWotUkFTOeqw+XglDB
         x8sQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXIUZQmR3yeIQmbRQRCaAVh/YbS4pQge7NCoGH+Qq29GrUnCSFx
	xgIPM1teODeJXPQl7aavBubbWui/xZ2V2lBcKUsjMbhBLkvkzTfRqbXPZZb+BcgsNpk9o7OwVYy
	Ip5wQN03ROxksNHOvcwbclyxWGzGk3kuIuXxbBHSqC6VNKT4uDSwhLHVvZudcWLY54w==
X-Received: by 2002:aca:ed44:: with SMTP id l65mr15066258oih.107.1558955535193;
        Mon, 27 May 2019 04:12:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxY4PmiM1ulv6fNQnT8Gx79t5npl5wsf9OZ+pEHu+vD5TfIuvm1+ARBjuz3fx1WsCFjfATc
X-Received: by 2002:aca:ed44:: with SMTP id l65mr15066229oih.107.1558955534640;
        Mon, 27 May 2019 04:12:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955534; cv=none;
        d=google.com; s=arc-20160816;
        b=yaW3FepraXXpF744nJVYUuVgicqKW6PcV+Zt2yE/tgkYK6D71wq7Tr7HgY5IGN+zjn
         gfGfx5aOcmIH5xzY/XfvL6bOykzr8b9bo/9PIiNlRgvmuGBp70QfNwOCq+ZaVl6za/sL
         dS8tmZhlwyonUup17yR7Je/SbBDCC+229lFm7WNqlY4WFDSLgQGWPoBsMLmnD4JI6xaB
         upgw/dTyNQzmYxPnq33IxoZpcAckBKCNt+gA8jhsGQz4hYs86M1LskEbzlSTpTvWiRNJ
         +bR10jSwK5SX3Fmp1o79g1XNpym1OVECEwpfS0w1FBkdQpVjKcJyRfmnh97PgU250oot
         aA5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZzVHyKxsaFuN8jNqoGwUqAgqRnUraSka3HiY2u0A+MY=;
        b=rbSWC7hEjfV/U30cbQbMnjKrfZo168PtrA0uw/awQaws9ba+y67lDfin7H3JlzUeHR
         tG//FgAR2/G9i+y/fHvuwaipYC19IH69dYRlggonEm0gzKuur7zHJAwylA6EkqHCK126
         D73xhC+POB/RLj+h9VkWtcq1nLD8JEdRoZMvoLVfCbzNhnUJUfqCh5wOj7w/np6oCzHk
         v7su0CJaf1gXBJGfs9ZE6McCK6iwmZl8h6RtKO7+SekjpFS71mBE5nfqYSTnjoAOYQBV
         S2Aeeb5PtfgM4jLUhsfi2oybXMalslRWBMQFutvMzExHeuOklk8bFh9B9bZ6/Dz+WHre
         PU9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r3si7059719otg.222.2019.05.27.04.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CD8CF330259;
	Mon, 27 May 2019 11:12:13 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 54D6E19C7F;
	Mon, 27 May 2019 11:12:10 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v3 01/11] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Date: Mon, 27 May 2019 13:11:42 +0200
Message-Id: <20190527111152.16324-2-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 27 May 2019 11:12:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By converting start and size to page granularity, we actually ignore
unaligned parts within a page instead of properly bailing out with an
error.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e096c987d261..762887b2358b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1051,16 +1051,11 @@ int try_online_node(int nid)
 
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
-	unsigned long block_sz = memory_block_size_bytes();
-	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
-	u64 nr_pages = size >> PAGE_SHIFT;
-	u64 start_pfn = PFN_DOWN(start);
-
 	/* memory range must be block size aligned */
-	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
-	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
+	if (!size || !IS_ALIGNED(start, memory_block_size_bytes()) ||
+	    !IS_ALIGNED(size, memory_block_size_bytes())) {
 		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
-		       block_sz, start, size);
+		       memory_block_size_bytes(), start, size);
 		return -EINVAL;
 	}
 
-- 
2.20.1

