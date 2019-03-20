Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB2AEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BE9F20854
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BE9F20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBDE86B0003; Tue, 19 Mar 2019 21:06:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6DC66B0006; Tue, 19 Mar 2019 21:06:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5CE86B0007; Tue, 19 Mar 2019 21:06:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8543A6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:06:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z26so770454pfa.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Xst49ofFZym2GBTG4vGswqMTlXQz7owvePCJT5IB0Cw=;
        b=gLz1qTbQP1vhbTlGGTQwjYbULzk84YmzXZ4wPNrFkU9IVM5tc3tfjC8YLR3ZWhc1ZD
         nJyD1+DpP1HesqgnxYDWsfId9oYkZHdFrkIHDPyJ6W+sNfdwWctWG273wiauGLclj/J1
         BW9Z+16n/sZxj7uL2JiQAZKg8VPgIRBA63/GoJ+JgTrZ24fc5mUtDnaJzQhpg9ssB7XK
         GJbuRLERmegrNBTed0KW4Bbax+9CBeDLvpKkFxa5Banx3CDyZAqItEnJ7T8+BNDZitGr
         vF3OSzEK+DDLSBoojK9BdQQIV1TYV5mj+/D+F1bLnCzb/gzgEdP5Gdae0jeeFDjCsZlO
         62GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWuut9ik/HhFxxyFKWp+M2blTFguAFxhM4U8P6g9/mAgZw6IcK6
	G+KH0u53Ij9dDQbpTgZHyC5P1NrF2uhCP+dvlQxuovbdvih4Sni4lkO8jmFTpXEGCmlSIZBcJSH
	S2ERxlin+30HjPjphs4NCP3UmkvzRRBpCZxEn7LX0CTYytYQk8cHedYUOZYVaIfOEcg==
X-Received: by 2002:a63:5652:: with SMTP id g18mr6383758pgm.290.1553043994142;
        Tue, 19 Mar 2019 18:06:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXIz5RiKNC4LL0wPJQ+SI8n0m1pzQmFQl1Ght6s96/mh93hbuZdCjn9N54uqf0A/LaNAdq
X-Received: by 2002:a63:5652:: with SMTP id g18mr6383686pgm.290.1553043993253;
        Tue, 19 Mar 2019 18:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553043993; cv=none;
        d=google.com; s=arc-20160816;
        b=dpIQJ10jdPvXYaomZlQuiYOHpODPj/N0LZAQUy2ttg237UiSqX4cjOR65edX1YYLHA
         8PjPopi2Ifo+bLlAIwoSTRH+l1dib07iq76piy4Bga/XcdsGB/O505xkW//gUZNTLZFi
         l2eLvsgpBDEpT9rD/jgiw2doa8Z5gRwbExPu2hYeoaAqljLf/RLzGY1tfA0K82xwRtrE
         CvsiLJEzQO22AdeeN7K5jnEEpg3eYKtuJTzsvCGHp/I2St5zjy0ZH69gYHeAbjxKm+RY
         /jcXEIazM95B6lR/QRahkkosCgLCzk82fpg3gkAQzpZTNIH73S4mNO+mPAPoL3BRps0Z
         Cj3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Xst49ofFZym2GBTG4vGswqMTlXQz7owvePCJT5IB0Cw=;
        b=ME+4iewqdX19aEKIVloDcZ8+FCcHB5+psTsgHnKrN2rAB07gtGb9S1twgPuS4hnEkW
         49HFYIOcj4gaDpEW5EEVfOnXTmTTA8ksmKFn5GxipkNMbPAvn9L2EkA+TnEz/YA+GzNY
         sDjBnd0bYc9zGAyihjU+GOG/5xnU366aGVOhT9yxkatp9FzvzJrFO6oSvxS6wXbDLzbQ
         96TztQx8/WulsyLZpJPNxBHjd15ayHearBOhToNJM/5wT46SIgC6kfbJ+znAVRHFNnbP
         syHJIQaDYk2wdTS/1jYvWnOMp/ibMBMvNCtnkx12A4bulKhfx3vVhr2OSyb13o8Uu5lp
         Zp6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id h21si347166pgl.346.2019.03.19.18.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 18:06:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07488;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TNA0mks_1553043988;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNA0mks_1553043988)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 20 Mar 2019 09:06:30 +0800
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
To: David Rientjes <rientjes@google.com>
Cc: chrubis@suse.cz, vbabka@suse.cz, kirill@shutemov.name, osalvador@suse.de,
 akpm@linux-foundation.org, stable@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.21.1903191748090.18028@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <5ef2a902-7abb-a0a9-f478-dcccbb393893@linux.alibaba.com>
Date: Tue, 19 Mar 2019 18:06:26 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1903191748090.18028@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/19/19 5:49 PM, David Rientjes wrote:
> On Wed, 20 Mar 2019, Yang Shi wrote:
>
>> When MPOL_MF_STRICT was specified and an existing page was already
>> on a node that does not follow the policy, mbind() should return -EIO.
>> But commit 6f4576e3687b ("mempolicy: apply page table walker on
>> queue_pages_range()") broke the rule.
>>
>> And, commit c8633798497c ("mm: mempolicy: mbind and migrate_pages
>> support thp migration") didn't return the correct value for THP mbind()
>> too.
>>
>> If MPOL_MF_STRICT is set, ignore vma_migratable() to make sure it reaches
>> queue_pages_to_pte_range() or queue_pages_pmd() to check if an existing
>> page was already on a node that does not follow the policy.  And,
>> non-migratable vma may be used, return -EIO too if MPOL_MF_MOVE or
>> MPOL_MF_MOVE_ALL was specified.
>>
>> Tested with https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c
>>
>> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
>> Reported-by: Cyril Hrubis <chrubis@suse.cz>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: stable@vger.kernel.org
>> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: David Rientjes <rientjes@google.com>
>
> Thanks.  I think this needs stable for 4.0+, can you confirm?

Thanks. Yes, this needs stable for 4.0+.

Yang


