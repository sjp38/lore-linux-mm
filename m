Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29365C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 23:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E379021955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 23:06:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ic76KIn3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E379021955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D07B6B0003; Mon, 22 Jul 2019 19:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781926B0008; Mon, 22 Jul 2019 19:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6712A8E0001; Mon, 22 Jul 2019 19:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4707A6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 19:06:13 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a2so19183584ybb.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 16:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=8L2t5eNHtNZSBlKOQ4UF/BYJB/qKm9Cii8LsBa8jE4c=;
        b=QYuZwa8A2IhHATfN/6ed66PEjKxQZtDT6MD3m8SdKAEeSSSwyrSi4tokQN8qGVxG+l
         KlqdGvFypAZNMDym1ZNZnxR5nxLkhKtqyMbRPGm8G9DHBF1t+WgkglvuSv7iO6x3+Eee
         8goaHrqgsgKyUHgO+QviWRkNlfYEg7S2LQVOpFXhwxXTMAsmtc0KUr/RJEyX+dDTBBGm
         E76G5VU81C3CdXpaTbb84t5lnVJgoI/F883VZ/SRH0LCHUmVVBGaRUpJbVOYWduYuyZo
         8vwIRbpRD38hIneFqpdLCtnN4pv6Ka0aj3KwMKa+hjLTLHnari9f6ouCJziXnU3LsLAj
         YtSA==
X-Gm-Message-State: APjAAAXESCVaV2fsEzeBWOdRzGqKFfVyk2/k1XOlv7g/gc5oL5D4G5de
	ZtRMuR3d0Er+VrJYsOKvSp3H8xRnwgb7Er7lFk32O7tLXJFi2dl9utPUE6ayZyj2yfM5oiIl8IH
	CPlS9Ocgf5TafN2bWcVSRiU/CS1X8UkrLC6+A60gk07agYPvPaZXUqjCLqnYGZPrxVQ==
X-Received: by 2002:a05:6902:524:: with SMTP id y4mr44489775ybs.438.1563836772967;
        Mon, 22 Jul 2019 16:06:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWgpcdjB6oBWMurOO423fhouI/eFrqrb9cpBtyTBZbSpR5XbkJed03VMdt3xTqTlTGAWZS
X-Received: by 2002:a05:6902:524:: with SMTP id y4mr44489734ybs.438.1563836772204;
        Mon, 22 Jul 2019 16:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563836772; cv=none;
        d=google.com; s=arc-20160816;
        b=rrJT5/0tA5nBBn1HIMFVlQkv3oM2d+t+/NazxC17ozBJ0uvwKdX5PBaIc8Bcs4xVVr
         P/ClUJbC6JIcg7kt2/DFodkPfjAbpRBwDosIhdOi1/dZifCXqFrbusV6AoYkGfFwo2P9
         CyxNJHIZeaPtu4ERg84ykIteurYNnvERQ5PAe3RqiN2Y4yx2Cx3ZWK2MQ0gkYJgWkJzG
         W3sZBgirjDKjf7Pihi77HqmjXHeiqh5tmJdXYRnpM9+Bm3KxAJQ0UJhNBPONDhOHK3Y0
         ekr3pIaxqyMppB7qMoEUJrF3QGUfahgERfqinzRU/zmS6a76GRHyIIYUwwe7fVD0uGIb
         Aw7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=8L2t5eNHtNZSBlKOQ4UF/BYJB/qKm9Cii8LsBa8jE4c=;
        b=eDIQvnuusVpaNi4a+aEXhahDuqSHbFm8PP6nBFHSOAuUJJVfpZu9yhPSJ8woTaaykD
         WLaAHwp3jldi+YdtqQApsHbaXWIe+l0Fb52iBFFALYuONEzdJxAJJFrJINeDQgHyWSqx
         7TBKl4EAO/tuejTGQe4GhdhkPE4CYV6DwhpJSAN0Vz3v+w/pUPskJUMU3anRAf94xV89
         X9nsR1ehm+GjKe/1FWae+Dqi8GdoymibsvrxP865H3dqAXdwv8JKPc77gN9iCk6sigA5
         cY/sNw3p36/1GGZP9ot/5XlRzNpufKudrOIADXmvO7X/EAvtLJ4cPzlfJy9JaL+BYdj4
         mF4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ic76KIn3;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e131si16149633ybb.149.2019.07.22.16.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 16:06:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ic76KIn3;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3641600000>; Mon, 22 Jul 2019 16:06:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 16:06:11 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 22 Jul 2019 16:06:11 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 23:06:10 +0000
