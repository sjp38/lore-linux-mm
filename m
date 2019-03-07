Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E960C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:28:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07C8920684
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:28:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07C8920684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADB998E0004; Thu,  7 Mar 2019 16:28:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8B848E0002; Thu,  7 Mar 2019 16:28:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 953D68E0004; Thu,  7 Mar 2019 16:28:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68E578E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 16:28:28 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id f24so16668398qte.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 13:28:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rIqgl/6/WFCRjPs27GP+si0pYdgDZ7NndsX3jKTFacw=;
        b=tYd+Z9bSUVpM0fb0Kjd/FM8ndIgbpbB1dzI4UiMrDZK38SFKrqFoFveoINQ9f5OhUg
         6wJRY8Gx5GWvh0KrZR5KZrLg218ms+M2pfWDMkxf7G6sjmwURhGXPN6Qv6JN+rQnJZ82
         RZ0JvSl/P8cTYWOwyBvjAgAODNg07d7mpriwwAt5SY78RyqpdpS7JCnCIrRA1tgwUK2F
         CsmZ4yuuNRgS1M0vYDfKBrkoDTAHjv0pcdlLxG18VvNzu1GSCjjObxquOInIgg0xvL9z
         kOiq6adx1ms311ngmZoAuyk4AW7FwLBRviNFg1BA0RjNV3qSXh8nm/yxB/+fMqRdyN7T
         eqog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXyZuuoOmbuNpTCbxXiTCKg3ynIL5LN0OtJj2WZoOJIJze+4NT0
	D89nmPYA4PvIXn0jifBUaMXnHWM8ETk6Zrlg6sl1TgrAAFxhndD4RYB67+oc/0KWAL6XCuj5MF+
	5XwbRF+sJ6zN3uxGHZLkJp/KD9Oic1sfEZzPWI+4ktDHh3Dtv6v4iO+YrzGYf1tMaag==
X-Received: by 2002:aed:2269:: with SMTP id o38mr12356965qtc.222.1551994108205;
        Thu, 07 Mar 2019 13:28:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqyk4/rP/+qChkdUz+NFml9M1JM1zfzK3i2HsCgA67h6fLsM0kTN6OIAC+9/7SZChx1RvY4q
X-Received: by 2002:aed:2269:: with SMTP id o38mr12356909qtc.222.1551994107293;
        Thu, 07 Mar 2019 13:28:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551994107; cv=none;
        d=google.com; s=arc-20160816;
        b=GFn1KTt6LDM5s3QcsVJcUVC47yfT+Klzply5cMo2+AZ/Q/I89wDlJez/QSqZYd/u9s
         bUuOXEDj7pVljPw4V0aLk/jZ0M5MvGVGAd448dpVMQdaBZeuDCSvr0i5u6/vdMx/ToW6
         7wLIx/YPkNk4vNKtVY8mh6+/dj5cFJ0nvgYNRtBRGvCwmp9XEIKtA85mdRa9AkJ6lDe4
         UwH4qSxvGE+AtOaPKIvD2rcWsVNLhKNSTN2O2eJR6xNi5pxYc2itG1ylqdblXoc+kCCq
         NGVjUsS+yWnj5pcNILmmz3/DDBK/d4CO903N7LeCL3Pj6Ld+8Wt6Hr0zD//VqqbeMG58
         STQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=rIqgl/6/WFCRjPs27GP+si0pYdgDZ7NndsX3jKTFacw=;
        b=Tj+YvwM1sKYV8IatMA8VuKVITL0QERwj/Os5/SaFGtknDHrVhTkUAhVAvtduY6OX1k
         vidJToLVxqyoh+Ll/7fVHimGswvTAUauDFGgQZYM3b4iCLBqlIZH5QOLGo+bzZolHGWc
         GRYK0eEm91I8U1MaGc5JEiqOrDTbsgMRnn1mWL6mlyyirEyLGOGuEWaR2djolrVNTCAx
         1LRH/glFi8lHcRs6zz1qWRysYFb7cEJVrxxdG2LRm/ifB2PZG30uTTrJ9YUy+7EhM71y
         zz/wut5lhJp56YRLirRlHl6I0RGcAy7o+Yi02uQyzbUpnHe2daeHC4yakWVA/eQs6tCt
         fUnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w130si116502qkw.222.2019.03.07.13.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 13:28:27 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2FAFAC05090A;
	Thu,  7 Mar 2019 21:28:26 +0000 (UTC)
Received: from [10.36.116.67] (ovpn-116-67.ams2.redhat.com [10.36.116.67])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DFFE75D786;
	Thu,  7 Mar 2019 21:28:14 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
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
 <CAKgT0Ue=Y-6-mzqzZ+tJYvfOd4ZeK59okeZKjfJ7LHwhbdpY_w@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f15ccc0d-7c92-bab5-cc24-f49a4fea576f@redhat.com>
Date: Thu, 7 Mar 2019 22:28:14 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ue=Y-6-mzqzZ+tJYvfOd4ZeK59okeZKjfJ7LHwhbdpY_w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 07 Mar 2019 21:28:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.03.19 22:14, Alexander Duyck wrote:
> On Thu, Mar 7, 2019 at 10:53 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>>
>> On Thu, Mar 07, 2019 at 10:45:58AM -0800, Alexander Duyck wrote:
>>> To that end what I think w may want to do is instead just walk the LRU
>>> list for a given zone/order in reverse order so that we can try to
>>> identify the pages that are most likely to be cold and unused and
>>> those are the first ones we want to be hinting on rather than the ones
>>> that were just freed. If we can look at doing something like adding a
>>> jiffies value to the page indicating when it was last freed we could
>>> even have a good point for determining when we should stop processing
>>> pages in a given zone/order list.
>>>
>>> In reality the approach wouldn't be too different from what you are
>>> doing now, the only real difference would be that we would just want
>>> to walk the LRU list for the given zone/order rather then pulling
>>> hints on what to free from the calls to free_one_page. In addition we
>>> would need to add a couple bits to indicate if the page has been
>>> hinted on, is in the middle of getting hinted on, and something such
>>> as the jiffies value I mentioned which we could use to determine how
>>> old the page is.
>>
>> Do we really need bits in the page?
>> Would it be bad to just have a separate hint list?
> 
> The issue is lists are expensive to search. If we have a single bit in
> the page we can check it as soon as we have the page.
> 
>> If you run out of free memory you can check the hint
>> list, if you find stuff there you can spin
>> or kick the hypervisor to hurry up.
> 
> This implies you are keeping a separate list of pages for what has
> been hinted on. If we are pulling pages out of the LRU list for that
> it will require the zone lock to move the pages back and forth and for
> higher core counts that isn't going to scale very well, and if you are
> trying to pull out a page that is currently being hinted on you will
> run into the same issue of having to wait for the hint to be completed
> before proceeding.
> 
>> Core mm/ changes, so nothing's easy, I know.
> 
> We might be able to reuse some existing page flags. For example, there
> is the PG_young and PG_idle flags that would actually be a pretty good
> fit in terms of what we are looking for in behavior. We could set
> PG_young when the page is initially freed, then clear it when we start
> to perform the hint, and set PG_idle once the hint has been completed.

Just noting that when hinting, we have to set all affected sub-page bits
as far as I see.

> 
> The check for if we could use a page would be pretty fast as a result
> as well since if PG_young or PG_idle are set it means the page is free
> to use so the check in arch_alloc_page would be pretty cheap since we
> could probably test for both bits in one read.
> 

I still dislike spinning on ordinary allocation paths. If we want to go
that way, core mm has to consider these bits and try other pages first.

-- 

Thanks,

David / dhildenb

