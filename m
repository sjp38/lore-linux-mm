Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76220C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:24:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 262102173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:24:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 262102173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBD966B000D; Fri, 29 Mar 2019 10:24:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6D0A6B000E; Fri, 29 Mar 2019 10:24:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5D8E6B0010; Fri, 29 Mar 2019 10:24:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 824C66B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:24:37 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x18so1884911qkf.8
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:24:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=H2OYUSiAr5R0+SbIs7deRsqYXoB3uHnOy2PY2dIhp84=;
        b=lVZZ1SeyL6D+1QpsopGcQgGMSMsm8COD0bzHkaTcP18Pfln/9z38kYmCGqQIyQgS7F
         RXkQsNRHfdnkZ+bAVFvaPUasgmjnF9F+YyStzTZ0vWAOc/eoFx4aBuHmg1qc5Sv9f57h
         a64M8DIlCGoHLjbKeCVtTrYuEFmFKl+xYUG4kh623zH1GeZQgVbrz6oAzIdcm8xHkAWo
         HPr/CzjlEDTVEwAzOmRNHyN3K85hL3cCgBx0BFnhHR3MESwL7Y3SuBR3lSpidBGef9rN
         z2TaUhXKaLcOKHKZ/wz7fp9cDeSkXgIpMNnVTCGumgjVJ41wnBLXOiRP79tUIsBoxQck
         NZMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVGL2Gp+A8m56cZOKUpSLqitv/2s4annmQXn/fuUzh8dBl/eqn5
	45XNMt21MRSHzDNgSAMbodg+53KhZ627YGrQb2bYxw5nAhJ+Sn7oM/X2dkcwMeV5nj6d0p24zS/
	ukraJJeYRlPGUSsMzu3P5XfQOfP3PHz+6tYu1gsOAJ6jkz3c8unwu98cw24cSqrC0fg==
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr40717403qvc.37.1553869477104;
        Fri, 29 Mar 2019 07:24:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMph/Jgk5NKD01pQrrVq83MzLqsNhhqN9L9EoOSZVyWsLRACTI8SS+UPR+YfYyvJDEJ4uJ
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr40717321qvc.37.1553869476092;
        Fri, 29 Mar 2019 07:24:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553869476; cv=none;
        d=google.com; s=arc-20160816;
        b=R+fnYFTqbWYrH2arNfppdKOG9wIULEj7QT4IexYC8sirR8aGXNNBwvegV0c5rHHZO3
         NauxwSOflEIIbSTz3QcZFu35K5v4wdsR4T3mSIlTsw8N9sQ13BBrKPAHLmCztP2a7CNr
         qTkAcey/AA9aAVPgVtkbf328ArTMexMuugpNegTwN2/VolLEqcxdneewswQwOdod90Qu
         OnI9brCG7YM+X72ZFgPtw9VhBWR29zDohcAb1QMHv8cpMY+W24VjcKZ23simYPU2Q5l9
         3yEqv0CeqbOMVeFIr9ZTb5ifsWp/mpRM0Is55UXcRIq+0/5R99w9SwR41a5cO7Z1oVTG
         A1hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=H2OYUSiAr5R0+SbIs7deRsqYXoB3uHnOy2PY2dIhp84=;
        b=gN81XBvnhOB7NcUmBvjnIV5W9smN6RcX//tL771TdS7d8MsaqWmYUfErwSmms/ZpKe
         ZhWpg59xNjImgBooe7NmhD11UFYzYQGyiOE415RHZHAB9BaYT5uyYtS8DD8g363LKueH
         pfMBptXVm6O+uwGchGGiN2iJWdi8TJZKVVnl4Bk3x2K/EA1j1Pxm0kfT82ivtnxomXcn
         K5ot4eLVhUL+f8I3LQXKJlrAuJpzRXdJgIxqoA1Q4b3YFFj12/5rkj6km7L2CUB4ZLMy
         V3z7gR9Kho0BUTbsAJimnMFHBzEdUGj3wIBpJY33JWmHkS87DOFntZpP8o40rSweJpsH
         Of9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 94si1348371qtc.15.2019.03.29.07.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 07:24:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2EA0A821C6;
	Fri, 29 Mar 2019 14:24:35 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4F93919C4F;
	Fri, 29 Mar 2019 14:24:25 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com
