Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E14DC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 04:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E42792082E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 04:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E42792082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B9A06B0003; Wed, 10 Apr 2019 00:21:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7688C6B0005; Wed, 10 Apr 2019 00:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6803E6B0006; Wed, 10 Apr 2019 00:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 432676B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 00:21:09 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id k78so447041vkk.17
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 21:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=PLxPvC2vZwl/2vSFXixmIqsGdw30nNYGQO8XXcT/S7E=;
        b=cFnpfnmEfN4h0qrVwPynfawXH1uNR1E7cyjF/lC/MgCbbddIsF+9yFosF9japO84Wv
         LKdxvVb4zVL7sJAIyfjXQtlspByqTfiJNBixqmdM0p/uxcG+WlIuqj8GDrzdYFBiraRq
         Uj8s+dXemg5BloyKks9GcvoX3dZNg7bJP/tIzTQh5TKbe7lZdSMe5l1roc6Szaf5avEZ
         LGZJ7GEKD20DE5UVHuTg2iTw2z8po/51fzFhlZmnrPhAAXxpVLuGKiAXsVWFj6o40DyB
         KRMG1MLOTmZGycZyu1kr8FrcsbLCyKLCLfH0jgdpNhnS06awIC4CJ2bMO4KlPGu/Swfh
         M2VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAUfDeY+0upSlFs3kPxzQZktRjXRThqRotV1HRR3a9oHWgj3j0lb
	N+t79b9NJsdYkKPEyzNxFp3cnvHUsn3W7YfEOYsnzG3AKRjtu+j8RwdGjN99AAurz5vgNp2FX+C
	toH93sclbUutUl6lRHfWhXJiUTRmWKGE7rDw/fu4LWB2UI0ISzJ4iqq0y0SdooHkQdQ==
X-Received: by 2002:a67:f414:: with SMTP id p20mr22206366vsn.94.1554870068928;
        Tue, 09 Apr 2019 21:21:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyTX0AN8y+t5hLMKT0N4mCPQQsms1SnSr8mF8DqN7EeUpLoiSS0DgBJyKmHivQhZRxPy+/
X-Received: by 2002:a67:f414:: with SMTP id p20mr22206354vsn.94.1554870068288;
        Tue, 09 Apr 2019 21:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554870068; cv=none;
        d=google.com; s=arc-20160816;
        b=hJz+ZLv3u6vwNdlvOlFAT9jlFY7TjXe35ho3jBUMIZ/EO8PcWaWQI6d3czTyT+92JG
         BUW3/HCm5J91UX2FJQ3uy3S3Of9445VXviHghTDJftgmhnvx8+l/hX5sfpLrgoVy8u+3
         OziSqJx3b4qjnZlOgUEO5Y57oHnLum4I4v3gBbH25tK1AoWbE5HnD9vY05hf2V0AYjF3
         8X4u3+xOl/qa96POYXpYbaTeB2ofmaMExg6bkBjkGSr4hufe8nw8xLQWkb2mp+cdobsv
         nAmBx6bJENmG6bQz/oLco2OZtSu6JMzywgoLQPTqgxKuGl0WlelQUPcjiu/asfV3egcu
         oEXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PLxPvC2vZwl/2vSFXixmIqsGdw30nNYGQO8XXcT/S7E=;
        b=vmiwCthU/PdwQ2VceOtvD+Cd25K3zgUPN0HIFc7N3SvUrdL/lB9SGk4F2TvEDvyY0B
         DpHUJA6JtmS/u+wtlzDXgjbXqvKTR7w5APZ05Aj0vTs/kWjRLg4gYt8jZrZP2UVwPlJf
         nhwwWAlHVjxWhGMWay/5MPq2To/wtS0I3XZFufIV38UXxKa4yMG+fduwv6SV60DKYvQG
         F7dJU03EvP/wsnipAuPJVr7Hxr3UnyI9P+nJTD4D2Qwk19ww0eQ0r+IcBgQnErK4H/nH
         S10FR52spJ9JAePlcnb7vqj/FUV0p/g9BmMv5ZCy58S4r9QPEOHeRq1jYUf/CwYR0tJJ
         YYrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id t14si6829245vsp.341.2019.04.09.21.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 21:21:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id C31E9789D2AF0F397F06;
	Wed, 10 Apr 2019 12:21:00 +0800 (CST)
Received: from [127.0.0.1] (10.177.219.49) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Wed, 10 Apr 2019
 12:20:51 +0800
Subject: Re: [PATCH] hugetlbfs: fix protential null pointer dereference
To: Mike Kravetz <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
CC: <kirill.shutemov@linux.intel.com>, <n-horiguchi@ah.jp.nec.com>,
	<mhocko@kernel.org>, <yuyufen@huawei.com>
References: <20190410025037.144872-1-yuyufen@huawei.com>
 <e8dd99bb-c357-962a-9f29-b7f25c636714@oracle.com>
From: yuyufen <yuyufen@huawei.com>
Message-ID: <1a43c780-3ded-a7bc-391e-f85295eb942d@huawei.com>
Date: Wed, 10 Apr 2019 12:20:50 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <e8dd99bb-c357-962a-9f29-b7f25c636714@oracle.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.177.219.49]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Mike


On 2019/4/10 11:38, Mike Kravetz wrote:
> On 4/9/19 7:50 PM, Yufen Yu wrote:
>> After commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map"),
>> i_mapping->private_data will be NULL for mode that is not regular and link.
>> Then, it might cause NULL pointer derefernce in hugetlb_reserve_pages()
>> when do_mmap. We can avoid protential null pointer dereference by
>> judging whether it have been allocated.
>>
>> Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Signed-off-by: Yufen Yu <yuyufen@huawei.com>
> Thanks for catching this.  I mistakenly thought all the code was checking
> for NULL resv_map.  That certainly is one (and only) place where it is not
> checked.  Have you verified that this is possible?  Should be pretty easy
> to do.  If you have not, I can try to verify tomorrow.

I honestly say that I don't have verified.

>> ---
>>   mm/hugetlb.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 97b1e0290c66..15e4baf2aa7d 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4465,6 +4465,8 @@ int hugetlb_reserve_pages(struct inode *inode,
>>   	 */
>>   	if (!vma || vma->vm_flags & VM_MAYSHARE) {
>>   		resv_map = inode_resv_map(inode);
>> +		if (!resv_map)
>> +			return -EOPNOTSUPP;
> I'm not sure about the return code here.  Note that all callers of
> hugetlb_reserve_pages() force return value of -ENOMEM if non-zero value
> is returned.  I think we would like to return -EACCES in this situation.
> The mmap man page says:
>
>         EACCES A  file descriptor refers to a non-regular file.  Or ...

Thanks for your suggestion. It is more reasonable to use -EACCES.

Yufen
Thanks.

