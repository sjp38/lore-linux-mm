Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2ADCFC04AAE
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0312206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0312206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DE5C6B0007; Tue,  7 May 2019 14:38:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9907B6B0008; Tue,  7 May 2019 14:38:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859D86B000A; Tue,  7 May 2019 14:38:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 643036B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u15so18996801qkj.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S+eOGatgZeskj0KU0uy0qphspDfnUZrs/C9R13O+fz8=;
        b=MxfNKBFWG5P6vg6ILAgTLGRVEVvGL3k7bMHxfEVUlNjrl+pd01eepSRDjqmk3VHKuu
         HcdXMU8uSnBtfJyzNhDIDEoMAVXEr2F2LeiFbO9R2b/l+FYjHDqdBTfJ6AXuQ6maOe7F
         hlVWWRswAZYkwiyTnd7sX9dzcpVhPkNb9dgLlhjl2CV9j2hVZJfUe+QHkTcD7iNYW/eq
         P4EICM46Y8B77s3FV55aQDPnsxwF3iVBSlT/oyJ5knS4PvB5XJRUJk10RgOrv+O1+cre
         hXQ6hTTewmcjs2lVlExUpsY3sod7MdUHgD+XVuIV3awoSuWF6lUdktzSQ8nMJZ9/uBEm
         +goQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVhkewPbQf9mrxrrrpN5pMydKm87My3F8+sybkHgI6TpFu8DwjY
	5c8MBpMWvhzrdJwaRv2WEbtwUZQ3/ydcUg+RHwSndamrlKV+w+FMLLlP8zu1Vu2uV5nhYDx24rN
	O1Ee0kw4AljKjD0Mxf9T0ZMEIiHUj4djx5D5EYqD5Q+TaMQzqMxvNAFJ+9KcxZXFVMw==
X-Received: by 2002:a0c:969d:: with SMTP id a29mr27368157qvd.56.1557254310188;
        Tue, 07 May 2019 11:38:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXDiwvoDslaowcUAc/MgTBtuaF6GiP8dz1ZcxtSl0jtlrUAG+rPoeM0HfYI/YLP3qUpVEn
X-Received: by 2002:a0c:969d:: with SMTP id a29mr27368121qvd.56.1557254309640;
        Tue, 07 May 2019 11:38:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254309; cv=none;
        d=google.com; s=arc-20160816;
        b=EFBisREWI8fm8K7ZXX+VOx6ZGf71R0Aq/GL/wEkYU4dRB4fT61kKcFovgycKwvjtv0
         eXVJ9cb5miF8iAtyFlIRcTyySm6JQzo6qdk2805EkPSYNZiBBFFtlVDe06tSA4YozPjp
         7goh2UFUf8sy5ukDhP7OWDjex5PEnkVXmORKuAzVQgpjoysn07WZ5Q3EDgt2JaG5W2r0
         dpW3l9G7TcEP829H7E+CS3VFk3/MH98SsMwsa2JYGmirdlA4y4OZNO2cQOYUTS9BHB+G
         FB8e+lHPefhbFOOOnZQADkIPX4TbLjsm/2oVbNXmX9yKGTDrLgl3Puz3QSFDUsnA/l4V
         stYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=S+eOGatgZeskj0KU0uy0qphspDfnUZrs/C9R13O+fz8=;
        b=tguUGNsoZ4SHpTi0agOzOz87VcIko0CHtTMSI0VPlE97D7I6pSKICILSsh+jyNC3im
         io2EEV3TglIDH1fZpGMIWiMQotW/BS/VZrsMzYwWF1y0YJksAlyOoZzGk2Pppdllp2Hx
         ieZKS+iXgOzL98gCzaU1+2VDGyG+Snd/1mFnWfGzMaKa9Izh4nk1oo0H/xpIgdFxrR2l
         ATFFhPC2ZY4gX6qohoSpuJBDaqjyJ0tsSzl6vcOyapoUmhsGTPyix6dGnvW5zyX3UGCx
         G0rsVCpG4cPrC4qCbRFXbeDNvQDrNvEm6BQQkrBmpIsr37F/TKqKveMlbL8T0rERVHCt
         0dng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l12si7632452qtj.182.2019.05.07.11.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ABD9B308FEE2;
	Tue,  7 May 2019 18:38:28 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B1B871EF;
	Tue,  7 May 2019 18:38:23 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: [PATCH v2 2/8] s390x/mm: Implement arch_remove_memory()
Date: Tue,  7 May 2019 20:37:58 +0200
Message-Id: <20190507183804.5512-3-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 07 May 2019 18:38:28 +0000 (UTC)
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
index 31b1071315d7..1e0cbae69f12 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -237,12 +237,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
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

