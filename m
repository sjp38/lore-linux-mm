Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DED5C46470
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:20:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AA8821655
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:20:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AA8821655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97EA76B0007; Mon,  6 May 2019 10:20:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 954D66B0008; Mon,  6 May 2019 10:20:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81E706B000A; Mon,  6 May 2019 10:20:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35CA66B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 10:20:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m57so12317197edc.7
        for <linux-mm@kvack.org>; Mon, 06 May 2019 07:20:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qjpVlu0JNb8BZoTPQY/+lJhBCUQ0MV0Fx+CMtSKL6i0=;
        b=n92hBS78irOJrF5UBjv88lvfbxFo8BRiSXN5WMvd0YpC5N774f0U7mEM+MPFbWt/jJ
         Zh0+uRn/BlheMd2bsTep1x4lmf5Wk1xz+pX+Yq7frXDKR0x4AWJJJzMdkjORsabcRIyU
         RJ1AahjSDEY7vZq/Qdq/P+LYPI88oItn5pWh3ZVkItzJMoxKEyNSYQ6v4BiNeJPvAq7D
         tmNGAj1cjOgv1ZeYptjzDr8QJafkxZaTcTXcWXKO9umWiJN4q4xy7qVCcmyuZE9kqxj4
         oRPiCukZVoEFdXGu+Um6zFKUOVj8jtPuUfqGY7gFDhlA/WDVxKcHluiq3ZD8UZVFD91j
         Uh+A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWR0JnhqdIKkB293nX5m8ZVSrc6B4Nc2oLJoy/TeIWZfe68J6hH
	YmW6mEcFd9Szd9lpWC0zfalMtbkI0q5pmiQe6KzTTdfDspxhdZzDrCEk2PJb857lt6O3vh/pkjm
	InZ7JJaCIcvb/H67lnuwxmcsGaB1uGnbHZxK4Atnnke4Wm2eaWIhYE5wvHKSqqiI=
X-Received: by 2002:a50:b19a:: with SMTP id m26mr26660636edd.243.1557152404763;
        Mon, 06 May 2019 07:20:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNZZlN4dnLAZ4PA9ofJl4ZGKELtHQGd7KmrFrJic/yrAx0la234cibAyJCrlyQNI70LBpd
X-Received: by 2002:a50:b19a:: with SMTP id m26mr26660525edd.243.1557152403789;
        Mon, 06 May 2019 07:20:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557152403; cv=none;
        d=google.com; s=arc-20160816;
        b=enVNfCtjykBinmH9pJLR/oNGu+Q6Et3IcAJy5WpD6KFWJ7PYu+TuCOx5MambwMKJcc
         WfZ8MKPepfRd5gr1HxrV5tBMXDzDZKXoElh8cY8Cuw+Ao2tbBrkSMUsoHemqxId5nq6y
         e547DwxD8Bj0w7aHCtRsYrK0p1YWHGx22juOTjPdGCQHm1kLCpXJLQh6j56OTF0nxf0a
         56eaWue/VPTDSCT3AukUeeDv6jCM9tfPEfml+cPv3g0iJUm8v54wxyEW/fUnANno901V
         gPWM7YT79KPibj96LnhIMgLoKHtU7G1k2ZqWcQum0BFbduIivdN3AowB4L+1nckbVfAO
         niYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qjpVlu0JNb8BZoTPQY/+lJhBCUQ0MV0Fx+CMtSKL6i0=;
        b=QAutvlm8+PNHNzxsh5+7FvNU2f+7BJYoFS+4B24SYDmsYbP2RiKT0JZly8CJoVLtgg
         2OXGZUFR59BDyBPlbLq/+ya7u8+oIEMJF+xvmVyeo+OK7V+5FbUO66km5OYIamBiDp8z
         X9Yxcxp27Y7fSHVi011tjGDxzWiaxPdimkjWzTX2A1kCnyYXOXx2Q5z7ZjqQA5ulepZy
         VPX4TfTxAVu3UkHV0zP/pCBeu8YpzI/RGISDd80XUAiXAwN3XwehnwgGMeO+5Dd55t34
         kleC2k2FKZN7xlGV7gtuJqh0VyF3jU/lH9etmM1XScIC/BlphUCFLQngS8Qs2uQIqC5c
         Kowg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ay4si3637396ejb.102.2019.05.06.07.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 07:20:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EE89EAE18;
	Mon,  6 May 2019 14:20:02 +0000 (UTC)
Date: Mon, 6 May 2019 16:20:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Cc: mike.kravetz@oracle.com, shenkai8@huawei.com, linfeilong@huawei.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wangwang2@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>,
	Mingfangsen <mingfangsen@huawei.com>, agl@us.ibm.com,
	nacc@us.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
Message-ID: <20190506142001.GC31017@dhcp22.suse.cz>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 06-05-19 22:06:38, Zhiqiang Liu wrote:
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
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
> v1->v2: add Acked-by: Michal Hocko <mhocko@suse.com>

A new version for single ack is usually an overkill and only makes the
situation more confusing. You have also didn't add Cc: stable as
suggested during the review. That part is arguably more important.

You also haven't CCed Andrew (now done) and your patch will not get
merged without him applying it. Anyway, let's wait for Andrew to pick
this patch up.

> 
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

-- 
Michal Hocko
SUSE Labs

