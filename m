Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34883C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:56:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB03F21473
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:56:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="AMkTDxs1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB03F21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 640E26B0007; Mon,  8 Apr 2019 15:56:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EFEB6B000A; Mon,  8 Apr 2019 15:56:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DFA16B000C; Mon,  8 Apr 2019 15:56:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17BD96B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 15:56:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g1so11208075pfo.2
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 12:56:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=E+yVjhVz7hUuMuUS71zV31X7NgehVdKX9ZgoshuaFks=;
        b=Q+L6LrrTSsKKYqeLUIjntesEKqe0sU1oOCWAbtLpDSQfrTa3/ihun0c6HvWeY/x86D
         mEoGfbk2p4R+CjoEcYwegFy9V1zC2OtE9NrEnd821MaEz+CgJ0m9ijZtptPLl7cPd43C
         KmFEUTmQWFFi7Cwoa+LhfnJIX4kX5hiP55/hYchqBpNaQaOgcNh7CJrrwdLTYrMbD16F
         VfSzYkLk9mELYqYf7FGmPmGn5jCKraAbeyzt1n6GCPInSxAJlWx0SlYFEPjh9dCR4q2A
         HmtncYN1kCCXCPCY5/GjMPvSsquJ13A+eV/H7fIuSyPf3sVN7HtgTjFYCjh8DI8h7dtA
         25rg==
X-Gm-Message-State: APjAAAXOc0PeKn0rotKpzirv7HzA8hf7NOZigYAapfGcwF1Z+ogX7aXA
	3/LUKHIErAKSmZK/PZujK1Tsh/jRyl6+kYW6XdrAIi49rU01Ze5G2YdUkj1ZKqaaB23zE9qfSIr
	7NVGMX6mbCv7qBgpYwm97AZrKXj11SSL+myK4+yKA2cJMUNDktryTjymVOm7ZCICxug==
X-Received: by 2002:a17:902:3e3:: with SMTP id d90mr32200794pld.271.1554753375599;
        Mon, 08 Apr 2019 12:56:15 -0700 (PDT)
X-Received: by 2002:a17:902:3e3:: with SMTP id d90mr32200728pld.271.1554753374904;
        Mon, 08 Apr 2019 12:56:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554753374; cv=none;
        d=google.com; s=arc-20160816;
        b=AuAy+zP/xSPtXrqjnqa0RTwd0kNYJTbh6/VZqBuuCqqvgWV3qwPhqxl4uVCtoJ+aLo
         l3pabqzwV8+Cj5xk7i97IuM8vnxmDCNUGS1/75rORFYyDhNx9iPodHkT0dswCbQx/v2p
         LdX/N7D5aesC3x0w3jI70Qv5OC0bp31jbG6q8p+QG4IoONXEvqyHub7owD3Uuf9bJDoy
         Ufv+JBL0iaAGm6wDGZaG0xVCKdoNhptkFvidu6vfEIKu8NIxYnOWzSxeN98NNWy8BveM
         A0hdfGPovfHsSX1ctaAgzn5d1qX7TfXmgTkCOFCdstGnuPJYEkC63KS2WpC/NlfevffW
         LerA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=E+yVjhVz7hUuMuUS71zV31X7NgehVdKX9ZgoshuaFks=;
        b=ts8XV/j16DU8wGnyQDI3EbB3g7fxvj7HX3kMHJMZGRls+DIrnuXNE6jG7ivFI9KZTw
         DbmmQiinx/zlEGTJh2+PuDVkvAYjMptMYkBvU6/bofjFaVKF+rSjoOEhoK0mFh0WbLeN
         ibDwlXFmkK56rhUR6ZQhnFUM92mUJExWeXtxkjtYRFZbb6uv1Lrog1ZWzeSoBHe+BMcD
         eJx074dVDeR5AvX/1OTukYI+1wUH00dwNbuNbvf9GNZnPId3vvaMYXNn3MvsCjCf5MpX
         cwldnQ8Qc8TfvWYCSktwxEvwu5Ns3gMOyk1o3QDRUmQ4S+HlOVxUk9E36CxD9msVU6nZ
         pjng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=AMkTDxs1;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor30384219pfh.36.2019.04.08.12.56.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 12:56:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=AMkTDxs1;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=E+yVjhVz7hUuMuUS71zV31X7NgehVdKX9ZgoshuaFks=;
        b=AMkTDxs1LHsHlchUXT3nGVvExN68Rr2G6ioVk0vWn79VfbBGuSrXUKd0aMLgaapNL1
         v2UgpFjkjxIgHdLsqbOBzBU50FtFFja71QzwlDk7EijQZPac6FpLeM3eb7tfVnxSegBt
         UZJMawK98mMNgFOw76z8wQ3XeaqLIIGjxMwYxN4YRuGV1chNg7vvVra6khsBGAPMng0V
         Jq8ABXsISFdSvxCqsySwOBNubuEm8b3l4OGlUgUt7PiXncdwGtTGxaYiYY01N3rhpQHk
         Bkl4UDP+Pzn3WTQVSemDaW9Wv3kiln6EvB8xyIVnVNjQJcpXPzpK21u7vZCAkMWruZHu
         /HGg==
