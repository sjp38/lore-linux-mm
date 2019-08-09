Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36E29C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0066821743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0066821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DA516B0006; Fri,  9 Aug 2019 08:57:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38CA06B0008; Fri,  9 Aug 2019 08:57:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27B466B000A; Fri,  9 Aug 2019 08:57:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0647D6B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:57:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c207so85540485qkb.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:57:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DYax3JMtrJNaf7Y5J+JViqXkZFDgg9sSwIsxT/iAzxM=;
        b=XwZUrzoeIkcRXheHg/vZnQskTAl5T6SRKsJ83WfNgFYCRefPeSS8wlMWRiIhKI8Vwf
         R3cRz+9Mb/PNnwaYxaUKuXv5FrTC1kQrdshZoezS2nAgfT+cC4aM+mAkRdwwekEwRStQ
         fAuWMxNaYZC9LvdxPQ+iANkK71VHK11d/gwM7XwvLgb6LblYusszikXfStGdzwJF4ii0
         i2NlGAgUlP1l0v74OeCDjWY976r1L7tpBmwEugFZnAnD77mCxHHthEyCSUdFtRQ+wW2t
         07B7MU3+JE12Enlfqc8srw49SKzn0q1o1fqAvipMQ3Ns9GEF2MKSS+ljCE8sO0OGmrH7
         cO4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUME8+vLPhjiqBsF9DzpI3eWV6W091c79BJ0Fdt5Eae2Ybax9XZ
	vFcsxfPhDtQx80fWuY1/IGGxKIfX7St+f0ELdqy5SSxwKIzZKgzrGLKFNchp8i0D4+95P+K2E+t
	zcVX6p8N51TkEailss94PuZGGfbVYnzSFfzrnVrbMMCqBvmXMhfIzHwZvguoNtUsQFQ==
X-Received: by 2002:a0c:da11:: with SMTP id x17mr2862879qvj.197.1565355459831;
        Fri, 09 Aug 2019 05:57:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7gkV3zRXIIUlqnknXvMneoxqIsBOGU5MRtqnPJ0K+9senhrEZazJbni6QqobaQ7RqysjH
X-Received: by 2002:a0c:da11:: with SMTP id x17mr2862854qvj.197.1565355459248;
        Fri, 09 Aug 2019 05:57:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565355459; cv=none;
        d=google.com; s=arc-20160816;
        b=FVKo40FKbqpDLwB4bFFjTga11vx4jeoHR7mCTGPC7DXnFR+Df+vI5O9l4Ut++8zWAN
         WIlzfDkPZcsP2Ys+88Q4I4uXDuo8aiw94FyGwoTgOOrR7Mh9MrbQc6c+q5gZIOBe2/sp
         JFuDdaA8dS73GAKWtgypob4ylWa5kNZphk0Y+zcuivPo6o8QdnWn50SLc61mrRfEBQLI
         W6xWlkFXMJx+ARvmH5UczpCmMOEJXD5e1TlzknTSoyDSsqH/Wwa4XfRhoMN1mXt3B6jE
         yTGHvnum6QjRSPol40IGY4vofoJHVSsYmjgSyyAAkWnmqp4ZPeLpu3WzZKPbs91h3Zvq
         Dc0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DYax3JMtrJNaf7Y5J+JViqXkZFDgg9sSwIsxT/iAzxM=;
        b=s4aV8g4pbcMubj4lUjxyygEHiOXuW4KmCEGGSfev8dxQf7tCOZdYj3IROwwlSL0jxf
         aQ1K1CUnN4htt43X4BjpWstwsmXmeWWz6oO0DCmuP8/lP3XwCe/LNc0mZmWbQsoWyw7s
         6zBjalpw8pc2fZcXfvjLIuPNr1Mz+FQG8+jUugvDx3i6TU0T80/iQDCK3AGnezek6T9V
         pwQfat+uScsbHgAFhGCe7ruWgok/QdBD5VggbIP3b0mJwq9MPQGpg8kMo4TvoMDigoNT
         NvUT2wNLDYynnvDMfm3itQVu/m/niTCQSGgIyJnFpvIGtdCPRFEUCOygo/zEIz0dQ54O
         dCbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e33si1457030qtb.0.2019.08.09.05.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:57:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8711BC0BBE4F;
	Fri,  9 Aug 2019 12:57:38 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-120.ams2.redhat.com [10.36.117.120])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B569161F48;
	Fri,  9 Aug 2019 12:57:36 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Arun KS <arunks@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v1 2/4] mm/memory_hotplug: Handle unaligned start and nr_pages in online_pages_blocks()
Date: Fri,  9 Aug 2019 14:56:59 +0200
Message-Id: <20190809125701.3316-3-david@redhat.com>
In-Reply-To: <20190809125701.3316-1-david@redhat.com>
References: <20190809125701.3316-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 09 Aug 2019 12:57:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Take care of nr_pages not being a power of two and start not being
properly aligned. Essentially, what walk_system_ram_range() could provide
to us. get_order() will round-up in case it's not a power of two.

This should only apply to memory blocks that contain strange memory
resources (especially with holes), not to ordinary DIMMs.

Fixes: a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as higher order")
Cc: Arun KS <arunks@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3706a137d880..2abd938c8c45 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -640,6 +640,10 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
 	while (start < end) {
 		order = min(MAX_ORDER - 1,
 			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
+		/* make sure the PFN is aligned and we don't exceed the range */
+		while (!IS_ALIGNED(start, 1ul << order) ||
+		       (1ul << order) > end - start)
+			order--;
 		(*online_page_callback)(pfn_to_page(start), order);
 
 		onlined_pages += (1UL << order);
-- 
2.21.0

