Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 826FBC04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:22:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BA66205ED
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:22:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BA66205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1116B0005; Mon,  6 May 2019 11:22:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4B046B0006; Mon,  6 May 2019 11:22:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EA6C6B0007; Mon,  6 May 2019 11:22:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7168C6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 11:22:43 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v13so399561oie.12
        for <linux-mm@kvack.org>; Mon, 06 May 2019 08:22:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=ovnisgPkJfTYzk9qsN4hmpmsB6v1xo9sAuqJPJLYGgQ=;
        b=hui4BaANh2r3RJKtFpHZ6+rwG2+WrKPB1+mVIu7nB2nTbRwE8si4SFwjMt7ZGkybVv
         5d4lIxePE6q0ELvgAF7uPL8a8Sp74r0qKpQVgvtfxt3uRSVuXkHBdSwGBeXi59Ehqu8Z
         k9vTLQ8sROzAIrpCIDRr1ObsaLDEl7wMO84TstMC1n1fWF9mYmnDT7FPISzMAdoAXrm6
         HXKWnsmhEW52XgSNuzlOaA1IOBgSuBGg5No/zKu4NO790SXEmnmDc6Fd37s7pvvNykcI
         +0EqLs37VqMlsJSzeVQ4pmVkJalPMbwDZSaysfKIQPfQKFf5Rvo5jBsSB30QDEEW54EF
         GsHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
X-Gm-Message-State: APjAAAVufre5xADaP+l5ZsqY4nwn7LwIS6ZIlTO0abcJvRXoJ4LUXv+z
	61eUNnW4bX1X3xrgOXkwc/lb5RB7anDwFCzZexxdXL1ngM9FN9H7eDwSUInNmhEYb2GdDjTHUEu
	v+TWAMedZNr0LbXknI/TrILiAs8p5N8PWKh5LmPgbe2wp1+ML7lmPQWK4NMTHwYtC/A==
X-Received: by 2002:a05:6830:10d5:: with SMTP id z21mr17335192oto.355.1557156162932;
        Mon, 06 May 2019 08:22:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz00Gq3q0H/aFzXgMbS/FFrI3JdPY5cr97uH95UrmFTW5aE0OyiEEHf/J2fMgJidAHhYZB/
X-Received: by 2002:a05:6830:10d5:: with SMTP id z21mr17335130oto.355.1557156161967;
        Mon, 06 May 2019 08:22:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557156161; cv=none;
        d=google.com; s=arc-20160816;
        b=HqnOD5vh+jQcjAyBUX8TYjKodBAqoW91f5Y1RWThuXyxGJnADOpq6s7jJOMpGxMkgM
         /8PcjMOlq/zdF2SSyV7VkV1zDQpONZ5ING/z/8DcLHN7ds1OnJwLZjeHKk1iNRWKn6bU
         ginXfET+Caa8bY3KNaLpxpygtBZuMUethchYjKwXzczoaW+WdefhpdieWHHurgJwQOKA
         LVTEO5fRwLyjvZZiNqrBKdZkaJIgfp4ni231G+/LgIEQ3T8sBm7nGku1vzu9qxAL8orH
         b7H4GQGIXwbFkXv3dETszWWY5/D+9dKnYOPlJGDcmk79DtD7QgejTervtaDuV//wqJWJ
         3y8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=ovnisgPkJfTYzk9qsN4hmpmsB6v1xo9sAuqJPJLYGgQ=;
        b=jjbaFXpb1555U5qH8gjoXgkhyt5FRgcqvsQ8crNA2lek0YJogOrCMn3WlnvfhheFbL
         ewykHrKd/f7lrwVK5aoqinaLYuZx/x4P3yafW0Fzd3y2u3KLOyn6hj+pRFXJqd+z9h3B
         VjsXyHFmM5m5aXAzwNG0QeOkRHj3qpEGFOs0wjhaHHvCz2AEaTQp2XaJ4JBR3tb0QvT1
         Jscq/IJj5liyBFe8fpOZrOlcqWgR8vGrZUJeTm92Az/LNAG1G++bFI5rHX9RP3ST2cYD
         tVo6HQLrAOalldD7I4DEJZQTH6NpxPXnbmrC1RxpBnGCk1FKiVrVEZ418VrwpakoKYGQ
         SM1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id h14si6713018oti.285.2019.05.06.08.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 08:22:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 506865A2C282EF52340D;
	Mon,  6 May 2019 23:22:36 +0800 (CST)
