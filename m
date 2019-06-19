Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE51CC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:54:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8533D2080C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:54:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8533D2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA5E06B0003; Wed, 19 Jun 2019 04:54:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E56F18E0002; Wed, 19 Jun 2019 04:54:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD03E8E0001; Wed, 19 Jun 2019 04:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB9516B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:54:15 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v80so14838715qkb.19
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:54:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=d6kNICFWRLj2ax6Ull3Dwq4Ud3JaX2V2EqtFtXp3ZUI=;
        b=B/+HlczSf8qZkDM3SfY28U+AivFDhlIrmO1TENwhYBOQJUjr9FmZcrl6eVM0FFBtoh
         IESswj6DOieO4TR1AKSDzYuY5DeeJ+TyK29ZaCTBd5dsCNloWAgXYQpTVN/iXeqtVqWd
         KwQK2KP6+xRd68T/u16S5FJHlz7bFQZ9tZVz5NT/YYvCkoPYoHPSDtgZeV/yz/Mie/cn
         R8BlwUcO66eIIebbZGam2Xeahv4bb/VikoKUFssA+x41p41q9m/hxqjsjMf2wTlO8ViI
         CZk4M0ttkTl7Llpnc5Zpwmp1SOEVu8E2cLblDYlxL8UbgCSZZ1F/Ppf9qB663GrFWw1Z
         Ws4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUv3TmdH2rF3gQq3HMru3lMiOI1wiJ+0qsO+ySjp/WHGGonH1pd
	ShWX1qGG7C3J9KovIraD69ItiwmgQUx8oqA+2+9KhQqyMhB0Mv09H3HL2Cv9BFE4ZREfBvKQ1Bb
	v3uN7bJeNJhf8/p8e580HlSfEtB+ErWzG79RJbkUA8EyalE2G25Wn4sXOyaRaTVvgYQ==
X-Received: by 2002:aed:3e7c:: with SMTP id m57mr99464897qtf.204.1560934455456;
        Wed, 19 Jun 2019 01:54:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwxhjzTJTaAMkaLZrLjlppFCclJB9PWZfP0NFBYkCIf2rR9AoTZrmhU4L1DDMxThwmeBTR
X-Received: by 2002:aed:3e7c:: with SMTP id m57mr99464860qtf.204.1560934454878;
        Wed, 19 Jun 2019 01:54:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560934454; cv=none;
        d=google.com; s=arc-20160816;
        b=WOGID4wSIDNcywho83DgaSjORKQZMx6FpHzqRXebb2Aph3ToLS5TXuK6TZHrbvgv2I
         ALalb0OE0zD9mLuUx6vWts5hvz4Lplinj6V2QOmsrZFYPL59Zsd/qCTD5Z7VkSbh17WF
         nkhMjGeLZm2bobmcdmyCAJIK3qjkndnecNoVswP4sULS7L3pBznrFJYf8tPpMCAF1t4g
         LnuMf56lGbrEu0qO/qbts5zV6HksUIeYllAVybBGvYaFS3JAHUP43YD3YzdKBICdc4u4
         l1hC4PCB8ecWbRx2OD1xYB5OlPvAn+MA0e2wqAT8hZ4cDc4a052vcVahd59RKEjZEkb2
         39DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=d6kNICFWRLj2ax6Ull3Dwq4Ud3JaX2V2EqtFtXp3ZUI=;
        b=huBbC/O0w4ZN0OvKFqK71kF1vgASQf1v0x0pJnt3Sr8FBTz/QqzXr8hZyQ4iWOZAOo
         XLw25hLjKtEX/tRTJx7MHS+qFZWPGzBCWMGO5Q5WOd4ybT6uzYZN2HDfw0sGAb567l8O
         VSqMEWNvkhMJkzS9Dyp4Wjd8/Mr8EijNDW0uKkuZ8NFdciUlJKkGA5Js7CnLuHFJ5dDu
         KdOrMW6N16JQU8jTgk7Mzy5s5Ki1xKl/MYYI8UBySbxsd789Kx3Nnlku1a3dkHvm1nAB
         k1h8jV21w1RYkRPqr13/D6J2eebxdnMEwXeYewTYu4Lacrhe6y8KMv+QJ5JSgfLdkqHt
         CErg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u55si5464991qvg.168.2019.06.19.01.54.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 01:54:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A97153082133;
	Wed, 19 Jun 2019 08:54:11 +0000 (UTC)
Received: from [10.36.117.229] (ovpn-117-229.ams2.redhat.com [10.36.117.229])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 45FEA84FF;
	Wed, 19 Jun 2019 08:54:10 +0000 (UTC)
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
 Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 akpm@linux-foundation.org, anshuman.khandual@arm.com
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux> <20190618083212.GA24738@richard>
 <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
 <20190619061025.GA5717@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <aaa9d3af-0472-ffde-a565-fe6a067a4c49@redhat.com>
Date: Wed, 19 Jun 2019 10:54:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190619061025.GA5717@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 19 Jun 2019 08:54:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.06.19 08:10, Michal Hocko wrote:
> On Tue 18-06-19 10:40:06, David Hildenbrand wrote:
>> On 18.06.19 10:32, Wei Yang wrote:
>>> On Tue, Jun 18, 2019 at 09:49:48AM +0200, Oscar Salvador wrote:
>>>> On Tue, Jun 18, 2019 at 08:55:37AM +0800, Wei Yang wrote:
>>>>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
>>>>> section_to_node_table[]. While for hot-add memory, this is missed.
>>>>> Without this information, page_to_nid() may not give the right node id.
>>>>>
>>>>> BTW, current online_pages works because it leverages nid in memory_block.
>>>>> But the granularity of node id should be mem_section wide.
>>>>
>>>> I forgot to ask this before, but why do you mention online_pages here?
>>>> IMHO, it does not add any value to the changelog, and it does not have much
>>>> to do with the matter.
>>>>
>>>
>>> Since to me it is a little confused why we don't set the node info but still
>>> could online memory to the correct node. It turns out we leverage the
>>> information in memblock.
>>
>> I'd also drop the comment here.
>>
>>>
>>>> online_pages() works with memblock granularity and not section granularity.
>>>> That memblock is just a hot-added range of memory, worth of either 1 section or multiple
>>>> sections, depending on the arch or on the size of the current memory.
>>>> And we assume that each hot-added memory all belongs to the same node.
>>>>
>>>
>>> So I am not clear about the granularity of node id. section based or memblock
>>> based. Or we have two cases:
>>>
>>> * for initial memory, section wide
>>> * for hot-add memory, mem_block wide
>>
>> It's all a big mess. Right now, you can offline initial memory with
>> mixed nodes. Also on my list of many ugly things to clean up.
>>
>> (I even remember that we can have mixed nodes within a section, but I
>> haven't figured out yet how that is supposed to work in some scenarios)
> 
> Yes, that is indeed the case. See 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a.
> How to fix this? Well, I do not think we can. Section based granularity
> simply doesn't agree with the reality and so we have to live with that.
> There is a long way to remove all those section size assumptions from
> the code though.
> 

Trying to remove NODE_NOT_IN_PAGE_FLAGS could work, but we would have to
identify how exactly needs that. For memory blocks, we need a different
approach (I have in my head to make ->nid indicate if we are dealing
with mixed nodes. If mixed, disallow onlining/offlining).

-- 

Thanks,

David / dhildenb

