Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A6CC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:12:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EC5421911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:12:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EC5421911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7C0F8E0008; Wed, 24 Jul 2019 13:12:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2CE28E0005; Wed, 24 Jul 2019 13:12:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CEC88E0008; Wed, 24 Jul 2019 13:12:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EEEB8E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:12:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so30562130edc.17
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:12:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6ODrP6DcHvPLc7qyA9XPL9ii1GE+u/9TjfvkOvUPkKI=;
        b=bDon6mfODT8bAWjocMU1+8V2ACgxo1Ubqnpl+edSOb8vBIWr101xCGKyLzJXt8hm9m
         wbEMck7uZjDXdqpWMn715Knq5RxXDIoHPNa8DLX8a+abAtct4iLzmYVhUPkPiaWL8bl2
         rr1jftfYNIuZxih76dXAN00npSTTtIOg8e7FbZG/vyihTY1AAYVAm7k3i4WcPKVbQRjv
         ZnZS88pXh8OYHtoC3jv823h/PdQQZ9izYEmLNRwOZVlSBMrQRRM1Jz3Wa6t/uFrWC0DD
         egBSLlleycRlUVmBxc9Otgn4q+G5tmGRgYkKHLLw7yusL5ZijUbWNqb5hDyFVny8QYY2
         49Ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAVlMMxO2cK5dPPVydiiehIy3Z9ZleSZ3ALq08vJZz6+duVJWyBO
	ZgFAt+9lezPNtiiJbHWMBA+w33YnHjb2Bcx9lxAlokBEgX7ry8tteCbaLippkhnmZgDVjrdb7sa
	HBmlWiI3ejJooKFYSFE9GdpzLmVaQ+r9gQaZERB2J9sO7UaSNeazYM/N3zxHTFV6f+w==
X-Received: by 2002:a17:906:9147:: with SMTP id y7mr63810887ejw.66.1563988347826;
        Wed, 24 Jul 2019 10:12:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrowdz0Yq/fKZBMnCr33UZ+wN0ACZqUYDbVtQ0GfFbDo+AZuGfosD8PQtlqqKXZrUBt8rF
X-Received: by 2002:a17:906:9147:: with SMTP id y7mr63810842ejw.66.1563988347049;
        Wed, 24 Jul 2019 10:12:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563988347; cv=none;
        d=google.com; s=arc-20160816;
        b=eDHlTW7v+jCX3zg7DdCXj5VJu6U+j/QXuF6x2WjQkbchmUZ0V5bpWXDAnAhfNBpb2M
         cJxKDuoM3n8i25OSeBJmwz8ABSgLd+6/irorukmzF0r0/C/UIOHhywVGELEaoUjGlwwc
         8BCQc/tPzWubWALIexzQjkWvTC0kS/u4WR9tvgrkteVnmxrXYvvBLVl58+eXF612wVsD
         KKrRiNeSph6YR5l7Tahi2sJx7lPB+KG/G685FBfxeyqlPpZGGbMEAZxtB0nni8pIF20A
         MvMlwc2lsHb97aa8qOA1GxJQrgGeF7/pL2mWhxrESvrm7dbEX2emBOv/AB7P7kj9Kdwx
         AQ+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6ODrP6DcHvPLc7qyA9XPL9ii1GE+u/9TjfvkOvUPkKI=;
        b=0gStM+IyEnY2VV12RadcwxTHTw4zdFxqx/TVkv6pw3+X6LfU1cY5dCyQS/5GKex9NU
         FEa09GOSTXRiy7wQQQy2n1BCew1eZ23ZghpaYcgw9+52Wo2o6nB5Rmvqx5ZLi+Rzv6LK
         qznJpaafeD/KdILeMpLEcmB5yAQHlDkMLWaJNviI88eTU8NOV8fuEQQQ4FRVvEntfKFU
         8YYUTC0eSg4Q9ykHCNaIgiPlaR0CaST97zHDo0icpfnZDKM1kySA0efQO3ge+Et5aNeC
         TS3YFfYrpCBN9Gq0DOLAIzLLUzrNmq8g+Y5VzleymWvM2Y0E+7ax4GMx3dZ0mV3ObF8E
         yaJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i17si8525126ejc.55.2019.07.24.10.12.26
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 10:12:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E49528;
	Wed, 24 Jul 2019 10:12:26 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3CE253F71F;
	Wed, 24 Jul 2019 10:12:21 -0700 (PDT)
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
To: Will Deacon <will.deacon@arm.com>,
 Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>, dri-devel@lists.freedesktop.org,
 Kostya Serebryany <kcc@google.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Leon Romanovsky <leon@kernel.org>,
 linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>,
 linux-media@vger.kernel.org, Kevin Brodsky <kevin.brodsky@arm.com>,
 Kees Cook <keescook@chromium.org>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Alex Williamson <alex.williamson@redhat.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Dmitry Vyukov <dvyukov@google.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Yishai Hadas <yishaih@mellanox.com>, LKML <linux-kernel@vger.kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <f27f4e55-fcd6-9ae7-d9ca-cac2aea5fe70@arm.com>
Date: Wed, 24 Jul 2019 18:12:20 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724142059.GC21234@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Will and Andrey,

On 24/07/2019 15:20, Will Deacon wrote:
> On Wed, Jul 24, 2019 at 04:16:49PM +0200, Andrey Konovalov wrote:
>> On Wed, Jul 24, 2019 at 4:02 PM Will Deacon <will@kernel.org> wrote:
>>> On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
>>>> On Tue, Jul 23, 2019 at 7:59 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>>>>>
>>>>> === Overview
>>>>>
>>>>> arm64 has a feature called Top Byte Ignore, which allows to embed pointer
>>>>> tags into the top byte of each pointer. Userspace programs (such as
>>>>> HWASan, a memory debugging tool [1]) might use this feature and pass
>>>>> tagged user pointers to the kernel through syscalls or other interfaces.
>>>>>
>>>>> Right now the kernel is already able to handle user faults with tagged
>>>>> pointers, due to these patches:
>>>>>
>>>>> 1. 81cddd65 ("arm64: traps: fix userspace cache maintenance emulation on a
>>>>>              tagged pointer")
>>>>> 2. 7dcd9dd8 ("arm64: hw_breakpoint: fix watchpoint matching for tagged
>>>>>               pointers")
>>>>> 3. 276e9327 ("arm64: entry: improve data abort handling of tagged
>>>>>               pointers")
>>>>>
>>>>> This patchset extends tagged pointer support to syscall arguments.
>>>
>>> [...]
>>>
>>>> Do you think this is ready to be merged?
>>>>
>>>> Should this go through the mm or the arm tree?
>>>
>>> I would certainly prefer to take at least the arm64 bits via the arm64 tree
>>> (i.e. patches 1, 2 and 15). We also need a Documentation patch describing
>>> the new ABI.
>>
>> Sounds good! Should I post those patches together with the
>> Documentation patches from Vincenzo as a separate patchset?
> 
> Yes, please (although as you say below, we need a new version of those
> patches from Vincenzo to address the feedback on v5). The other thing I
> should say is that I'd be happy to queue the other patches in the series
> too, but some of them are missing acks from the relevant maintainers (e.g.
> the mm/ and fs/ changes).
> 

I am actively working on the document and will share v6 with the requested
changes in the next few days.

> Will
> 

-- 
Regards,
Vincenzo

