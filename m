Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6DDEC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F852086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:18:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F852086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 348F46B000A; Tue, 11 Jun 2019 13:18:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1246B000C; Tue, 11 Jun 2019 13:18:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1998D6B000D; Tue, 11 Jun 2019 13:18:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE9EF6B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:18:05 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d12so4348568oic.10
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=3jqFCGv1cq4cNPvb+nrWLAP5Cb9VAkgIgCvt4MCgNTk=;
        b=ZowyjUsQ3fwcWLg2C0ZVDiyxz9QEyZXNk0lH6suqXt6+UOwbkHs44j7VPK8Q3ALBhr
         ivJsDEFh8dpK+s103ELsrAO7uygqAKIAbmlKPihYH7QZcGN2XXbmInc9n/WMeKKgdKr4
         wbnwpcVgn7kv7y9OULJcNxSLSGCFYlmNySNzJKyagaJ2EyYLLjPJoYwbBXENCRr01lDv
         s91sHUW8ndw86L9TklES1qQSUUCM0IMCLeYcaiVKEKs0B9wSMbR+dVcttPaylCauNTua
         o9fP7OuEAVB1KNI6m0w1MSgrFOlP7mYH2jv7w9VcevT6a6sV8F17pq+6/PLN7bOx99MK
         lGFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWv7WM7665kvZ6zMup594zylXRHHddrVIA3pjNkY+V4scCpqLPY
	cOuDQJ8VKvws1lDENT8TO2UiaFF+mzFGImv7pMGV1RHOg7go+UoeZ9OeG2GudNYJ0LxMiG97g2f
	ek0GoIOmMobwsK2hlafuWyHEVruvHg2jm/Pv/JjiPszet25pGZiM/HzQWUdtqDLtxmw==
X-Received: by 2002:aca:4e84:: with SMTP id c126mr1300325oib.153.1560273485445;
        Tue, 11 Jun 2019 10:18:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygVmBUMxRenp6+P5XFetk0q9n30IDY8FHOcYoQsMSSUrr+uy3GnLxmGnPbuyv0ODI8zfJq
X-Received: by 2002:aca:4e84:: with SMTP id c126mr1300299oib.153.1560273484913;
        Tue, 11 Jun 2019 10:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560273484; cv=none;
        d=google.com; s=arc-20160816;
        b=n8sW204BOyZAZSalA4ccaTTJ5HN0sk7Cvt/TuMJLQ8N+nxICOC4ZsiGwHZzi+aSK+L
         xxFcyBJ1PaRzIeymGbqFktNHmaagsMpZoTsv/Ha91/zprw/OUHRQzBN+wRvg2ee8rr5O
         jTLzf9e5bSFd4etMX4uKVa72irhMfANZzogOrPHN7TLIC1OqI+lzYbUTxobPMVx703ob
         UUCuEyQp9xwvlMbI8QobXAo53O72MQ3ckQ19RPRcmVBRr9s8ky2d1FS+j0h9OQPmU/P2
         trmdsM9MSO4/3DRzr6/eKb9plLEVdMv3IZf5jBiOpWHgQola53duVf2QtJoaSpvpAAjG
         CUvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=3jqFCGv1cq4cNPvb+nrWLAP5Cb9VAkgIgCvt4MCgNTk=;
        b=mocb7rRE25pUGFBNu5AgBbuBBa6brCOrPHKlKl51RJ8ApBia+ueGIEcD15vYaubS4W
         6K73dX0gkY8+eG4dmk2GQ/XOH7QG5dLngOKmtR0Nd2cadNaTDhlUepq/my1V2eMM/Xlj
         gVFDhK+RPxiaoJAjoqNU9X9a89wW9KBYDkzoA1W4oCsd8N0qp5Wd5rBwn3qxZrLGfGaJ
         WoXaya53PxPGDASUA0xA9378rq56qMC5gN8G3t1yoWGHwxagSf9aogxYqJCabj3uK/QI
         4EbcPEBFK1dxq4N0f7Iy+N2k0cVk1iEwL45qt0I6TvCZsx+OtqyaRNui/ku+1zpbisNb
         KqSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id c4si8389597oto.312.2019.06.11.10.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 10:18:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R561e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TTwfifQ_1560273465;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTwfifQ_1560273465)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 12 Jun 2019 01:17:49 +0800
Subject: Re: [v7 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing
 sc->nr_scanned
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Oscar Salvador <osalvador@suse.de>, ying.huang@intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, josef@toxicpanda.com, hughd@google.com,
 shakeelb@google.com, hdanton@sina.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560202615.3312.6.camel@suse.de>
 <d99fbe8f-9c80-d407-e848-0be00e3b8886@linux.alibaba.com>
Message-ID: <52ec93c6-a41b-e5aa-54f0-f508a5e30a09@linux.alibaba.com>
Date: Tue, 11 Jun 2019 10:17:39 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <d99fbe8f-9c80-d407-e848-0be00e3b8886@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000023, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/11/19 10:12 AM, Yang Shi wrote:
>
>
> On 6/10/19 2:36 PM, Oscar Salvador wrote:
>> On Tue, 2019-05-28 at 14:44 +0800, Yang Shi wrote:
>>> The commit 9092c71bb724 ("mm: use sc->priority for slab shrink
>>> targets")
>>> has broken up the relationship between sc->nr_scanned and slab
>>> pressure.
>>> The sc->nr_scanned can't double slab pressure anymore.  So, it sounds
>>> no
>>> sense to still keep sc->nr_scanned inc'ed.  Actually, it would
>>> prevent
>>> from adding pressure on slab shrink since excessive sc->nr_scanned
>>> would
>>> prevent from scan->priority raise.
>> Hi Yang,
>>
>> I might be misunderstanding this, but did you mean "prevent from scan-
>> priority decreasing"?
>> I guess we are talking about balance_pgdat(), and in case
>> kswapd_shrink_node() returns true (it means we have scanned more than
>> we had to reclaim), raise_priority becomes false, and this does not let
>> sc->priority to be decreased, which has the impact that less pages will
>>   be reclaimed the next round.
>
> Yes, exactly.

BTW, for the scan priority, the smaller number the higher priority. So, 
either "raise" or "decrease" sounds correct. "raise" means the real 
priority, "decrease" means the number itself.

>
>>
>> Sorry for bugging here, I just wanted to see if I got this right.
>>
>>
>

