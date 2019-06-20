Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E220CC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:08:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B38572070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:08:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B38572070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F60A8E0003; Thu, 20 Jun 2019 12:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5C88E0001; Thu, 20 Jun 2019 12:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 295888E0003; Thu, 20 Jun 2019 12:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E27BD8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:08:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e7so1848900plt.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:08:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6OmiIKV1Q+0KbBGkyrRFvzKFQIaPtUosW1vlbQFZPsY=;
        b=X4SzHVyRz+j00TDcjiYsjyy1FQEik9i32PWJcgJdgBPMibh1AYfPY3A7ISOJzbqzFb
         3HUVo6rqJTADKZkfnYQqxIzAm0CYTfq8nTGEqNEDL2xvuVCUdMwrhlGwLFGHBHMjb+9q
         5oloLnGte65phVJ504lucrDchXDX/8jIM/nstaLd73AQQqYw4FcFx8wYjuhn3wuGGisw
         0q81PVqgBEc2/PuAVDU26WomKruTPSCfFqAE0BORQk4+4HT5XUryn/cvFVj95SU5x+G+
         UyikhnmOhXiVU2JQ4fdt/4NgbGlxWVWFvmvMv8DZia9CGGRRm9pYo6cz53sxHBjtdDBq
         yvNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX16/vdDfBREEeSbM84L7M6jvNgF5eLBMOPbv4fj9mqBIH0HBED
	TfVrxTtSO/rXQMBIIHDvvUxmwpAEMzxGiTCJ/ivtkEAT/2LgMzrV1u7vkr49/lT75TrBTp0ujpl
	bzwJhSzqoClanj4Vw1VCzKuyN6fk7CPpmhteO6lZTlCjyA0i13RLoMiaDUs1IK1HGjg==
X-Received: by 2002:a63:3547:: with SMTP id c68mr5878603pga.428.1561046920427;
        Thu, 20 Jun 2019 09:08:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBPWP1S83i/NEReqkrOJQW1WczRdITNpESKv5Wi3/ScTfv4z1+JEz/yB/WOL99F1HIhrnE
X-Received: by 2002:a63:3547:: with SMTP id c68mr5878545pga.428.1561046919622;
        Thu, 20 Jun 2019 09:08:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561046919; cv=none;
        d=google.com; s=arc-20160816;
        b=g3125jsEn0Qvz64oFxu/eQKF3vbOf50BpZiLaJ0YfU9sNKEW6k6WKEq3WCMOehIDqC
         bxSDGRdNabS0ir88lyKAC2Eoe2GQNdoli0pyDRQzfKsAXMuPFDpINYUIjb93fX1ehGb/
         KN5L1u2ZeF2B4i+/ne56UCw1RsMTZpJ8YRbBSoIgrlaTL3Q2QA9eeW4Fw7nECFEWpqic
         KrbZwIuKdHF0cazbCSFkjPXwamJWh16y3CbLMWpi6UtWkfMCR7QnJCENN+pA37a0euNL
         mQjg1/33+JhidPl2N+6rZ5DCSAPo7f1KGrrZ0LR6SLRV8Xc5ybZdLkd23oq5hC0hIBES
         /nSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6OmiIKV1Q+0KbBGkyrRFvzKFQIaPtUosW1vlbQFZPsY=;
        b=yiy0hugUaQLK/d8fRrfb9MTU578vLTXnM07Tx80fwsAhu1X2XC9J/4ufYH/hlegQ/u
         whHd3No5v6gK7G/WIRD19IDdRtvGcdaURTnl21R3OLcpXpFz/G3UvAHJl9c2O3pi8Ffu
         cFR3J2N7K4THGBAoT11AQ0Beu297fADjs7pdnVKUoGpSvhgu9F42MUbp4ksXwmgBNRy3
         t9shI7Mhq+OWgmJ92ahjURr0mQcMiz8aiT+M+gAEr/Q80qX0KtDSc7mvbb2RvcALlmUf
         kWIStmWpQ/E4ZgIWjGZ64XrATSnFInTkRnPi6zq1e8onr7+EhErY1JRV33SNjjPkSFZc
         N7og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id q129si18331576pfq.43.2019.06.20.09.08.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 09:08:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R771e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TUlBe2E_1561046914;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUlBe2E_1561046914)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 21 Jun 2019 00:08:37 +0800
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
 <687f4e57-5c50-7900-645e-6ef3a5c1c0c7@linux.alibaba.com>
 <55eb2ea9-2c74-87b1-4568-b620c7913e17@linux.alibaba.com>
 <d81b36bb-876e-917a-6115-cedf496b4923@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d185f277-85ed-4dc1-8ff2-2984b54a0d64@linux.alibaba.com>
Date: Thu, 20 Jun 2019 09:08:30 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <d81b36bb-876e-917a-6115-cedf496b4923@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/20/19 12:18 AM, Vlastimil Babka wrote:
> On 6/19/19 8:19 PM, Yang Shi wrote:
>>>>> This is getting even more muddy TBH. Is there any reason that we
>>>>> have to
>>>>> handle this problem during the isolation phase rather the migration?
>>>> I think it was already said that if pages can't be isolated, then
>>>> migration phase won't process them, so they're just ignored.
>>> Yes，exactly.
>>>
>>>> However I think the patch is wrong to abort immediately when
>>>> encountering such page that cannot be isolated (AFAICS). IMHO it should
>>>> still try to migrate everything it can, and only then return -EIO.
>>> It is fine too. I don't see mbind semantics define how to handle such
>>> case other than returning -EIO.
> I think it does. There's:
> If MPOL_MF_MOVE is specified in flags, then the kernel *will attempt to
> move all the existing pages* ... If MPOL_MF_STRICT is also specified,
> then the call fails with the error *EIO if some pages could not be moved*
>
> Aborting immediately would be against the attempt to move all.
>
>> By looking into the code, it looks not that easy as what I thought.
>> do_mbind() would check the return value of queue_pages_range(), it just
>> applies the policy and manipulates vmas as long as the return value is 0
>> (success), then migrate pages on the list. We could put the movable
>> pages on the list by not breaking immediately, but they will be ignored.
>> If we migrate the pages regardless of the return value, it may break the
>> policy since the policy will *not* be applied at all.
> I think we just need to remember if there was at least one page that
> failed isolation or migration, but keep working, and in the end return
> EIO if there was such page(s). I don't think it breaks the policy. Once
> pages are allocated in a mapping, changing the policy is a best effort
> thing anyway.

The current behavior is:
If queue_pages_range() return -EIO (vma is not migratable, ignore other 
conditions since we just focus on page migration), the policy won't be 
set and no page will be migrated.

However, the problem here is the vma might look migratable, but some or 
all the underlying pages are unmovable. So, my patch assumes the vma is 
*not* migratable if at least one page is unmovable. I'm not sure if it 
is possible to have both movable and unmovable pages for the same 
mapping or not, I'm supposed the vma would be split much earlier.

If we don't abort immediately, then we record if there is unmovable 
page, then we could do:
#1. Still follows the current behavior (then why not abort immediately?)
#2. Set mempolicy then migrate all the migratable pages. But, we may end 
up with the pages on node A, but the policy says node B. Doesn't it 
break the policy?

>
>>>

