Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 653A4C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:35:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17BA32184B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:35:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17BA32184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4EF38E0067; Thu, 25 Jul 2019 07:35:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FF888E0059; Thu, 25 Jul 2019 07:35:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A1FE8E0067; Thu, 25 Jul 2019 07:35:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1778E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:35:39 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 41so38374150qtm.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:35:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=VrVDnmqu9ueijxT3n5f7y4MVWVeyC9Zpjxdvgu8BfWg=;
        b=GffjSM7ev+x1ZiVULhBe69G9Bcz3elolu/BnvY+OJ3TtplqhPOY8XREq0ELKnGp4Sw
         VgQWZupZvoBDQKX+ZfxQ7sNAzL0wx2HNZmjr0j1UlnVwEgFABN+b+nRNYXukkooX2W3+
         pHzS99BGkv/dUmx8K0tEiq/dqfQ7qm7ili/RQLdzso1yLLikD423JKs7HHE969qbyy34
         6V4Z5iuBAZaL8udqOCr2DWjIDDvUTi8FMIZ5PbaAZ7kqdkbppTP9K2O5HjSa433bJJJP
         37Y+opOotPnJyj4q85JznIroc/UhOOpjvkGcB3+rrV5g+kgYlNpUcKwhmI+ASARujkMM
         vmYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVZp5xPUd1rMBZYJnz0xNL02jtc6zMS/tgTWmTEE8wiK3KCKzeJ
	4SneRSIIBFgHSg9FKwqks6rKHXHwv0fwzqeNpUFuKSmMXME30mfXkjTCRWZdBsD5JkGwKsPnBsd
	KDoDAbquPbPtE9DWtv2hFsJH5Y6soitVgXThhAKwiWSI/Y9SCgVdqYAuB75rg4YMi9w==
X-Received: by 2002:ac8:2410:: with SMTP id c16mr61340767qtc.108.1564054539147;
        Thu, 25 Jul 2019 04:35:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyT3k+9ZuIGb3AsE9sA4TiWv9n34KshlqPvnLTZ2zTxDy8BDm1ujzevoMhWh7qWD1caro/6
X-Received: by 2002:ac8:2410:: with SMTP id c16mr61340718qtc.108.1564054538284;
        Thu, 25 Jul 2019 04:35:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564054538; cv=none;
        d=google.com; s=arc-20160816;
        b=porOjQY9ZAFk7D+x7JJdDJSicrUvxSFsDmd0V0aP/cpWJC+NYl8SYis3bWaDx95TkQ
         8yLp5jKtoMIoFmNEhf3W8OnbnNK/k99+8CgOaUleU2VVhCOmroMmV1uDlrGZzv1ohLRD
         0+yZcdG2V7YwJqsTSKnSMaPdWOlJrN1QSI58d6V1qry9dmSgCsyRMl1jlknfDCyfCcLb
         33RxvD7Ndh5XsW2fXq7lVhTV2SyPcT2ELewZ3TcfR4D/SyzGNS6B2QGv2ACa7QHIniVW
         b7dQOPOSu6KkOU6zX+upcm1ZJBYeNw0k7YfSMPcg+QrI0cTrJK3F0CtNMuXruIT2TIew
         GzMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=VrVDnmqu9ueijxT3n5f7y4MVWVeyC9Zpjxdvgu8BfWg=;
        b=X2PYHxvx0vVDITe4kMOE/fryL4PhTtpQu04reHD9PgpX7uGvxXnP2h032reig5aXD/
         dAidtc42YojoIik1vHKV5h1RC9bsEF8EK695O0FiA6UVfUH1Gf2MHQGwTUPVKM3yfJm0
         0S++Wrs9INsBFxzGv+QLN0KKwAgjFz4/YRA+6WqDmBwMyx0T33JMWUj4zU5mvswOWKFq
         SgASmlYmeM2XVHq2S75d/+g/kvDOrd/nH4PFF164U9W+M8zICKa0aWvlCr6YuHayrWr8
         JnvrFcB8VS2lTAFvRkrKKJ40fPF8aasq+/07OmjEvahk5DDFoVkAw94SlU/plLGscMGx
         JUtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i1si30767909qvq.100.2019.07.25.04.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 04:35:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8DBFDC05E760;
	Thu, 25 Jul 2019 11:35:36 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1440A19C7F;
	Thu, 25 Jul 2019 11:35:26 +0000 (UTC)
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
Date: Thu, 25 Jul 2019 07:35:25 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 25 Jul 2019 11:35:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 6:03 PM, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
>> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>
>>> Add support for what I am referring to as "bubble hinting". Basically=
 the
>>> idea is to function very similar to how the balloon works in that we
>>> basically end up madvising the page as not being used. However we don=
't
>>> really need to bother with any deflate type logic since the page will=
 be
>>> faulted back into the guest when it is read or written to.
>>>
>>> This is meant to be a simplification of the existing balloon interfac=
e
>>> to use for providing hints to what memory needs to be freed. I am ass=
uming
>>> this is safe to do as the deflate logic does not actually appear to d=
o very
>>> much other than tracking what subpages have been released and which o=
nes
>>> haven't.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> BTW I wonder about migration here.  When we migrate we lose all hints
>> right?  Well destination could be smarter, detect that page is full of=

>> 0s and just map a zero page. Then we don't need a hint as such - but I=

>> don't think it's done like that ATM.
> I was wondering about that a bit myself. If you migrate with a balloon
> active what currently happens with the pages in the balloon? Do you
> actually migrate them, or do you ignore them and just assume a zero pag=
e?
> I'm just reusing the ram_block_discard_range logic that was being used =
for
> the balloon inflation so I would assume the behavior would be the same.=

I agree, however, I think it is worth investigating to see if enabling hi=
nting
adds some sort of overhead specifically in this kind of scenarios. What d=
o you
think?
>> I also wonder about interaction with deflate.  ATM deflate will add
>> pages to the free list, then balloon will come right back and report
>> them as free.
> I don't know how likely it is that somebody who is getting the free pag=
e
> reporting is likely to want to also use the balloon to take up memory.
I think it is possible. There are two possibilities:
1. User has a workload running, which is allocating and freeing the pages=
 and at
the same time, user deflates.
If these new pages get used by this workload, we don't have to worry as y=
ou are
already handling that by not hinting the free pages immediately.
2. Guest is idle and the user adds up some memory, for this situation wha=
t you
have explained below does seems reasonable.
> However hinting on a page that came out of deflate might make sense whe=
n
> you consider that the balloon operates on 4K pages and the hints are on=
 2M
> pages. You are likely going to lose track of it all anyway as you have =
to
> work to merge the 4K pages up to the higher order page.
>
--=20
Thanks
Nitesh

