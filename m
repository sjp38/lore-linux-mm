Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18394C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:32:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C49F72175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:32:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C49F72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55E526B0003; Wed, 20 Mar 2019 14:32:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50EFC6B0006; Wed, 20 Mar 2019 14:32:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FE4C6B0007; Wed, 20 Mar 2019 14:32:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8A6B6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:31:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h15so3297625pfj.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=QoKnnP/Fgjvk/zKPmZ8xtxutDW9Qi0e7oXIQMpKJF4Y=;
        b=Mh2h8yGLMsBmiTJFu2uY2aD5hCD2FSMCQRS+P4DMkmUst//eD3yTWDF3jMn8aVJCaC
         iRgbsif0R7VIsxglm2TYIt8Uec4QTWB5IzsBHNKmzjskcVUFMSZh0V//CdKiLyTI8VRJ
         1vtnFwLWuxdKhsJTf2D6b3YD243UJhKbY9VLWHbSAsntefnhyNYISQDCsTIvWyIm2Ycb
         XxIiC5/tGIQeffJewQpDtOFyqXSF1L//QPnih3YrWlqLtgecdNXCcIUNch3GKM9nUiFq
         BBA+noxSRgr4bn8KT8q1IRq29VzhLkDVVNwMb0L4bDBOaCYXpxxABXfoenbuwZVSTAJd
         PUSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWAIwPDFKkyJdwCTaU9z867Pyc6hw3Y9JsfB875ypdTFenw8mAQ
	Ug2mv1UQn5TQVRa2M53O5gnXOdPUTmPQjoD3DCJQNSLQ7W8kp5pv0IbzNu7zyzskvcOGEJlT9Tk
	h0tK/phMn9/6YDVDo8FSn1QY1L6qqddjPBqWoHeMD2KriIXfGeTaothMutmYybxcDpg==
X-Received: by 2002:a63:2bd5:: with SMTP id r204mr8864528pgr.48.1553106719568;
        Wed, 20 Mar 2019 11:31:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweDWTvq/uZoSzYJTYgpBpHmOi6dx4XfZa4qcnj3qKTZUTjD3L/expxUCP9E6oMQqZDjKnc
X-Received: by 2002:a63:2bd5:: with SMTP id r204mr8864457pgr.48.1553106718706;
        Wed, 20 Mar 2019 11:31:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553106718; cv=none;
        d=google.com; s=arc-20160816;
        b=KK6G4Jge/KUHdLRmKuvPa1EUFyyrE+Unmamcrd60bE4ca2Hj2uqJAcUz2p4MhrBh1g
         ytnSghJLshY+RkCpNB6lkHuelMm76BtuQHs60p212mJESug00kP4Fyn6SvnPwSQy99qo
         xUWfSFioEQmtuH6xfISdJwmP8ATz2WxhZ4qbqjmBDQQDBV+/YGuYj+KniAHR7ck9o86m
         ObegzvkP255wluzS08kYEmCg+ilzpIV27ZuQ7u10cr0Bgs6DfyvboJoeOEJksiVRwmJd
         s0iOFP3vjxl1ybKDJCwNEnMdpYjQZ+R4ylt5ATauWSEc8YGiC5ihiTBWlqzYjei2yZAc
         fNCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QoKnnP/Fgjvk/zKPmZ8xtxutDW9Qi0e7oXIQMpKJF4Y=;
        b=wMeOvsxo520L9ygZ9jYNqlf4CH4rCLd2S7EYWbT9C1ev57nn1wuhhJU6nbmrR+qUPR
         Dq9mky6HnopVEOq8R6fo5cz9ljTlqZ3+NeHz6sCLP7I01AzkTSbaDLdsrH6zf6FUzGRT
         FtXypt3wUv8JQE5YkPLGNrnnAhDUrYCNdCf3V57yjxTDrMJvstxSzcpWZRePTIZZmk1x
         HXq18WHBxSDVRLCePaHuNfJtzOOln5AGhwv9M7J0aZ+FEfPEHMfNMP1jO424CUlhwBra
         tg3jTfR3g0jgBfK1apRLZyUwBlea9AbZxTiKHbWp2aoJR4lle1eGL4PAQzgfnkKAI/qL
         8DwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id q20si2171265pgi.499.2019.03.20.11.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 11:31:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TNDTpod_1553106713;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNDTpod_1553106713)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 21 Mar 2019 02:31:55 +0800
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
To: Oscar Salvador <osalvador@suse.de>
Cc: chrubis@suse.cz, vbabka@suse.cz, kirill@shutemov.name,
 akpm@linux-foundation.org, stable@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190320081643.3c4m5tec5vx653sn@d104.suse.de>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3c880e88-6eb7-cd6d-fbf3-394b89355e10@linux.alibaba.com>
