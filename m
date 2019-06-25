Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A36AC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:42:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F0F32054F
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:42:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F0F32054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE3366B0006; Tue, 25 Jun 2019 03:42:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C94698E0003; Tue, 25 Jun 2019 03:42:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5B578E0002; Tue, 25 Jun 2019 03:42:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 921576B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:42:24 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l16so18950161qkk.9
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:42:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=4u0oYeqsf1PUJd+uhf7gF6kxebnPdEXddeH7ef+4LBo=;
        b=DnTm8uGGiv1DHzWfVARDdQw/zEayPaVytuQvjqiCienmdvu3yCOYzd0+ef69P1kaHk
         se3GI9beIcWKEzwgA7rhsOloo0HD6tT8jOhyDjtAXY21fjZZ93Ym9H2n2rhxoQaH95Ru
         dA6OY4rWIG9mTd3ROeDJAX01zr5swHonDHbCVmKMBSPAvSygsSu6PLGsvtftygKHvG+G
         MlbDlsMr5PC1zEn7y6wnQBmWx0bp7qq2mrzzIzFIox5rke4jqshSV7MVKtvhI7iHqSTi
         jOVzsRjc/SuPlEYDoEybmpKWzcoNXk6BBE2wqnPxoHOHhifamBgt6Iopm8Tv5ttPrAh8
         kosw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUMwOUpSGlD9TBZGrKX+4BGIN+kRxGW7+IECAi6bYk28e7NSkCK
	S6aWkiqxUDTFTg2C1uL3pkqxQb6NAXIsIfkxTKnHwIiDoW9zNc1scJeDWs2AgatdmbdFNi/JlSP
	I4Hh/y+X79xTW8a3tOTmNh+hzDIsiGscpSzKPZZVsGPh9kHDIM8JdSxQOTQGfqXHo8Q==
X-Received: by 2002:ac8:eca:: with SMTP id w10mr20669328qti.81.1561448544326;
        Tue, 25 Jun 2019 00:42:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu162VqYtNSpWRAZJS6Lhnsuz74XyaCIw52Jw02VdRD/0hiTPOHkEkHAZYZ45PLZZ5JGmB
X-Received: by 2002:ac8:eca:: with SMTP id w10mr20669300qti.81.1561448543548;
        Tue, 25 Jun 2019 00:42:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561448543; cv=none;
        d=google.com; s=arc-20160816;
        b=spdxsV/D1vBXQ2GSAFXJx9WGLpiaP0oLN8K2/jIihwgcTscW7yVrG6lyoFIycAaA3x
         5r67PbanYt6wtCOJWiwBJFeBJJYGTcERVrJUm19/zKyl9n6fPQqkfWfICyRBzF4isPk0
         XXp4Xow8IM+EKUFsVnNL5zY+uatbs0nUxd3/VeRb+M9V7hcbrZZUbT9yq12thlQd4yXL
         kFiAo9kMA6y78h7tCOvPwu3kZfzVC4ZCHMb7fjwqLoih4SFHRdSgCDQ9/B14TiNZPhFe
         ykZE8xWNgeHVX1WOzeM1ri8b9N/uGC9knL3/LKdGXtzd7dHeEAxdAjR5EoInQsRsFCbN
         D8Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=4u0oYeqsf1PUJd+uhf7gF6kxebnPdEXddeH7ef+4LBo=;
        b=i6WKmKfZO8aya2F0mOD/nBiQ6RpJL3DHsNYcoDJhtQ2wBuzKJJaE3V+DRS+qkVekCP
         jvU6gE5ZeSMLCQvZHKC8L97S6a1ohU5AhfJktR3YekyMa5WrL6PDny23ZxCuNbogSwll
         gGbYKQQ0Jj4r5PwgcLlqnaRFwb/RT8s/nqgnEBWu7bKb0Gt2+LBdgbnDV1uJ2gSs7crF
         neT6MXpC108U7/V+XNupl97UzaMpXyYJszvB25dENmNag0RemUYf0cPBmZm0QajE3xm3
         4HFhUpKAplcJQDNmWSP+z9IUM9c7qaoRQvJaNzTZ4S4Fv50ovgVgKJhLTcpBnGJLSyHZ
         1stA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i189si8496527qke.128.2019.06.25.00.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:42:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 56FCE3086218;
	Tue, 25 Jun 2019 07:42:20 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F191910021B2;
	Tue, 25 Jun 2019 07:42:03 +0000 (UTC)
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
To: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
 kvm@vger.kernel.org, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
