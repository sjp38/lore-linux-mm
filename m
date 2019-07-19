Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E39C3C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93E272184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93E272184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46C5F6B0007; Fri, 19 Jul 2019 12:18:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7836B0008; Fri, 19 Jul 2019 12:18:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E4AA8E0001; Fri, 19 Jul 2019 12:18:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E66FB6B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:18:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g18so16080205plj.19
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Lgasrr4dlemG2e4tlDTPLP+BGdKOUIcNlcjcmGzx0EQ=;
        b=r4AlPcDhCTO5s2dPcjCza/Ri4djcdHu3Qv+Rgo8KFAZ+pT08Qedtdujjq3C4RR6agg
         tBW8LZhRYNpyrtzEE1F3Jx22OmY9Wq38PhsmhB9Ux3SdpfSjtqQBGBe7zGHHPUwZR3Ej
         DxIvOxE90+6hHKPX1tHlv3Tg4Yp4l+iBFRgtYrlOz3DZvLhKwBfsBV6bzeuvBvtSEatw
         6JSAsAJ4rmv+uK1vD4XT3crsT0NDx1xLsanjzsZusv5QmmNVS3C1gLgPKWiOpC9GuIVo
         9KOgcJfT3UnghvJXuY1QF8POl+j0ytRHCCcY375sEi3U59JPY9Afy4Z0YRShjVDsjVAM
         MfZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWx1PSEWn4hQmYEzb21o8XWJWT8UR8Jievi5VT3n0lyY6oyQat6
	Eg48ZmtMf9379NkNIxmnxIFRvPMckRhrRv88zZAEGkQw22Tnejqg4IzrLTDKydCHf3bPUCtUj/v
	iMvNaMVt7YYEk+w5UbguSi5DK1a85gHeH+kPHxXjZfUa9qMNdKe2G8X9JCmy9Sutrtg==
X-Received: by 2002:a17:90a:bd8c:: with SMTP id z12mr58963163pjr.60.1563553131513;
        Fri, 19 Jul 2019 09:18:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCXu49LmG98rsESP6BF29NasUV+D2AEqvEwcbSVrwbZ5JofiUGMSSul/EJSQ3fXLZJSuuz
X-Received: by 2002:a17:90a:bd8c:: with SMTP id z12mr58963073pjr.60.1563553130576;
        Fri, 19 Jul 2019 09:18:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563553130; cv=none;
        d=google.com; s=arc-20160816;
        b=QFDCU7ImelAFzSAPxZ0dKAEIS4abcLk5480/3xCHC2GvzF/NHUZmqXH/RS5lQq3FuW
         6M662KPTuYT1TGdCFjxQHqY3aWP9L4cseSkdSn8WSeZzNSxEZiDwqWibNOBfdlZF66uk
         wOgCyDy6VsYpvU40tJ0qcAFeT6NR7GSDtVuXwH7wJSJYgxV1YeUJ2mZjOirj4ijeq1Bd
         c8lshI/oY7jm4wuKWk7un8QwBxKfgbGMzUZdTvFLEs9Yu3nSNFOOxYBMwCUQLnaC5Xrj
         GFEK4iQU2JqTKYXbplT6CII8b6AF1aCJjVEQVHl2Y96opqoCN9vcCkuIUXaAn2LaSZMH
         2SBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Lgasrr4dlemG2e4tlDTPLP+BGdKOUIcNlcjcmGzx0EQ=;
        b=s0/ZCb+mLbaigM8Q6VrwYDgvEknGYu8v6ek03FKCh9nFjYBS3T5jJ1uGAKJkdwjQcd
         YsT6X7/+bwLDG7jNjGSE22MWUUikwplSKzOjophUrdkSMMowZ5r+f8AmkHQmxYO1BwRO
         5bwdykcfT4icEtTovI5+rkHBhDj9JCE2MlFVuQe0NqNxd6syiSxscSmHf4r896ohW22u
         immljdhc5Dlzx1kakBy4pkX5NPg5U7wOlKyMthY26MbWiwt6FvWzBzBMPOc4cxNUlJuV
         E7uU8QgTnme6xMR1r2RxnVkeHcoOyf4s50heojWgVVp2xOKmxMUeTc9v/Ss24Xe6R8j9
         Rjjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id k186si378467pgd.229.2019.07.19.09.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 09:18:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TXIf.k8_1563553123;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXIf.k8_1563553123)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 20 Jul 2019 00:18:45 +0800
