Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE323C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C3862086D
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:09:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RSGZrCGw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C3862086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 256F48E014D; Sat, 23 Feb 2019 16:09:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201D78E009E; Sat, 23 Feb 2019 16:09:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0822A8E014D; Sat, 23 Feb 2019 16:09:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B80828E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:09:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 2so4244428pgg.21
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:09:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K66G5HmZjEQCrHXRADZNrFMV0d104cLEHHvxzhpMoiM=;
        b=DpZaBvaGvhpZvu7tvkE6Y2B8rrPylK8pNfUNLoaJvFipsQTZe99ftxrtcd7qOPONK/
         xqMFzjHGhEuoqBYIKNOvjIowBiBYk0Ui7qJFFdhiM9pfmMEcpmHgEvQNOZX/45IrIatQ
         EL/0j0mkgVM+GUVGdHMJBJDgyrU+7Xiwrrmzt8roNSpKqUQ3BIKUYFdfMzw2Ns1CpziV
         F2/TGCJc/j6PHlfgf7I5iD4tZsVJGXGsBpLVPkQG5UYhzSnmj6+7XI5pBitPCS/t4ZJP
         ldPKvp1TfHVIOuGL62kxULbADxvrUJ3bCtir5vPsu4XJwEzYXRRN7TRibI0CdesWmHJf
         8g2w==
X-Gm-Message-State: AHQUAubV7zDGnaxGFaQF8sc0g27UZ1jdeaOeb/6c3ldQ0kRG65Nl5ku/
	bB0EGiFtR9H/HeUkZCxeFCs8LKRNDzM2Celg+l1l/HeQ47JfknnW9MJjjYiWrmVwzj1a5+cMQhf
	4wv072sILkvm19s3I+HE80dEbS0pSmtAWI/iLoiC94l6C/gTUw9Vo2JF9lGtfRX3b9g==
X-Received: by 2002:a17:902:930b:: with SMTP id bc11mr11216342plb.101.1550956185439;
        Sat, 23 Feb 2019 13:09:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhU233GkV+HNRyjXelANSNzWp4h+P3x+dWC/JtFjMIVzztGT/mIsEas4XnOc18HPykpIkq
X-Received: by 2002:a17:902:930b:: with SMTP id bc11mr11216299plb.101.1550956184842;
        Sat, 23 Feb 2019 13:09:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956184; cv=none;
        d=google.com; s=arc-20160816;
        b=Yg2fOFa13TQvxFglSYaSOLrqUlBgwzabBNLevL3UZYvoUlyXRmIHxBciCRWqJaDVE9
         dc34OvyyHAMIH28bdn2ThIug4Zr5WJHo2DEtLyo7h1G/b2QLi5HmZYTMvrIu/6FlRCt9
         BYCRRr/SDrwYEMzzAUsWUmWXnsSZ0TDXWgBkXpb7OMz61fMZPJQba4jIhNZjDn1eBCsC
         XQBdUFmAddXsOeYFgs9OJhoHsUfY+aXOWb4Y71BheNUIfA3wKDF4cvuVoNALKyYuoi4t
         vzP1FztpC1rsvIT32KTBuwNoiScSvIsOGczVbHffdltrciwNvP9/v/WqplH6TPNnoeZ1
         OKVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=K66G5HmZjEQCrHXRADZNrFMV0d104cLEHHvxzhpMoiM=;
        b=cQ3dahbN4eIH3ckyvhtNJHP/sZwfrGyOPKZN6QGGUroD+AmslBWQzDqaVWqLbK/Ak2
         TNOW9PhxRKb6Aa1iA849ujd6ttLOXasZ75lNS/rq1dCnA9r3soni4I9cPw0Ugtzp+GF6
         OhnjRiYX3GoDg+IVwzpFrs+Y5HRpOJ4fe5qwU0zDDgL7kNSHTSpycI3+durJrEukA6Qt
         MIsojMo/Fy8ZN2u08DdDdzxJtR5oA0YO+8WwrcTnZh1tijpHRHkIk0unDVCR8Nc7wWmA
         XzY5XlYP6hppTZZmGP51bqencgMDmuKohvjTCao437PerdM5aF4nP5LafbJnHEJPHsUH
         UqmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RSGZrCGw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k26si4671761pgb.72.2019.02.23.13.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:09:44 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RSGZrCGw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2DCD12085A;
	Sat, 23 Feb 2019 21:09:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956184;
	bh=orU3qlI7A0lZ9aXd+9Ue+V1x3JGAW+4QnjHfWashMNA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RSGZrCGwGi3nt2uASueP8vfi0rA7F4UWunrf1Ue8yvbokDfGV6dw1Ol3hBaLK9gSD
	 CeBQ8rMuv1+WaVtwpT6qqw9GHvNWqRHPoyE2qFxhsYlvMNKqcMeWqaRwYZMNx20HnX
	 B+9vICoKQhOWCjC2IipEdlIzq3q90ZMmBThgiZtk=
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
Subject: [PATCH AUTOSEL 4.14 41/45] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Sat, 23 Feb 2019 16:08:31 -0500
Message-Id: <20190223210835.201708-41-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210835.201708-1-sashal@kernel.org>
References: <20190223210835.201708-1-sashal@kernel.org>
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
index 39db89f3df657..c9d3a49bd4e20 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1297,6 +1297,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
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