Subject: Re: [PATCH 3/3] sgi-gru: Use __get_user_pages_fast in
 atomic_pte_lookup
To: Bharath Vedartham <linux.bhar@gmail.com>
CC: <arnd@arndb.de>, <sivanich@sgi.com>, <gregkh@linuxfoundation.org>,
	<ira.weiny@intel.com>, <jglisse@redhat.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-4-git-send-email-linux.bhar@gmail.com>
 <c508330d-a5d0-fba3-9dd0-eb820a96ee09@nvidia.com>
 <20190722175310.GC12278@bharath12345-Inspiron-5559>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <15223dd3-8018-65f0-dc0b-aef43945e54e@nvidia.com>
Date: Mon, 22 Jul 2019 16:06:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722175310.GC12278@bharath12345-Inspiron-5559>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563836768; bh=8L2t5eNHtNZSBlKOQ4UF/BYJB/qKm9Cii8LsBa8jE4c=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ic76KIn3tVio6vzVxE2FnWPCYuR7SXKbShoLnDet+7TPVb2NHLdtlV/kDMJCRRg5I
	 t95iAmFuphbDWTfhJWQVcutfK4K3SSC7t0F07t/GUpbG5ve7mqdnCpz9zM5WVTZl+o
	 HGCA5yP0OGGXa76TuqLlfEc+S1OholGwzkmaROv5W2B7rQgMJbNC/NEkcDdp4TjjyS
	 4k83+HfBmE41XSDRriG7l+FvX8LSKEaI56L7iHXvhZ1cFPSFVCko1yx/ukVBFs4KaH
	 LwwauagCcI6DjUxHcUesRH9e43/t9Wl7Iz+snHAqXnxusLedgIJXzOB3cZRf98KVyL
	 7I7k+ccEnSXyQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/22/19 10:53 AM, Bharath Vedartham wrote:
> On Sun, Jul 21, 2019 at 07:32:36PM -0700, John Hubbard wrote:
>> On 7/21/19 8:58 AM, Bharath Vedartham wrote:
...

>> Also, optional: as long as you're there, atomic_pte_lookup() ought to
>> either return a bool (true == success) or an errno, rather than a
>> numeric zero or one.
> That makes sense. But the code which uses atomic_pte_lookup uses the
> return value of 1 for success and failure value of 0 in gru_vtop. That's
> why I did not mess with the return values in this code. It would require
> some change in the driver functionality which I am not ready to do :(

It's a static function with only one caller. You could just merge in
something like this, on top of what you have:

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 121c9a4ccb94..2f768fc06432 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -189,10 +189,11 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
        return 0;
 }
 
-/*
- * atomic_pte_lookup
+/**
+ * atomic_pte_lookup() - Convert a user virtual address to a physical address
+ * @Return: true for success, false for failure. Failure means that the page
+ *         could not be pinned via gup fast.
  *
- * Convert a user virtual address to a physical address
  * Only supports Intel large pages (2MB only) on x86_64.
  *     ZZZ - hugepage support is incomplete
  *
@@ -207,12 +208,12 @@ static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
        *pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
 
        if (!__get_user_pages_fast(vaddr, 1, write, &page))
-               return 1;
+               return false;
 
        *paddr = page_to_phys(page);
        put_user_page(page);
 
-       return 0;
+       return true;
 }
 
 static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
@@ -221,7 +222,8 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
        struct mm_struct *mm = gts->ts_mm;
        struct vm_area_struct *vma;
        unsigned long paddr;
-       int ret, ps;
+       int ps;
+       bool success;
 
        vma = find_vma(mm, vaddr);
        if (!vma)
@@ -232,8 +234,8 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
         * context.
         */
        rmb();  /* Must/check ms_range_active before loading PTEs */
-       ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
-       if (ret) {
+       success = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
+       if (!success) {
                if (atomic)
                        goto upm;
                if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))


thanks,
-- 
John Hubbard
NVIDIA

