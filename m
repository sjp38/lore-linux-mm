Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF940C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:10:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8589920878
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:10:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kIwrjfF9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8589920878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33CE48E0151; Sat, 23 Feb 2019 16:10:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 314B58E009E; Sat, 23 Feb 2019 16:10:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DFC98E0151; Sat, 23 Feb 2019 16:10:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC22D8E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:10:42 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 19so3606237pfo.10
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:10:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hHKoLZxzK8nZNaA+bf8eF0lrSklgTlSSxc0jWxuhbK4=;
        b=a77rNxkQzjHRKhQ1Kd/JKDB2l/Du38R6VJ16tzd2RTNzjfZMu2Nj40wJB7NVPWnmBC
         LZrsn1Aur0/1hEIINtWCP5FOgM5HNOPRVRJ94i7NCrJXnzeQfCB2tALM39Ob/ooncZrb
         +3lYDUnDB2odp6ngePhz7QZ7234Ea02vBlVOjVe3IHOLQZsdCl9hY+n3xFsatOrAFPkX
         4LAbU3eHFIqQlFBmEjUvMFW6Hzgo3YWN0oSplQXJT+TtLZwdHOjZ0kOBwwihbnbqtF24
         oY4yZemljfaYQgfiaoGKOWyKbGa2uTJpchClM0D9kO8HVejbsmmQRp2fO9yi1hFSSPVp
         t7zg==
X-Gm-Message-State: AHQUAuZc0RsT/I6UIqpDAqTsv069FO8z89D42ZVVSv/Zscn8zpOriyo4
	3J9SfyRZ4EaCBo1NDniEf+dB2jkrCFMpsIm64N8sBTFuwrcd4S1X0yufgbgnUOgSUthsESOl0MO
	eItIMK49xlpBEveKHyaLMfTFStKO+yyfwhFHmbdypr/8v274TVF6sGuHcCAotbJsuHw==
X-Received: by 2002:a62:ae04:: with SMTP id q4mr8918775pff.213.1550956242484;
        Sat, 23 Feb 2019 13:10:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib9WE2jfJlAWRmKKnSlY9uwiDwv4nVbs+TYH9pK8jjq6ZMjwRPHM6coaIyFN8q4pnJdjhn0
X-Received: by 2002:a62:ae04:: with SMTP id q4mr8918734pff.213.1550956241849;
        Sat, 23 Feb 2019 13:10:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956241; cv=none;
        d=google.com; s=arc-20160816;
        b=PTF0WvgLs70lWSt1hSQZow0pM1IJafR+TMm9RJH9ZZoXSYrFjjESDkl5c8OkHHd1zK
         /kxNDNuw7hxICZ7TJAgEpeynt+IsnM4jkQu+1o0pmeldyw73oGDqZArAwpCWwPwK5PDU
         ikrwqmL4oRTgG+1zhZd9VqUjbC6Pc7va+R7oLxmA1vVp6uQ4YqnIKKT9PEqXyYT5rv3R
         3OoOrNszmTZqjOKRrGQv00J3mpLx4huST2xFVTMAvgSZ7mFeEE84hrHdB7YfKaf13713
         kCWOIZhE9sBz4NF2B8Ak1cj5j7ZrDNTDitrkHJb9/JGdrCZFFU67rPnhwdpTRW3HECLt
         getw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hHKoLZxzK8nZNaA+bf8eF0lrSklgTlSSxc0jWxuhbK4=;
        b=YfYN7vlm70KkeBLVRZErnOx4kEjhsbfE2MHtBdSBahAy/kkB6MzNNSFOhLEMnL3cpE
         lF8zB6qC4CluJKbnb+l/NqxRvDtR+y+7PlHeCFLYf0clR0JJl3PzSEckeDx6r8m0VA5k
         YPAi1ojSsSMfGApjZzL5mYCWHR+zEqOMMxsqHaTWqi81KvZEdE9cubNyNAooD0E38dId
         G9ulv405tE+TbSaq96AslXYLAt1BkwgpL119fr7HkqCJdX02Z4WOyJjrr4lo7v7QzNet
         Z0Zp9+Cuc8CfhJNTh9kKKcmQVtOwLynbVPp5KECEOO+N1MjN1DVTsFK90xLY82/nw3bF
         2jxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kIwrjfF9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e2si4712060pgm.568.2019.02.23.13.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:10:41 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kIwrjfF9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1EAFC2086C;
	Sat, 23 Feb 2019 21:10:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956241;
	bh=5dJBWdmzpLIU/hMkcRTv1CNIQ0tkqk49P1WzD1dBm+0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=kIwrjfF9l62jxQgkt/m5RpxvJuhHNTO3KrBZRWD5CdzGcpz76RjUFJKJSetG6wNRn
	 8UenSz737iokrgVM7p5kvDOsxo3aK7oIU/6v0MXQ9NcF6XHxNK9WYWmVlANLafjBC3
	 PTOWSQ7Z/2BD9xuVDhRyXKEHfJ6eTNvWIRd4lq0c=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 29/32] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Sat, 23 Feb 2019 16:09:48 -0500
Message-Id: <20190223210951.202268-29-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210951.202268-1-sashal@kernel.org>
References: <20190223210951.202268-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mikhail Zaslonko <zaslonko@linux.ibm.com>

[ Upstream commit 24feb47c5fa5b825efb0151f28906dfdad027e61 ]

If memory end is not aligned with the sparse memory section boundary,
the mapping of such a section is only partly initialized.  This may lead
to VM_BUG_ON due to uninitialized struct pages access from
test_pages_in_a_zone() function triggered by memory_hotplug sysfs
handlers.

Here are the the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
   test_pages_in_a_zone+0xde/0x160
   show_valid_zones+0x5c/0x190
   dev_attr_show+0x34/0x70
   sysfs_kf_seq_show+0xc8/0x148
   seq_read+0x204/0x480
   __vfs_read+0x32/0x178
   vfs_read+0x82/0x138
   ksys_read+0x5a/0xb0
   system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
   test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

Fix this by checking whether the pfn to check is within the zone.

[mhocko@suse.com: separated this change from http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Link: http://lkml.kernel.org/r/20190128144506.15603-3-mhocko@kernel.org

[mhocko@suse.com: separated this change from
http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a03a401f11b69..b4c8d7b9ab820 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1512,6 +1512,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
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
2.19.1

