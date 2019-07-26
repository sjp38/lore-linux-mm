Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1262C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FC44229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:37:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FC44229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2292A6B0007; Fri, 26 Jul 2019 05:37:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DA7F8E0003; Fri, 26 Jul 2019 05:37:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A1B28E0002; Fri, 26 Jul 2019 05:37:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC3326B0007
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:37:11 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k31so47024603qte.13
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:37:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=0pyeHz4OHPND0jaksdmVOuvNWcMK6gzWjnEZb4s/Si8=;
        b=TOJ1h801vbwrw0UYa+E+IqGzPjp/b1FJCmizWcveWCbrXSiXApfGC/2Jz02c7sHHH2
         4nDL9+Z9SbLHk3/eLSpsBbU8fZaoEHHI1YYgRXK6jVLKPAZ530ocd3xbEs2flKLVJdJP
         agnz/FJ+HsHcgCFFzcGhyze0bFQzedXiINILmkoXgF6umHYTX/IZwff60zf0xtMv8NL/
         ccLTA8UU54J9sfCmtXB+e0MVxcFvpGVsjb36j+xA15OK9ALEHnVLMvQ9TnJzfZDLDuzP
         aRGu7MK6l1tMoRN0VsyfBUW32+0U3Cs2xNBZKxAd9AyIs5MNb1cDyMdG+mhY3sO7ny+R
         up1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVgKqEYLY8NgjBjK7sLZnAqZ/pheNuqmMjaRAPZ1n0Og+Pfam8R
	yU7WDp7UuGlk3hglsUVrWsWFuz7XcXm584msRVuzkdhTtdrhoMV+6sAC40me+cLCK3+ytb8lQWP
	zj+X3S9NQDe0qTIblFwi2IJOWZXztmDFjPoN3m2bIjd3G5X1ZL/Wc/aI5tRXFlGMkew==
X-Received: by 2002:a05:620a:b:: with SMTP id j11mr27921459qki.352.1564133831672;
        Fri, 26 Jul 2019 02:37:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrOBAoU5zr2WiYDLR4LIa9SU0GZGqRpPPfM3o8S4lFdIbcCQrUvbqdMy0XW05EGw1dYuFE
X-Received: by 2002:a05:620a:b:: with SMTP id j11mr27921430qki.352.1564133831077;
        Fri, 26 Jul 2019 02:37:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564133831; cv=none;
        d=google.com; s=arc-20160816;
        b=KtY6NjEQR/tmVbksSsxHpm1OoJ3KeWnD1J3Rv+pJzBgPCUfpD/d71ZIoy5bHeBTpiE
         AypqHXgMSccgoA4gJod9wjyk0HFseh+HQYsNc6NjvEnZruVIUnSIBiU0ZHgVFa00PWs6
         4IvP3K7JXwsUoesT6IlieymiNFJoXZOkkl502aqMWOemgTQuUpjlhHr/hlXRbZgub2pk
         FdmmiORMhJHjJZlJjANAUGP+UCIKA0Z16s843FqqSNLHH7gRfDhfNfaAtVzKF6TCrKq/
         xLUz4O12IZfn0ZBHy8xfpNctt1qgbofibMaSryC2mcRj3BpNDqwikC2w5WpEMZOCmiPx
         wFQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=0pyeHz4OHPND0jaksdmVOuvNWcMK6gzWjnEZb4s/Si8=;
        b=PJce6zVIvKYmOwZETwBKALcSTYHlw/Tv4cmA7uqlQDXG4QmPztzs2EfTXG7oWsEQLC
         G6lc7zXJje7i0zrjIM5WRZxjMk7Heq2yc/dFizAQuLPdSHVoR2QoBu3pnYiR23O7nwiW
         IVXGucCLt+zB0O7L/Wt3iVFOukp1OU3VGyQXTfl9AEAZqUF3X5gBkfuLTvSLLVKFMEFi
         klf+a/wbiR7LPGMqYYAU+AxkfumR00wGhu0TPqvBHSQ9XTix4QRfkrPrL+0m6i1ajK1/
         iqdnoPCpCb4nEjMlbZrFC7wpfF59jv4UorEpJFhXDaMhmRJ8X1QJyWfZlYND5l3rRqfB
         mg0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p15si18367417qvj.11.2019.07.26.02.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 02:37:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F0B030C133A;
	Fri, 26 Jul 2019 09:37:10 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2703E600C4;
	Fri, 26 Jul 2019 09:37:07 +0000 (UTC)
Subject: Re: [PATCH v3 1/5] mm,memory_hotplug: Introduce MHP_MEMMAP_ON_MEMORY
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, mhocko@suse.com, anshuman.khandual@arm.com,
 Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-2-osalvador@suse.de>
 <8b60e40a-1e8a-1f7c-a31d-ad2e511decd5@redhat.com>
 <20190726092959.GB26268@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <bcb326c5-7a68-86de-ca92-1d41cfcb9bfd@redhat.com>
Date: Fri, 26 Jul 2019 11:37:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726092959.GB26268@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Jul 2019 09:37:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>
>>>
>>> or
>>> 	add_memory(0x1000, size_memory_block * 3);
>>>
>>> 	[memblock #0 ]
>>>         [0 - 1533 pfns    ] - vmemmap for section#{0-2}
>>>         [1534 - 98304 pfns] - normal memory
>>>
>>> When using larger memory blocks (1GB or 2GB), the principle is the same.
>>>
>>> Of course, per whole-range granularity is nicer when it comes to have a large
>>> contigous area, while per memory-block granularity allows us to have flexibility
>>> when removing the memory.
>>
>> E.g., in my virtio-mem I am currently adding all memory blocks
>> separately either way (to guranatee that remove_memory() works cleanly -
>> see __release_memory_resource()), and to control the amount of
>> not-offlined memory blocks (e.g., to make user space is actually
>> onlining them). As it's just a prototype, this might change of course in
>> the future.
> 
> What is virtio-mem for? Did it that raised from a need?
> Is it something you could try this patch on?

virtio-mem is a paravirtualized way of hotplugging/removing to/from a
guest. (similar to, but different to e.g., the hv-balloon). It
adds/removes memory to/from the system. In the long term, it will try to
also act similar-but different to a balloon - but that will require more
work. In the first shot, it's all about adding/removing memory in the
smaller granularity possible.

The old prototype was

https://lwn.net/Articles/755423/

Since then, a lot changed. Some more updated information is at

https://events.linuxfoundation.org/wp-content/uploads/2017/12/virtio-mem-Paravirtualized-Memory-David-Hildenbrand-Red-Hat-1.pdf

There is also a recording of the presentation on youtube.

The current prototype is unfortunately not in a state yet that allows me
to test with this patch set - my Master's thesis consumed most of my
energy during the last year. I just started hacking on it again.

-- 

Thanks,

David / dhildenb

