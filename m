Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B3E7C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:02:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D13A20645
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:02:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D13A20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90B986B0003; Wed, 26 Jun 2019 05:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3138E0003; Wed, 26 Jun 2019 05:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D2B18E0002; Wed, 26 Jun 2019 05:02:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAD16B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:02:11 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so2001384qtn.14
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:02:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:references
         :user-agent:from:to:cc:subject:in-reply-to:date:message-id
         :mime-version;
        bh=sDLgZ7kkCj1/psN8c9BNyiXC/2gRj1TehpBUyxTvRCo=;
        b=Lsn9RhYJLBrBZlGWfTsFIu4QKti1F7lbENd0hmLHm9su+ihIM6Ke36xY3z9IpAkDZN
         db5bQE4PEFKIzUxMfDgrnBB5O/UdSON2LxAGlSOxkzUbLvIq/pe0M7MQqxwz5oL0VeWT
         FKYN4Xgm5N1auI7i53FDUR9GBrccdDGONYqAl6sliy/KVypnjbc3FJOhISHUk+yVYVci
         A3jVrkPwdc1Jj9ngVuBAfYM1eD2tzUj8PK2q1nnh/DAU7lqG6vrtld7SYl14pkh31329
         IJ1ppqtmif89KZyOj+7RP2rcGQLDtPS4f5poZXzjCME9uOxKRfOfEh4Vbo4SjbXK/Cd2
         RJpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dinechin@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dinechin@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWSTgZnxBzmaOuiP2lBUV0l+Og2Pkeauo0zDJjGjIQmR2XiMMbM
	9pXbTe3gv59An+lDACybXX3UCWN7bWE2ojmHc91Fxx1yCYVrS4ZN1oyc6IC7mPFGVDPHsOucwEg
	AlGFpM7D9z79FQztbMkVDxBBi1iNaNI8Wo+EqSAQWsULhKDQdCfBAKu3es69sUmr/iw==
X-Received: by 2002:ac8:e05:: with SMTP id a5mr2702639qti.53.1561539730824;
        Wed, 26 Jun 2019 02:02:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydxVvkw7LGv20b+TW5FZifIWE4nOzSnl1n5Sf7dMZ4omUoDHjOJKMDx7q7YNDV2IYVHi/b
X-Received: by 2002:ac8:e05:: with SMTP id a5mr2702536qti.53.1561539729343;
        Wed, 26 Jun 2019 02:02:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561539729; cv=none;
        d=google.com; s=arc-20160816;
        b=D6c/F9gUihyAnXC3Rb20433A3nLI1G13zZBAVtdn9nU91U3J67zhsz7GAKP+958ne3
         aocVCJU7ZCDZzQjBo7F72jwjdlSGWb+A7I0619aLAxYJsWrqcx9x8QL9SW0b9k1Icqln
         Pq06h6R/wJo8cq047AscBPLYMUnZV4bva7ji5XFSrd7OVbdSQM0kVbWpcASkPS4tKGwR
         4ZyNy1Rp3/pgog+e+NgOcfzq7SvgmwftkIL2NYJ8vGtsYAqAunREwuaPpN6++6NRD48z
         jyPwKLFS+l9SCbyG2TZh8tiYE4oQAwmWn4yHzh5drbxVnURTw1vmCawF4KRcunqfBVc0
         SKew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:in-reply-to:subject:cc:to:from
         :user-agent:references;
        bh=sDLgZ7kkCj1/psN8c9BNyiXC/2gRj1TehpBUyxTvRCo=;
        b=fKm5NCckMOJ1KIz0EvCeKfGIgl3gMTOpRVjR3f0XL/cBloWZQLWZVl3cm/qXTulVq/
         vSCfCXofDpDa7bspA0d3LoBkOIjxlK86QwvjtjBtLrc6GR+fuPslEC+D2QPftmdnSk+k
         bJN8S6lMYA+fvgo042PQIXbbmBvcZlgkBCyGZEsn5rhT5d4ZqbjB70KX1/xcw9A6Smqd
         WHQi0jF/utU+BJNRQuFzNyEo571Lb63gwfGUmV6Z/irp71bH2etEbevF5PZlEEg7uBO9
         YrWxpEQsSh+XHIP3ipedh1Fyv7MlWNtRDBqImF9DvejJFJtjxUF96OK3ANkvU9slBRRD
         VUpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dinechin@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dinechin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si10118411qkc.67.2019.06.26.02.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 02:02:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dinechin@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dinechin@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dinechin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 414C5C04FFF6;
	Wed, 26 Jun 2019 09:01:45 +0000 (UTC)
Received: from turbo.dinechin.lan (unknown [10.36.118.42])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1EAA160C4C;
	Wed, 26 Jun 2019 09:01:22 +0000 (UTC)
References: <20190619222922.1231.27432.stgit@localhost.localdomain> <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
User-agent: mu4e 1.3.2; emacs 26.2
From: Christophe de Dinechin <dinechin@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste page treatment
In-reply-to: <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
Date: Wed, 26 Jun 2019 11:01:08 +0200
Message-ID: <7hmui42017.fsf@turbo.dinechin.lan>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 26 Jun 2019 09:01:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


