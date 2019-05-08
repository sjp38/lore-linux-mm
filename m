Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E51B3C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 16:55:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9572F20850
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 16:55:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9572F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C2036B026F; Wed,  8 May 2019 12:55:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0730B6B0270; Wed,  8 May 2019 12:55:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7BE96B0271; Wed,  8 May 2019 12:55:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0A646B026F
	for <linux-mm@kvack.org>; Wed,  8 May 2019 12:55:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t1so13003184pfa.10
        for <linux-mm@kvack.org>; Wed, 08 May 2019 09:55:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=GNbhTnMzX6/69PbfLQg12/hwhIPtoMD7iF1hBAfIxdc=;
        b=YA4FJ9IqICaQsuVtf8otUnQM2VNrqSIL/ozdY+k12D7pnwZZQivm8ANSIFx9NWn2NG
         M1KQ1s0E9VjOyqZDyPoi/LexGMe4/PRbO5Qds8kYipAhvnxHzE4GoC0A+56I57IW+02U
         9WLfZlcfRhZm4IL3yarCElKoMcjpchXbDYZtVwUmEbYQqir6Wryx8umKxTCg3jfT6vu2
         G1/eC5EHfx+weU/9pFBSEPG0J8rPCILkI+hxqtlqxd/a72qV7UuHidbqcHSSMYi8tsoD
         z4gWYGfYOja3jltfGruY6+RqCOlWgZcCiIbZu6aDO87jmI30CrsLWzPYXBdXOMJZilzW
         Ne8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWZpnssZhACYTaDGr2np4s/vMjbdBLvTzvK1b4EUSLGGUXkJ6yX
	9nTn5sVxBYE7jJN/kpGvcamBqkYnLqxaTeGlZCTS2RVqoYCvhYo+u/kXQFuu43TCtn/xfIHJN77
	w4nEwgPZsgVmzOeiNhwKKrxLMzylYllbNT+GuNJPecGSD6Ur+0lsUWWJjdpbVE+O9ew==
X-Received: by 2002:a17:902:302:: with SMTP id 2mr49133952pld.232.1557334540256;
        Wed, 08 May 2019 09:55:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydYiHVYjdnX8K2FnU5ynnKD8dAs++ztdXZpC4b8vwoiI6LtoqFQTOQO5tqyo9Qg3RwBq61
X-Received: by 2002:a17:902:302:: with SMTP id 2mr49133835pld.232.1557334539100;
        Wed, 08 May 2019 09:55:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557334539; cv=none;
        d=google.com; s=arc-20160816;
        b=rO6gJrTA+VwKJZJ16GAkCWZsVXUFHzmyXQg8T/RnkUnFpVuYmba1sNsvOft3ovuzBj
         0vwNttL1J3EXoLiBeQUrd/KqCLJrtac+YqmjSmZ8n8Lw7zW4ieAeDyid/r3YkCgVPaJa
         B2Bto9nWvZgJBT/KtgSD2KBOj0HSavc7hgXLbmX6Xx8VhEft1SIkcxcs/mTO+P8JPocB
         QT1oaStQt1hk1Y+pB16AU486uDbmCYN3VVFRwoqXAwiKbCAOTal4rxmqkdhaH5LI3gBj
         wBc9PBX7mxPisgFrQMZdNofIh053xcewWBQyrrSkLQvr9mpbse2wImboKXI3B3XsQ7bI
         k4CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GNbhTnMzX6/69PbfLQg12/hwhIPtoMD7iF1hBAfIxdc=;
        b=RuzWjbc2PHSOdaq0ZtjL99zJZ5v85cmN+z+QQeQSyC3EzfFV+kpCptuhTcElEyQ325
         KA7jBV3sT9isS+/oP9MNSgcvPE/me26w/+QKnbcGf0qsBRi7rzi1rrxYvYb9HdSdsQIx
         g0J4mN3W3qScrRZLSiGQfI5Ak0npgOhlTQc1UVVkbeaJVEIylWTGxX7W1p2+Ikb6xu/L
         EpIX4gALcPO47dMQJbwtvB+aYtrxpKpjaR97jiKunTPdLqElL+6V8ILfdCcXardEPDjU
         YYIZ5nmNqTMEfCEZyhS4H4j7gaNLN/mSxslFrCKZhgjPI3KOHQACna1/aCpNs3NoLda6
         1lxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id s17si23534252pfm.170.2019.05.08.09.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 09:55:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TRCE-nj_1557334521;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRCE-nj_1557334521)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 09 May 2019 00:55:25 +0800
Subject: Re: [PATCH] mm: filemap: correct the comment about VM_FAULT_RETRY
To: josef@toxicpanda.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <66e2f965-4f4d-a755-69b3-5342aa761ff3@linux.alibaba.com>
Date: Wed, 8 May 2019 09:55:21 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Ping.


Josef, any comment on this one?


Thanks,

Yang



On 4/25/19 4:22 PM, Yang Shi wrote:
> The commit 6b4c9f446981 ("filemap: drop the mmap_sem for all blocking
> operations") changed when mmap_sem is dropped during filemap page fault
> and when returning VM_FAULT_RETRY.
>
> Correct the comment to reflect the change.
>
> Cc: Josef Bacik <josef@toxicpanda.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>   mm/filemap.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index d78f577..f0d6250 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2545,10 +2545,8 @@ static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
>    *
>    * vma->vm_mm->mmap_sem must be held on entry.
>    *
> - * If our return value has VM_FAULT_RETRY set, it's because
> - * lock_page_or_retry() returned 0.
> - * The mmap_sem has usually been released in this case.
> - * See __lock_page_or_retry() for the exception.
> + * If our return value has VM_FAULT_RETRY set, it's because the mmap_sem
> + * may be dropped before doing I/O or by lock_page_maybe_drop_mmap().
>    *
>    * If our return value does not have VM_FAULT_RETRY set, the mmap_sem
>    * has not been released.

