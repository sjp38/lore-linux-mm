Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DAF2C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBD2F2085A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:53:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBD2F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 767FE8E0003; Fri,  8 Mar 2019 06:53:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 716C28E0002; Fri,  8 Mar 2019 06:53:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 605958E0003; Fri,  8 Mar 2019 06:53:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37B908E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 06:53:42 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y6so15862561qke.1
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 03:53:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=otfmxpytj0ejT3cnTAyieVK3RWaV2EZut+bgtiVy3Rw=;
        b=pqJvr6BMWoEhcpBU663lYCT2nK2fgba9cLfMJB83ovsC6vnSAxZKDXz3N3AQZXRRxi
         YZkuNS1/r1xGawuttbFnVSMpwOToMr2GHpk8LW2FPn3+jziD8nKv9HAUmHVwPx2mP89n
         zo34FD59XI5F0HZQWmTHw/xIpN5vSXELQU8pjPbBDu1J6mKDpSE7cBJfAPvHtvePz/NG
         K+w+n3XJDA6lrZhW43L6JbUahDe5euXrqJMBEJq8/48cyyy67zUqEcxY7N7oCntyGmU6
         yATZGj6Qp0PKmJLspfi+vS4jzva20X0hc7zuB0kgCS0lr/rcQB5KG16CtfXYECZZQM27
         iBTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7T6YKTABHnIYDE8yYxIATvvuB8mH52ojuQ4pt1DBMu9QTTjtu
	joBTuGpMfXJFGAcFqXHApWtFUNhMYF8yAL4ho1MGdJuyP6oAb29II/2ChyQ0nFQO1t643tIUaEo
	HQGK5uCxjex3a6q9TKJfAN2CRQb8nyeA5Rr6MmnCrtd9ep5Im1I9l3LjEaKEFHW2r9g==
X-Received: by 2002:aed:2a6d:: with SMTP id k42mr14853088qtf.390.1552046021777;
        Fri, 08 Mar 2019 03:53:41 -0800 (PST)
X-Google-Smtp-Source: APXvYqybXqpoZbSAGYEjwvfSMgJOQB5jefHgAWC9y4XHuYW3kfifU5WHkZui7WNeiWCayxU4c00T
X-Received: by 2002:aed:2a6d:: with SMTP id k42mr14853040qtf.390.1552046020807;
        Fri, 08 Mar 2019 03:53:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552046020; cv=none;
        d=google.com; s=arc-20160816;
        b=lFBTX5za3h23zPNfNVzpWgofp0B1cY7YkWk5ULDBLF7eL/rsvIAq8Gmjqw20iyLQcL
         9aF+bEF9FmijELDZtJNWE07euJHBso32UyhZXDIeSB5i92h8zQb3h3+x/LKc9FoCgex0
         hw4OP1O2UFeNV5zUb8yWW9B3nkZx9xz2Z/gauXQ/by2RgpqiyZS3z1cCC6Rl3EeKXad+
         a59L4EnVknf8jV4rQJn2Ex20upuQVj6Yo8Snjzl3ig6HSekGjNhITokOv2lnqSMA0uCu
         7ydMzfpqVOXMZ0GVtVmrCwE8cGEuCp0M6guOI1Kzn2aOfDZQqdpmkoFvf9GRuO5YLA7S
         FXDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=otfmxpytj0ejT3cnTAyieVK3RWaV2EZut+bgtiVy3Rw=;
        b=X1V4gTqkI+Q7FqAtxHLl+eaFjwJ33i1UmayOMtsEIE1wJQtFWchBr1PUu1+Lbl6cVm
         LAtRv/QEDTINks8ZXe54b6kqpH12FsdfvONb0l21Jelp8Fz8FVs7IilaUH83ovYld9t9
         +ZpFQGFxDXFHb7eQyo0kGD61GM0LruAzbPrfzytcHJ6Fd3n4Z6/8Q8wrwjimmn/Hyo3g
         coGMArj8VEKLuC8WihBzIm8adq8thKBOfca9NY023nTwYgG6lVyAA03THD9pNjQ/ah/H
         xQMKgecei7MdBNUZci9OMamkDfhYYYts6N+BJomphVQEm7YxzjcNSrPIkHvJOrtiU6Gh
         b7yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s24si927146qta.16.2019.03.08.03.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 03:53:40 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B68D730D78C1;
	Fri,  8 Mar 2019 11:53:39 +0000 (UTC)
Received: from [10.36.117.67] (ovpn-117-67.ams2.redhat.com [10.36.117.67])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9C957600C8;
	Fri,  8 Mar 2019 11:53:27 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
 <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
 <20190307134744-mutt-send-email-mst@kernel.org>
 <ebca2674-ac15-f1a9-87a4-2ee17a257e4c@redhat.com>
 <20190307212253-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <198b3382-e511-2f7d-e738-5aedcb1a09e6@redhat.com>
Date: Fri, 8 Mar 2019 12:53:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190307212253-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 08 Mar 2019 11:53:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.03.19 03:24, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 08:27:32PM +0100, David Hildenbrand wrote:
>> On 07.03.19 19:53, Michael S. Tsirkin wrote:
>>> On Thu, Mar 07, 2019 at 10:45:58AM -0800, Alexander Duyck wrote:
>>>> To that end what I think w may want to do is instead just walk the LRU
>>>> list for a given zone/order in reverse order so that we can try to
>>>> identify the pages that are most likely to be cold and unused and
>>>> those are the first ones we want to be hinting on rather than the ones
>>>> that were just freed. If we can look at doing something like adding a
>>>> jiffies value to the page indicating when it was last freed we could
>>>> even have a good point for determining when we should stop processing
>>>> pages in a given zone/order list.
>>>>
>>>> In reality the approach wouldn't be too different from what you are
>>>> doing now, the only real difference would be that we would just want
>>>> to walk the LRU list for the given zone/order rather then pulling
>>>> hints on what to free from the calls to free_one_page. In addition we
>>>> would need to add a couple bits to indicate if the page has been
>>>> hinted on, is in the middle of getting hinted on, and something such
>>>> as the jiffies value I mentioned which we could use to determine how
>>>> old the page is.
>>>
>>> Do we really need bits in the page?
>>> Would it be bad to just have a separate hint list?
>>>
>>> If you run out of free memory you can check the hint
>>> list, if you find stuff there you can spin
>>> or kick the hypervisor to hurry up.
>>>
>>> Core mm/ changes, so nothing's easy, I know.
>>
>> We evaluated the idea of busy spinning on some bit/list entry a while
>> ago. While it sounds interesting, it is usually not what we want and has
>> other negative performance impacts.
>>
>> Talking about "marking" pages, what we actually would want is to rework
>> the buddy to skip over these "marked" pages and only really spin in case
>> there are no other pages left. Allocation paths should only ever be
>> blocked if OOM, not if just some hinting activity is going on on another
>> VCPU.
>>
>> However as you correctly say: "core mm changes". New page flag?
>> Basically impossible.
> 
> Well not exactly. page bits are at a premium but only for
> *allocated* pages. pages in the buddy are free and there are
> some unused bits for these.
> 
As I said, we have to be very careful here.

Most parts of struct page can me modified by *the owner* of the page. In
case the page is online but not allocated, buddy is the owner. Not some
kvm/virtio thingy that hooks into some callback.

Manipulating random page bits of buddy pages in *some* kernel module I
consider problematic and will most probably not be accepted upstream.

What could work is, factoring out these parts e.g. into
mm/page_hinting.c, then it gets part of the core mm in some way. Which
would actually be a nice thing to do either way we go.


-- 

Thanks,

David / dhildenb

