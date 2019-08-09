Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABA46C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 01:03:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7804A2173E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 01:03:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7804A2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 221656B0003; Thu,  8 Aug 2019 21:03:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D24C6B0006; Thu,  8 Aug 2019 21:03:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 099F66B0007; Thu,  8 Aug 2019 21:03:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7D786B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 21:03:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j9so4732417pgk.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 18:03:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=SaBZ2/RBQvpEpBePzfeVnItopZgz55kiC8yX4ppg1kY=;
        b=V9tUSPmHbab2xD2veDU5VuFP1tCr/32eraDZ8GpJPSYSNO0bCiIxRPfEwu5JnLDwOJ
         InfilFwk1IRsqRD6ogmuvF/leLJbZB6whbQkYDVyUzLcliwxs7SEHqXDx45/PmuzOKVD
         b5+mMOwhMI9SGAJoThZtWDRwXWcA2pIsaKSo1Fu90RrEn4tWt6zwBQgtbJXFq/WLaXi5
         i1aqFiI+Gk0Wk5WTfy0ZA57/L02ctTr/02/e998Hzu4+GEsnyQ1ZM6XBlJQaMDAFFw/N
         3hKONwqILAQAT09dg2fw9AMXrcOHA7BKifrgfTN41XuEEyzHV/wNbdDxjDx3rRK6op7a
         /Gww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU8Z4X78pRToSSjb+KwfhpwTBN2Ez9vDU/dqPRD++q7ny5xxYON
	+3PsVRGfqGTRK5CQ0ZuzFGl+8r54eGdL+2edvLB+4u6K7dBO0L47hHn3sRohyWgc0/ceDLwfzj+
	4XKKGvbczBA5d8Ok5tpBgvdZ/72IFUQctKVcYg2ws0yR612OlF55IhQuLqE0ao/fA7A==
X-Received: by 2002:a17:90a:9b8a:: with SMTP id g10mr6690713pjp.66.1565312605406;
        Thu, 08 Aug 2019 18:03:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwf5E3AL6Vd5jJPBok5dBwnzMWy0pk95QR+BKd+Wc3+Hw/Y4e68+FkqBWayaY0XO651uNpQ
X-Received: by 2002:a17:90a:9b8a:: with SMTP id g10mr6690668pjp.66.1565312604661;
        Thu, 08 Aug 2019 18:03:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565312604; cv=none;
        d=google.com; s=arc-20160816;
        b=qHMcbRe0G9bHlkIheWD+4ZFKZuTpR2YfQx4wrMbgsmvbQVeJ6xunjbqMhmOvTskExY
         04Yi4Zt1I6KFIryR0X2FCrZpJSXQLPAw5qihMMD0iK//ZC+6COhRTD929gLMozOe8QxN
         CQov+1FR5aGobRp5DiD10MaPlK3iXd1zlUSiOmqPU2boZJVo9GQmsRoDn7/39oIyQJz5
         4JTz9UEzCkVggb+TJlwpmfwSpoWhVOrzAd6S/1tqFWB/DkP8ljDkopgLsVV9/3zU6Kfn
         qO7wROPsKLUcSqtbUThdVOcVURKXxXn6Hup0zsS4IlcK8+gHIamnsMUPJV1XNyAusU0M
         kZiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=SaBZ2/RBQvpEpBePzfeVnItopZgz55kiC8yX4ppg1kY=;
        b=YNzYSUFf4pTtaU5y8nSFE3gPM/yglhpkIq7x0XKwesiABwXrJc3ywvloDFmJnM39U5
         vR8ESpe1qLpXix8ePbSO/aHMbSJgbUjiHk9fZrpInuUj/Xv1N8hhXETsW2GboiEcwOwO
         126+VmPgTuub1kxqVYUdHdsNtToE1eIaAmSnpcmPsJ4hIlkISCminM7NUjmik11l0XXx
         CK179Cz+6qr6lFURO0QF5xVxis5W/QW6+iuWUZUtwQwdJ7yCVLUY2Cpwiylde6Bgzh2l
         13HO+uKPVCqY3Og7g557vT0Vf18YnZHAJrbF/oq2J5WOliWShZojLIz2kONZIPcIV0gl
         B8jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b40si48116526plb.426.2019.08.08.18.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 18:03:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 18:03:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,363,1559545200"; 
   d="scan'208";a="350356786"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga005.jf.intel.com with ESMTP; 08 Aug 2019 18:03:22 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	osalvador@suse.de,
	pasha.tatashin@oracle.com,
	mhocko@suse.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH] mm/sparse: use __nr_to_section(section_nr) to get mem_section
Date: Fri,  9 Aug 2019 09:02:42 +0800
Message-Id: <20190809010242.29797-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__pfn_to_section is defined as __nr_to_section(pfn_to_section_nr(pfn)).

Since we already get section_nr, it is not necessary to get mem_section
from start_pfn. By doing so, we reduce one redundant operation.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 72f010d9bff5..95158a148cd1 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -867,7 +867,7 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
 	 */
 	page_init_poison(pfn_to_page(start_pfn), sizeof(struct page) * nr_pages);
 
-	ms = __pfn_to_section(start_pfn);
+	ms = __nr_to_section(section_nr);
 	set_section_nid(section_nr, nid);
 	section_mark_present(ms);
 
-- 
2.17.1

