Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6DBCC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:06:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1644206BF
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:06:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1644206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CE146B0008; Mon,  6 May 2019 10:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47EAA6B000A; Mon,  6 May 2019 10:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3465F6B000C; Mon,  6 May 2019 10:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8C16B0008
	for <linux-mm@kvack.org>; Mon,  6 May 2019 10:06:55 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b5so7544706otq.5
        for <linux-mm@kvack.org>; Mon, 06 May 2019 07:06:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=yhwjf/lGP+BLE1UxuYYhtDwb96UANfQX0fYvudzfvco=;
        b=QAbjxrRx+Ltbh3agtRlCZKfSqicrimqyi9I6RrhX8BjdAQOJHDhm3ITXQa8s/UxwX5
         wpF9+s3sk3PtTB1mbMQfmBpF5JfzrICnIVNi9A2zVpCy2BIMoS4rvojTy86PTdEHzm/K
         m86fbAqtWaP4qe/aeEZ1RWjTZsvzXsjNPc9iCp0ZAQtH3qsXkDetN4DDlkz/rmlluJJw
         05bHWwn2B6QafVSGV/ghyyIvTksCxnjPkefq0A/Fro8MG8Y5s18ZEQdJuI+FVrZmqZcI
         qALPxbsJXl78HW2aS5WpqxPa+vGRWhY4Iy5xXAmNUCOe/UPTkjfiohEhUeYRLCR/p7Sr
         WVcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
X-Gm-Message-State: APjAAAW/CRrTtm5SacJN1RFZV6cbxFyP/cqlLMmWJCwcDKwteu4rrWSH
	aVnTxQR1Y86+PB83Mb6JBDsrGskdxEGdaKqgJ3eIKTlAnIPQDgYjTx4YPXtWFbpq9ZxDN0Yqrha
	acHHRa6yzYY4kBTgLMK2s9nW87NANc3XG0XbpJgOuxTAwWg5ImlqTzoOR9Ei5eq3HdA==
X-Received: by 2002:a05:6830:2081:: with SMTP id y1mr4059219otq.164.1557151614639;
        Mon, 06 May 2019 07:06:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSugefAOpTofzkVumTeuKzCOzVIoQufKS6KfT65SSVhXVaBWfaCLtD0VN/iRNUFDKct5K5
X-Received: by 2002:a05:6830:2081:: with SMTP id y1mr4059142otq.164.1557151613562;
        Mon, 06 May 2019 07:06:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557151613; cv=none;
        d=google.com; s=arc-20160816;
        b=uBBwssRnm4+wKXJUZfr4cneysJlaeUjSf5KGUOAkznnzC9ALSA3n0hG+UFvvo3KUoH
         rmgK/sDChmRu+b1shj8T07jOqUR6E7SOZ4wIKX1xf3KkhuV9i2smE5tPT7HcC0iU1iuX
         g50sTaHMEgyW/a+Wveytgt7zm3RPnuJEB6MCtvqGGMffEuF7rbKBJ5stQYGxqtog0RfW
         NRWcQHdus1pNa4s/edHSzSanFjbgjiDdS/xBD2THdtc85T7MEMwoDcUxuy+ilQl+LZd4
         qYfvzqpbwQg6GnCFUT/ycHie+LwoTLBfdOZDhmnkdb4BJ+/KK7EVOQTZVjOjWIXs/ZRW
         ZHlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:cc:to:from:subject;
        bh=yhwjf/lGP+BLE1UxuYYhtDwb96UANfQX0fYvudzfvco=;
        b=XplETfnMOwckofUH6bn8sWfIVNtsnyFHvTiRXJSQYPhZgebPcZG4nEUAcBUxOKdloC
         GAi6DjMpIBAa8Vhmf5cmB+rNJb8NPLiSKoQwE390UYEUsI8Ut46A/Q1l/a/rIgEfOdxT
         6uNEjxUe+2f+8CC26xAOlt970JA6h/7dC8RCG68/gxc1Q9LZr76lZPGL94OQ4HzbYTVj
         /+7uaSLlDdjoX9ipxcFQCGSNHFE/ZMH8Rrr6kGmIwtrYGHXE6iunYc4V/1kzaV9ubqtm
         k9+5O+F8/bf9D73a68rlfQqk+lIdqfjZGarY5vORuPkEa0FEuROInDTwJ5NVHZiQU9Xl
         QLqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id x10si6400794otk.163.2019.05.06.07.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 07:06:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id B5049A20A38C0258464B;
	Mon,  6 May 2019 22:06:47 +0800 (CST)
Received: from [127.0.0.1] (10.184.225.177) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.439.0; Mon, 6 May 2019
 22:06:39 +0800
Subject: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
To: <mhocko@suse.com>, <mike.kravetz@oracle.com>, <shenkai8@huawei.com>,
	<linfeilong@huawei.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<wangwang2@huawei.com>, "Zhoukang (A)" <zhoukang7@huawei.com>, Mingfangsen
	<mingfangsen@huawei.com>, <agl@us.ibm.com>, <nacc@us.ibm.com>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
Message-ID: <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
Date: Mon, 6 May 2019 22:06:38 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.225.177]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Kai Shen <shenkai8@huawei.com>

spinlock recursion happened when do LTP test:
#!/bin/bash
./runltp -p -f hugetlb &
./runltp -p -f hugetlb &
./runltp -p -f hugetlb &
./runltp -p -f hugetlb &
./runltp -p -f hugetlb &

The dtor returned by get_compound_page_dtor in __put_compound_page
may be the function of free_huge_page which will lock the hugetlb_lock,
so don't put_page in lock of hugetlb_lock.

 BUG: spinlock recursion on CPU#0, hugemmap05/1079
  lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
 Call trace:
  dump_backtrace+0x0/0x198
  show_stack+0x24/0x30
  dump_stack+0xa4/0xcc
  spin_dump+0x84/0xa8
  do_raw_spin_lock+0xd0/0x108
  _raw_spin_lock+0x20/0x30
  free_huge_page+0x9c/0x260
  __put_compound_page+0x44/0x50
  __put_page+0x2c/0x60
  alloc_surplus_huge_page.constprop.19+0xf0/0x140
  hugetlb_acct_memory+0x104/0x378
  hugetlb_reserve_pages+0xe0/0x250
  hugetlbfs_file_mmap+0xc0/0x140
  mmap_region+0x3e8/0x5b0
  do_mmap+0x280/0x460
  vm_mmap_pgoff+0xf4/0x128
  ksys_mmap_pgoff+0xb4/0x258
  __arm64_sys_mmap+0x34/0x48
  el0_svc_common+0x78/0x130
  el0_svc_handler+0x38/0x78
  el0_svc+0x8/0xc

Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
Signed-off-by: Kai Shen <shenkai8@huawei.com>
Signed-off-by: Feilong Lin <linfeilong@huawei.com>
Reported-by: Wang Wang <wangwang2@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
v1->v2: add Acked-by: Michal Hocko <mhocko@suse.com>

 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6cdc7b2..c1e7b81 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1574,8 +1574,9 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 	 */
 	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
 		SetPageHugeTemporary(page);
+		spin_unlock(&hugetlb_lock);
 		put_page(page);
-		page = NULL;
+		return NULL;
 	} else {
 		h->surplus_huge_pages++;
 		h->surplus_huge_pages_node[page_to_nid(page)]++;
-- 
1.8.3.1

