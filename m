Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1AF1C04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6236B208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:01:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6236B208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D87726B0277; Mon, 13 May 2019 06:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37BC6B0278; Mon, 13 May 2019 06:01:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD99A6B0279; Mon, 13 May 2019 06:01:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3886B0277
	for <linux-mm@kvack.org>; Mon, 13 May 2019 06:01:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k6so12346846qkf.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 03:01:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=dQSCIxX3ntSUdrvTY+T4nAWW+t+rEZJblVFPGhIKet8=;
        b=AAa0ZhbMlUlI8n6qMehrrRkiLgWZEzmsLFdrczXsvq5DzykV7EkicLkeBCikDHK1um
         mm4htPDbI9VWDc1mDdYX+Dld3dOiKJKyiB8CAKm4rz2K8TvMimqAnPjt5nNZolWY2Sf4
         AqpRgyWGRKUyWvtijyIjoF35JjpGY6S4EUeXpw0uBiNT95I1unk1KG5CHFQotwErnv2r
         P/UafeZHa4zNecW6PLqzlhAio2edx9/Arm1krSofMMfPL0Jl+FdtqULQ0l4cOH8gPC2p
         Y1QTfXm1102UE5ojXJ5E9L84bNEekX76D41AMp6S1rNCyX8uaiEKTYJm5GG9yIvDfFHN
         6jcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRikwIPXBXBGNFwxLNyhqiG5DkR7J4y0A1BCoTmDMQywkoZJUq
	yozUBpyQY5B10ZvzJX2k1z5VS8TCqIQjdcs5S1+49vhUnjXiwUJS6gpgUTkH4n1gRVpqmNh8FJa
	ZCS2DOYnY1VPfV54zhg9/2N77Rob6ifi3ibHPmSoVffoFxjv7j0fKKqMkwtf+HDGyGA==
X-Received: by 2002:a37:7b03:: with SMTP id w3mr20707714qkc.266.1557741704321;
        Mon, 13 May 2019 03:01:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp/qhZktm5IZvzLSVKwFpc4yAGMBeZlMJ6hBYvHQnWAhRvrRQNvn/asGlDeXZndr2sLEJW
X-Received: by 2002:a37:7b03:: with SMTP id w3mr20707653qkc.266.1557741703463;
        Mon, 13 May 2019 03:01:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557741703; cv=none;
        d=google.com; s=arc-20160816;
        b=jEaKNrcN0Me6fzi984ezdz6i6ld3Pbv3irpSDX8WElIe2QwGCN2mK1xTTPfNNLDKnK
         TOQOsv2ABdcdr3ZF7YzQ3eTDkIIKjpXTF3/GPmySAgzzqSzDyMR72Id5EpSxwmfoPeuq
         gqN/Ti8pYZymzLOaJwvjDFH7Hevvih9V2yOHBohUzV2+txwUfFybZlRpv7qgcOY1qAbw
         /cmPBfhoo9fChFJoSZzOcG5oC/7nBhPNi2bDgEbQwqwab3QLzaId83+qL6My0YlQ7KQ8
         Dh93mIrx0OVzAHYaRF9hK7Ix9pUiFScwgbt562Lxo59+tITg4ksx334vKJQtbmJrE8i8
         FaYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=dQSCIxX3ntSUdrvTY+T4nAWW+t+rEZJblVFPGhIKet8=;
        b=IZAJF9S5lPzuVPeNBrAzqgF8VTJde7DsQFH/jDc6/P8K5+aVNW8Hi6dPGtPYi3U5bC
         vT3u4rJbGXiaBEj5xbs+DnZOGCOuz5Zi7VscdQ7THc9pPAg2koFryKRP0BSpHXzcXd9g
         cr3CyROTekSbcrAt/KcTxmON7I7AOOdD2m1G5yH5XQZwoBwe/Kbrqy4CeEmFBbhmkG7P
         knAQygQU8PcfJ7mso6e10MVkKxlgkDWWC8ETa7endobNSiERGOzZC+LRWk+XdaZK7cFv
         qdcN481+dDdFi+s3LSMsifbI9bXBbOUK4r3jbc+9GoMAbMTKggeNBQvD9cKJY0KHr75y
         H5OA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c15si1246913qkc.73.2019.05.13.03.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 03:01:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5C07223E6CE;
	Mon, 13 May 2019 10:01:42 +0000 (UTC)
Received: from [10.36.117.84] (ovpn-117-84.ams2.redhat.com [10.36.117.84])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5F4FE5D706;
	Mon, 13 May 2019 10:01:37 +0000 (UTC)
Subject: Re: [PATCH V2 0/2] arm64/mm: Enable memory hot remove
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <bbfc6ede-01b2-2331-112e-fa28bc2591fb@redhat.com>
 <67efff12-6d7f-9696-0c34-c9ad11acd297@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a396de3d-b5d4-51ae-51bf-5e6ce66c30f5@redhat.com>
Date: Mon, 13 May 2019 12:01:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <67efff12-6d7f-9696-0c34-c9ad11acd297@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 13 May 2019 10:01:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.05.19 10:37, Anshuman Khandual wrote:
> 
> 
> On 05/13/2019 01:52 PM, David Hildenbrand wrote:
>> On 14.04.19 07:59, Anshuman Khandual wrote:
>>> This series enables memory hot remove on arm64 after fixing a memblock
>>> removal ordering problem in generic __remove_memory(). This is based
>>> on the following arm64 working tree.
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git for-next/core
>>>
>>> Testing:
>>>
>>> Tested hot remove on arm64 for all 4K, 16K, 64K page config options with
>>> all possible VA_BITS and PGTABLE_LEVELS combinations. Build tested on non
>>> arm64 platforms.
>>>
>>> Changes in V2:
>>>
>>> - Added all received review and ack tags
>>> - Split the series from ZONE_DEVICE enablement for better review
>>>
>>> - Moved memblock re-order patch to the front as per Robin Murphy
>>> - Updated commit message on memblock re-order patch per Michal Hocko
>>>
>>> - Dropped [pmd|pud]_large() definitions
>>> - Used existing [pmd|pud]_sect() instead of earlier [pmd|pud]_large()
>>> - Removed __meminit and __ref tags as per Oscar Salvador
>>> - Dropped unnecessary 'ret' init in arch_add_memory() per Robin Murphy
>>> - Skipped calling into pgtable_page_dtor() for linear mapping page table
>>>   pages and updated all relevant functions
>>>
>>> Changes in V1: (https://lkml.org/lkml/2019/4/3/28)
>>>
>>> Anshuman Khandual (2):
>>>   mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
>>>   arm64/mm: Enable memory hot remove
>>>
>>>  arch/arm64/Kconfig               |   3 +
>>>  arch/arm64/include/asm/pgtable.h |   2 +
>>>  arch/arm64/mm/mmu.c              | 221 ++++++++++++++++++++++++++++++++++++++-
>>>  mm/memory_hotplug.c              |   3 +-
>>>  4 files changed, 225 insertions(+), 4 deletions(-)
>>>
>>
>> What's the progress of this series? I'll need arch_remove_memory() for
>> the series
>>
>> [PATCH v2 0/8] mm/memory_hotplug: Factor out memory block device handling
>>
> 
> Hello David,
> 
> I am almost done with the next version with respect to memory hot-remove i.e
> arch_remove_memory(). But most of the time was spent addressing concerns with
> respect to how memory hot remove is going to impact existing arm64 and generic
> code which can concurrently walk or modify init_mm page table. I should be
> sending out V3 this week or early next week.

Okay, thanks!

> 
> - Anshuman   
> 


-- 

Thanks,

David / dhildenb