Received: from [127.0.0.1] (10.184.225.177) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.439.0; Mon, 6 May 2019
 23:22:27 +0800
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
To: Michal Hocko <mhocko@kernel.org>
CC: <mike.kravetz@oracle.com>, <shenkai8@huawei.com>, <linfeilong@huawei.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <wangwang2@huawei.com>,
	"Zhoukang (A)" <zhoukang7@huawei.com>, Mingfangsen <mingfangsen@huawei.com>,
	<agl@us.ibm.com>, <nacc@us.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
 <20190506142001.GC31017@dhcp22.suse.cz>
From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Message-ID: <d11fa51f-e976-ec33-4f5b-3b26ada64306@huawei.com>
Date: Mon, 6 May 2019 23:22:08 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190506142001.GC31017@dhcp22.suse.cz>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.225.177]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon 06-05-19 22:06:38, Zhiqiang Liu wrote:
>> From: Kai Shen <shenkai8@huawei.com>
>>
>> spinlock recursion happened when do LTP test:
>> #!/bin/bash
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>>
>> The dtor returned by get_compound_page_dtor in __put_compound_page
>> may be the function of free_huge_page which will lock the hugetlb_lock,
>> so don't put_page in lock of hugetlb_lock.
>>
>>  BUG: spinlock recursion on CPU#0, hugemmap05/1079
>>   lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
>>  Call trace:
>>   dump_backtrace+0x0/0x198
>>   show_stack+0x24/0x30
>>   dump_stack+0xa4/0xcc
>>   spin_dump+0x84/0xa8
>>   do_raw_spin_lock+0xd0/0x108
>>   _raw_spin_lock+0x20/0x30
>>   free_huge_page+0x9c/0x260
>>   __put_compound_page+0x44/0x50
>>   __put_page+0x2c/0x60
>>   alloc_surplus_huge_page.constprop.19+0xf0/0x140
>>   hugetlb_acct_memory+0x104/0x378
>>   hugetlb_reserve_pages+0xe0/0x250
>>   hugetlbfs_file_mmap+0xc0/0x140
>>   mmap_region+0x3e8/0x5b0
>>   do_mmap+0x280/0x460
>>   vm_mmap_pgoff+0xf4/0x128
>>   ksys_mmap_pgoff+0xb4/0x258
>>   __arm64_sys_mmap+0x34/0x48
>>   el0_svc_common+0x78/0x130
>>   el0_svc_handler+0x38/0x78
>>   el0_svc+0x8/0xc
>>
>> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
>> Signed-off-by: Kai Shen <shenkai8@huawei.com>
>> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
>> Reported-by: Wang Wang <wangwang2@huawei.com>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> ---
>> v1->v2: add Acked-by: Michal Hocko <mhocko@suse.com>
> 
> A new version for single ack is usually an overkill and only makes the
> situation more confusing. You have also didn't add Cc: stable as
> suggested during the review. That part is arguably more important.
> 
> You also haven't CCed Andrew (now done) and your patch will not get
> merged without him applying it. Anyway, let's wait for Andrew to pick
> this patch up.
> 
Thank you for your patience. I am sorry for misunderstanding your advice
in your last mail.
Does adding Cc: stable mean adding Cc: <stable@vger.kernel.org>
tag in the patch or Ccing stable@vger.kernel.org when sending the new mail?

You are very nice. Thanks again.



>>  mm/hugetlb.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 6cdc7b2..c1e7b81 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1574,8 +1574,9 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>>  	 */
>>  	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
>>  		SetPageHugeTemporary(page);
>> +		spin_unlock(&hugetlb_lock);
>>  		put_page(page);
>> -		page = NULL;
>> +		return NULL;
>>  	} else {
>>  		h->surplus_huge_pages++;
>>  		h->surplus_huge_pages_node[page_to_nid(page)]++;
>> -- 
>> 1.8.3.1
>>
> 

