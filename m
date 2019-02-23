Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00939C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:06:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B60AB206B6
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:06:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="eQzxQo36"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B60AB206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2307A8E00F3; Sat, 23 Feb 2019 16:06:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DE1F8E009E; Sat, 23 Feb 2019 16:06:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07E258E00F3; Sat, 23 Feb 2019 16:06:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9E648E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:06:32 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so4226733pgv.23
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:06:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SQ1yPE5Qkg9aesvtfDz6XanO/ZO/iK7Im7EOP2WHw7s=;
        b=J+mQtuCkzW7XeORTXlJc5AskoFskmgA9rW0saJgfAu3GcQGVT7LpLHhExEwQovGcia
         NKlg6+hZbdVlt1IBwT2tkvEAt2Rfp7cdl180N3FXt+OKAtWImL00S3NV8ui9piJmxY6W
         CeQTa8aJgCGEhR+yYT+/Yq/oSK2GuYjJ2+H9P2NdU9G61u4YNdKjyqBcT3xsZ7WFr1+f
         8RjXUZUkC2kbDq/xrl39Byc4fzyCvaTr2rEhIdtfEoOfAckS2MsaukhLVH4CsRVbxH9I
         jUhuzQ+zv5u1dcxRociECPi8mnKm62s0F7YSsEuG1jjm5rGBixPlorZiIiT7WGmZwMrO
         XjuA==
X-Gm-Message-State: AHQUAuav76E0eR+jsAWE4Z+39WBEQuTswzaofyVUAZGlFvOK0iu/H5bh
	lchxb/Qz8DRSZk5oDLQfk9ZHySTTtmeQ05i6XK1vEvPQAxB7MM7+QPhLGVrAqfJ0n9lKGgl1XYH
	lT/xZY348ZAm869FRGSe0V/kfMbBXwhoQSFIFHCqQpdXplwIhHyJzri6sHc16yGs0Bw==
X-Received: by 2002:a62:2f87:: with SMTP id v129mr10963788pfv.220.1550955992334;
        Sat, 23 Feb 2019 13:06:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYmBeIAIwkFOInflCx/LUllyMRL3Di4HvLiVzdBEZRZsJqknBlaEVAy5Wb9NZ9ZTBPcUXQQ
X-Received: by 2002:a62:2f87:: with SMTP id v129mr10963742pfv.220.1550955991605;
        Sat, 23 Feb 2019 13:06:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550955991; cv=none;
        d=google.com; s=arc-20160816;
        b=GYU3hqT8P5BzofolQypSHZjJeZ/CZQOgtR8t4U90yGPSOvNtsjd5kQMkzZixKMZL8b
         7ZZOiJIZN2EpHyIjsgmpBGgqBUxGN3pKzW5m9uALHtb1eegZnqsEdgw3rpLZbFeB26fd
         zxdY6fHwZRl6BNsdGnYZ2B5dfcT2lnprkpVTHofajOzR84OSg2fL4y6bfsDLgXHM4ciS
         Ln1R7Gn5mYRwMvv3rB5tZfKxifn+u0D6Z7yvD2myoxc+drl6IV4FmVMO2phW9nxOMDui
         /n41xOE89vmBktxJwPWSHnlCrZTLy6qyjsl6MMpTZlUz1ckJYhYQULFb6iZHTZKjq5Mt
         jwwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SQ1yPE5Qkg9aesvtfDz6XanO/ZO/iK7Im7EOP2WHw7s=;
        b=T3yJBg8MWKvNWhr3KhGkIq5LkSZ0eUhPGrb5jtpK00cWCX3yPVGWa2pFx2BRqPgVek
         764xgaJ8LRm1fTxvtepDvDyUT+769L4gggLgIPg92D4ZqT6CpK/5Gsjy/PcqXEgu7tB8
         Q/2H3tJYgAFluZATZOjGjHaDX5cfVVMyNod5FhxvAD2EBl2ikNzJohGrkc20CXnAsLN1
         niKbzBTUZFsONFrMBWnPl1iAYr5LCN3xOG5HNMRS7Z0T/0ruSPoAuktReQrsiM/V9XU6
         8ue5W9K30zDh67bCk99tkXCNIP2aY4MvgnCKYRHp5gTmm+Bni+s4il5hnKjg1gzz2td9
         y6uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eQzxQo36;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 11si4569687pfh.90.2019.02.23.13.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:06:31 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eQzxQo36;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D639E206B6;
	Sat, 23 Feb 2019 21:06:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550955991;
	bh=lTVWDCH3qnV7+hTgTeFUMJNVNvCL+05npWikEVY3b8w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=eQzxQo36i1d4gtsovUJJeHgsW020MhK1Zeg38H2aLs73CdvS970ZXjKrsYBSqBnpY
	 smv89mDr3fNTSPS28dx7Ch9ny/FmXB+ITooAGA4FmCn7qcNIP2eK6hTmbnyAQibi6y
	 sOz7rMezSBMkgGt5SPCg/DiRc/j+qddFXa4ukNvo=
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
Subject: [PATCH AUTOSEL 4.20 67/72] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Sat, 23 Feb 2019 16:04:17 -0500
Message-Id: <20190223210422.199966-67-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210422.199966-1-sashal@kernel.org>
References: <20190223210422.199966-1-sashal@kernel.org>
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
index 5ce0d929ff482..488aa11495d22 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1275,6 +1275,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
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

