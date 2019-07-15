Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCCC0C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 898B52064B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:58:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 898B52064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28F9B6B0269; Mon, 15 Jul 2019 06:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 217256B026A; Mon, 15 Jul 2019 06:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B7E26B026B; Mon, 15 Jul 2019 06:58:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE5526B0269
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:58:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s22so14401640qtb.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 03:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=30vJhecBiJXghL0EIWpg31X9BQkDdWm06nnqLtw/77I=;
        b=cM9XnuGps+o8EdfoY2LEX9gb1KfL7qw+fjNydIhNfQIt8O9MxIZj3R4nOHob/9U5HR
         jftuy03vLWolI/9j/IHqiCk01gjpjEhvYAt/mCqRkR3BZNX6GCLzKPHjprfcUYXSsX8c
         HXgrGPZmu8C5aVJKykAh2BKZO6geukp4XXVgtOitDUF+dBl9cLUhl6OL8aCsEfIHqrkn
         0EqJBzHoeKwugM1PEXBMaLFH3z309a9c09iIoBIsOHUXvH0B8YP31D64DMjsxx07bJy0
         AkPR3DktKwud0+vdBjhlAd8zFLcUxYQZz7P+qytaqjfBnA0W3tYcGuzFaVrR6QMomDkw
         f2PA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXTvxfq/KETsfOzh9Udc32Cp3Jn4nA968kuMVgi610iADnGMkSQ
	FHP/t6YmVjB0f610dKbCY16l0kcdchoTPuGiciDH2c6XcCxfBa3XR+SYjZpWzxK49ZQo2o2E30c
	zdT5Z64Xx7BEUrE8SBDeuhRaqKBcK+D43VIvGoyXOZMxZvf5njYzLs1WdCENR7hnrUw==
X-Received: by 2002:a37:660d:: with SMTP id a13mr16485258qkc.36.1563188309687;
        Mon, 15 Jul 2019 03:58:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw37Z3jILiylrB11RtVjrr968J/ohMVNx+9I+L7voW5MXFKnXhMTg0+vWBgQ+lq0yZEDR08
X-Received: by 2002:a37:660d:: with SMTP id a13mr16485235qkc.36.1563188309142;
        Mon, 15 Jul 2019 03:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563188309; cv=none;
        d=google.com; s=arc-20160816;
        b=y1+7HexwxRmUE2H0PnMNoAyVBCUOTLAR0MqVne+AHm5dDm4ao6HIJCXTTkMyd0N25I
         CNhdWuNe6TjzrXOVSdlKwcpv2L+PgpWvLGUILC0Vdzqns16wsLv1FTXormAOT8x/b8XL
         GoZpqNsb+jwP/kU3fYRap9i61LVZ4uMESdASj32L2Wdq/6LlQAQLrcGJmCB67OT+J+Ho
         7dMogS7fAPT0c54KdiqDN6AuqMykhbFQ/6QX8bYGjm2HhOdPKFQqyLZphAkpM6B5/aAj
         qGzdmYDIB3PRjG2kpdGbhcbCGYpXqf3gMfb4r0Se3EPvAYEcern8yAUlLy1RIIsxONgh
         S81g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=30vJhecBiJXghL0EIWpg31X9BQkDdWm06nnqLtw/77I=;
        b=LwHBFY25pBFxFyjujnQQn23nxs7jOjprgRrQjanL3lGWUCxWmYFnZZ3P5rRlS8CuVJ
         u6fT0OUVgNluF2YsgThenM0U3dB8AxF3938Q4Qr1PYaiL9Ju0QIPtCrbvwJsLEki548k
         EXAAP6X1j1WE3t9k4dPX0PBNY9GmknIKS9dNwZ4UmlcoSl906cnSyteVQpqvTHL/Fv5d
         9pS95DkFkeowFaAFJ1cyx3z3IeOoL1nvfjKcJ2LOgEk7M18EKiqAdMU1sbwbhgSvE6yM
         PJVtrTUUFOZWr1K+5bgq/s4r2SslmGQ3OBTyKwyaYJf01JuqIgkMKsCd8HtjK7XeqTMx
         JcWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o26si10866513qve.74.2019.07.15.03.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 03:58:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 10740356C4;
	Mon, 15 Jul 2019 10:58:28 +0000 (UTC)
Received: from [10.36.117.137] (ovpn-117-137.ams2.redhat.com [10.36.117.137])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2036C5D9D2;
	Mon, 15 Jul 2019 10:58:22 +0000 (UTC)
Subject: Re: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Wei Yang
 <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Andrew Banman <andrew.banman@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>, Oscar Salvador <osalvador@suse.de>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-10-david@redhat.com>
 <20190701084129.GI6376@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <54a2f873-374e-b132-ae0f-4924a7e332c0@redhat.com>
Date: Mon, 15 Jul 2019 12:58:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701084129.GI6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 15 Jul 2019 10:58:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.07.19 10:41, Michal Hocko wrote:
> On Mon 27-05-19 13:11:50, David Hildenbrand wrote:
>> Let's factor out removing of memory block devices, which is only
>> necessary for memory added via add_memory() and friends that created
>> memory block devices. Remove the devices before calling
>> arch_remove_memory().
>>
>> This finishes factoring out memory block device handling from
>> arch_add_memory() and arch_remove_memory().
> 
> OK, this makes sense again. Just a nit. Calling find_memory_block_by_id
> for each memory block looks a bit suboptimal, especially when we are
> removing consequent physical memblocks. I have to confess that I do not
> know how expensive is the search and I also expect that there won't be
> that many memblocks in the removed range anyway as large setups have
> large memblocks.
> 

The devices are not allocated sequentially, so there is no easy way to
look them up.

There is a comment for find_memory_block():

"For now, we have a linear search to go find the appropriate
memory_block corresponding to a particular phys_index. If this gets to
be a real problem, we can always use a radix tree or something here."

So if this becomes a problem, we need a separate data structure to speed
up the lookup. (IOW, this was already the same in the old code)

Thanks!

-- 

Thanks,

David / dhildenb

