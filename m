Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDF43C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 09:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDD9A2077C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 09:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDD9A2077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02B0F6B0005; Wed, 17 Jul 2019 05:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6FED6B000A; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4AD58E0001; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 736836B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so17597328edv.16
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 02:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=m4HIcYVa3ra0WJB1AuQ2/08UF86bylQj4T0ONjGQM1g=;
        b=Go6qJZeFRJz3WqLnvhqp2NAheu4bJqwDzJxSa0ym1I5RnkOAtyuLd6aX7sV39rRH+4
         pYxBfDOiKC1+PCvg9VSfm41VuIlVbE5FN7YkI7E3AOkOmCxo1c6ehVbMFa/9CVldUoTH
         K7sXjg5LRgmsbR6fPd5noboBuuPmU/f2p7T3TzSXIdgyHvBHYeR+xsjRNIxhnbZ8ihRd
         e4aWBXOUPfV7G6wYWFk+3/TGk6UUbv3KpO36cK3hYZ5RHDoArgdaapxsDNTH0Os7I+T3
         cEVxm9I4xMu8p1pBAEPsPe5z9O4UF31zE2dZMFr4mrSEP4uag9oy7j/rJlLPSj24Vp2K
         tb6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVJsEoHyudec4P9ked2hL44CMiRPq8ouZFCiD3/FuBGD2dWeSkw
	oYL/wE5/C3oh24K8zEzg8QHnfrOQIumLt3TasbmYfddGapLjFp1hu0zVfHZfdZb94i0b/z4AqEo
	quLMo+swGO7hfWXXK45ED6e4nSJb8kyxKJGzmYnRWFGhydak86rod/pjkKfMgnHPoEQ==
X-Received: by 2002:a17:906:e91:: with SMTP id p17mr30254537ejf.217.1563354451055;
        Wed, 17 Jul 2019 02:07:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJcs/m1Zgd3rxKRo7/7hPN0wJcJzjafE57mDtspggsON/Xvh7gIf47MzmSMCXzR1kpkNEV
X-Received: by 2002:a17:906:e91:: with SMTP id p17mr30254475ejf.217.1563354450301;
        Wed, 17 Jul 2019 02:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563354450; cv=none;
        d=google.com; s=arc-20160816;
        b=e2fltTj+XqKECKj1dmq+UU8NKYIAHY3oQymy8XPsaQGrSdMyXozgZiEUlmWjSFHluQ
         mf7s/j/qFrOPebTBJRJhcwQ26e9Il/gKC7W64Imbn1by5O6lc7MA7Ssaau/dhozJKrjP
         EjOknu+ESGk2yChERUZsFeDCkl0rKo9y4FYs0Rfn9zuo6smOcUp/l0Jl3z6FBCp6PD43
         07p7UdW8LELkjqUALtaoF7ymHOMmQFFRzD0T83v/STcADI+FkVTTm8DAwh+0vl6hiMWn
         jZ0KmVSpZMrWwvvnWo2ced20b5Be68j4oZz0kWEaPXKWtDLynBldTfGAKCs4uMfFnv4s
         A1Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=m4HIcYVa3ra0WJB1AuQ2/08UF86bylQj4T0ONjGQM1g=;
        b=DZuaPupn+tlThYssEXJYuXvziIpTKxjZ4fqpG7Jf/A2rH7/hIcf8DbSsimeFRoxxrX
         FMr3eozc81/3T/3tnCTpYixP8Nc7YolW7bN2LUwUIXBMLN26qWJUJ6kiGj4D4UE8+aQo
         zmplOViJKcjTeRypmOCGl2IGPuW2WCzt8KOb/CM1eeJBSL0OYswKFwknxxEpLjUH91dk
         99TF9gindj2nIDkkDIbev+ZmX8B8s4qX885KqfmnKwxbLf8FAQSMjVOxcdxlzVzIaCa9
         eQjBSQ3d2qzaVLunwh3RDXtnrdsQSN5PlAwODRYddeWNaW6pgCAwu57rJYdPCxCign2D
         833g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si11516746ejz.208.2019.07.17.02.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 02:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EBF48AF57;
	Wed, 17 Jul 2019 09:07:29 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	aneesh.kumar@linux.ibm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
Date: Wed, 17 Jul 2019 11:07:25 +0200
Message-Id: <20190717090725.23618-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190717090725.23618-1-osalvador@suse.de>
References: <20190717090725.23618-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION granularity.
We need to adapt the loop that checks whether a zone/node contains only holes,
and skip the whole range to be removed.

Otherwise, since sub-sections belonging to the range to be removed have not yet
been deactivated, pfn_valid() will return true on those and we will be left
with a wrong accounting of spanned_pages, both for the zone and the node.

Fixes: mmotm ("mm/hotplug: prepare shrink_{zone, pgdat}_span for sub-section removal")
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9ba5b85f9f7..2a9bbddb0e55 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -422,8 +422,8 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 		if (page_zone(pfn_to_page(pfn)) != zone)
 			continue;
 
-		 /* If the section is current section, it continues the loop */
-		if (start_pfn == pfn)
+		/* Skip range to be removed */
+		if (pfn >= start_pfn && pfn < end_pfn)
 			continue;
 
 		/* If we find valid section, we have nothing to do */
@@ -487,8 +487,8 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 		if (pfn_to_nid(pfn) != nid)
 			continue;
 
-		 /* If the section is current section, it continues the loop */
-		if (start_pfn == pfn)
+		/* Skip range to be removed */
+		if (pfn >= start_pfn && pfn < end_pfn)
 			continue;
 
 		/* If we find valid section, we have nothing to do */
-- 
2.12.3

