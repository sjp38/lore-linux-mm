Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C43B4C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 11:16:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66C3B2681F
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 11:16:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66C3B2681F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4AC46B027A; Fri, 31 May 2019 07:16:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C23016B027C; Fri, 31 May 2019 07:16:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B11E56B027E; Fri, 31 May 2019 07:16:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 873666B027A
	for <linux-mm@kvack.org>; Fri, 31 May 2019 07:16:41 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l63so3338772oia.7
        for <linux-mm@kvack.org>; Fri, 31 May 2019 04:16:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=n6JgB3q1mmzUCsPoUjqn6CaeDFwyS4Sew4/Lrqi5vTI=;
        b=H6fShdPhjYi5vNuO59/YwDT+Ji0ju60XIzz01gdfTPa6yizPpBoz3foKIuDPdpasC1
         vfi0qXYXPtL88KXxlWNkRx3152ZRB4fflfxGvgJ6JcMYi9IdP1kKNl3jfTSi0A8HPOaw
         OQXMAGAAMUmT3f0wrrSxqgUskImqnid/yPuo6mB2APOeepHD03kvApi/Vvdko/GaWW16
         w4t/yAIGpwZdnW8Z+EiBnSl01wBIWb6uP7+kl1NgpdFBlbls92XlWe59QFlk/UKgwkod
         w709CbI4SVF8QzoqvfHUxJDktbYKg7EODqxJX3kyfeYzygz851QriJYtFzlKpIw5alqc
         psbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXMowQdCLZUBVOOOWaDf7ivAcNfCI5E7oGAC2LUL+tojD7Ecfi3
	jhAgHL5+VRMs+iI6H+jXAzPWjvnaqLl6CtTejwx8JNw0T5fNK5atLxvthv4M/+w593Gzic1EMpS
	xddevV2In4Ntvahl92EhuL8wPgbkNMLwiz2iey8azsdFzxXc6eUKqwDBin1v8yBu0QA==
X-Received: by 2002:aca:d757:: with SMTP id o84mr5429293oig.90.1559301401202;
        Fri, 31 May 2019 04:16:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrVBN4DcxWlpc5qafHzOq4kcPEVqj4MqX4hlqsDEgjU9BVrXRsQZZFniaFAS872lJt9SbN
X-Received: by 2002:aca:d757:: with SMTP id o84mr5429242oig.90.1559301399929;
        Fri, 31 May 2019 04:16:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559301399; cv=none;
        d=google.com; s=arc-20160816;
        b=jLD42I1cY2lk8pSL9OrwcK1GYNWEMTpW/YSEMkfZSysBsVhlyeTwqpBDm1VC9bOnMb
         5xUfs+D/KwwZtkJ1mTqh1Blh49QTuo0G716wey24yuh2KtnqXmEBmIka7aECSLRkecPY
         RKt2TJLK9u3SGu1rSOMj1VxqydxQDFsS3vnlTrZT7mEXt4MKHXChc9EfyK5VyOuUv4ax
         hJAJBsNhB3FmLYzuR9Gmb31HRP/pawlzYqWjhHDwFiL22+X9FDMpzU9Q9QOl3h9U10bi
         3W4SYu0gCvcHMW+YsX8tZ8nrSW8tDEF0+w5XR65ARqOFUSso+eGuzeXZXYkqqsI2QMpg
         wG2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=n6JgB3q1mmzUCsPoUjqn6CaeDFwyS4Sew4/Lrqi5vTI=;
        b=HYG2hEM4a552AsedsNsOIJE8OFa1UscE4vq2RKukPOwjjdnA1KiD5qg8Kl2ZurLeEr
         SEhDPW0AtddiwVrsj21zONWhQAuSO7LxhAyV9A3X7honNOrmZQQi+oPD4eWV+hU3aURI
         9mRL2s3nHwD6YRcBoVdbFjU36/8DSgwcv9N+4Soj8t/FoUuwWQ/l7UVt6bq5RksB0lLM
         PcKt+6HQm+GxGJhmcVHsmAuCxWtaLFjoaB86oNTohY9E/7Fvf63tvR34iT+YJ7xzo3Vo
         kJa48UdyRFd5CVTiyHWyS7wJXmpEyx5YPkg6DdmFAQ+2w3l3Sf147FJ2z/zG1nrXb6uy
         Djbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13si3067269otm.240.2019.05.31.04.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 04:16:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 00BD730C1214;
	Fri, 31 May 2019 11:16:34 +0000 (UTC)
Received: from [10.40.205.96] (unknown [10.40.205.96])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4E0901001DED;
	Fri, 31 May 2019 11:16:21 +0000 (UTC)