Date: Tue, 25 Jun 2019 09:42:03 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190619222922.1231.27432.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 25 Jun 2019 07:42:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.06.19 00:32, Alexander Duyck wrote:
> This series provides an asynchronous means of hinting to a hypervisor
> that a guest page is no longer in use and can have the data associated
> with it dropped. To do this I have implemented functionality that allows
> for what I am referring to as waste page treatment.
> 
> I have based many of the terms and functionality off of waste water
> treatment, the idea for the similarity occurred to me after I had reached
> the point of referring to the hints as "bubbles", as the hints used the
> same approach as the balloon functionality but would disappear if they
> were touched, as a result I started to think of the virtio device as an
> aerator. The general idea with all of this is that the guest should be
> treating the unused pages so that when they end up heading "downstream"
> to either another guest, or back at the host they will not need to be
> written to swap.
> 
> When the number of "dirty" pages in a given free_area exceeds our high
> water mark, which is currently 32, we will schedule the aeration task to
> start going through and scrubbing the zone. While the scrubbing is taking
> place a boundary will be defined that we use to seperate the "aerated"
> pages from the "dirty" ones. We use the ZONE_AERATION_ACTIVE bit to flag
> when these boundaries are in place.

I still *detest* the terminology, sorry. Can't you come up with a
simpler terminology that makes more sense in the context of operating
systems and pages we want to hint to the hypervisor? (that is the only
use case you are using it for so far)

> 
> I am leaving a number of things hard-coded such as limiting the lowest
> order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> determine what batch size it wants to allocate to process the hints.
> 
> My primary testing has just been to verify the memory is being freed after
> allocation by running memhog 32g in the guest and watching the total free
> memory via /proc/meminfo on the host. With this I have verified most of
> the memory is freed after each iteration. As far as performance I have
> been mainly focusing on the will-it-scale/page_fault1 test running with
> 16 vcpus. With that I have seen a less than 1% difference between the

1% throughout all benchmarks? Guess that is quite good.

> base kernel without these patches, with the patches and virtio-balloon
> disabled, and with the patches and virtio-balloon enabled with hinting.
> 
> Changes from the RFC:
> Moved aeration requested flag out of aerator and into zone->flags.
> Moved boundary out of free_area and into local variables for aeration.
> Moved aeration cycle out of interrupt and into workqueue.
> Left nr_free as total pages instead of splitting it between raw and aerated.
> Combined size and physical address values in virtio ring into one 64b value.
> Restructured the patch set to reduce patches from 11 to 6.
> 

I'm planning to look into the details, but will be on PTO for two weeks
starting this Saturday (and still have other things to finish first :/ ).

> ---
> 
> Alexander Duyck (6):
>       mm: Adjust shuffle code to allow for future coalescing
>       mm: Move set/get_pcppage_migratetype to mmzone.h
>       mm: Use zone and order instead of free area in free_list manipulators
>       mm: Introduce "aerated" pages
>       mm: Add logic for separating "aerated" pages from "raw" pages
>       virtio-balloon: Add support for aerating memory via hinting
> 
> 
>  drivers/virtio/Kconfig              |    1 
>  drivers/virtio/virtio_balloon.c     |  110 ++++++++++++++
>  include/linux/memory_aeration.h     |  118 +++++++++++++++
>  include/linux/mmzone.h              |  113 +++++++++------
>  include/linux/page-flags.h          |    8 +
>  include/uapi/linux/virtio_balloon.h |    1 
>  mm/Kconfig                          |    5 +
>  mm/Makefile                         |    1 
>  mm/aeration.c                       |  270 +++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c                     |  203 ++++++++++++++++++--------
>  mm/shuffle.c                        |   24 ---
>  mm/shuffle.h                        |   35 +++++
>  12 files changed, 753 insertions(+), 136 deletions(-)
>  create mode 100644 include/linux/memory_aeration.h
>  create mode 100644 mm/aeration.c

Compared to

 17 files changed, 838 insertions(+), 86 deletions(-)
 create mode 100644 include/linux/memory_aeration.h
 create mode 100644 mm/aeration.c

this looks like a good improvement :)

-- 

Thanks,

David / dhildenb

