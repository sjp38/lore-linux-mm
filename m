Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1557AC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:45:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC7482147A
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:45:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC7482147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C7DC8E000A; Mon, 28 Jan 2019 09:45:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 475CE8E0001; Mon, 28 Jan 2019 09:45:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A62B8E000A; Mon, 28 Jan 2019 09:45:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9F2D8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:45:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so6713165edb.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:45:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=20RN4Ot/Ll9C5dQDy9pNPCPR7Irx0eiJja18LrztjV4=;
        b=XNmblRrVD31+VxTyfgvRqf6subtKrDylndtFTb4Ivc3uvSAhDUCcp54KeOqI6C/edV
         V3qbFUyrOfH/P1UMP1s2eeeUbCQQz8JPvh1gGXBzVGe2OmpdmpAvjY5dNAYw+UVHA8gu
         qNIcIVZpds+E6B7AItEhfv9OUzj2BM2DvyTEkxE8efem4nzyKhkj3kMhjud2lIeUyPhd
         65LBqLJWVTJvrFMSuBV71utjNVyoyfCqKMrKpjGgNoNraSCKK2AzdCaNUBgCA1lQmjcJ
         ao243t+rgdL5a3VGEag15c5PkMJs8cnLiqfa0D3f0UDCjCZAXXNayize7amK0xgTL/ZA
         4kFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfo9aD05F7Ru6ri3NbNoC4Aw56XX9ygDfIi9NFBvp02Kwv/Ufmy
	EA8iQAxH98hVCUYqEI90jQJVdH7mztlhJGfxbZ1ZH/hUoNZKM4krW8bVgrYG7VE3A2XTV0YSnbo
	fBTRF+0B/zDP6k87z9ekTKJayYc1RNN1AW/3tAImp40ouXp/5hiKvxbE3VndrnUkZRNOxJirOmv
	vU/cZY5QiXPPmNMJVKOOy8hdUvct85zF1JGlZVhjScBoviPIunSKU1iDPs/LaZwnIzqWinAj8we
	mFNGoW6tDYNyfuEbQ+A+GM4Dv7pdvABr5BBHQz2VbESUXYWyZf52Ov6ndWyKr90O+7E6annKAFA
	c0MztU/KM4JcyQy/KG7jhkkS5TPADlykaD+8KPQEO/gpaBhMCNvZkt6H73GPmedsVS3SJrR4ew=
	=
X-Received: by 2002:a17:906:c2cd:: with SMTP id ch13mr18813368ejb.198.1548686717223;
        Mon, 28 Jan 2019 06:45:17 -0800 (PST)
X-Received: by 2002:a17:906:c2cd:: with SMTP id ch13mr18813313ejb.198.1548686716222;
        Mon, 28 Jan 2019 06:45:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548686716; cv=none;
        d=google.com; s=arc-20160816;
        b=oTEeQ7hkgBpZ1+hQtjEKDXprgEz5qMu0CkXRcSXeIJzVpXlYYU/a/hlHUtrnutKrp5
         sHA+wbysd7DPewchhPlLw2OAtchhB6fAdILCqyaaeU61HVETNfWi5av3GZMQYjehQyQZ
         ZVJgnjs7DiW5qB18mora9BRkigbkm9vwss6ZbJeW9QnWrNvE/Cu8rHa+dP1KfcBGhGwo
         Kq4P01WL+SwpjSb0LW0tTu12k8wXAVx1AN7a5xH/SiROOFiEUSRGKg79dN5C6ivOPr7X
         eBjM1mxkPvcWJwXWQ0zkVelPPAAOaqZvR1oU7Py1TxSicjubQQIXKEiMdEc3jjq4ejGC
         38wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=20RN4Ot/Ll9C5dQDy9pNPCPR7Irx0eiJja18LrztjV4=;
        b=sie+U/n4izy3MJlmGwBqm/d+KeqMeLn+JzMZg6piCU28oh+puaQuXExxZNPudwqeFv
         SmbdvOACcfX8y34znGSjLNfADDVO0ZbIB5do6p2cZK3qXGxzyLfkS1b7x4+omspfcRi+
         jMN41Rol7VBHm9aS1uEOlccS8YHLsVFynHppAvl//BeepXDsieyLOFleK6oJ6xbwxfT3
         x89CdaqBrdhUlM11mdI8XeujJypSnUxn8qV9UChus9NSnvdJPQ4f8BgdDTz7R+zEL02u
         0x44sHGVR1jELtGWVqRT+GUC/7ODcntMuV8i8K87v7ttvx5qgWaO9rerbn4+9oyeWfID
         igBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l52sor31136483edc.17.2019.01.28.06.45.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:45:16 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN5V/XrVCAGFvAeKOM6OXjDXHjVZ8bDG7fiP1ZYe7gGffkuJLxpuoCDWNjAhGPGfBirUc3C4Tg==
X-Received: by 2002:a05:6402:758:: with SMTP id p24mr22446609edy.92.1548686715871;
        Mon, 28 Jan 2019 06:45:15 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id j8sm2919064ejr.17.2019.01.28.06.45.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 06:45:15 -0800 (PST)
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
Subject: [PATCH 1/2] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Mon, 28 Jan 2019 15:45:05 +0100
Message-Id: <20190128144506.15603-2-mhocko@kernel.org>
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
Message-ID: <20190128144505.2G7S1gir_0P1_M3LDhMLV_OwMGsDRN_OiuJsaPyyJNg@z>

From: Michal Hocko <mhocko@suse.com>

Mikhail has reported the following VM_BUG_ON triggered when reading
sysfs removable state of a memory block:
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

The reason is that the memory block spans the zone boundary and we are
stumbling over an unitialized struct page. Fix this by enforcing zone
range in is_mem_section_removable so that we never run away from a
zone.

Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..07872789d778 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1233,7 +1233,8 @@ static bool is_pageblock_removable_nolock(struct page *page)
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
-	struct page *end_page = page + nr_pages;
+	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
+	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-- 
2.20.1

