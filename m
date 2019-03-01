Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FA39C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 08:25:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F572186A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 08:25:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F572186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47618E0003; Fri,  1 Mar 2019 03:25:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF6A68E0001; Fri,  1 Mar 2019 03:25:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0BA88E0003; Fri,  1 Mar 2019 03:25:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDE98E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 03:25:30 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id a5so11176449wrq.3
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 00:25:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WDxEDUK9/tJHMhJPo8AdJ653s12BnDPTAZYIQ6x5Ls0=;
        b=TsqzE+PFUslf2zg7n+EV0TfxqXKoHtP/bPYXp9HpMEhOKLlYgx7iX6ITsdwv/dVDmw
         3h3cAbY+MqqJtoPkjpcM1XL/XQZNf6bmncYTRo7tyKQnQ3UzDgi6p4s3R6vn5UQIbD5w
         ATF3m7U8wwY6nfqoS5T0UKJFN2ujnYG6pvi97hokRLJOcPOy50rQxLtTwtH7rgJNr5du
         0wn1G5zx0lyyyb7mELGzw1DNfP3SPRWHXyXCjFr8DzSe2/KLOCcfvIwDgIzERtj0UwMR
         nPpYKFOW1Zpq1ZbgsNHCYeQ0bMBQeWCn0AzAPo6dnoU2E4c9Z2bQe8WYlj64394ircYK
         jvHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guillaume.tucker@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=guillaume.tucker@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: APjAAAWfaFNZvX7JXdt1vkJaAeZLX7mAVStjakDcCZDMeJF38SkHYFIr
	wxPWvjas2+8DhZvcipbSdfZfQTUTdXn6S0ibSxzECJQ4VzKoKpiaXg/i6MIBYl9TUxRz6m9/ZGE
	zfQ8/1ccbCiV+bSauzmB555FErZs3vR2EJB19miFSJwClF/cOA2I4t+7mrw2NKPx6YQ==
X-Received: by 2002:a1c:9aca:: with SMTP id c193mr2302639wme.2.1551428729972;
        Fri, 01 Mar 2019 00:25:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZlbjB4B4JBkS+sLVpQ/4xA4R8fysM4waq01MmaSEepKOgxlrKLMO+0NA0TDFfSdLnhxZPP
X-Received: by 2002:a1c:9aca:: with SMTP id c193mr2302587wme.2.1551428728851;
        Fri, 01 Mar 2019 00:25:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551428728; cv=none;
        d=google.com; s=arc-20160816;
        b=I9qgp/HrE6uONJmuJ/M3fnCYr/M5wCMS7K3dEKy33E6HAWZX0o+PhAv9FTxpvwgnZX
         hGAU2xjkDlfSaFvUrrX/veefaCUdkngseedmLOCKq+1PaA/KJqihaUT21Ucm3ORb6lja
         TzM5tYvXXhqO0xDN9nE4HpJglKDAZTyu/016T5UBKoRyOWblwQB1h+2HHm0ZKz0HSUBj
         vbY0rFckmG4iHwJUw0IJkT+Z2E+ew581vqVgVO2YmuJ3iqWyTq41AD1IAK/R8+DD/3YX
         oMYLKiG7jRDqBRHbugb2JMkkfptuDO1X32gn5Uj4MEGK6OBEtE5W52K/wb1qHSr+Qodd
         QVPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WDxEDUK9/tJHMhJPo8AdJ653s12BnDPTAZYIQ6x5Ls0=;
        b=aFjgFfiPGhUpcok0vdtC8HPK07wxK8IGhesSwQ/D9bf3Ocyh7TDjZ8nPF1608NDAOd
         oEYG0sufvv4gkCMOqX7zivbRpFsUFZ2qL+LbUEt1zx3VxBITffA/uTTuh3bbiEi+OOvT
         4pu/Vvl4LgqqlxlHZfFrcMcHIk2rTuqDobViQmVTDKwXPxVsBFfhhoTD1NC82uww/6pq
         FjJtuYRhD9wlGB3d3G+eyp56ryxr5h4JdQ0SkrNgIgXXW9TVAFaQDK0Y81/AoeIKdBm5
         gwJPFAivzLYZsoJQ0Fr5695FhAJtdTy5/qfnFx0TX37RVpjwOSPsqPZrxqC+poTGD5DB
         scFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guillaume.tucker@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=guillaume.tucker@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id 125si4736626wmc.125.2019.03.01.00.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 00:25:28 -0800 (PST)
Received-SPF: pass (google.com: domain of guillaume.tucker@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guillaume.tucker@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=guillaume.tucker@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: gtucker)
	with ESMTPSA id 078D1260D0B
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Dan Williams <dan.j.williams@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Mark Brown <broonie@kernel.org>, Tomeu Vizoso
 <tomeu.vizoso@collabora.com>, Matt Hart <matthew.hart@linaro.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com,
 enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Richard Guy Briggs <rgb@redhat.com>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
 <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk>
 <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
From: Guillaume Tucker <guillaume.tucker@collabora.com>
Message-ID: <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
Date: Fri, 1 Mar 2019 09:25:24 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/03/2019 00:55, Dan Williams wrote:
> On Thu, Feb 28, 2019 at 3:14 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> On Tue, 26 Feb 2019 16:04:04 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>>
>>> On Tue, Feb 26, 2019 at 4:00 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>>>>
>>>> On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
>>>>
>>>>> On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
>>>>>> On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
>>>>>
>>>>>>>   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
>>>>>>>   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
>>>>>>>   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
>>>>>
>>>>>> Thanks.
>>>>>
>>>>>> But what actually went wrong?  Kernel doesn't boot?
>>>>>
>>>>> The linked logs show the kernel dying early in boot before the console
>>>>> comes up so yeah.  There should be kernel output at the bottom of the
>>>>> logs.
>>>>
>>>> I assume Dan is distracted - I'll keep this patchset on hold until we
>>>> can get to the bottom of this.
>>>
>>> Michal had asked if the free space accounting fix up addressed this
>>> boot regression? I was awaiting word on that.
>>
>> hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..

bot@kernelci.org is not person, it's a send-only account for
automated reports.  So no, it doesn't read emails.

I guess the tricky point here is that the authors of the commits
found by bisections may not always have the hardware needed to
reproduce the problem.  So it needs to be dealt with on a
case-by-case basis: sometimes they do have the hardware,
sometimes someone else on the list or on CC does, and sometimes
it's better for the people who have access to the test lab which
ran the KernelCI test to deal with it.

This case seems to fall into the last category.  As I have access
to the Collabora lab, I can do some quick checks to confirm
whether the proposed patch does fix the issue.  I hadn't realised
that someone was waiting for this to happen, especially as the
BeagleBone Black is a very common platform.  Sorry about that,
I'll take a look today.

It may be a nice feature to be able to give access to the
KernelCI test infrastructure to anyone who wants to debug an
issue reported by KernelCI or verify a fix, so they won't need to
have the hardware locally.  Something to think about for the
future.

>> Is it possible to determine whether this regression is still present in
>> current linux-next?

I'll try to re-apply the patch that caused the issue, then see if
the suggested change fixes it.  As far as the current linux-next
master branch is concerned, KernelCI boot tests are passing fine
on that platform.

Guillaume