Subject: Re: [RFC PATCH 00/11] mm / virtio: Provide support for paravirtual
 waste page treatment
To: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <34c0ea04-720f-6915-6a99-b05e5eb87968@redhat.com>
Date: Fri, 31 May 2019 07:16:19 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 31 May 2019 11:16:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/30/19 5:53 PM, Alexander Duyck wrote:
> This series provides an asynchronous means of hinting to a hypervisor
> that a guest page is no longer in use and can have the data associated
> with it dropped. To do this I have implemented functionality that allows
> for what I am referring to as "waste page treatment".
>
> I have based many of the terms and functionality off of waste water
> treatment, the idea for the similarity occured to me after I had reached
> the point of referring to the hints as "bubbles", as the hints used the
> same approach as the balloon functionality but would disappear if they
> were touched, as a result I started to think of the virtio device as an
> aerator. The general idea with all of this is that the guest should be
> treating the unused pages so that when they end up heading "downstream"
> to either another guest, or back at the host they will not need to be
> written to swap.
>
> So for a bit of background for the treatment process, it is based on a
> sequencing batch reactor (SBR)[1]. The treatment process itself has five
> stages. The first stage is the fill, with this we take the raw pages and
> add them to the reactor. The second stage is react, in this stage we hand
> the pages off to the Virtio Balloon driver to have hints attached to them
> and for those hints to be sent to the hypervisor. The third stage is
> settle, in this stage we are waiting for the hypervisor to process the
> pages, and we should receive an interrupt when it is completed. The fourth
> stage is to decant, or drain the reactor of pages. Finally we have the
> idle stage which we will go into if the reference count for the reactor
> gets down to 0 after a drain, or if a fill operation fails to obtain any
> pages and the reference count has hit 0. Otherwise we return to the first
> state and start the cycle over again.
>
> This patch set is still far more intrusive then I would really like for
> what it has to do. Currently I am splitting the nr_free_pages into two
> values and having to add a pointer and an index to track where we area in
> the treatment process for a given free_area. I'm also not sure I have
> covered all possible corner cases where pages can get into the free_area
> or move from one migratetype to another.
>
> Also I am still leaving a number of things hard-coded such as limiting the
> lowest order processed to PAGEBLOCK_ORDER, and have left it up to the
> guest to determine what size of reactor it wants to allocate to process
> the hints.
>
> Another consideration I am still debating is if I really want to process
> the aerator_cycle() function in interrupt context or if I should have it
> running in a thread somewhere else.

Can you please share some performance numbers?

I will be sharing a less mm-intrusive bitmap-based approach hopefully by
next week.
Let's compare the two approaches then, in the meanwhile I will start
reviewing your patch-set.

>
> [1]: https://en.wikipedia.org/wiki/Sequencing_batch_reactor
>
> ---
>
> Alexander Duyck (11):
>       mm: Move MAX_ORDER definition closer to pageblock_order
>       mm: Adjust shuffle code to allow for future coalescing
>       mm: Add support for Treated Buddy pages
>       mm: Split nr_free into nr_free_raw and nr_free_treated
>       mm: Propogate Treated bit when splitting
>       mm: Add membrane to free area to use as divider between treated and raw pages
>       mm: Add support for acquiring first free "raw" or "untreated" page in zone
>       mm: Add support for creating memory aeration
>       mm: Count isolated pages as "treated"
>       virtio-balloon: Add support for aerating memory via bubble hinting
>       mm: Add free page notification hook
>
>
>  arch/x86/include/asm/page.h         |   11 +
>  drivers/virtio/Kconfig              |    1 
>  drivers/virtio/virtio_balloon.c     |   89 ++++++++++
>  include/linux/gfp.h                 |   10 +
>  include/linux/memory_aeration.h     |   54 ++++++
>  include/linux/mmzone.h              |  100 +++++++++--
>  include/linux/page-flags.h          |   32 +++
>  include/linux/pageblock-flags.h     |    8 +
>  include/uapi/linux/virtio_balloon.h |    1 
>  mm/Kconfig                          |    5 +
>  mm/Makefile                         |    1 
>  mm/aeration.c                       |  324 +++++++++++++++++++++++++++++++++++
>  mm/compaction.c                     |    4 
>  mm/page_alloc.c                     |  220 ++++++++++++++++++++----
>  mm/shuffle.c                        |   24 ---
>  mm/shuffle.h                        |   35 ++++
>  mm/vmstat.c                         |    5 -
>  17 files changed, 838 insertions(+), 86 deletions(-)
>  create mode 100644 include/linux/memory_aeration.h
>  create mode 100644 mm/aeration.c
>
> --
-- 
Regards
Nitesh

