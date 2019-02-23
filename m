Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1A19C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:12:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F20D2085A
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:12:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="a1KXgBWN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F20D2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFD018E0154; Sat, 23 Feb 2019 16:12:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1A68E009E; Sat, 23 Feb 2019 16:12:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC26B8E0154; Sat, 23 Feb 2019 16:12:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2B78E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:12:04 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a6so4296111pgj.4
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:12:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WjGju5e8vzppxF+dIN17eIpZCJ0Uww4H5BByicXUAfA=;
        b=XyB5iOPRHFMt58l8ISIQRf9llTAhebI2PgjCbcgvGe6DQ8rj4s13h7cPphiEGBvRAI
         XDL1k0gUwp+5wQqLuOWje+DcwIvLkmBzfRjRLgeEi6eJzo2ZYQzSA5rVZ+B2EKhI32Ag
         BE00o54xJKnm0+iobRLdUCrR/zrvI9Wg6Ek30+NU6gPxjdi/vHvAMlJxNJrT7l2HpbA8
         xbo/sS2i9MoXZtYrY2RSqxYd47IqburRGt1RLRSztA2pf7GGuYnDyw0b8ZJETv5v0L0M
         ayVVjKnYv8zUSYV+dPagPOKjeBSxZQCa/HjDvevj5JFrcI92Z5vnqQR5C7Bud8oWqVJ5
         eVhA==
X-Gm-Message-State: AHQUAuaACEtZYDexd5htRFQsoWVoPKzSRm397RquJ9G5uB0X6Q4Xe0xf
	VJARfSwSRh+4/Mdtf1NnEaoj302qOHjLzzj1P9cB9SwCO/LoqneLstXCmIuHHz5htpHwM9fbIRE
	nqOYxfepmdh7Bv76tafbZS6a2y4euF+vCPdwF4JGXuPL3+XgZQgdZCzBGJSHyhWeW8w==
X-Received: by 2002:a63:8341:: with SMTP id h62mr10490919pge.254.1550956324281;
        Sat, 23 Feb 2019 13:12:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCNE8FXUIIZLtNq0TR1gKJJozfK95d3mojaPNIYU7bD1DsUttEX9+YJRXCTztuP4iwif5o
X-Received: by 2002:a63:8341:: with SMTP id h62mr10490877pge.254.1550956323569;
        Sat, 23 Feb 2019 13:12:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956323; cv=none;
        d=google.com; s=arc-20160816;
        b=Wuh9hQNF3Gle4BjojY21CaEER7juIoH7GmCOLrz9jABV/7KIKQDCf45dnLAbJz1oxq
         kvXcMSI5SZrFwHE7OwhCmRjXogMSz0iiSSxB11yubf1IsElCw8aO8vrrX6MqovlOTlnA
         G6GNkIr7caAGbxxzyyEGWUIcqlaCNSzfDypWrU61SoDc56wLKK7W2ypIdlESeyqWeTFf
         7vcZ0eJRJxh8LnbM7woO6J4IlWAzS/2uWnQebRFuWpfH/YfBpR/vtylsXnMaxLg/rKdR
         KbZVwAvJdwqWxXOqBrRQlfDCsOReFa10Bwgin4aKAzQ2Hp8c99xG30L6k44xPU1008z/
         0EGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WjGju5e8vzppxF+dIN17eIpZCJ0Uww4H5BByicXUAfA=;
        b=DZxNr6/3nI2mMEjfdcf40xg+MQxrikGV2IgY47R8+YqgT0SSxRsA9kto56gm41cwe7
         fUOZw8Vcv6fLDr/Fnsqy0zoUc18mDGY1S/AXIYcnDFQtN/A/g8MZqnz9PQ1Z+MmMHUnZ
         F1oQYS0DYL7SC3c7eIxuZwExii44x1jq68Y4sJciMezXIT1Q2tRCeD2RGpPlTlVHLkUj
         sdHBStxqPEl5NE1cVd64+peUI/xXdN/llLvD2wTVLzls1ZMp/eqpq1zGIbmarUDim/lS
         /1pwfnVNQAA4mXGERZrkln7F3OYQWA1/8yJNgJhp7PvkbjYiRTOdizDGIubCRinpWSM6
         Zkhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a1KXgBWN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k1si3155058pgg.215.2019.02.23.13.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:12:03 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a1KXgBWN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 264542085A;
	Sat, 23 Feb 2019 21:12:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956323;
	bh=RMZX0xOOglp9B6COxG283ka+EmlXWMlPcJ4Qh2lx3hA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=a1KXgBWN9SBK5JMmrLwtfDvapdECQPHZj/h2VEbzpeoiObuRQBngMwg7tOhiXIE9P
	 Mze6UEeNczgu0Z9nGYYci5uNqo9BeM5S7XYX6NBN0O2Uyoa/vFQTFC180/o2Q1xIw/
	 S12xPJcbuwwAeXm4PzUQo+7C6dfKSRV69DJZDYBg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 3.18 16/18] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Sat, 23 Feb 2019 16:11:33 -0500
Message-Id: <20190223211135.203082-16-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223211135.203082-1-sashal@kernel.org>
References: <20190223211135.203082-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit efad4e475c312456edb3c789d0996d12ed744c13 ]

Patch series "mm, memory_hotplug: fix uninitialized pages fallouts", v2.

Mikhail Zaslonko has posted fixes for the two bugs quite some time ago
[1].  I have pushed back on those fixes because I believed that it is
much better to plug the problem at the initialization time rather than
play whack-a-mole all over the hotplug code and find all the places
which expect the full memory section to be initialized.

We have ended up with commit 2830bf6f05fb ("mm, memory_hotplug:
initialize struct pages for the full memory section") merged and cause a
regression [2][3].  The reason is that there might be memory layouts
when two NUMA nodes share the same memory section so the merged fix is
simply incorrect.

In order to plug this hole we really have to be zone range aware in
those handlers.  I have split up the original patch into two.  One is
unchanged (patch 2) and I took a different approach for `removable'
crash.

[1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
[2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
[3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz

This patch (of 2):

Mikhail has reported the following VM_BUG_ON triggered when reading sysfs
removable state of a memory block:

 page:000003d08300c000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
   is_mem_section_removable+0xb4/0x190
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

The reason is that the memory block spans the zone boundary and we are
stumbling over an unitialized struct page.  Fix this by enforcing zone
range in is_mem_section_removable so that we never run away from a zone.

Link: http://lkml.kernel.org/r/20190128144506.15603-2-mhocko@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 05014e89efaec..3fb2067c36a4a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1321,7 +1321,8 @@ static struct page *next_active_pageblock(struct page *page)
 int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
-	struct page *end_page = page + nr_pages;
+	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
+	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-- 
2.19.1