X-Google-Smtp-Source: APXvYqyr6Nw2aE69+Sv05HhyzHpd5PPgyTc/AzcorrzgRuqd+2YHFvCQexJLbjXUeRLfMimlQ5muiQ==
X-Received: by 2002:a62:4e86:: with SMTP id c128mr31870152pfb.39.1554753373844;
        Mon, 08 Apr 2019 12:56:13 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id j16sm41054868pfi.58.2019.04.08.12.56.12
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 12:56:13 -0700 (PDT)
Date: Mon, 8 Apr 2019 12:56:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH 1/4] mm: swapoff: shmem_find_swap_entries() filter out other
 types
In-Reply-To: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1904081254470.1523@eggly.anvils>
References: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Swapfile "type" was passed all the way down to shmem_unuse_inode(), but
then forgotten from shmem_find_swap_entries(): with the result that
removing one swapfile would try to free up all the swap from shmem - no
problem when only one swapfile anyway, but counter-productive when more,
causing swapoff to be unnecessarily OOM-killed when it should succeed.

Fixes: b56a2d8af914 ("mm: rid swapoff of quadratic complexity")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

--- 5.1-rc4/mm/shmem.c	2019-03-17 16:18:15.701823872 -0700
+++ linux/mm/shmem.c	2019-04-07 19:12:23.603858531 -0700
@@ -1099,10 +1099,11 @@ extern struct swap_info_struct *swap_inf
 static int shmem_find_swap_entries(struct address_space *mapping,
 				   pgoff_t start, unsigned int nr_entries,
 				   struct page **entries, pgoff_t *indices,
-				   bool frontswap)
+				   unsigned int type, bool frontswap)
 {
 	XA_STATE(xas, &mapping->i_pages, start);
 	struct page *page;
+	swp_entry_t entry;
 	unsigned int ret = 0;
 
 	if (!nr_entries)
@@ -1116,13 +1117,12 @@ static int shmem_find_swap_entries(struc
 		if (!xa_is_value(page))
 			continue;
 
-		if (frontswap) {
-			swp_entry_t entry = radix_to_swp_entry(page);
-
-			if (!frontswap_test(swap_info[swp_type(entry)],
-					    swp_offset(entry)))
-				continue;
-		}
+		entry = radix_to_swp_entry(page);
+		if (swp_type(entry) != type)
+			continue;
+		if (frontswap &&
+		    !frontswap_test(swap_info[type], swp_offset(entry)))
+			continue;
 
 		indices[ret] = xas.xa_index;
 		entries[ret] = page;
@@ -1194,7 +1194,7 @@ static int shmem_unuse_inode(struct inod
 
 		pvec.nr = shmem_find_swap_entries(mapping, start, nr_entries,
 						  pvec.pages, indices,
-						  frontswap);
+						  type, frontswap);
 		if (pvec.nr == 0) {
 			ret = 0;
 			break;

