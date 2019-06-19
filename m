Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50393C31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:21:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3236217D7
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:21:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3236217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 602108E0002; Wed, 19 Jun 2019 12:21:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B31D8E0001; Wed, 19 Jun 2019 12:21:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A1648E0002; Wed, 19 Jun 2019 12:21:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 118358E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:21:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so12022808pfb.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=AzD7nLjW05hIiK62FZhpdvUxJwq6bxkrkLdLtw1/BhM=;
        b=UeEfy+AqIc6v17LHgB2oHrHHiUvZQE6flJMRy+l6bY8cLhUnP0tU97LmFD4wEg6N7+
         XmbC32z5x9YQf0l1nBAOV3mdr5N8j4hNey4a3Q+9TxQTC5hhU3b7JedveDZ8S2RyUSW9
         lTRdmi8hcKNNmsjrkrAXLeBMjxVXJl32So6hv/BMCqTyRu5M/PSUOxWy5ilBeUeIfdMJ
         2oR7PXuszGgmJZ51VMlmYCtGS5LfQ12hsYaVpQZIMBYC/CgyBKBCQTw1Wv+yPV79Ut/S
         zYDLR1Cogkxe0QU+H6WASeRZBs4rDsFo4KiQsp+F1o1AODC+ACCqaH5K8befmimyIa6t
         XHbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUyOQ5tcBQbSKvYYbqu5Hq4gy/RMX807VpQLJdv7J2o6nMqSYE+
	F/9XbKIv17cGiBVoAKimhY07Ue2vOfhPtpFS8byj/CYVhCoKwGPSpec/BWTT7asE3Va7mLOzRp2
	6gW1DHJx6/fjcWut9A0FlhyVnJfXOFvs0hgltq4KHXn4y7pgd4WnF2LiDJxvDPaS3FQ==
X-Received: by 2002:a63:374a:: with SMTP id g10mr8337679pgn.31.1560961287600;
        Wed, 19 Jun 2019 09:21:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYRmtknr1Ntg0GAfac9iqUSdrwKZzY2dMgXRBy+DXckEsk8q6Jq7HsTkKmn1xipNoaNTIk
X-Received: by 2002:a63:374a:: with SMTP id g10mr8337621pgn.31.1560961286745;
        Wed, 19 Jun 2019 09:21:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560961286; cv=none;
        d=google.com; s=arc-20160816;
        b=c86bGXswPHpMG3G9yR1N7uMU60KgzhodrTFH5U+IlDDN2XsQIK45s57ulPq4IcF+xT
         sduWTx+ZawFLghz5Y+1JAQ4UofgYxFdMIbTKJuwykvOAw5mkg/cOGSx7aKz3kX3mS6f4
         E5oMYHRFm3zNOPe0ywMp9eX4wMSNVQzW8FvigA3vLgOo5iq9sc32JwyXWEo/9PI55fhB
         5utQYW4FfYEf5+jyzjxS+0lgnEvIQiaV2C4z3tNisxACSF5I5X6K5y2SaM5dXDKgEzKk
         CduRLSddd7G6kKXPNT1YvSaY3hYqO149lpdJ3GYYvJKSv0LR5cwQQ8zRg5I07DRpl/2W
         Xw3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AzD7nLjW05hIiK62FZhpdvUxJwq6bxkrkLdLtw1/BhM=;
        b=orw1Mm1G7CwnvlShNO8zGxQRceqbWVubtMkbd16GXb7YN7ei4NKXIdnIqXVPGnchE7
         An/pNV0QRTe9i2Qvxa4PdE8AU/jN56a8YjGMhHMBKduZBCp1tFfC420zzUJKO+Cpkm8v
         xSmjgnseZuMadh5PfsdgFH3yeoGqn5bkIlJWS+7/nZfewG+ZXORBSlA3cEf0uwNH8+gx
         c6+3CtCGg2kiH8XFi+PwQOVfyDU+mX2QLfFfIrxEUF8iQy1bYgZhRbyQjWmWPDDCihed
         +4bsvFyKRrzbg4wkz2y13nD83A1g5pG+l8dPICqpf3ypA1IgPA9uxNTIQuyrPrOoBEF8
         X16Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id x5si1784646pjp.75.2019.06.19.09.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:21:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R221e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TUcmGMH_1560961263;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUcmGMH_1560961263)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 20 Jun 2019 00:21:06 +0800
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>,
 netdev@vger.kernel.org
References: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190618130253.GH3318@dhcp22.suse.cz>
 <cf33b724-fdd5-58e3-c06a-1bc563525311@linux.alibaba.com>
 <20190618182848.GJ3318@dhcp22.suse.cz>
 <68c2592d-b747-e6eb-329f-7a428bff1f86@linux.alibaba.com>
 <20190619052133.GB2968@dhcp22.suse.cz>
 <21a0b20c-5b62-490e-ad8e-26b4b78ac095@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <687f4e57-5c50-7900-645e-6ef3a5c1c0c7@linux.alibaba.com>
Date: Wed, 19 Jun 2019 09:21:01 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <21a0b20c-5b62-490e-ad8e-26b4b78ac095@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/19/19 1:22 AM, Vlastimil Babka wrote:
> On 6/19/19 7:21 AM, Michal Hocko wrote:
>> On Tue 18-06-19 14:13:16, Yang Shi wrote:
>> [...]
>>> I used to have !__PageMovable(page), but it was removed since the
>>> aforementioned reason. I could add it back.
>>>
>>> For the temporary off LRU page, I did a quick search, it looks the most
>>> paths have to acquire mmap_sem, so it can't race with us here. Page
>>> reclaim/compaction looks like the only race. But, since the mapping should
>>> be preserved even though the page is off LRU temporarily unless the page is
>>> reclaimed, so we should be able to exclude temporary off LRU pages by
>>> calling page_mapping() and page_anon_vma().
>>>
>>> So, the fix may look like:
>>>
>>> if (!PageLRU(head) && !__PageMovable(page)) {
>>>      if (!(page_mapping(page) || page_anon_vma(page)))
>>>          return -EIO;
>> This is getting even more muddy TBH. Is there any reason that we have to
>> handle this problem during the isolation phase rather the migration?
> I think it was already said that if pages can't be isolated, then
> migration phase won't process them, so they're just ignored.

Yes，exactly.

> However I think the patch is wrong to abort immediately when
> encountering such page that cannot be isolated (AFAICS). IMHO it should
> still try to migrate everything it can, and only then return -EIO.

It is fine too. I don't see mbind semantics define how to handle such 
case other than returning -EIO.


