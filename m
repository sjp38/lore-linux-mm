Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE0AC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:18:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45C4C2087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:18:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45C4C2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A03688E0008; Thu,  1 Aug 2019 05:18:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B4908E0001; Thu,  1 Aug 2019 05:18:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82F0E8E0008; Thu,  1 Aug 2019 05:18:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 606BF8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 05:18:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o11so55492770qtq.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 02:18:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=wrCKiOW16+oui4BgBlYyl1DNcG3393teG5Vd5AWe4eQ=;
        b=hJDfD/8KpZv60HWX4TdB4PsQxHgS/QdnXjU/jxprigGSecu2WC8hiYQakcFq0iojKD
         q2mUaKldIJGSI2IfEimEoJOiZD2alXodJ/UG7SDtFmBjrdSxeldzEHI+RmvRRXfWBrgd
         HmzCNQz1ys7i84tWf2yBFQHdmjzn1zDosee5TRYojFEN+ZuYU9NmhqEfTag0YOqd00Xt
         Qwdx5jkfH1zZtXL/iy4QKi3KklXTC7TLI6H3goeUoPTIwqfC//CQ381YHlK1UjWgazwD
         eYxBPtBn1sXBE0NAdpocOmZqds+Lyv7miT6cIADbfze8rffGBQb3eEb3+ohKvQ8KZy+G
         h7PQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXI+m8GjhDx0yvGWkuJU+AWo5L05Bb7ssVjdo+Hh2LGK+ZJfAUX
	Lca58YxfDl1+qo0c/pWvjk8/ffPuZRsCYq+WTasHQ9LB8zzvsreob7hlkRjsOXa+dIUvxRNn4OZ
	uUmdZleJVbXwTjo7XoTYeicHqE5114Mrt1MBgE+Rw6ftKeHTT8OMcysM0UVdoheCWaA==
X-Received: by 2002:aed:222d:: with SMTP id n42mr88931502qtc.144.1564651129124;
        Thu, 01 Aug 2019 02:18:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzViE92nmgwgwHoGjte/o7ZcjfJZksoXJ+PFHBJbGYcBL5N7jCiaJ9GkrSYU4ykjemN12YB
X-Received: by 2002:aed:222d:: with SMTP id n42mr88931464qtc.144.1564651128321;
        Thu, 01 Aug 2019 02:18:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564651128; cv=none;
        d=google.com; s=arc-20160816;
        b=ebmG9/jacL5zUr79/teQ3OWpgkWrAnEDqfTE0nhK7G9PfA7X2o51Pq/akxnzBa78hl
         AxJcTuesmK60MVRwQlNOz3gSc//mvU1Te3SNOMX7g5Sntaar6/hgKPWI1mmlWp02c2g6
         wSJ2L+0KZFH4EeGRGYOgFqlRg/u8IYwm4HzJKK5oD7L4rpMEoxqzMvazWHgxR7lWQR0P
         4IIj02fiMlxj9kaDko+kOual7xvTD3YgxoORwBcps7HlUjxcmu6kmCoK9HyR4OVs0rZ5
         pPi3Eolf3yb7I8ciXUnnHPC5TEnWJjFg7rEkhCrlY3mu6mlfthMUWc8G0Q5OZDPYjJ01
         tQqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=wrCKiOW16+oui4BgBlYyl1DNcG3393teG5Vd5AWe4eQ=;
        b=OnSF688cU7DCWHfx67boaDDX8nFTZFZ3RucWyKAYD3ILLK1fjkCl3WAWaHGeKmI+E3
         CvVvJ5MnyR2wmJp60oiNeYh3VcOxssX883bvvcdsdmn4cMKIrTtBxfbHY17j5i3cLXQG
         RGWwp0k+Z0LoYwD1X472DJzindSdhV0mutcBcfepMqfBah0HKGg7EqqSXy0z1NReva9c
         jEePpUO35LXWAuFlrBJrS8kodqHZfJq0ubpl0nkRVuVkp9Dsl7kc5FIwTQ7GxlO7yDAq
         U49yPJfMYoiweh3d0NOHTRJioSd79JbJ5jFwTwc9URM3BY0VEavx2JbuAXiRfb8D0Q89
         orZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b184si37036864qke.35.2019.08.01.02.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 02:18:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2FF1BC049D62;
	Thu,  1 Aug 2019 09:18:47 +0000 (UTC)
Received: from [10.36.116.245] (ovpn-116-245.ams2.redhat.com [10.36.116.245])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D633319C70;
	Thu,  1 Aug 2019 09:18:43 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Michal Hocko <mhocko@kernel.org>
Cc: Rashmica Gupta <rashmica.g@gmail.com>, Oscar Salvador
 <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
 <20190801072430.GF11627@dhcp22.suse.cz>
 <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
 <5e6137c9-5269-5756-beaa-d116652be8b9@redhat.com>
 <20190801073957.GH11627@dhcp22.suse.cz>
 <20190801074836.GI11627@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <48340e96-7e6b-736f-9e23-d3111b915b6e@redhat.com>
Date: Thu, 1 Aug 2019 11:18:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190801074836.GI11627@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 01 Aug 2019 09:18:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.08.19 09:48, Michal Hocko wrote:
> On Thu 01-08-19 09:39:57, Michal Hocko wrote:
>> On Thu 01-08-19 09:31:09, David Hildenbrand wrote:
>>> On 01.08.19 09:26, David Hildenbrand wrote:
>> [...]
>>>> I am not sure about the implications of having
>>>> pfn_valid()/pfn_present()/pfn_online() return true but accessing it
>>>> results in crashes. (suspend, kdump, whatever other technology touches
>>>> online memory)
>>>
>>> (oneidea: we could of course go ahead and mark the pages PG_offline
>>> before unmapping the pfn range to work around these issues)
>>
>> PG_reserved and an elevated reference count should be enough to drive
>> any pfn walker out. Pfn walkers shouldn't touch any page unless they
>> know and recognize their type.
> 
> Btw. this shouldn't be much different from DEBUG_PAGE_ALLOC in
> principle. The memory is valid, but not mapped to the kernel virtual
> space. Nobody should be really touching it anyway.
> 

I guess that could work (I am happy with anything that gets rid of
offline_pages()/device_online() here :D ).

So for each node, alloc_contig_range() (if I remember correctly, all
pages in the range have to be in the same zone), set them PG_reserved (+
maybe something else, we'll have to see). Then, unmap them.

The reverse when freeing the memory. Guess this should leave the current
user space interface unmodified.

I can see that guard pages use a special page type (PageGuard), not sure
if something like that is really required. We'll have to see.

-- 

Thanks,

David / dhildenb

