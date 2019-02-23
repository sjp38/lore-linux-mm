Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F83EC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:10:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A8AA2085A
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:10:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="EVmxZHyS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A8AA2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A4E28E0150; Sat, 23 Feb 2019 16:10:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97CD48E009E; Sat, 23 Feb 2019 16:10:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8452A8E0150; Sat, 23 Feb 2019 16:10:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4478E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:10:40 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 17so4267705pgw.12
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:10:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5TLL7Nh6PWtDrnuPpozh4FrMAOfBwvSbdbr0yEZGvrk=;
        b=WwO0Tl/ZheBJwVg6DMvNqMdb2PoM6PF4ALXBVZib2t9Kow6cXB5uW0444zg2lXNeaZ
         lS5zFMq1oD/6E8F7WjfWs7qmwar25M8YyMTOzAyTneVujqaCvL83IzVjME/+efS6iBhL
         jA9ghqsD+3X6Wpo41JjmPw38R7QhGLm8yjz99rPx/AZ6abBULjpHSsgHeTYspxDYd8Zy
         21ALlfTQPhFYzt3j7RlnTMSrVRguoL3CAlfH8aIs6kIkZ8bx5O7A9xvdyXeB4fzcSybs
         UFh2VaR14kft5ZtsWAQjG54LkRNYPp4K+xc1CgOdmbSaZgKbLX0/2cUKiQdQZKjI1Iaw
         vLkA==
X-Gm-Message-State: AHQUAubWCoZAl3aTYD7fIgURUJ4F3cwd3bLyWR5VvwYZiADk/lg0DigI
	INooW2xIrE9L94rv2cWMxg9TIeISnaS7a1AbEj/SRnhT5+IF/r7MdZtsBEqgUSM1RU9MAEuuaby
	dvQFam+m92anNcDgovkrQH4FqjsOKhAAH73JNYo6tzXBNWu9hawWRUJXhLWnyP2fhnA==
X-Received: by 2002:a17:902:b70b:: with SMTP id d11mr11340977pls.178.1550956239927;
        Sat, 23 Feb 2019 13:10:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iacfx0JAtNms0VYyt0/XvJ/i8z8tpk/Nli9H2+sKP2yuno4ye+MMJZGnNvVkT/l0gBWCcXp
X-Received: by 2002:a17:902:b70b:: with SMTP id d11mr11340928pls.178.1550956239173;
        Sat, 23 Feb 2019 13:10:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956239; cv=none;
        d=google.com; s=arc-20160816;
        b=U0v/+2AQYxKY/5zeArAde0rlf4LhvJktJ/z/ADSwjANYK78nO/QE6Qe0U2SR+ifyRw
         1hGnDLS7jWF7VwJU8Trci3xl9TXIGuCi8FDR6p+2yVAKPFD2VKeJnmjP1LGMfbO31NB6
         vlNXYwX8VWoCgcEUuYd9JBOupD7tArCSOSa2XuEinrE7mBWms7otwx1pNZiO60x08NKK
         P4ZgzraXBnuijo2i5rutFtYkR52NgWObvHpUFe3SiIX5o6/HNeqTVhSLiDMr2xc9UYv8
         DglVGRcytUmHz780rEzBO6JPveNgYUl9YAfrykEUirkeG5XUEEWTFFlRhJC9bxjw+Jv7
         o0rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5TLL7Nh6PWtDrnuPpozh4FrMAOfBwvSbdbr0yEZGvrk=;
        b=WI5GvYGXEvGYDOlQwv1zKGhb1aM5cmE3Xgk2OOjqnBSX75jK+QKNW4sLS4E8rQnxW3
         HcUqz81+5P04bOnCSivGPXMfTCw8MBuPfH4WHYYVjIEyO/H6pRSzgQ+GrpyQGqfK38wZ
         XJA9i/UvrVTrV8dOYa9bm4n+EtcNiFXSauBMi7mmIngTUXT3bnlII30OgDj8DnD8wKwU
         162ub/EZR+XYPHwHUWVsPqsswm5Rn25Bd3chfqU8Zy3tmtyY1HACPTIeT/l3rIeOrjI5
         TSYuK+n9A+u5MAzoP+CpiVnjlb6AlHE6RAmo+lA3wilmaZGi2Y2ihH/s87WJsgBtANX9
         0gGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EVmxZHyS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x33si4663464pga.130.2019.02.23.13.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:10:39 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EVmxZHyS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B80782085A;
	Sat, 23 Feb 2019 21:10:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956238;
	bh=jRzziEskIZtJrSQUz8QgkDilPBucsUna3XGsK5H4thQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=EVmxZHySyZOrTVb1BVeZWRxYXTC4/ZzSsBkuxD8GQF5WGgVHgKnUmZjbwCgmiRpFc
	 O4iXQdzi2zQuPrd3sK98frK/XBA9fAcrwmyymzEAU4tbTyozMWCDVvd206+L80Kbbq
	 tVUJP6eGR9Fta8yj+AxUYl9CO70G0uhT0OmQccGU=
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
Subject: [PATCH AUTOSEL 4.9 28/32] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
Date: Sat, 23 Feb 2019 16:09:47 -0500
Message-Id: <20190223210951.202268-28-sashal@kernel.org>
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
index e4c2712980741..a03a401f11b69 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1471,7 +1471,8 @@ static struct page *next_active_pageblock(struct page *page)
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

