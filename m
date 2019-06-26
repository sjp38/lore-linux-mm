Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CCF1C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63B5F20645
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:13:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63B5F20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D96AC6B0006; Wed, 26 Jun 2019 05:13:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D481A8E0003; Wed, 26 Jun 2019 05:13:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0EE98E0002; Wed, 26 Jun 2019 05:13:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A03656B0006
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:13:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h47so2016071qtc.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:13:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Y68kjL3oB4no+75Vc4L5WJi8kvCbtpayI2ogScb1Png=;
        b=R2P6pxvK24R+kUmfy0IuPUpo9nLDMTQn7+si0erM0FR1NdrJcnrBeFRAKchfLN5sGQ
         w4bBTtPixG+4+vUsWG4B0cDP/zIRFGbBzXTiI4Bsr2nlIuNrk4po8z8XLP2VKCghBc6x
         klYMCf3emDy1Irf6I03d4v0Cf1L2C6Nva+JmRpq8BgWbMIIrQltMMP5Y8oOY4ns9zkvf
         8AurnOOUMWKu2gq01BeBFsvQE6Zrye1Eu/FB1DGbRTmJzHRE8koRAmHSvhXSHbBUW1BW
         rGOKvTT0q23rgRsFxyNGHrwhDaXcWcp6VB5yUudFnfmEMI0DLcM8J4/0R3RjGFumbnqW
         dsyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX42vz709ozQajPxLWddmv4w/oUoSEPP1Z74gFRP104xAE+mY1z
	JJF3BMOvlLbPeX8qLPOS306AVrhYX7AGoylBJ8A97pOTsDVC7gcwk4vOkv1M2mp/kEQlTXDRWH1
	j74MaawZoFlT9MtIAaM12RdZS7FeNKBnvsfygAgGakXGvxqqwJ5UytYaG35i20uznUQ==
X-Received: by 2002:ac8:25ac:: with SMTP id e41mr2772411qte.101.1561540380371;
        Wed, 26 Jun 2019 02:13:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjcxjXc5LD+o+S1YjgbLv8zSeQnnXXnUaByNlwRwTv7X/KEITBWNEU26vx/+reN4fbx5Zj
X-Received: by 2002:ac8:25ac:: with SMTP id e41mr2772351qte.101.1561540379274;
        Wed, 26 Jun 2019 02:12:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561540379; cv=none;
        d=google.com; s=arc-20160816;
        b=lnwMDGWAA18CIxF0gDee4Q0Ap1/eh18SIQN1WR1GrN2WZ0WRo6ph1uvXR0gnMDJryE
         v2RglD7rlXrLyWNjAxvBpjVqaA2HDvevynCBEdxpdXaLE/ZvYVK2zSjlz8aC/4mCGMah
         1GR0GcL7TbzLRJ+cVHK14c+YCMFBusONbVgNAJE2dEc+bsns/4CDms5QMiDq4mG2pJ8F
         cZIZWO09dKoIUC/Qq0PeXESbQZwPuZLrAFPc4xsjPOzBrolfuH4tdKBQiBbeHVcoiVFP
         zZK8N6F6qdJgIEtcCsvv76WthHTsfHT6DQGsfX11/+Y3DPZE68kXxO4PTM1kqW8w+tbl
         jFYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Y68kjL3oB4no+75Vc4L5WJi8kvCbtpayI2ogScb1Png=;
        b=HxOWdvHtulKTZ4yaM0u8Tebo2UFmS2g9Y79PT+CG7Zm1+/S7czQXcjnl3o3+Qbtsam
         O6CtnvTdQgc/mDeBZbo6twkeEhYQrhhjPIMZ2dCd4NRkfUoSBp87xbL5quWD+Ma8M3Yr
         VEeApB2nMLsd6/ZNrFPGjgSBBIENRb2DrtNPInbo9pdjIZNtdq5S1emIVDGRRunqMhIM
         lmixulBMTCf0P1N9oJKcPIeVYNU4sw36nvDbHtzJBsrMr2+GpNTGBssgbPEc2xWqJarp
         EkbE9V7/eZ3hNLCvjeztoUO9E4nCMrGNoXWUjXlwnDGA1kBrT6dFZOIDa3/PLIjfVRnP
         f24w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32si3911344qvr.213.2019.06.26.02.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 02:12:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E4707307D863;
	Wed, 26 Jun 2019 09:12:52 +0000 (UTC)
Received: from [10.36.116.174] (ovpn-116-174.ams2.redhat.com [10.36.116.174])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8B0AA5D9D6;
	Wed, 26 Jun 2019 09:12:36 +0000 (UTC)
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
To: Christophe de Dinechin <dinechin@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
 kvm@vger.kernel.org, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
 <7hmui42017.fsf@turbo.dinechin.lan>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e2f4185c-3263-a140-5f64-45794b9fa6a4@redhat.com>
Date: Wed, 26 Jun 2019 11:12:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <7hmui42017.fsf@turbo.dinechin.lan>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 26 Jun 2019 09:12:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.06.19 11:01, Christophe de Dinechin wrote:
> 
> David Hildenbrand writes:
> 
>> On 20.06.19 00:32, Alexander Duyck wrote:
>>> This series provides an asynchronous means of hinting to a hypervisor
>>> that a guest page is no longer in use and can have the data associated
>>> with it dropped. To do this I have implemented functionality that allows
>>> for what I am referring to as waste page treatment.
>>>
>>> I have based many of the terms and functionality off of waste water
>>> treatment, the idea for the similarity occurred to me after I had reached
>>> the point of referring to the hints as "bubbles", as the hints used the
>>> same approach as the balloon functionality but would disappear if they
>>> were touched, as a result I started to think of the virtio device as an
>>> aerator. The general idea with all of this is that the guest should be
>>> treating the unused pages so that when they end up heading "downstream"
>>> to either another guest, or back at the host they will not need to be
>>> written to swap.
>>>
>>> When the number of "dirty" pages in a given free_area exceeds our high
>>> water mark, which is currently 32, we will schedule the aeration task to
>>> start going through and scrubbing the zone. While the scrubbing is taking
>>> place a boundary will be defined that we use to seperate the "aerated"
>>> pages from the "dirty" ones. We use the ZONE_AERATION_ACTIVE bit to flag
>>> when these boundaries are in place.
>>
>> I still *detest* the terminology, sorry. Can't you come up with a
>> simpler terminology that makes more sense in the context of operating
>> systems and pages we want to hint to the hypervisor? (that is the only
>> use case you are using it for so far)
> 
> FWIW, I thought the terminology made sense, in particular given the analogy
> with the balloon driver. Operating systems in general, and Linux in
> particular, already use tons of analogy-supported terminology. In
> particular, a "waste page treatment" terminology is not very far from
> the very common "garbage collection" or "scrubbing" wordings. I would find
> "hinting" much less specific. for example.
> 
> Usually, the phrases that stick are somewhat unique while providing a
> useful analogy to server as a reminder of what the thing actually
> does. IMHO, it's the case here on both fronts, so I like it.

While something like "waste pages" make sense, "aeration" is far out of
my comfort zone.

An analogy is like a joke. If you have to explain it, it's not that
good. (see, that was a good analogy ;) ).

-- 

Thanks,

David / dhildenb

