Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8EFEC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A19220883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A19220883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 317286B0276; Mon, 27 May 2019 07:12:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C6736B0277; Mon, 27 May 2019 07:12:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B6686B0278; Mon, 27 May 2019 07:12:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E62B96B0276
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:24 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id z1so8654256oth.8
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FWepBTVtBSrXDhoobt+I+QFd6CdFMlIwO5u9/uFDPcc=;
        b=Ub9nYLysuLO0GMHm0jY4pYb6OQJrviNvoI8nRm+1HYACQMX9pWWIo8zu/1VoK2XHbO
         shjikMrwe+U+3KMfwmD8rkwuI2kHQF6GYk9w46vBjgWLyI1+Xbv4WYdCZNy4ZqNRl4Sz
         C9LXc06Onul88mOP/qYLI+BZipaQ0gmk1iela56augqtTxIF8Adx0FCzeeVk5T/yR9Tj
         wY4Cyje4Rc+g1lILVPQq1XZCKA9rB1Kl8dmPRgNk1802T4zIkTt7Yu+T7kIvZZNpAKUX
         T0CCnXSLw70t+AmtU5zTC2j8uzl0Kc+UVub0Ejq8Yc6W4ruIvOmJlABwgxY8CzAj0WBD
         +FIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXNAToYhNgK7VkxfaFQxxp1hicXeaZPOlQBPDh3+c6dxnKS/yFC
	uNSHxCYiBhU9Ef0TwSIOZIRKvfx7wr2T8He8505nnQe005fclK5phc4y3huEoOGKWW1xbp5weiY
	TAE7V9X5pg9RrlQy+841mS0SSPRio/7xckAUeB7Soz8C+n7dC/XDOk6L94GLXQvcYrQ==
X-Received: by 2002:aca:844:: with SMTP id 65mr14123925oii.109.1558955544602;
        Mon, 27 May 2019 04:12:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1sz8iymntK/+3yy0yUP854o7C5KZefWwgz2i5unxCYaPvQl0G+rUMM8cs3dpudlfaDE2r
X-Received: by 2002:aca:844:: with SMTP id 65mr14123904oii.109.1558955544099;
        Mon, 27 May 2019 04:12:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955544; cv=none;
        d=google.com; s=arc-20160816;
        b=t8ig3PUqYgNabmx7ehKNCe1ncdqLtZDjDoMR2kKfP211hfFoPm8Jkri02KdO8W64U6
         V9CMWfhfHgiAscn4cwUL0gh+JdE6MO5nAZ/eX/P+f/6Te0ised/ZCwEQimLhHWi2k9Jh
         BQH4mzcQoYhWwbgflLHYciMYCljyXYp225Ltp872z38h/qvnyVzvSiEjIniV9ESdyy7i
         6NC1eY2miTOJMCzhvJ9h96Jqi78rjt13pFIA65LopX6N02x5TqrM/+qUjWMmXvTFtveA
         I15A4d2Jk2jx/6JmFBvCutmucOT2YXlH8pH4vnDC4Me2xmrlidGHL80vkdd0XVgxWUwk
         HesQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=FWepBTVtBSrXDhoobt+I+QFd6CdFMlIwO5u9/uFDPcc=;
        b=mhyT5Mmi2LyRdXEwU1Ap0hQfF3vF1+uVlW5jMn2z9/IbvB720kM8Nf/fAO+V/tTA81
         28KiIgcYrjAByhAGxLd/B2Eu5/52YWDpvLR3+uNEQz2HPMcKkuHQON+fNr68zOVp2Ix9
         ogo4uF7Klo2smSXG/CyeKSgd1kco3NvVJzw/4niPGRuwVR13CtN9Q3CKeJ4zTCRNZiDZ
         DMHk1+ypLmFfOY9iG+Zp5OuV53ayoNj1XOeW9iY2CYMRsv80QkXsU4t3OhENc48wGQuU
         n3aQeHDcdAino65rv4UwJkEhdbRaQ+hyb6+Hvcvd2zWfuDpEKnl+UcxG0m5g6kZi4rBv
         r9ww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i8si6134783oih.11.2019.05.27.04.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 61EDA5D60F;
	Mon, 27 May 2019 11:12:23 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 200CD19C7F;
	Mon, 27 May 2019 11:12:19 +0000 (UTC)
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
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: [PATCH v3 03/11] s390x/mm: Implement arch_remove_memory()
Date: Mon, 27 May 2019 13:11:44 +0200
Message-Id: <20190527111152.16324-4-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 27 May 2019 11:12:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Will come in handy when wanting to handle errors after
arch_add_memory().

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/s390/mm/init.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index d552e330fbcc..14955e0a9fcf 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -243,12 +243,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
 void arch_remove_memory(int nid, u64 start, u64 size,
 			struct vmem_altmap *altmap)
 {
-	/*
-	 * There is no hardware or firmware interface which could trigger a
-	 * hot memory remove on s390. So there is nothing that needs to be
-	 * implemented.
-	 */
-	BUG();
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	vmem_remove_mapping(start, size);
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
-- 
2.20.1

