Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E5E8C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 11:42:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 411862184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 11:42:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 411862184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C68976B0007; Fri, 19 Jul 2019 07:42:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1A2C6B0008; Fri, 19 Jul 2019 07:42:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE06B8E0001; Fri, 19 Jul 2019 07:42:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88C6C6B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 07:42:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so27374779qtn.14
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:42:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=O5ht9vEP3J2JScYhhEph/n/BHYx9SoVhZ0CMGiHc51E=;
        b=XBsJj8mswmYxsJj1D0FxzyHQxngf7LHTMJUHF3sKqkvRaDyHJCjFL6K3+GG4LyolL/
         /SNCAdbg5aMIYSwmMvtyzkW9Ey7zDVuxgsQhwvEzrO5LFaxK+MBNSwDk8VzFJQMlFFaR
         rxmE0HE0HnFcMvYkSaKw2cqdKBvqFRXgwR6giwjbSbU6pn7QlFRa+Yf+ipMdaa4I/75S
         DX3JXQ2nPVHboJgc4hfO4X/l46m29zr6eDuZ7QBe1jG1bz2IEvT8D+Uag1ooVmns/2JY
         XNFeqKoxyjiAur3hUHFl/dSClIzMA/g9rcSUJG6Rjq36+mc5F5UJTjhD6uIY/qU2yksh
         65mA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUoamqTKzps6eF5w9OcBxymGqAiiJ3Ai9KQq1A9cbkcM0savoOg
	tX09S0J4L8bTC7ewNHy1Drs9kRj2bRT/8oYqcBI4+uOHz19enDD/oe77XhuxiG3VenYYO9/VnPs
	+QZWdEe0P7g4scwTDLoHniiIhjUysd5iVFJU2nDv5KHMBv47kZSlAuHRYla7KNKywVg==
X-Received: by 2002:a37:a20f:: with SMTP id l15mr34772564qke.212.1563536532310;
        Fri, 19 Jul 2019 04:42:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzh/vkJSETsP2QVRXj6H3T+vhyo8cQZYBwjgAl8/No3EyUAbnc9sP5Wzzeax1+sATOUuzSk
X-Received: by 2002:a37:a20f:: with SMTP id l15mr34772530qke.212.1563536531670;
        Fri, 19 Jul 2019 04:42:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563536531; cv=none;
        d=google.com; s=arc-20160816;
        b=xbO0vkteXaoyoMq6iubjZ2UaeCkC7gIwji4FsQsdlj20nlhRAKGxVU7cc0I2VPa8JR
         PPoITKMtNFUKb1haDTz/FWV1Hlo8wxj7AnSRUps29Swh1qkXcskFENvdU2chCKmeMOA+
         w9OvZjlCzjFdD1D3iOdNKy6APSKNQ0wC+f1SOQebEChPfW2bBDzNvJvp8C4UkeQ+d91I
         5M1KekWwJlAtdwk3l5sUK/WcxE/ov6UGdN9xynKmPfEgPxiQWLzZCvv3YjGGh7GsUVSK
         eUW8hxSqGR3kdVB2+AygGHDNphMLpCw177lOgOVLYSo5uuqtJs0vyG3LOMSJRa54eiF5
         Fk7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=O5ht9vEP3J2JScYhhEph/n/BHYx9SoVhZ0CMGiHc51E=;
        b=tcQJ2NIoRojq3d09wbgnGZvN8Hk8eHZyZVpofqsQhR7es9SQkgvb2REI5f1Cz/uZ6d
         awRUHdidi67UfT/D9s8B1WEgsYhnYTiBEVPD7XEuaUO3yuKaURX+GE/9mlJxHFp9JqHF
         zM5oDoPqiKQK0Xm8+lciSG0ZJrkLcisWphAiGYUk6SB5kg3pdvZCpq3PCOAp3jLOwphw
         kw2v2fv2gk/i4di7kcH0tRUv/YZnrPg+Td9e+7LcxXjIO0aZmCvF2qb7mca4GGFcOMLB
         jzipwo8AUyaSNzi9glGplA9tRDs9rBaFV9RD9dDSn5gYQwG1EIWSW/mkkmC9gDSDOJLm
         aJmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i46si21353118qte.104.2019.07.19.04.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 04:42:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9D6DEC057E29;
	Fri, 19 Jul 2019 11:42:10 +0000 (UTC)
Received: from [10.36.116.220] (ovpn-116-220.ams2.redhat.com [10.36.116.220])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 98DD55B6A5;
	Fri, 19 Jul 2019 11:42:08 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Oscar Salvador <osalvador@suse.de>
References: <20190718142239.7205-1-david@redhat.com>
 <20190719084239.GO30461@dhcp22.suse.cz>
 <eff19965-f280-6124-8fc5-56e3101f67cb@redhat.com>
 <20190719091313.GR30461@dhcp22.suse.cz>
 <48ea1d5d-ce40-aaad-b9fe-006488ed71dc@redhat.com>
 <20190719113647.GS30461@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c203ae99-e47f-a7dd-83f0-93196125db70@redhat.com>
Date: Fri, 19 Jul 2019 13:42:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190719113647.GS30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 19 Jul 2019 11:42:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.07.19 13:36, Michal Hocko wrote:
> On Fri 19-07-19 11:20:43, David Hildenbrand wrote:
>> On 19.07.19 11:13, Michal Hocko wrote:
>>> On Fri 19-07-19 11:05:51, David Hildenbrand wrote:
>>>> On 19.07.19 10:42, Michal Hocko wrote:
>>>>> On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
>>>>>> We don't allow to offline memory block devices that belong to multiple
>>>>>> numa nodes. Therefore, such devices can never get removed. It is
>>>>>> sufficient to process a single node when removing the memory block.
>>>>>>
>>>>>> Remember for each memory block if it belongs to no, a single, or mixed
>>>>>> nodes, so we can use that information to skip unregistering or print a
>>>>>> warning (essentially a safety net to catch BUGs).
>>>>>
>>>>> I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
>>>>> node that is magic. Why should we even care? In other words why is this
>>>>> patch an improvement?
>>>>
>>>> Oh, and to answer that part of the question:
>>>>
>>>> We no longer have to iterate over each pfn of a memory block to be removed.
>>>
>>> Is it possible that we are overzealous when unregistering syfs files and
>>> we should simply skip the pfn walk even without this change?
>>>
>>
>> I assume you mean something like v1 without the warning/"NUMA_NO_NODE -1"?
>>
>> See what I have right now below.
> 
> Yes. I didn'g get to look closely but you caught the idea. Thanks!
> 

Will do a quick test and resent later this day, thanks for having a look!

-- 

Thanks,

David / dhildenb

