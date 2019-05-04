Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7CDDC04AAA
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 13:01:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AAC6205C9
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 13:01:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AAC6205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4A926B0003; Sat,  4 May 2019 09:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB816B0006; Sat,  4 May 2019 09:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C4466B0007; Sat,  4 May 2019 09:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50C9C6B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 09:01:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s21so6744204edd.10
        for <linux-mm@kvack.org>; Sat, 04 May 2019 06:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mGMC4gp0OTH2/O/Fp82IT1KL0U0wtD27/na2szo7BEc=;
        b=XtBAfKNvsVS0GTfM6UPuosn9uIFoZLdlERp3796SrlICSbLXvSu9FWD+1+PMv/EDqx
         xiEm54hEksS0um7JG/wdlBKlX3VsA6PPM1IwBLVxW5eDtIaYZsOk30EkZD02D4r6LZP4
         LvJfSoquHxC7qyjPQo1OM572Sh0GO3Pke53Z6dXWjS9V4QQQwVtm6b6OmvUH5gS2YWuq
         oCKrCqrmNP/d3Uj9DrQSHtP+wtAeDF5C+6Cl3sq+10pLGr2lYTJR+o0D5HCk+/psq6fL
         b0DT7gB5zpz+AVhPPw88xIlVDVW42w/Z9IRB0Xf+iui3blc+0witFafSSvWn7/UtqXvR
         HGWQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU3s6+0nHv/fmbFJNEM0eR8OYZg+3Qy16dc04HdwJ2w7TJrsbUS
	2pzFcN4ve++auQMgWBNi+iYtaQckIzzJrghVazWNSfmFmmlm98HTjjcS+6BwBzFGTjasbjgN+kS
	ulRIl2/rIw8P8upon+NUBReIGJEOf9CRpWi7TrYw+nd7xQ6NYlZXsjnsr9q7cGVM=
X-Received: by 2002:a50:9266:: with SMTP id j35mr14937465eda.60.1556974902871;
        Sat, 04 May 2019 06:01:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMFzThxcL3VQ02yWklCAl+2J/TYSP4L43H6Q2mH77sPWfc7T98neG2Yr4oHZiNKlxDBez1
X-Received: by 2002:a50:9266:: with SMTP id j35mr14937319eda.60.1556974901682;
        Sat, 04 May 2019 06:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556974901; cv=none;
        d=google.com; s=arc-20160816;
        b=AK8+LbmWEyMJDdb/LTMsa0mbaKY3GmvG6Wo3mJpwtSAI6uAyq5DjTs31xYuRZ9m3ey
         YYR/SZ2jZAnvKA4xRbWm0kmCjDD6cOaC9DjnAClmTXqRk4l2gzrJ0T07Pi/OrElHfYhj
         KiUkvy6JKFoTSxnm8rgPRXP6mHcU4WUQGfaGBpHPmkZyctSXl9qfXO9ygR+BsaMSSdO+
         XTwY9Edk2ntJh04I4dWfw6V8xP9XcPvOcm29HcV5f6Yqf/m8ZGo1UFx2hWcp2gREkJqY
         PxAFLr7+UCucjPD38W1siTbxFGvrzx7N9ZBL8RuPOndcJKWe/jDEAhbr8Y686z9cjXxs
         Ejdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mGMC4gp0OTH2/O/Fp82IT1KL0U0wtD27/na2szo7BEc=;
        b=kGCmjpnRj/EgeiaNdB8zu7eIK/8xoYCVbka0eNDeiZVJIPdNZl6Ix2OlXiDlkXcki7
         dEfMjkIHa3n8WZ0id2UrEHFlmhwqlqq8LQ/0mK6urjyib+jgTsmkl7NcHou2mmWH3m7K
         DRbA9LtWqfCdksjfU6SN+BZZvzimm+9R+vBzfUpzGfIvvtqD3Niu2O8QK528MjjwX0d9
         jcsgAsIIUIFA6LRZyIoyjO3zVTfx/MMqRF4bC0hBetSiXwMXq4RK4Aa+QWjvYuoekIIl
         JWXfWYvZ2BAr5csBZfxYMRMjrfzslVyH/dBKxpb2eUTFbrkTJO6vDD/Tlgj2SL60Cbf6
         1yaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si2763345ejm.334.2019.05.04.06.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 06:01:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DEE15ABF0;
	Sat,  4 May 2019 13:01:40 +0000 (UTC)
Date: Sat, 4 May 2019 09:01:37 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Cc: mike.kravetz@oracle.com, shenkai8@huawei.com, linfeilong@huawei.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wangwang2@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>,
	Mingfangsen <mingfangsen@huawei.com>, agl@us.ibm.com,
	nacc@us.ibm.com
Subject: Re: [PATCH] mm/hugetlb: Don't put_page in lock of hugetlb_lock
Message-ID: <20190504130137.GS29835@dhcp22.suse.cz>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 04-05-19 20:28:24, Zhiqiang Liu wrote:
> From: Kai Shen <shenkai8@huawei.com>
> 
> spinlock recursion happened when do LTP test:
> #!/bin/bash
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> 
> The dtor returned by get_compound_page_dtor in __put_compound_page
> may be the function of free_huge_page which will lock the hugetlb_lock,
> so don't put_page in lock of hugetlb_lock.
> 
>  BUG: spinlock recursion on CPU#0, hugemmap05/1079
>   lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
>  Call trace:
>   dump_backtrace+0x0/0x198
>   show_stack+0x24/0x30
>   dump_stack+0xa4/0xcc
>   spin_dump+0x84/0xa8
>   do_raw_spin_lock+0xd0/0x108
>   _raw_spin_lock+0x20/0x30
>   free_huge_page+0x9c/0x260
>   __put_compound_page+0x44/0x50
>   __put_page+0x2c/0x60
>   alloc_surplus_huge_page.constprop.19+0xf0/0x140
>   hugetlb_acct_memory+0x104/0x378
>   hugetlb_reserve_pages+0xe0/0x250
>   hugetlbfs_file_mmap+0xc0/0x140
>   mmap_region+0x3e8/0x5b0
>   do_mmap+0x280/0x460
>   vm_mmap_pgoff+0xf4/0x128
>   ksys_mmap_pgoff+0xb4/0x258
>   __arm64_sys_mmap+0x34/0x48
>   el0_svc_common+0x78/0x130
>   el0_svc_handler+0x38/0x78
>   el0_svc+0x8/0xc
> 
> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
> Signed-off-by: Kai Shen <shenkai8@huawei.com>
> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
> Reported-by: Wang Wang <wangwang2@huawei.com>

You are right. I must have completely missed that put_page path
unconditionally takes the hugetlb_lock for hugetlb pages.

Thanks for fixing this. I think this should be marked for stable
because it is not hard to imagine a regular user might trigger this.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/hugetlb.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6cdc7b2..c1e7b81 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1574,8 +1574,9 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  	 */
>  	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
>  		SetPageHugeTemporary(page);
> +		spin_unlock(&hugetlb_lock);
>  		put_page(page);
> -		page = NULL;
> +		return NULL;
>  	} else {
>  		h->surplus_huge_pages++;
>  		h->surplus_huge_pages_node[page_to_nid(page)]++;
> -- 
> 1.8.3.1
> 
> 

-- 
Michal Hocko
SUSE Labs

