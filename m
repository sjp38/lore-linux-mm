Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEEB5C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:39:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72BB2206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:39:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72BB2206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF1758E0003; Wed, 31 Jul 2019 05:39:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA2148E0001; Wed, 31 Jul 2019 05:39:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D69048E0003; Wed, 31 Jul 2019 05:39:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B38A48E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:39:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s22so60882601qtb.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:39:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=2hZFfhjwWQ79elgtayDS9ndSc9ZrktgyA5IbLdSSeVE=;
        b=aE8x94Q7YL7l1HcvyLZJKHWalqgcwU2j8HzFTu6Do1GNqnHuYwYdk9/rPBRXWi2ngL
         v1l0uu8AvoX3iVM+uf6NGXUu1ACpWyafOOq7D6PkxCCFnNpP43zQXdD5nxB1XHyZzIDr
         QWUQJk+ExIu9/8mCIdhypAuF2q2K0n5I3SICyyrUDmpjo2gEVw2aT8/Yzr5doZN5WQhU
         4dYYgWoEu5c8oSx8BhYtO0jXZ2SNW37iH/2kmQm0SjFeSIxYULcppA05WiuKtRkNZcOZ
         ZURa2nfWyKK0v8vn5Vs69rnXnbi9FDfL9FjO4dCRsZAKl2ejSSC2MuFuiH4WoOSB+heE
         lmJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQrXnqDKm2tWNW49lkPyorphC1leGGAxlgMEziRW6VFGlf2VLV
	r5ZiylPik4/70EGXy0bEDCk2svDBJuaWX3kTI1ArbUJstrl2d1/jWt+oj3Bs6fjlEvQgSwDaVMC
	QfiSgnavg6FuFQNyeqICbUg4rn7ry6IDym2bhm97751npsRMBuVHe0wlhMAo8f4Ip6Q==
X-Received: by 2002:a05:620a:1006:: with SMTP id z6mr46947368qkj.312.1564565963461;
        Wed, 31 Jul 2019 02:39:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1GMNdXdCyqyJbX2chcL1qhfJjmUvnsuUWAsAdYehZFmM41m47hmcA6Ik367XN1YxEmkG6
X-Received: by 2002:a05:620a:1006:: with SMTP id z6mr46947338qkj.312.1564565962825;
        Wed, 31 Jul 2019 02:39:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564565962; cv=none;
        d=google.com; s=arc-20160816;
        b=EybGQvOb7xs0WHXaSkSuz6fwMXUgPLHuFf5ZtqB1csQporWHjje0DD+ECbOT68j2p/
         ZlqKnkGzJnFcnAfqFwJqQqTjCBn2mdVCIWAAxAH467BDdQwyzVSfFgi+mLFfJc1YPlQl
         CqO97kGwf144dp8FHrdHpqTuGx1bgBQgbdDZlIeUjkzLAL3xvNvp2I4d0iKD+DDtPQ1y
         LNfVBi7Cf/ITEgXbzYgzwZAdlLnlnXYZlinKBAH8Tz94JOBVGoyuFNVUaHCqalVYjXdo
         jV9yuDkt0N35btaMupRcrOj01EsY1alBQzfDXbY/Si6yPj4bj1z8I+UVcGzQS4sW0/2j
         nWUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=2hZFfhjwWQ79elgtayDS9ndSc9ZrktgyA5IbLdSSeVE=;
        b=JtK+p+IGUfGBvuF7BH7nN09f8jM46p5/LcQCUaSlR8jE8pMsNXvRm/rcuPQBddj0Tc
         efQ8CwCGTlSTeLFjZh17s6aInzCrqg3ppdjRGKOiT5WHntGZzxGf9TWVUxQ/RvE3ojp2
         KkC6WKvOaz0CJ/zA8L/qgaja3E5moBf6NrvTmVPH11t/pagWDIi6b004vxUMSAswl+8C
         oN0C5/h/KqRBA4xAcwMJ4Qu75kxG1C+b9xFicN9GpW8Q2E3GzOpeYsAHNAhtM+ibFtjd
         CYm/9H4YR3ForEybjSVmrUq4kY558ProwxG7Uhj2gvjHtmyxZdrVgzfkp5HZrVGBV6/q
         iXzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p126si21058280qkf.349.2019.07.31.02.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 02:39:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BAFEC30917AC;
	Wed, 31 Jul 2019 09:39:21 +0000 (UTC)
Received: from [10.36.117.32] (ovpn-117-32.ams2.redhat.com [10.36.117.32])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5E8825D9C5;
	Wed, 31 Jul 2019 09:39:19 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Rashmica Gupta <rashmica.g@gmail.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <0cd2c142-66ba-5b6d-bc9d-fe68c1c65c77@redhat.com>
 <b7de7d9d84e9dd47358a254d36f6a24dd48da963.camel@gmail.com>
 <b3fd1177-45ef-fd9e-78c8-d05138c647da@redhat.com>
 <7c49e493510ce04371d8d6cd6c436c347b1f8469.camel@gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <5454a6b8-4abc-0922-63a4-a7c0e9d44fcf@redhat.com>
Date: Wed, 31 Jul 2019 11:39:18 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <7c49e493510ce04371d8d6cd6c436c347b1f8469.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 31 Jul 2019 09:39:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.07.19 04:21, Rashmica Gupta wrote:
> On Mon, 2019-07-29 at 10:06 +0200, David Hildenbrand wrote:
>>>> Of course, other interfaces might make sense.
>>>>
>>>> You can then start using these memory blocks and hinder them from
>>>> getting onlined (as a safety net) via memory notifiers.
>>>>
>>>> That would at least avoid you having to call
>>>> add_memory/remove_memory/offline_pages/device_online/modifying
>>>> memblock
>>>> states manually.
>>>
>>> I see what you're saying and that definitely sounds safer.
>>>
>>> We would still need to call remove_memory and add_memory from
>>> memtrace
>>> as
>>> just offlining memory doesn't remove it from the linear page tables
>>> (if 
>>> it's still in the page tables then hardware can prefetch it and if
>>> hardware tracing is using it then the box checkstops).
>>
>> That prefetching part is interesting (and nasty as well). If we could
>> at
>> least get rid of the manual onlining/offlining, I would be able to
>> sleep
>> better at night ;) One step at a time.
>>
> 
> What are your thoughts on adding remove to state_store in
> drivers/base/memory.c? And an accompanying add? So then userspace could
> do "echo remove > memory34/state"? 

I consider such an interface dangerous (removing random memory you don't
own, especially in the context of Oscars work some blocks would suddenly
not be removable again) and only of limited used. The requirement of
memtrace is really special, and it only works somewhat reliably with
boot memory.

FWIW, we do have a "probe" interface on some architectures but decided
that a "remove" interface belongs into a debug/test kernel module. The
memory block device API is already messed up enough (e.g., "removable"
property which doesn't indicate at all if memory can be removed, only if
it could be offlined) - we decided to keep changes at a minimum for now
- rather clean up than add new stuff.

> Then most of the memtrace code could be moved to a userspace tool. The
> only bit that we would need to keep in the kernel is setting up debugfs
> files in memtrace_init_debugfs.

The nice thing is, with remove_memory() you will now get an error in
case all memory blocks are not offline yet. So it only boils down to
calling add_memory()/remove_memory() without even checking the state of
the blocks. (only nids have to be handled manually correctly)

-- 

Thanks,

David / dhildenb

