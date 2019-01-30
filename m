Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E65AC282D6
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:12:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E9612184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:12:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E9612184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 720AC8E0004; Wed, 30 Jan 2019 04:12:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612C28E0001; Wed, 30 Jan 2019 04:12:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 458948E0004; Wed, 30 Jan 2019 04:12:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6AA78E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:12:31 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id g3so6819902wmf.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:12:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IFyaSZDvG5tAIyjheJu+7MuaC7bK/awFyWok5SF8UwQ=;
        b=jaehZrd8nEK5GGucng0aJOAsmHy1NGCNUScii6I2UEQ7Xn8Wz3nSp0bJ6x5gjkEQmI
         C1r4RikNsDtv4ttloDMDiVIqxPgDEHTKp3Fh2BtraeMQ108o4/RQzUtkW+AX/4uMobxq
         /IT7yhWE9nWDfBCyG94kYnxFJcw80jt6JGkWzVipuSujRvWOZJih2m+IRYWvZwd8nURz
         Bxv5LyzT0X0TUGueOho6YSAOJqhIUCKVxe5BvHLy6kCkU7CTsLwBMaPn2pqDbx0ww9IU
         aXfe6T5QtE4k+u1PIKv0xe3bjxTGqH/fWhzHe00bBM9cb1Oo8UZQ90FN4u/p/tLWwnZD
         eQ/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdd4Q7chBSun/UMACL0GwXN/jO4HFAI3fuEHV2PLhlBOPxdTrqN
	+zPIfp1wJIx6moGl9auAE9h4Icmo3YDCkxUaoA1dd2POMqK4rdKDJZ0mQckLVxX9sMstiRwmxrN
	/fSIlR2I/r3bfi0jcJpFCmMa8+BKQkwWhJ9W07E/PtR41N3qAypz7Kt6V06hj5JXEtTURv5kV9d
	zrrGgZw8mqTAD6S9sJQWg7LlVeKbCaCQn6ZHskhuAy0bWRlUqob4/etgXn01wYEUs0823x+CA43
	4gmmetkKGStlrIme1jwI694CFMPkOEgQJrmO9b0NibnOR9sUg6PlJXA56jglsZk32spqRsfwpU7
	0bAtoW07HfcC04APEVvF2CahiRSX14oD/grN3ZGdon5t3TDW3kZTByHvBk3ec97UutFJp5uKFQ=
	=
X-Received: by 2002:adf:9061:: with SMTP id h88mr29012139wrh.65.1548839551440;
        Wed, 30 Jan 2019 01:12:31 -0800 (PST)
X-Received: by 2002:adf:9061:: with SMTP id h88mr29012074wrh.65.1548839550526;
        Wed, 30 Jan 2019 01:12:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548839550; cv=none;
        d=google.com; s=arc-20160816;
        b=DuuFJfjg726+9xHa7CeyB3+YNu9CWBDkPNOprS4bUa9CT4rZUrgyo6tL3sb0W9qqn3
         U3nOkUbm6V6Hri2FgHpquRD2D7Y7AjhjKld1Nc1kLpMlZzZcKR+KZJphZ3b6uCzaMoqu
         bBTtBhh4SpzburDpHxJorAkpdFnbeRZ/UKYU7on4CyKFYBxJuP2QgpdgURbj9GCrLJLb
         fOnuUr/B56YLCyG0qFYzgaRGIOLU3mV4QxEN63jOKHc+nnS6IGeySN3P9E/WHIu0QqEe
         RO0CRYY9uBErBTSvwHNjwIOWiPOCTqtX2NCXkR1L0BjWVfLWDX4oyBMPn+K28P6y/v2L
         aKxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IFyaSZDvG5tAIyjheJu+7MuaC7bK/awFyWok5SF8UwQ=;
        b=JuQvkJpawRpuNNdzbrKdEsJlBZ+mmA7i4KT6O9+ZTh957UWHKcSPzxyjWvJk3LwPcl
         UAdeKXo/WtfRcuGzsz2n8338OCv4Csvaa9NkRuP7m7OQ3QZXXGq1ymyPMvXENl/BaOt3
         nOVc++ebIu6E0pNR5uCbwCqmRaodP0bn+zZ9DAK7B5HFdxnp9PJ05GXB24R7XLKC/pau
         9HJ6tFFChcQh+Ygfc2uoHCC/v6wllld+IfI1s4/3JzPg21ebEq3KAerkEj2yzN0MlMZ6
         +/0p7PzGm4IHX9Z3KMLxC8NesX+6sJlImOdFK+bI05hSMGoBvk3JtqnVxuuL3iPCC2kR
         mkjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r4sor910976wmr.10.2019.01.30.01.12.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 01:12:30 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3Iaq8fWIDq9I86+HaQ9zHJ55J5mjfGRbhPSWjN7j9DPfqEzANX5rnBt5mnJftfFn161SONvHRQ==
X-Received: by 2002:a1c:c1c9:: with SMTP id r192mr13492549wmf.146.1548839550147;
        Wed, 30 Jan 2019 01:12:30 -0800 (PST)
Received: from tiehlicka.suse.cz (ip-37-188-142-190.eurotel.cz. [37.188.142.190])
        by smtp.gmail.com with ESMTPSA id l19sm1491875wme.21.2019.01.30.01.12.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 01:12:29 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com,
	gerald.schaefer@de.ibm.com,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v2 2/2] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Wed, 30 Jan 2019 10:12:17 +0100
Message-Id: <20190130091217.24467-3-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130091217.24467-1-mhocko@kernel.org>
References: <20190130091217.24467-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mikhail Zaslonko <zaslonko@linux.ibm.com>

If memory end is not aligned with the sparse memory section boundary, the
mapping of such a section is only partly initialized. This may lead to
VM_BUG_ON due to uninitialized struct pages access from test_pages_in_a_zone()
function triggered by memory_hotplug sysfs handlers.

Here are the the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
  [<00000000008f15c4>] show_valid_zones+0x5c/0x190
  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
  [<00000000003e4194>] seq_read+0x204/0x480
  [<00000000003b53ea>] __vfs_read+0x32/0x178
  [<00000000003b55b2>] vfs_read+0x82/0x138
  [<00000000003b5be2>] ksys_read+0x5a/0xb0
  [<0000000000b86ba0>] system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
  [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

Fix this by checking whether the pfn to check is within the zone.

[mhocko@suse.com: separated this change from
http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 07872789d778..7711d0e327b6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1274,6 +1274,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 				i++;
 			if (i == MAX_ORDER_NR_PAGES || pfn + i >= end_pfn)
 				continue;
+			/* Check if we got outside of the zone */
+			if (zone && !zone_spans_pfn(zone, pfn + i))
+				return 0;
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
-- 
2.20.1