David Hildenbrand writes:

> On 20.06.19 00:32, Alexander Duyck wrote:
>> This series provides an asynchronous means of hinting to a hypervisor
>> that a guest page is no longer in use and can have the data associated
>> with it dropped. To do this I have implemented functionality that allows
>> for what I am referring to as waste page treatment.
>> 
>> I have based many of the terms and functionality off of waste water
>> treatment, the idea for the similarity occurred to me after I had reached
>> the point of referring to the hints as "bubbles", as the hints used the
>> same approach as the balloon functionality but would disappear if they
>> were touched, as a result I started to think of the virtio device as an
>> aerator. The general idea with all of this is that the guest should be
>> treating the unused pages so that when they end up heading "downstream"
>> to either another guest, or back at the host they will not need to be
>> written to swap.
>> 
>> When the number of "dirty" pages in a given free_area exceeds our high
>> water mark, which is currently 32, we will schedule the aeration task to
>> start going through and scrubbing the zone. While the scrubbing is taking
>> place a boundary will be defined that we use to seperate the "aerated"
>> pages from the "dirty" ones. We use the ZONE_AERATION_ACTIVE bit to flag
>> when these boundaries are in place.
>
> I still *detest* the terminology, sorry. Can't you come up with a
> simpler terminology that makes more sense in the context of operating
> systems and pages we want to hint to the hypervisor? (that is the only
> use case you are using it for so far)

FWIW, I thought the terminology made sense, in particular given the analogy
with the balloon driver. Operating systems in general, and Linux in
particular, already use tons of analogy-supported terminology. In
particular, a "waste page treatment" terminology is not very far from
the very common "garbage collection" or "scrubbing" wordings. I would find
"hinting" much less specific. for example.

Usually, the phrases that stick are somewhat unique while providing a
useful analogy to server as a reminder of what the thing actually
does. IMHO, it's the case here on both fronts, so I like it.

>
>> 
>> I am leaving a number of things hard-coded such as limiting the lowest
>> order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
>> determine what batch size it wants to allocate to process the hints.
>> 
>> My primary testing has just been to verify the memory is being freed after
>> allocation by running memhog 32g in the guest and watching the total free
>> memory via /proc/meminfo on the host. With this I have verified most of
>> the memory is freed after each iteration. As far as performance I have
>> been mainly focusing on the will-it-scale/page_fault1 test running with
>> 16 vcpus. With that I have seen a less than 1% difference between the
>
> 1% throughout all benchmarks? Guess that is quite good.
>
>> base kernel without these patches, with the patches and virtio-balloon
>> disabled, and with the patches and virtio-balloon enabled with hinting.
>> 
>> Changes from the RFC:
>> Moved aeration requested flag out of aerator and into zone->flags.
>> Moved boundary out of free_area and into local variables for aeration.
>> Moved aeration cycle out of interrupt and into workqueue.
>> Left nr_free as total pages instead of splitting it between raw and aerated.
>> Combined size and physical address values in virtio ring into one 64b value.
>> Restructured the patch set to reduce patches from 11 to 6.
>> 
>
> I'm planning to look into the details, but will be on PTO for two weeks
> starting this Saturday (and still have other things to finish first :/ ).
>
>> ---
>> 
>> Alexander Duyck (6):
>>       mm: Adjust shuffle code to allow for future coalescing
>>       mm: Move set/get_pcppage_migratetype to mmzone.h
>>       mm: Use zone and order instead of free area in free_list manipulators
>>       mm: Introduce "aerated" pages
>>       mm: Add logic for separating "aerated" pages from "raw" pages
>>       virtio-balloon: Add support for aerating memory via hinting
>> 
>> 
>>  drivers/virtio/Kconfig              |    1 
>>  drivers/virtio/virtio_balloon.c     |  110 ++++++++++++++
>>  include/linux/memory_aeration.h     |  118 +++++++++++++++
>>  include/linux/mmzone.h              |  113 +++++++++------
>>  include/linux/page-flags.h          |    8 +
>>  include/uapi/linux/virtio_balloon.h |    1 
>>  mm/Kconfig                          |    5 +
>>  mm/Makefile                         |    1 
>>  mm/aeration.c                       |  270 +++++++++++++++++++++++++++++++++++
>>  mm/page_alloc.c                     |  203 ++++++++++++++++++--------
>>  mm/shuffle.c                        |   24 ---
>>  mm/shuffle.h                        |   35 +++++
>>  12 files changed, 753 insertions(+), 136 deletions(-)
>>  create mode 100644 include/linux/memory_aeration.h
>>  create mode 100644 mm/aeration.c
>
> Compared to
>
>  17 files changed, 838 insertions(+), 86 deletions(-)
>  create mode 100644 include/linux/memory_aeration.h
>  create mode 100644 mm/aeration.c
>
> this looks like a good improvement :)


-- 
Cheers,
Christophe de Dinechin (IRC c3d)

