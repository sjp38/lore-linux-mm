Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0EFFC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 18:47:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D20020883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 18:47:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="Hri+HJCZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D20020883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC2E46B000A; Tue,  9 Apr 2019 14:47:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4A726B000C; Tue,  9 Apr 2019 14:47:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B39176B0266; Tue,  9 Apr 2019 14:47:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D17E6B000A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 14:47:52 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v18so2232175lja.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 11:47:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZtvXqzO0qfhBbJzHqDbAc/BFxNFrLzr0Ad4Vpdj5Y48=;
        b=hxk+JcyiRrITI8uLdqFr7iOEwhVbiqRCNNEBw0pK8ypelUgGTDJbpiE8QZyjUVeHvc
         ay5l9dz/mol/LuSfypEsasrdttrryyF/1TkMutcdCfTBWcCeOdJJFEAp+1kvQc0nSMoy
         6u9jyqLoPxn9goqD0wiWjBN26mWP/0aB20P+DEGb8uIwBQ7zXQulftjQ0gQ9r0lfiafs
         /CJaotkU5I1tZHuYRaCzOE/1NC1NLIyktRfxiC12Cf6HRkGn+jxlCzQ/pzJtTeCoz0jp
         8Lbuz7TOzR6KPUnHNyT/xE1Dbu2Ly3+ZAs2P+TpfvK89vRXxbZFP2/P5yjdkviP7wTnD
         feeA==
X-Gm-Message-State: APjAAAU3cKlnHAr87aLwjz11UjSV5fCnbXGPW0V55XxeTa2ni8D+usa9
	2ytm41yNg73zODCKoPYDJdvoOPW/rIfopN1G6yOQg3a58k1p4MZ23uTI1J94elt/A3Gip8FgMue
	8VDoVMykgN8QQOCZMMmg+Gj69nwLEMWVYdXNxLl28zLqervVcT6oVvsQxP7SP3W0+aw==
X-Received: by 2002:ac2:48b1:: with SMTP id u17mr20683052lfg.5.1554835671431;
        Tue, 09 Apr 2019 11:47:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwB8zQqaUGf+FJuJr9CrGluxK5UJ1VJSaUUtb76QANyJhAT1DgLWNQQiYMeyiQsxfPe7lD4
X-Received: by 2002:ac2:48b1:: with SMTP id u17mr20683019lfg.5.1554835670560;
        Tue, 09 Apr 2019 11:47:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554835670; cv=none;
        d=google.com; s=arc-20160816;
        b=sr9uxFQgK1zBv5IPS9WdYBVzBFW8S8E67KKJo8YAEfi1jgiOuT2RBGsRdj8U5wTVp6
         uBQTj9Sdsd6AICSefXo+aZwteI+OmeTzoro9Njudh0LxMpJwkGf4lIjHeHHaXnjAK/Ri
         wcToB/ZsRRNS52UxK3IxOfPSMpvfg5HoQEgYKLniMyhWzoM+agMOX9Ud9DGMw8JnQ1Uq
         /3JGFH16cw97CyYGxMs21iyujjZQSdeFyYJU0sy3KyUsKyglpzeiVeIg/uJ5rsUaGZZp
         zwA4mDJu+oVRR2a+nJuJtHd+R6l8ajxfcLC3ZGBXoKIu9DPN1OSV+ltjb7sRIO//epoa
         ZbRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=ZtvXqzO0qfhBbJzHqDbAc/BFxNFrLzr0Ad4Vpdj5Y48=;
        b=lnWMxJkglNC9Tiosq94snx+Vw3FL/DV38Fu2QJJxT/Anub4hJ8kaT2vGe+DjBIUkrJ
         JyYu1JWhnl7hAXTlJrdBu4yieKcSsjJYvE2OoEwz9jSuRi16vj8FeJC9PIwUW87C7wu4
         mf6cFN6B9FZ9gaY2yXO3n6W7N/g3f/gS57ilCT1jRD53ChTqTSgV9wKnZOIb5BAl1GBt
         3zMI6Uj5ihtNDh9n36qd28TZgkhMJsNYaN8hmrrlFqTjKDTW5qf/3OeUBu7tMWHpCAPf
         DLBxo6Y8nfy735vogoekZ0CnF7i9EU3QupjshFqjRtmdsCPTwYzQJkINg7O3mZa+RTYd
         2nIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=Hri+HJCZ;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTP id f16si5052441lfh.2.2019.04.09.11.47.50
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 11:47:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=Hri+HJCZ;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 09DCB2E14E9;
	Tue,  9 Apr 2019 21:47:50 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id clXESCwkUC-lne42Jwo;
	Tue, 09 Apr 2019 21:47:50 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554835670; bh=ZtvXqzO0qfhBbJzHqDbAc/BFxNFrLzr0Ad4Vpdj5Y48=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=Hri+HJCZuvyhyYgbN9G0Ffqmr/qE6/wwv9SXxiDHETlv8t0UOsuAiRKL/isxie4pD
	 muBm/pUT0cTZROeVhQEOeVXPZqZcEEli8zAV2N5D5BuFpoQmRSg9yUHdD7qsJI7n4l
	 LussINAsnpolsrEDSVKhm4M/MABuTIxajcZc6Fc4=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f5ec:9361:ed45:768f])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id s7VgZ94zbH-lnYSsqGR;
	Tue, 09 Apr 2019 21:47:49 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable
 in sysfs
To: Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>
References: <155482954165.2823.13770062042177591566.stgit@buzz>
 <155482954368.2823.12386748649541618609.stgit@buzz>
 <6a297270-5879-5a57-d41b-7d0629c53fd6@suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <e87d3c53-c5e7-b828-5f15-850ca85e5446@yandex-team.ru>
Date: Tue, 9 Apr 2019 21:47:49 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <6a297270-5879-5a57-d41b-7d0629c53fd6@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.04.2019 21:22, Vlastimil Babka wrote:
> On 4/9/19 7:05 PM, Konstantin Khlebnikov wrote:
>> This fixes /sys/devices/system/node/node*/vmstat format:
>>
>> ...
>> nr_dirtied 6613155
>> nr_written 5796802
>>   11089216
>> ...
>>
>> In upstream branch this fixed by commit b29940c1abd7 ("mm: rename and
>> change semantics of nr_indirectly_reclaimable_bytes").
>>
>> Cc: <stable@vger.kernel.org> # 4.19.y
> 
> So given the same circumstances as patch 1/2, shouldn't this also
> include 4.14.y ?

Oh, yes. Second patch should be applied for 4.14.y too.

> 
>> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Cc: Roman Gushchin <guro@fb.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>   drivers/base/node.c |    7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 1ac4c36e13bb..c3968e2d0a98 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -197,11 +197,16 @@ static ssize_t node_read_vmstat(struct device *dev,
>>   			     sum_zone_numa_state(nid, i));
>>   #endif
>>   
>> -	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
>> +	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
>> +		/* Skip hidden vmstat items. */
>> +		if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
>> +				 NR_VM_NUMA_STAT_ITEMS] == '\0')
>> +			continue;
>>   		n += sprintf(buf+n, "%s %lu\n",
>>   			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
>>   			     NR_VM_NUMA_STAT_ITEMS],
>>   			     node_page_state(pgdat, i));
>> +	}
>>   
>>   	return n;
>>   }
>>
> 

