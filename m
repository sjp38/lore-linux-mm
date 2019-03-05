Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C282C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 02:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325CB20684
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 02:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325CB20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB0008E0003; Mon,  4 Mar 2019 21:09:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5E428E0001; Mon,  4 Mar 2019 21:09:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4E488E0003; Mon,  4 Mar 2019 21:09:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4938E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 21:09:55 -0500 (EST)
Received: by mail-ua1-f71.google.com with SMTP id x9so1251619uac.22
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 18:09:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6GxaOD4HFEu0DEL/n+C5FjHS1rG0JY7s52jWFWxJPIU=;
        b=oYEJrQMHLTpng66ue8o9X8yL8VdrOoF79ietZpV6Gg+0xrSZEehNYQJ3CcW5/QyC1I
         NEJ/R3bUoyga7bBbCrCy8G3129Z45UcVowjFfP88pQ0N0pmuP9IoX8oyireUTKhIfQqj
         wWWzy4+RXdzv0QolzgWUUOFnQ+g2z2dNMrHRa7L9PLFGYYoBxM+K3jymZEo+ikyTh/kp
         dgDAsJFC2mw5BsA2xnYXSSaInuAr8DoqYVvrC1/Mtjg4m11Jh4/NkzX/cvvbhWKUNIi1
         CLJGQJ3EOIe6MGExsujJ2WlZnwMWGMrLaXYLX1LDFKtHILVs7gvImrKw5UkMks7KIe/u
         sVAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAWCM7mT3yunezB+s6HCczhwC6kzvOjmG5IjWHAWtlrDmJaVyiM8
	aVkIdqgGUvEuQ31eOHeNzCl4+UV2C15m4IYSyn4d5WrYAqR/Rc/DeSk/phxtVVcqKbXHeYmGtAI
	aAcm1Fr+AkQuR595gU7ZbosL+Zp/Qu7dPd7fwsD4ZtFqj5Gayp72qSsuL9PzY6f+9xg==
X-Received: by 2002:a67:7b15:: with SMTP id w21mr4284240vsc.237.1551751795147;
        Mon, 04 Mar 2019 18:09:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqz0xNFQB3sXiac03DZkMes9El+XtPGNRqk/+BCJ/iziQQbGSPbFgVru5IzcThnbynmRgHbC
X-Received: by 2002:a67:7b15:: with SMTP id w21mr4284229vsc.237.1551751794441;
        Mon, 04 Mar 2019 18:09:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551751794; cv=none;
        d=google.com; s=arc-20160816;
        b=L2GmIIjG6mTAvdu5Dl/axoI5cHzvOKaUd55rZLwZ97yAvx6vNINY8+NjbC91/lU4w5
         gdsIMohCRoZXtTN4GbnykMRQZQbk6Pp1BH1adbKJ2ylEkLAEesYSwwl7VesmKSjaEBz2
         YxpOIsvOC2idotiHImCFzFiqkZd7IhYnbhZzkvObJxUSmbSKkpmxqnrROY35Uwhujd23
         vXk7t6NoxYD00fmDBD5Hj4iSCe012Xy59T8T2ZXDVBxQNSM+HrK+PJs7nzeUYcAg6du1
         YtyxGw5D4qBwu0cC79rLg4eQVORx/Lu/LCtrGi5Q8S1F4QukBX62OoYY1F2bTTRPR5Gm
         xJBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=6GxaOD4HFEu0DEL/n+C5FjHS1rG0JY7s52jWFWxJPIU=;
        b=jLnn98+bxE4k5isHZTyDCi14DKHijKNAOgnmTmUDBAc0l6fewiDAKjOFFjDSvM7pYT
         5cwjU4YD+rGZ3/7wGGXjuzAjhjpIixbylVwvEoxMglofZhMa1Ue170D8NgEaQnEEJRPj
         +2/A2ZtUwfeEsdbqWaar+s5eIDDHnG7yEGjMn2R1hOkb5rqKii1kuyRlnFX0Ps8PqvES
         xcbiFXoLjWTglW/T/eLEDwXYMxJA+cocsDnF8S/nnyzkA7bs8HerPn9cdn7yQji7OQ5l
         nLTn3xLk+ajSr73LXQU1/AwEdlv1mFQeJNmQoCVOSNtoffiwypnEi7YHupZ0O9lZs1er
         RqaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 132si2493092vkw.45.2019.03.04.18.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 18:09:54 -0800 (PST)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 1067F11C09BB4B6424CD;
	Tue,  5 Mar 2019 10:09:49 +0800 (CST)
Received: from [127.0.0.1] (10.177.219.49) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Tue, 5 Mar 2019
 10:09:45 +0800
Subject: Re: [PATCH] hugetlbfs: fix memory leak for resv_map
To: Mike Kravetz <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
References: <20190302104713.31467-1-yuyufen@huawei.com>
 <16c7f90d-ad52-4255-f937-b585b649ce57@oracle.com>
From: yuyufen <yuyufen@huawei.com>
Message-ID: <64ab7e52-91a1-cf87-8bae-871663547d43@huawei.com>
Date: Tue, 5 Mar 2019 10:09:44 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <16c7f90d-ad52-4255-f937-b585b649ce57@oracle.com>
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


On 2019/3/5 2:29, Mike Kravetz wrote:
> Thank you for finding this issue.
>
> On 3/2/19 2:47 AM, Yufen Yu wrote:
>> When .mknod create a block device file in hugetlbfs, it will
>> allocate an inode, and kmalloc a 'struct resv_map' in resv_map_alloc().
>> For now, inode->i_mapping->private_data is used to point the resv_map.
>> However, when open the device, bd_acquire() will set i_mapping as
>> bd_inode->imapping, result in resv_map memory leak.
> We are certainly leaking the resv_map.
>
>> We fix the leak by adding a new entry resv_map in hugetlbfs_inode_info.
>> It can store resv_map pointer.
> This approach preserves the way the existing code always allocates a
> resv_map at inode allocation time.  However, it does add an extra word
> to every hugetlbfs inode.  My first thought was, why not special case
> the block/char inode creation to not allocate a resv_map?  After all,
> it is not used in this case.  In fact, we only need/use the resv_map
> when mmap'ing a regular file.  It is a waste to allocate the structure
> in all other cases.
>
> It seems like we should be able to wait until a call to hugetlb_reserve_pages()
> to allocate the inode specific resv_map in much the same way we do for
> private mappings.  We could then remove the resv_map allocation at inode
> creation time.  Of course, we would still need the code to free the structure
> when the inode is destroyed.
>
> I have not looked too closely at this approach, and there may be some
> unknown issues.  However, it would address the leak you discovered and
> would result in less memory used for hugetlbfs inodes that are never
> mmap'ed.
>
> Any thoughts on this approach?
>
> I know it is beyond the scope of your patch.  If you do not want to try this,
> I can code up something in a couple days.

Thanks for your suggestion. I agree with you. It will be a better solution.
I don't understand hugetlbfs deeply, but I want to try my best to solve 
this problem.

Yufen
Thanks.

