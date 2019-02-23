Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C432DC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EF7F2085A
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:06:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ponZaQTL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EF7F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8F568E00EB; Sat, 23 Feb 2019 16:06:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3E648E009E; Sat, 23 Feb 2019 16:06:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B54CA8E00EB; Sat, 23 Feb 2019 16:06:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 729108E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:06:30 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f18so3077880pfd.1
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:06:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YjbH8sfLVmvNV7CqV9ejhmKaBHFUbMHUnvwo+SYKC6k=;
        b=O7k2LfSkcs6Aotfn0RyCLJbZly3y+vgCR3CJO3mTR6er5ky91Tn29iGe6c3w584ZXy
         VRVWq4vCqfxRwJcJ2VzUM6QfSFxlt+j+gelaKpO1OxGWm7uPjpLtlQsHPC7IpJPXIJKb
         lrABVkMeJyJByx8kwmt3L8hUy5OvtxNhikPigqropD9bFAX9/kZEtybtOEdOYDRIH/go
         2T2za+hUIHa6VMkY6o6KdhvxOEhqvBI5nfSl3y2UgTvfgBb0k7NU19txHZFWA5YCs8hP
         YCKmamL4pq8cCdmFO3AjstdbXYPooGluSBegvb5WpLIx92QDODOR7R/npxdQuWs7hVja
         Wj1A==
X-Gm-Message-State: AHQUAuaV58nnZCjciwSr7GB47r157HF1GMqAl16yXXPo7CxekbJ1srMa
	dQNfKfRoy80e2xLOTy4Oj610UEL27BZdk0Q7gW9Y2wZyGFk2ENRytbrwkRsCMQ6nrFewADwxxLI
	nbQxO6sF9sqiBY8jYHn+SrbaRvp0T9nZ0ZakdFf7PQc6XgJpOGWyVoWfpQFYZUjcrfw==
X-Received: by 2002:a62:4d81:: with SMTP id a123mr11296166pfb.122.1550955989968;
        Sat, 23 Feb 2019 13:06:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IailA23cFqQ/t7x2lXBFXFnjhLLo560vfNKLjqvxO7OsQbrfBS7Q2Uow7SLQZN4k/UV3F5M
X-Received: by 2002:a62:4d81:: with SMTP id a123mr11296104pfb.122.1550955989067;
        Sat, 23 Feb 2019 13:06:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550955989; cv=none;
        d=google.com; s=arc-20160816;
        b=FmpzHv31OW+rr000T0CWvUrJloG0GI9DdKnOV0oOxLS2t5bAU8JqEajjmRt2hWXKsM
         w2PWwQ0/oXNuq1Z4mGVoGlrNv5JPT7brso2Ei5XsJ/r5xMa/2sJdWV9Vg9b/x6c7EkLp
         j0rU0xo0IUtuS/qHna13yACnhn22s+lncKwQj7YI2XZXQgn1FwPNxuVlkMFvWLQO9bJj
         VK/4+3d4KQ9jMmXWiix31VpQ5AnSGQSWuG47Q0kqgs5z9/ve4l4MxOGlsUqw9K1/ONCB
         w/Ai9OU0XfE1q6pYCEbqKM5ptegYt08TsAxIU8TJNQS8kkcd4m+6KAhbGkREcK4KKRn2
         wlHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YjbH8sfLVmvNV7CqV9ejhmKaBHFUbMHUnvwo+SYKC6k=;
        b=iE3dYGwuEPlFWlaH+A/AvRlWwFXF506Tv196ozpbbrRik8E1oGj8Qu025RblLcId1s
         p2sOZYmxMRxK899QwZJdJW6a1lHBSg/D/CF8gLB/PvfCbfNRKjZvRF76op9oFdPt0hME
         WgAZ0EXvsdnKbjPtxmgYpx3LSijDYcRdiPG92BKua4i5dJ1h9cOcvVTu/kWmKyWwxyZt
         zFcc0mPUh5nYVkc4lBFKl1e8+9inZ2shZXqCnIJAVGVkix3CP6/loKFGJY3LYtaGpc6t
         /8ms92k1Z5EIOCp+jggaNOisSVsuIYd9RppnSTrpROtBqGHINAYwh5fnXhzcsCfuURjv
         i7kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ponZaQTL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e67si4690130plb.107.2019.02.23.13.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:06:29 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ponZaQTL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5F9692085A;
	Sat, 23 Feb 2019 21:06:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550955988;
	bh=PpIK6yquttwIJH9K5kARyEyZ6ohka8ntz+E7xLYgmTY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ponZaQTLFaHwBjs2Qd5fxIirvtTI2xNK/KIcjdbpHdaZga54V2a5XpRS5hww8UIeB
	 YenAfWCjr5BzKaUSPxU7OFLZ7bqEpEK8EXcNN38n2UwnwmA837g/fPXWlyFyn2cqpj
	 ExCjjGnxaTx7tbruSXchgJq4L4Wiz7wehfYep8J4=
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
Subject: [PATCH AUTOSEL 4.20 66/72] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Sat, 23 Feb 2019 16:04:16 -0500
Message-Id: <20190223210422.199966-66-sashal@kernel.org>
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
index 21d94b5677e81..5ce0d929ff482 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1234,7 +1234,8 @@ static bool is_pageblock_removable_nolock(struct page *page)
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
-	struct page *end_page = page + nr_pages;
+	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
+	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-- 
2.19.1