Subject: Re: [v3 PATCH 1/2] mm: mempolicy: make the behavior consistent when
 MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org
References: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563470274-52126-2-git-send-email-yang.shi@linux.alibaba.com>
 <c1e2b48a-972f-3944-bc17-598cb81a6658@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <081eeac9-f7a3-a2e6-480a-9f527f378591@linux.alibaba.com>
Date: Fri, 19 Jul 2019 09:18:41 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <c1e2b48a-972f-3944-bc17-598cb81a6658@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/19/19 5:48 AM, Vlastimil Babka wrote:
> On 7/18/19 7:17 PM, Yang Shi wrote:
>> When both MPOL_MF_MOVE* and MPOL_MF_STRICT was specified, mbind() should
>> try best to migrate misplaced pages, if some of the pages could not be
>> migrated, then return -EIO.
>>
>> There are three different sub-cases:
>> 1. vma is not migratable
>> 2. vma is migratable, but there are unmovable pages
>> 3. vma is migratable, pages are movable, but migrate_pages() fails
>>
>> If #1 happens, kernel would just abort immediately, then return -EIO,
>> after the commit a7f40cfe3b7ada57af9b62fd28430eeb4a7cfcb7 ("mm:
>> mempolicy: make mbind() return -EIO when MPOL_MF_STRICT is specified").
>>
>> If #3 happens, kernel would set policy and migrate pages with best-effort,
>> but won't rollback the migrated pages and reset the policy back.
>>
>> Before that commit, they behaves in the same way.  It'd better to keep
>> their behavior consistent.  But, rolling back the migrated pages and
>> resetting the policy back sounds not feasible, so just make #1 behave as
>> same as #3.
>>
>> Userspace will know that not everything was successfully migrated (via
>> -EIO), and can take whatever steps it deems necessary - attempt rollback,
>> determine which exact page(s) are violating the policy, etc.
>>
>> Make queue_pages_range() return 1 to indicate there are unmovable pages
>> or vma is not migratable.
>>
>> The #2 is not handled correctly in the current kernel, the following
>> patch will fix it.
>>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
>
> Some nits below (I guess Andrew can incorporate them, no need to resend)
>
> ...
>
>> @@ -488,15 +496,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>>   	struct queue_pages *qp = walk->private;
>>   	unsigned long flags = qp->flags;
>>   	int ret;
>> +	bool has_unmovable = false;
>>   	pte_t *pte;
>>   	spinlock_t *ptl;
>>   
>>   	ptl = pmd_trans_huge_lock(pmd, vma);
>>   	if (ptl) {
>>   		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
>> -		if (ret > 0)
>> -			return 0;
>> -		else if (ret < 0)
>> +		/* THP was split, fall through to pte walk */
>> +		if (ret != 2)
>>   			return ret;
> The comment should better go here after the if, as that's where fall through
> happens.
>
>>   	}
>>   
>> @@ -519,14 +527,21 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>>   		if (!queue_pages_required(page, qp))
>>   			continue;
>>   		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
>> -			if (!vma_migratable(vma))
>> +			/* MPOL_MF_STRICT must be specified if we get here */
>> +			if (!vma_migratable(vma)) {
>> +				has_unmovable |= true;
> '|=' is weird, just use '='
>
>>   				break;
>> +			}
>>   			migrate_page_add(page, qp->pagelist, flags);
>>   		} else
>>   			break;
>>   	}
>>   	pte_unmap_unlock(pte - 1, ptl);
>>   	cond_resched();
>> +
>> +	if (has_unmovable)
>> +		return 1;
>> +
>>   	return addr != end ? -EIO : 0;
>>   }
>>   
> ...
>> @@ -1259,11 +1286,12 @@ static long do_mbind(unsigned long start, unsigned long len,
>>   				putback_movable_pages(&pagelist);
>>   		}
>>   
>> -		if (nr_failed && (flags & MPOL_MF_STRICT))
>> +		if ((ret > 0) || (nr_failed && (flags & MPOL_MF_STRICT)))
>>   			err = -EIO;
>>   	} else
>>   		putback_movable_pages(&pagelist);
>>   
>> +up_out:
>>   	up_write(&mm->mmap_sem);
>>    mpol_out:
> The new label made the wrong identation of this one stand out, so I'd just fix
> it up while here.

Thanks, will fix all of these. I will resend this patch along with patch 
2/2 which has to be resent anyway.

Yang

> Thanks!
>
>>   	mpol_put(new);
>>