References: <20190329084058-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
Date: Fri, 29 Mar 2019 15:24:24 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190329084058-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 29 Mar 2019 14:24:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.03.19 14:26, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
>> The following patch-set proposes an efficient mechanism for handing freed memory between the guest and the host. It enables the guests with no page cache to rapidly free and reclaims memory to and from the host respectively.
> 
> Sorry about breaking the thread: the original subject was
> 	KVM: Guest Free Page Hinting
> but the following isn't in a response to a specific patch
> so I thought it's reasonable to start a new one.
> 
> What bothers both me (and others) with both Nitesh's asynchronous approach
> to hinting and the hinting that is already supported in the balloon
> driver right now is that it seems to have the potential to create a fake OOM situation:
> the page that is in the process of being hinted can not be used.  How
> likely that is would depend on the workload so is hard to predict.

We had a very simple idea in mind: As long as a hinting request is
pending, don't actually trigger any OOM activity, but wait for it to be
processed. Can be done using simple atomic variable.

This is a scenario that will only pop up when already pretty low on
memory. And the main difference to ballooning is that we *know* we will
get more memory soon.


> 
> Alex's patches do not have this problem as they block the
> VCPUs from attempting to get new pages during hinting. Solves the fake OOM
> issue but adds blocking which most of the time is not necessary.

+ not going via QEMU which I consider problematic in the future when it
comes to various things
1) VFIO notifications if we ever want to support it
2) Verifying that the memory may actually be hinted. Remember where
people started to madvise(DONTNEED) the BIOS and we had to fix that in QEMU.

> 
> With both approaches there's a tradeoff: hinting is more efficient if it
> hints about large sized chunks of memory at a time, but as that size
> increases, chances of being able to hold on to that much memory at a
> time decrease. One can claim that this is a regular performance/memory
> tradeoff however there is a difference here: normally
> guest performance is traded off for host memory (which host
> knows how much there is of), this trades guest performance
> for guest memory, but the benefit is on the host, not on
> the guest. Thus this is harder to manage.

One nice thing is that, when only hinting larger chunks, the probability
of smaller chunks being available is more likely. It would be more of an
issue when hinting any granularity.

> 
> I have an idea: how about allocating extra guest memory on the host?  An
> extra hinting buffer would be appended to guest memory, with the
> understanding that it is destined specifically to improve page hinting.
> Balloon device would get an extra parameter specifying the
> hinting buffer size - e.g. in the config space of the driver.
> At driver startup, it would get hold of the amount of
> memory specified by host as the hinting buffer size, and keep it around in a
> buffer list - if no action is taken - forever.  Whenever balloon would
> want to get hold of a page of memory and send it to host for hinting, it
> would release a page of the same size from the buffer into the free
> list: a new page swaps places with a page in the buffer.
> 
> In this way the amount of useful free memory stays constant.
> 
> Once hinting is done page can be swapped back - or just stay
> in the hinting buffer until the next hint.
> 
> Clearly this is a memory/performance tradeoff: the more memory host can
> allocate for the hinting buffer, the more batching we'll get so hints
> become cheaper. One notes that:
> - if guest memory isn't pinned, this memory is virtual and can
>   be reclaimed by host. In partucular guest can hint about the
>   memory within the hinting buffer at startup.
> - guest performance/host memory tradeoffs are reasonably well understood, and
>   so it's easier to manage: host knows how much memory it can
>   sacrifice to gain the benefit of hinting.
> 
> Thoughts?
> 

I first want to

a) See it being a real issue. Reproduce it.
b) See that we can't fix it using a simple approach (loop when requests
not processed yet, always keep X pages ...).
c) See that an easy fix is not sufficient and actually an issue.
d) See if we can document it and people that care about can life without
hinting, like they would live without ballooning.

What you describe sounds interesting, but really involved. And really
problematic. I consider many things about your approach not realistic.

"appended to guest memory", "global list of memory", malicious guests
always using that memory like what about NUMA? What about different page
granularity? What about malicious guests? What about more hitning
requests than the buffer is capable to handle? and much much much more.

Honestly, requiring page hinting to make use of actual ballooning or
additional memory makes me shiver. I hope I don't get nightmares ;) In
the long term we might want to get rid of the inflation/deflation side
of virtio-balloon, not require it.

Please don't over-engineer an issue we haven't even see yet. Especially
not using a mechanism that sounds more involved than actual hinting.


As always, I might be very wrong, but this sounds way too complicated to
me, both on the guest and the hypervisor side.

-- 

Thanks,

David / dhildenb

