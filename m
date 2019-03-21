Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84CF7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:25:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43C8921900
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:25:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43C8921900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC43B6B0007; Thu, 21 Mar 2019 13:25:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4CFB6B0008; Thu, 21 Mar 2019 13:25:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEE316B000A; Thu, 21 Mar 2019 13:25:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6985A6B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:25:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f12so6116388pgs.2
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:25:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=H7gtcUyNyRf/ZDYz77uxy2MGCbJJn2bBBEbX7t0hDjQ=;
        b=HjrxzIBA+JLo3AdF+zeB4PVoGe2tozxMP9W1/oro3fvBNdGuJf0vtgwMflSIgABYmB
         ZJk2BYraHvjA86mlLKxl05g5+ukUlAjrHQ2Mx+PSc/jkLzmTsQpVkPKXRGIMn8nWxauu
         jL8Bl5la7kYppBX+geDO8SvXzC1u6R0mdXXwYrm7/iQdcJYeejnDVR3RGYYz3SeGWED7
         DWx03fsmUOKKr1a2sJv5QEg+Mmc2kt+VHUaWkh52B8njpn1iACXfmfS8l9Obwt78f8gJ
         Q4sxLuL5WioYRqhyCEHY+atZXMLp7T22kuPhYz1ad5m2xFDZBRwMXhoiIrQk8RxIezv2
         rBDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXJG5qO0aUikwSnocdd4np0sJrZoT5SQn00DJ8HKveUbrusNAPG
	kqfM4icv2tjje4UBJod8yNingPCY0T49SCKm7zGR9ewyVT4gsK+1OYVNVzUPKlUE+/wdMrLMI0N
	dmPs6+H9Kh73UAwIAx3m01AAIOUkBB/v3igyUAf/nEQFX6zinaFJqsJTWox//yoBJ6g==
X-Received: by 2002:a17:902:121:: with SMTP id 30mr4714626plb.315.1553189116064;
        Thu, 21 Mar 2019 10:25:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziJDnAYKg5kO9DTteXF1kkMgnOBgzAgssq+mTdRiuWvE9ctBEszx4yN/C8z52qz7do/GHe
X-Received: by 2002:a17:902:121:: with SMTP id 30mr4714558plb.315.1553189115081;
        Thu, 21 Mar 2019 10:25:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553189115; cv=none;
        d=google.com; s=arc-20160816;
        b=Kp+vbCnHCX1VjcJGrMXLp0IkOPiNhk2UOXujutzTrv1cTFrkEC3HquKIsM3ZP1i69+
         1TWiDnfX6D8rVdT+QGihVxeATTL4boOfrbTzlYN1ABkmIVkA5bs8bgtxXgDV8qR7n//N
         oj+iVZbGltZ5DqCryGiV6gC9+Ncfl8KIdq0aoEHCBM6AnXXxN/XyJEbLOlEMk9AbYCjk
         V8YeVCHhgSIWKdbk7gsxw/jMeVx/b/y//UI3lD6jwPBceVtkZT7AMaw22ufVkqxqNdOL
         21dnJi36OTmUG06oZ37LHlQz/IZduBRSjbBg+fd8yNUJAC83Vu5dNIjpf3+UTuXqvJnj
         nWvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=H7gtcUyNyRf/ZDYz77uxy2MGCbJJn2bBBEbX7t0hDjQ=;
        b=rF+2Isz0/li5PWv9D3kQdvpyntTY3KqGIU9v3U5jM7DlfaOjDF+kEbJ+A01fPRz74Y
         m+zLlzL8nyuVNwB2dU77rv7rdSZQdz6kjma127qAaKOP1B/DEfG5L+osV86+KCZA4F79
         zXzLUroDL3cYf0SgR6AKBk6ld5LW7OPJXB5mIFsSZXeSQRid365HdG6wgRzFQyE0ZMK+
         XvHofCyK+MgEi3Y+GnQMgewhEZUc2WK12/Zt5Nx/Qq1dNe6WQgR14syNcnDWo1djvwiQ
         tmIfz8odpQellHe7txEzYjgJfmTIN48p3Jrdz2eJ1mwxt5O9Wek6zcw/h/c+KvH0I0+1
         5B4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 73si5195014pld.156.2019.03.21.10.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 10:25:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04452;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TNITHgs_1553189110;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNITHgs_1553189110)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 22 Mar 2019 01:25:12 +0800
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
 <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
 <20190321165112.GU8696@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
