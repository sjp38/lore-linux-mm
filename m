Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB84C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC85C2238C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:08:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC85C2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626B16B0007; Tue, 23 Jul 2019 01:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D8558E0003; Tue, 23 Jul 2019 01:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 477AF8E0001; Tue, 23 Jul 2019 01:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0326B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:08:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so21213745pll.22
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:08:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=u/ENe7PYaAetCjjsddjbbWgd8qMMMyGOJuSHPQSX8II=;
        b=p5N2EQ2PO5bc2vI2YHihHUnAcb+OIwHz7W7E1ND9CPUhD3tb+V1pyWA6tx0cKrviSb
         FzRfs+Z8RkHapWw8cP9aUSIuFzkdwoQ29gmhJY+wBLhRrlQZX7K3jYVg1pKFX7dOOzer
         V4BvMdDynF7/1KL8OH1zieYZUhE78Kc2MALtaWTw6m85IeF/BRDFBO6aILKdCuRCSb1o
         x7yNWj5O95+v06mavHx38VM8jpIbNrT2bJ/AhxYkzPzPeB9aRgOnFoxm0bo8UfBLBkaW
         RbcJ+0IeAkSkKFOCbs7Ce+anXmyw8bYvkQieF1c1ZQuBn73+1E83KIBbWCzAZhXkixOS
         PSVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU+I5NjCA7cppMM+bfrSJA+IaO1bTlJxKCkksiEPSW0j77rVXNB
	I0nHz9vqnmkAovJZcPZ+j8WsgjsnE8gl2kXBriC27SCzwiQOR5Y9RyBVUiaG34FbXO/Ka8JJAdp
	1lwnxAcKtMGb8ITXdOZsMQGivCgd86Pf6TiP14+qh1yY2CNd231A4wAH2QL6n6hqtwQ==
X-Received: by 2002:a17:902:ab83:: with SMTP id f3mr78762227plr.122.1563858525639;
        Mon, 22 Jul 2019 22:08:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoyE5SmKMAfBJFsO0TAca2nT4iPkXdKphtKn2ZJto8CWCgHfFdNZPUTTGgvnN1VyqHgR5q
X-Received: by 2002:a17:902:ab83:: with SMTP id f3mr78762189plr.122.1563858524847;
        Mon, 22 Jul 2019 22:08:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563858524; cv=none;
        d=google.com; s=arc-20160816;
        b=Cif672VtXkABhHgDJbhc/Au6wKHgbR6U/Gd4EM/tr5LmW12I6whQdXpkyq5xo0T+sd
         StjovK4hx254zReBXPkoAOisCAOOd04L9zoSmbcfSQnhej0/Zi/Ez25VMd8XQvCcHrnD
         DASB3xicVJ08xkp7JQ23aGSWhilXX4KY3CpCZOwiH9+bkVOL2NZKNLtG4oeA3dUNvRYj
         jp0x+6cBOpCmtZfW3qbH9+AMi4nQkraE5dkZC/cfZbroxr5qcVswAI0JsEwbwX6Ku9Zc
         Pwym1+d0HU/4QfknSh4TsdaPWrsa/JqKKnelLrewciCZxGSV7sMgVPUd7xQRN/wWM1sH
         CZOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=u/ENe7PYaAetCjjsddjbbWgd8qMMMyGOJuSHPQSX8II=;
        b=070YJ6PRLGX7CIBj0+Xe2euhpfswRjKGeipR3SOUmh8U0XLupuSQez9Z2Sm5qLzF3p
         sHfz+J29DsKzPJfGIVPab3Uo8maKK+hw+itSV2ETievKqIZJhRjg+9pWRH2ET6yGNJHB
         4ug9woiMZ573a5Uvkrubn0faWSVkmJOSG/l6Jp6xt5g0i07A21X75VRk6Pqa/8cIiOs5
         Jo2KTOzXiJ6I2kjl8rZPZIRV5MbMd4IqpaJyDtGLoxgL7BPY5NnAOIwQplMErCQ+VssL
         bqGuRxoLoQd5a+wWDhguaTbfQBJoyrn+tHPfnsigt8Bbrcio4GeM0mJIQU3H2ImyouNz
         tAww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d1si9744061pla.75.2019.07.22.22.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:08:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jul 2019 22:08:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,297,1559545200"; 
   d="scan'208";a="196991815"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga002.fm.intel.com with ESMTP; 22 Jul 2019 22:08:43 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: huang ying <huang.ying.caritas@gmail.com>,  Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,  <linux-mm@kvack.org>
Subject: Re: kernel BUG at mm/swap_state.c:170!
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
	<CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
	<CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
	<878ssqbj56.fsf@yhuang-dev.intel.com>
	<CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
Date: Tue, 23 Jul 2019 13:08:42 +0800
In-Reply-To: <CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
	(Mikhail Gavrilov's message of "Mon, 22 Jul 2019 12:56:18 +0500")
Message-ID: <87zhl59w2t.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com> writes:

> On Mon, 22 Jul 2019 at 12:53, Huang, Ying <ying.huang@intel.com> wrote:
>>
>> Yes.  This is quite complex.  Is the transparent huge page enabled in
>> your system?  You can check the output of
>>
>> $ cat /sys/kernel/mm/transparent_hugepage/enabled
>
> always [madvise] never
>
>> And, whether is the swap device you use a SSD or NVMe disk (not HDD)?
>
> NVMe INTEL Optane 905P SSDPE21D480GAM3

Thanks!  I have found another (easier way) to reproduce the panic.
Could you try the below patch on top of v5.2-rc2?  It can fix the panic
for me.

Best Regards,
Huang, Ying

-----------------------------------8<----------------------------------
From 5e519c2de54b9fd4b32b7a59e47ce7f94beb8845 Mon Sep 17 00:00:00 2001
From: Huang Ying <ying.huang@intel.com>
Date: Tue, 23 Jul 2019 08:49:57 +0800
Subject: [PATCH] dbg xa head

---
 mm/huge_memory.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9a6b32..c6ca1c7157ed 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2482,6 +2482,8 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	struct page *head = compound_head(page);
 	pg_data_t *pgdat = page_pgdat(head);
 	struct lruvec *lruvec;
+	struct address_space *swap_cache = NULL;
+	unsigned long offset;
 	int i;
 
 	lruvec = mem_cgroup_page_lruvec(head, pgdat);
@@ -2489,6 +2491,14 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
+	if (PageAnon(head) && PageSwapCache(head)) {
+		swp_entry_t entry = { .val = page_private(head) };
+
+		offset = swp_offset(entry);
+		swap_cache = swap_address_space(entry);
+		xa_lock(&swap_cache->i_pages);
+	}
+
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		__split_huge_page_tail(head, i, lruvec, list);
 		/* Some pages can be beyond i_size: drop them from page cache */
@@ -2501,6 +2511,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		} else if (!PageAnon(page)) {
 			__xa_store(&head->mapping->i_pages, head[i].index,
 					head + i, 0);
+		} else if (swap_cache) {
+			__xa_store(&swap_cache->i_pages, offset + i,
+				   head + i, 0);
 		}
 	}
 
@@ -2508,9 +2521,10 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
 		/* Additional pin to swap cache */
-		if (PageSwapCache(head))
+		if (PageSwapCache(head)) {
 			page_ref_add(head, 2);
-		else
+			xa_unlock(&swap_cache->i_pages);
+		} else
 			page_ref_inc(head);
 	} else {
 		/* Additional pin to page cache */
-- 
2.20.1