Date: Wed, 20 Mar 2019 11:31:50 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190320081643.3c4m5tec5vx653sn@d104.suse.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/20/19 1:16 AM, Oscar Salvador wrote:
> On Wed, Mar 20, 2019 at 02:35:56AM +0800, Yang Shi wrote:
>> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
>> Reported-by: Cyril Hrubis <chrubis@suse.cz>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: stable@vger.kernel.org
>> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Hi Yang, thanks for the patch.
>
> Some observations below.
>
>>   	}
>>   	page = pmd_page(*pmd);
>> @@ -473,8 +480,15 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>>   	ret = 1;
>>   	flags = qp->flags;
>>   	/* go to thp migration */
>> -	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>> +	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
>> +		if (!vma_migratable(walk->vma)) {
>> +			ret = -EIO;
>> +			goto unlock;
>> +		}
>> +
>>   		migrate_page_add(page, qp->pagelist, flags);
>> +	} else
>> +		ret = -EIO;
> 	if (!(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) ||
>         	        !vma_migratable(walk->vma)) {
>                 	ret = -EIO;
>                  goto unlock;
>          }
>
> 	migrate_page_add(page, qp->pagelist, flags);
> unlock:
>          spin_unlock(ptl);
> out:
>          return ret;
>
> seems more clean to me?

Yes, it sounds so.

>
>
>>   unlock:
>>   	spin_unlock(ptl);
>>   out:
>> @@ -499,8 +513,10 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>>   	ptl = pmd_trans_huge_lock(pmd, vma);
>>   	if (ptl) {
>>   		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
>> -		if (ret)
>> +		if (ret > 0)
>>   			return 0;
>> +		else if (ret < 0)
>> +			return ret;
> I would go with the following, but that's a matter of taste I guess.
>
> if (ret < 0)
> 	return ret;
> else
> 	return 0;

No, this is not correct. queue_pages_pmd() may return 0, which means THP 
gets split. If it returns 0 the code should just fall through instead of 
returning.

>
>>   	}
>>   
>>   	if (pmd_trans_unstable(pmd))
>> @@ -521,11 +537,16 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>>   			continue;
>>   		if (!queue_pages_required(page, qp))
>>   			continue;
>> -		migrate_page_add(page, qp->pagelist, flags);
>> +		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
>> +			if (!vma_migratable(vma))
>> +				break;
>> +			migrate_page_add(page, qp->pagelist, flags);
>> +		} else
>> +			break;
> I might be missing something, but AFAICS neither vma nor flags is going to change
> while we are in queue_pages_pte_range(), so, could not we move the check just
> above the loop?
> In that way, 1) we only perform the check once and 2) if we enter the loop
> we know that we are going to do some work, so, something like:
>
> index af171ccb56a2..7c0e44389826 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -487,6 +487,9 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>          if (pmd_trans_unstable(pmd))
>                  return 0;
>   
> +       if (!(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) || !vma_migratable(vma))
> +               return -EIO;

It sounds not correct to me. We need check if there is existing page on 
the node which is not allowed by the policy. This is what 
queue_pages_required() does.

Thanks,
Yang

> +
>          pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
>          for (; addr != end; pte++, addr += PAGE_SIZE) {
>                  if (!pte_present(*pte))
>
>
>>   	}
>>   	pte_unmap_unlock(pte - 1, ptl);
>>   	cond_resched();
>> -	return 0;
>> +	return addr != end ? -EIO : 0;
> If we can do the above, we can leave the return value as it was.
>

