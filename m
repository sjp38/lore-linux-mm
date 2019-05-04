Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C93B0C43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 12:29:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93C53206A3
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 12:29:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93C53206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23DC16B0003; Sat,  4 May 2019 08:29:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C5E66B0006; Sat,  4 May 2019 08:29:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08E126B0007; Sat,  4 May 2019 08:29:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0D126B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 08:29:06 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 70so4235149otn.15
        for <linux-mm@kvack.org>; Sat, 04 May 2019 05:29:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version
         :content-transfer-encoding;
        bh=5CF861vbroC8j4oMUy/SLxFTNXHSvGvKgdiSSy4B4Pc=;
        b=cyEPUx3nuqgn1XwYJjBcfE4SUCfq0FwkdMjb0xvq9GJOJHflQMV+wh8skgmolqllG4
         DThhFcBfE1uA6iKqIRkkhw0uq+aC2GbiF2ooC1MS8nAGmjwFKzMdXs1rxUnXFtlpM2AB
         YuhzK6Pt1lGqmPSNpVXnaWJNGFzR7gcXyhRulLHW0OtnSVwUQ9iDAtvuRrj2daS5+4E+
         A20klnj+FTuzmg9ZwVPatSjiRxUr9AXBEevDTVAUJQWZjNHpTFhk4723xc8nn+9P1G2s
         ZQumGnJpg8u1Odj1sRXem7OzF5zKfKwXPsCddlp0M2K+GEOK4qXuDf/ByYPRm2fHQh+A
         6ClQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
X-Gm-Message-State: APjAAAWF7Twuwps0SjjgJYtkoL4BJR2PCh47gCCWCYHSaq1cH2IeMMNB
	7t5UlQ4Spn49wZyC6hg5V0tL3IIll5oNMj7Vx/G1YFL6d81qkKOOJ/6/pVF8eK31TqzDatlOaU2
	YKx80GY2Yrjrm/iGr85VumnJFGcGhy7kWBNqoH9spIfcoPc5SvVKoFvDFq3U8n1Wf2Q==
X-Received: by 2002:aca:210e:: with SMTP id 14mr903631oiz.90.1556972946483;
        Sat, 04 May 2019 05:29:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHL6irokjls9F/eE8S9Ga50cTi7cxEObtTZFc0k42Mr5WbbPd/w5Q3soM2Urfii4//FseU
X-Received: by 2002:aca:210e:: with SMTP id 14mr903590oiz.90.1556972945324;
        Sat, 04 May 2019 05:29:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556972945; cv=none;
        d=google.com; s=arc-20160816;
        b=LB3ddr9/smeBA4zLFmdzY3xdZvzhw+oTCaCdAaqjF63QJgsDs7/g7TL4Wwx5GoqIv/
         ezF3TkTA6YoWnQ3Uo3wcvJxx0oYu2tRXJ2oCg5qFVkqYRziCEi/+ehv2OupzjYTGyRb0
         6jNDsGr7YavPSzIBBAgL+GN5+cOl928foBcBL4Fi0c9D6Nn0TOTLnK5rzwTR3k0u4RWh
         Iu4I2oA1qogRojrBGPXStNezYrXMfTAUt1++a0wYiY8NTzSiq9s4ghrz7JcA9Fb5fkNM
         AaJ/clzMfILyTa2j1MCXDW6Qe64WIrZGr2Ut4ShRH0cASA/WS8PLYI/vVwTFM2z7lCtO
         mEnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:date:message-id
         :subject:from:cc:to;
        bh=5CF861vbroC8j4oMUy/SLxFTNXHSvGvKgdiSSy4B4Pc=;
        b=ZMnwkBRYimd6tfFoeBH0R07XO/Zedy6q8/R4iJqS9Ubmfa5aiMoB+HHdGoarK/MBc7
         l8ipSEprLTgXDbl/WTjgJEn59O70F+oT7aQyE/BP2N41j7yuKe2UEolzBg14dzOxIs2v
         kL/9AolBkp1nD7ikmjfKFZ0BktUNL6zu+ud5FfeKbdmjjyeMXrlK9UxNAfD+49P+6sRo
         z8Jka13YHqiVNzwPAZsf5/w0nz4NZW4UQEaAUyQmzPIa9OXODyqEcj4NtF7ctl2Xu/PI
         jFqXq4gpgpAoH/S28ZuXJFzCJVmf4LxSFX12kQMUWH/HZr6YabuQLXdRwtDiPlR6dRMC
         epBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r4si2828595otk.240.2019.05.04.05.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 05:29:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id EAC5DC8686F7E88E918E;
	Sat,  4 May 2019 20:29:00 +0800 (CST)
Received: from [127.0.0.1] (10.184.225.177) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.439.0; Sat, 4 May 2019
 20:28:54 +0800
To: <mhocko@suse.com>, <mike.kravetz@oracle.com>, <shenkai8@huawei.com>,
	<linfeilong@huawei.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<wangwang2@huawei.com>, "Zhoukang (A)" <zhoukang7@huawei.com>, Mingfangsen
	<mingfangsen@huawei.com>, <agl@us.ibm.com>, <nacc@us.ibm.com>
From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Subject: [PATCH] mm/hugetlb: Don't put_page in lock of hugetlb_lock
Message-ID: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
Date: Sat, 4 May 2019 20:28:24 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
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
---
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


