Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC036C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:45:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73CAE2147A
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:45:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73CAE2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89B1F8E000B; Mon, 28 Jan 2019 09:45:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC478E0001; Mon, 28 Jan 2019 09:45:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A1F08E000B; Mon, 28 Jan 2019 09:45:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC6938E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:45:18 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so6777052ede.19
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:45:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nTySQcXDgbgWvZzIuOomkfESKJ+ZiRRspPXpQ++HP0Y=;
        b=Ri4Wp1OCTkvvrlGKubePID2QfCAKUBZSSBUXp4kWpBabeqOhU7qhIDzb6MkBuWA7PU
         B4tPs5IAjNjWzYEsM1LWPUL+3LZnPesqGkR0wGgdtIYdu3JBOFHOkzyDs1hXrBLp6ROF
         a4ixadwQmYt+ip+oNbDF7xiJalQoeVkShQcYX8vigKN17LRoUeu3LOBbvu7gyjE5XQtl
         T9GIDxb9Ht3sYuDWyOlwHnaV/0h/uhaEfd08mXc2rsC0ioQxmaG8uV56V9ScxhL9jleP
         057ZR7a8rQLQ1mA7FAnhxPlLieVuCHbCkQ9FksS0d7WU8MDFU8hNFJSfp04L8WZdSFfX
         /9qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukd9px44PL6omPN4+ExNpzxzq35cjEW/njRX4E7jGdpX8275Wr+N
	IcXPleZRBgwTiRnb8sHYaCvUqvo5watQFrbgt5IBPWQJD4SY9Bhr3qBMgm9PLHz5We0ZeY/4nnm
	VwOI5dyszYc94l+6970hQ/kYhzqw7++4bmKuG+ZOiIm4uzLaTKGcxiTW2y0u7dvQL5hklpDvwB6
	tzrrMgQzUNiLxnP975kkUvZJsoFzt0sEsVV/qHVYc3T/dtY1WLKALQzzxhUcK1L/SJYnDHOipAZ
	ay5XVAnSZRAxIn4huIS32aH0tKK2I5Z5QQR81RIxNfPFXWFARqEWxb8VLZvODAosOezKL5gmSD7
	Zmo4ej8eADJBV2ETZjW9QE6sy43T9h1vl3dSia3TFxDihL/EMvi+u00D3g5QuVzxVN2GOcKICg=
	=
X-Received: by 2002:a17:906:1d5:: with SMTP id 21-v6mr18981844ejj.206.1548686718458;
        Mon, 28 Jan 2019 06:45:18 -0800 (PST)
X-Received: by 2002:a17:906:1d5:: with SMTP id 21-v6mr18981807ejj.206.1548686717569;
        Mon, 28 Jan 2019 06:45:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548686717; cv=none;
        d=google.com; s=arc-20160816;
        b=HKGSgz2f93V8x1K32juIc17UeDng6cGL+itE8oYCecdKuE7Ee1A+A/iIPD8W2X/7QG
         c0wHNLoUB+2o791cgDOEpeN9rBTlxNR4mtbA+k819Nq9GNPFTbr7tT9iViTBfq1M+zfe
         ycMmqfQ/iPDxTUwT4tKkgUagPnjTTXDJNMi/26b1vjNQrUOfTU3agw3q4wwDJBixoPRR
         76xbXCb62aIpoaSHzXEXSLiI66Akx9wp+ltQ1dH6wxUuiYCh8Gro5i6fTovetHfrKqR8
         mbexk18EUF+hz4zbS2/er1Rled7LdcURufuwaH3sy6VSUsugPIqUVwZimQLCzrw20rPi
         vbkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nTySQcXDgbgWvZzIuOomkfESKJ+ZiRRspPXpQ++HP0Y=;
        b=kI/q57/aAdLnAN0rAXsYHQ2QKkUGT/JiSHK/STt9MVAJWmORFYgIL2lZfUQXTVf6Vr
         mIAFp1qClU16hpYZiXok1SA+duwLaNWTB5A2tomBzd7pEtOzb9YKAHYnXoAm5LN/CH7T
         grxKh1QJ5rdUSzpAIhV9Kk0A1No/Y41fhMRn44X8XFL3AagpBeUuFJrO2KCkF/odprtq
         MhW0tPkUBC10glYx18O3ZjcOXFYHkZNXc/xXUGUX3tbUohhuqIOwjZhmNsQHR7uQwK6Y
         SjJOkP53oxwmYhIbBSclcNIdZVDMgu2BRxMChbVqMxFIgza4tAaYru8N51bQi9DO77GW
         ThtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor29758587edd.23.2019.01.28.06.45.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:45:17 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN4SDZcBeV3rbkI2gxNZ8px9xHNMo/kDxk2X/qizXtVKHesg5Jmhm964+1jN/CWGYVmWZahd/Q==
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr22208336edd.122.1548686717177;
        Mon, 28 Jan 2019 06:45:17 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id j8sm2919064ejr.17.2019.01.28.06.45.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 06:45:16 -0800 (PST)
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
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 2/2] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Mon, 28 Jan 2019 15:45:06 +0100
Message-Id: <20190128144506.15603-3-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190128144506.15603-1-mhocko@kernel.org>
References: <20190128144506.15603-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128144506.g_vYVQlYx-cqIrKnrWBdNVwTZMsURcuBdLsVYhxFgsg@z>

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