Date: Thu, 21 Mar 2019 10:25:08 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190321165112.GU8696@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/21/19 9:51 AM, Michal Hocko wrote:
> On Thu 21-03-19 09:21:39, Yang Shi wrote:
>>
>> On 3/21/19 7:57 AM, Michal Hocko wrote:
>>> On Wed 20-03-19 08:27:39, Yang Shi wrote:
>>>> MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
>>>> MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
>>>> mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
>>>> right away in 2012.  So, it is never ever exported to userspace.
>>>>
>>>> And, it looks nobody is interested in revisiting it since it was
>>>> disabled 7 years ago.  So, it sounds pointless to still keep it around.
>>> The above changelog owes us a lot of explanation about why this is
>>> safe and backward compatible. I am also not sure you can change
>>> MPOL_MF_INTERNAL because somebody still might use the flag from
>>> userspace and we want to guarantee it will have the exact same semantic.
>> Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm
>> this in the other thread), so I'm supposed it should be safe and backward
>> compatible to userspace.
> You didn't get my point. The flag is exported to the userspace and
> nothing in the syscall entry path checks and masks it. So we really have
> to preserve the semantic of the flag bit for ever.

Thanks, I see you point. Yes, it is exported to userspace in some sense 
since it is in uapi header. But, it is never documented and 
MPOL_MF_VALID excludes it. mbind() does check and mask it. It would 
return -EINVAL if MPOL_MF_LAZY or any other undefined/invalid flag is 
set. See the below code snippet from do_mbind():

...
#define MPOL_MF_VALID    (MPOL_MF_STRICT   |     \
              MPOL_MF_MOVE     |     \
              MPOL_MF_MOVE_ALL)

if (flags & ~(unsigned long)MPOL_MF_VALID)
         return -EINVAL;

So, I don't think any application would really use the flag for mbind() 
unless it is aimed to test the -EINVAL. If just test program, it should 
be not considered as a regression.

>
>> I'm also not sure if anyone use MPOL_MF_INTERNAL or not and how they use it
>> in their applications, but how about keeping it unchanged?
> You really have to. Because it is an offset of other MPLO flags for
> internal usage.
>
> That being said. Considering that we really have to preserve
> MPOL_MF_LAZY value (we cannot even rename it because it is in uapi
> headers and we do not want to break compilation). What is the point of
> this change? Why is it an improvement? Yes, nobody is probably using
> this because this is not respected in anything but the preferred mem
> policy. At least that is the case from my quick glance. I might be still
> wrong as it is quite easy to overlook all the consequences. So the risk
> is non trivial while the benefit is not really clear to me. If you see
> one, _document_ it. "Mel said it is not in use" is not a justification,
> with all due respect.

As I elaborated above, mbind() syscall does check it and treat it as an 
invalid flag. MPOL_PREFERRED doesn't use it either, but just use 
MPOL_F_MOF directly.

Thanks,
Yang

>
>> Thanks,
>> Yang
>>
>>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>>> ---
>>>> Hi folks,
>>>> I'm not sure if you still would like to revisit it later. And, I may be
>>>> not the first one to try to remvoe it. IMHO, it sounds pointless to still
>>>> keep it around if nobody is interested in it.
>>>>
>>>>    include/uapi/linux/mempolicy.h |  3 +--
>>>>    mm/mempolicy.c                 | 13 -------------
>>>>    2 files changed, 1 insertion(+), 15 deletions(-)
>>>>
>>>> diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
>>>> index 3354774..eb52a7a 100644
>>>> --- a/include/uapi/linux/mempolicy.h
>>>> +++ b/include/uapi/linux/mempolicy.h
>>>> @@ -45,8 +45,7 @@ enum {
>>>>    #define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
>>>>    				   to policy */
>>>>    #define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
>>>> -#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
>>>> -#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
>>>> +#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
>>>>    #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
>>>>    			 MPOL_MF_MOVE     | 	\
>>>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>>>> index af171cc..67886f4 100644
>>>> --- a/mm/mempolicy.c
>>>> +++ b/mm/mempolicy.c
>>>> @@ -593,15 +593,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>>>>    	qp->prev = vma;
>>>> -	if (flags & MPOL_MF_LAZY) {
>>>> -		/* Similar to task_numa_work, skip inaccessible VMAs */
>>>> -		if (!is_vm_hugetlb_page(vma) &&
>>>> -			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
>>>> -			!(vma->vm_flags & VM_MIXEDMAP))
>>>> -			change_prot_numa(vma, start, endvma);
>>>> -		return 1;
>>>> -	}
>>>> -
>>>>    	/* queue pages from current vma */
>>>>    	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>>>>    		return 0;
>>>> @@ -1181,9 +1172,6 @@ static long do_mbind(unsigned long start, unsigned long len,
>>>>    	if (IS_ERR(new))
>>>>    		return PTR_ERR(new);
>>>> -	if (flags & MPOL_MF_LAZY)
>>>> -		new->flags |= MPOL_F_MOF;
>>>> -
>>>>    	/*
>>>>    	 * If we are using the default policy then operation
>>>>    	 * on discontinuous address spaces is okay after all
>>>> @@ -1226,7 +1214,6 @@ static long do_mbind(unsigned long start, unsigned long len,
>>>>    		int nr_failed = 0;
>>>>    		if (!list_empty(&pagelist)) {
>>>> -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
>>>>    			nr_failed = migrate_pages(&pagelist, new_page, NULL,
>>>>    				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
>>>>    			if (nr_failed)
>>>> -- 
>>>> 1.8.3.1
>>>>

