Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F421C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:03:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFAE220823
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:03:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="FnIJiLll"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFAE220823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E0848E00E8; Wed,  6 Feb 2019 14:03:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 792988E00D1; Wed,  6 Feb 2019 14:03:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 681978E00E8; Wed,  6 Feb 2019 14:03:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBE58E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 14:03:50 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id t10so7848579qtn.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 11:03:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=vrZE7jlxhDQlqPgSkY9sCVBYabm2RWMiKM07ns+SLJE=;
        b=EvXOS6IJf06eeilbU93wc/KqbbDMP6ylt85dUgtmBwbUAbOq5kl82EMoZsyBcAPpAE
         tV3p0eRojyp8JnoDAJNPTXhToHxm9NcSTqcEBXpM75WJ73pS7u+J0RtDB206X2/NFqaK
         VKcaEk9LHJkuAEnaDuvWOTDXem0qaz15xT1ymrnWEM4TRMZ+9McFx+5giF1Fq5kGqYeu
         bun39OxK+kTDkLscfRTkc05vJA7TX9oWErWRvslEhL4Ew51gUltsLReRgLuGFpbTODPg
         kcXZBEng5IKgh004+rQuqJPEnBUA6EBhl3xIYP1+NhtzieWpbEu9Eejyd6nSZ9wa+d2y
         RZ3g==
X-Gm-Message-State: AHQUAuYQf/BNZcI3f0wnXhWOkMOhZtGYiY4COs/avOvfkonZaR2n3c9a
	579RLvRAcfOFjzZGgJdmbRuQBqR/SnAEATo252+MRnqvkSx79WeJhD2ijVcy66JmbILrjLrvg3p
	mUIOnLvfcpmAUqOcGv7s/vyzNVR+Wh3QTs4SjdbRuVO7YeHWkJEu5/OMW4HDK5g8=
X-Received: by 2002:a37:4f4e:: with SMTP id d75mr8550859qkb.257.1549479829908;
        Wed, 06 Feb 2019 11:03:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaKKM8Bu4kv6bngvFLOSJ+KOWK2X5Dex7srIeHsG+VHv/2+qCGKujm3R1dsOWHReKDjpRWH
X-Received: by 2002:a37:4f4e:: with SMTP id d75mr8550819qkb.257.1549479829151;
        Wed, 06 Feb 2019 11:03:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549479829; cv=none;
        d=google.com; s=arc-20160816;
        b=0ZhYv1xT9GDEodFEbPdVp4Q1fPK9XM4M2B91RX4jPUirbAPlnbVLc4bYTWBiXpqaQe
         o96r97NqeusVzHWnMT2kmb5/q9lGfgs9YoDeB4dIqJP9xOiQZ1zkjiGijSZqLB86+sAK
         oqJiaOIarACP33xvnLAHUhw5tBAlLnV0RGZMwT5a5t1D9/uxBza//Tdvw7LZCZgCsEkQ
         XOiC60D74IhH0b64rK5iOyeNddXC4thSjIO31oldqGXrQjJGHnlBjqUqu662a2pNtUiV
         pbUSNy+hRL84z4SBpJivAerb9FH3f9x1RLc/cIlCWWBtXqOTDHKI3W2Y147mK9dmU2DO
         RfUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=vrZE7jlxhDQlqPgSkY9sCVBYabm2RWMiKM07ns+SLJE=;
        b=jiQo3msGgkVSsXK9HLkvAXb6qap55o+xbe4QCXBi7AUUL4c3saw3jBRPFTMHfneig3
         vg8vj3+xXz8wSJxPItBGjhpUPZGV9P3bUAxeptQ4eQxhi75qgrBK96INA1yqrZjKw6hx
         2A/TTbPLHBK1m7QtjxCSuuJtqDNR8F88ndUGQtpR92cS+eJ+UDRo7djSWBzoozqOFm7Z
         WDWutrmL0Dm7MOB571HIcLb++m8uvLg99nISLI4WljwbGuapL//EGyD3IdCbBGfeh3aS
         OdSbScK21mFjrSvTIkEHw54qrfHnG3hN7QUJpR/8W0gqswx1ZX6MgbNH0ToG/UHVusFo
         JY4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=FnIJiLll;
       spf=pass (google.com: domain of 01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id k46si3500381qtk.49.2019.02.06.11.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 11:03:49 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=FnIJiLll;
       spf=pass (google.com: domain of 01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549479828;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=xYi6pCyDA9ZOQcYAxtOfItk+QwdU/COFlue4KVWz1Sk=;
	b=FnIJiLll8xQfoA9hfRIsqHXFv7JymnplP5wZ7DxNoHDvrUAPoo8SzG6tfvRnypj/
	V+jSIAlK+w1UOD/3q+ki7ZhfpMVhSqg9WuawKegLwHSdhj0/3my9z6+m5MYoCqyR8FV
	v8flXD841rz/28n7k4eaOm8F1TKxqtgAlY7molh0=
Date: Wed, 6 Feb 2019 19:03:48 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, 
    linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, 
    linux-nvme@lists.infradead.org
Subject: Re: [LSF/MM ATTEND ] memory reclaim with NUMA rebalancing
In-Reply-To: <87h8dpnwxg.fsf@linux.ibm.com>
Message-ID: <01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@email.amazonses.com>
References: <20190130174847.GD18811@dhcp22.suse.cz> <87h8dpnwxg.fsf@linux.ibm.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.06-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019, Aneesh Kumar K.V wrote:

> I would be interested in this topic too. I would like to
> understand the API and how it can help exploit the different type of
> devices we have on OpenCAPI.

So am I. We may want to rethink the whole NUMA API and the way we handle
different types of memory with their divergent performance
characteristics.

We need some way to allow a better selection of memory from the kernel
without creating too much complexity. We have new characteristics to
cover:

1. Persistence (NVRAM) or generally a storage device that allows access to
   the medium via a RAM like interface.

2. Coprocessor memory that can be shuffled back and forth to a device
   (HMM).

3. On Device memory (important since PCIe limitations are currently a
   problem and Intel is stuck on PCIe3 and devices start to bypass the
   processor to gain performance)

4. High Density RAM (GDDR f.e.) with different caching behavior
   and/or different cacheline sizes.

5. Modifying access characteristics by reserving slice of a cache (f.e.
   L3) for a specific memory region.

6. SRAM support (high speed memory on the processor itself or by using
   the processor cache to persist a cacheline)

And then the old NUMA stuff where only the latency to memory varies. But
that was a particular solution targeted at scaling SMP system through
interconnects. This was a mostly symmetric approach. The use of
accellerators etc etc and the above characteristics lead to more complex
assymmetric memory approaches that may be difficult to manage and use from
kernel space.

