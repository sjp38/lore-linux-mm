Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36D03C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 071E52182B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 071E52182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97FC16B0275; Mon, 27 May 2019 07:12:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 908436B0276; Mon, 27 May 2019 07:12:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81ECF6B0277; Mon, 27 May 2019 07:12:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1076B0275
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:21 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id e17so8667531otq.0
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Swr+8nWtCkcUT0w+A5+pIbEH1netntQUXuvTN9iIMe8=;
        b=HKPRMChA80DXm0B0isCrUOaVf78eFG7vaZQoKYUwpatX4VWLYpO5wcfdO2amVz17oG
         emHNPaHZ4pm+nxqESmOqt0Nm+gBeplHM+TWSLoSvSk1iiCau6svx+UREkzNI557ovKjD
         k6Sy/QmaZMyJf+Y+Ne8kLK5xlalGNSviQEMltnupBJgbaV8B+2PbifuAoTpfB+hqEc5p
         VU0TLFis1atR7C5+489Q96A60HDbPNU+ZoCQy9bKuCUVwtqj2ztCTcH4IS1fQR/5TBlr
         iNWi6EDDHu2Qc3nS5ta5Xlmi/2CXNz8tMaFLrRy+J5TXehjUMHDU8RZF2gh1EnaBjnMG
         HH+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWS1YSEaZkw/5FXkbR950hY2pF1LC+9iWs4wx68XxhGe3iCd151
	NY8gwZLEEz2PUXJjvu4MWCulMYPIrbdajX50Eac6I0jnArJ/TdDmWGVHpxIrkJe/2h2jO5NU1dx
	bCV7W8rv+Y9iS1x/vVhBMyCrmlJ2wg98pMLrEHVkOpu31wipM8EEyFyV0c/E9DVThcA==
X-Received: by 2002:a9d:5d10:: with SMTP id b16mr36601646oti.35.1558955541085;
        Mon, 27 May 2019 04:12:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqO8X62iXjCGrkE01KAA05fm4gdsJJgAVT2bS5v7A7xI+JpXQOq0i3r2DQMa5kF6/IL4Rx
X-Received: by 2002:a9d:5d10:: with SMTP id b16mr36601621oti.35.1558955540587;
        Mon, 27 May 2019 04:12:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955540; cv=none;
        d=google.com; s=arc-20160816;
        b=yLAYqBEMdgbgjqf2Fd2AeMfXVzpsuFbOKVq8rw2l17AyjUkHRZ6t9Psv6AwEhRmYby
         ezSX2m5jGNoLLITuYGVIiU0BemzZSf7vX0S0cTQ7lMMplTQcmp0LjivTw9R+7iJEgYol
         EIyqf+3Dl0LdDa6UssnlRgsk+zEAbS9BZaeZWIC/HBTOhK7ai2mOIQeMuUyJmmW8AJqt
         rRXDAINI4HCaSCH+Wz8rlIAROABKEi8S9fWfRR2rkU4LHU7+Nmip7c65RZ5E+83GDGZa
         HZbIbwCaVP7T+c9gsF5Ts1jVSASUmTPE+r5KPIBEQMSMkERxcSXc66m/29rOXmSt+ZtN
         R0DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Swr+8nWtCkcUT0w+A5+pIbEH1netntQUXuvTN9iIMe8=;
        b=abgpZ8b5QsICFhb5pRjZcjQxSTwc2Roo2EJ3uipdxWSQM81qJ0e9Wnd/ZNT2fNF3pL
         zKubT+Z+1F9KB2lY66M26CixkAGNqG2W4ZrCb2u41s77ATBoIZtgqIRsLEYKfhw99DKN
         TRkuosz7DquUpeNBQzlWNyX9MyuTS0zGHydWw5Il2SS6i55cBgd2YlT8jET2MEmDsYEI
         AZSCcQOxr+g4Pc/wx0O1XwPTRjjQiD8Md/N0TPWu776FrVoY0rXn7uUic0P0b9GE+Xu0
         z3yySegsGgw/r7MjI+1PgfYPKPCtZl4P6kDDb+E1TxrmcBY0qtIevOLZrbNzvXG8RmZZ
         taEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c3si5775739otr.37.2019.05.27.04.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BE4F43082B4D;
	Mon, 27 May 2019 11:12:19 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2A88F19C7F;
	Mon, 27 May 2019 11:12:14 +0000 (UTC)
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
Subject: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for arch_add_memory()
Date: Mon, 27 May 2019 13:11:43 +0200
Message-Id: <20190527111152.16324-3-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 27 May 2019 11:12:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
don't forget arch_add_memory()/arch_remove_memory() when unlocking
support.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.com>
Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/s390/mm/init.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 14d1eae9fe43..d552e330fbcc 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -226,6 +226,9 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	if (WARN_ON_ONCE(restrictions->altmap))
+		return -EINVAL;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
-- 
2.20.1

