Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4004BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:04:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD3A6206B6
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:04:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD3A6206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208338E0003; Fri,  1 Mar 2019 16:04:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9D48E0001; Fri,  1 Mar 2019 16:04:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0833A8E0003; Fri,  1 Mar 2019 16:04:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id A51968E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:04:52 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id u74so5661996wmf.0
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:04:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=V8sy0agZ55nRCo9Q2PNXzwo0Hp55JqCS0DxwToQnYBc=;
        b=bGIwTNsaSd6wRnmsBAEyp9DRv6UElHYLMgO6t3rKLUUtLnZYKNc7DovT4v0j3ritNs
         MVp9eharMTzxwScfjh9vHw5CYnZUDUaCEUGGD8XdZ/7KVubuWuSVD2wo2My3qauvbH26
         etpnG7gdLjAuOrzIK4+QAFF/q+0WOETWTwbyUnW2oAR+sGZtQD8KQfUcRcjkxVJuKz2L
         Hu4+sc7N1ZpywuQCikPB1eo9RXumZWNIqOja3DSDHmE1yIfL8BRcjfrkIJ5BtGUnzDSF
         ij+ySrjanXn4WwQuSSrSz4GmYoNnd3Xwq4Dscop52FGZL4Ghfng8R7qRRdE0zPoBYUuq
         2TUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guillaume.tucker@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=guillaume.tucker@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAuak2jDLeKawzxVd+r21doiI7ADCuYk097jcKHpTEkj0UYvpO182
	WIOFYtBMVFW6XzUy4qlsakHecUuZEFeKkgFcgHF5GBGm6RrxgvniuPt9K3AiPvJ75OHOvreMDZm
	dc4s6KAyCDFPlw65JdhbZ1sfHVHHE34jzXukIFf6sShWhPuIRDCnSYlDkUpGRp7iWFg==
X-Received: by 2002:a7b:c396:: with SMTP id s22mr4695836wmj.100.1551474292130;
        Fri, 01 Mar 2019 13:04:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iajj7Y5+ry+jZZrAWb9jCpKZKcNUotzAem+Mlxr74OxWh77EWsJvJBZo1qJk57xF/+CC9TG
X-Received: by 2002:a7b:c396:: with SMTP id s22mr4695791wmj.100.1551474290970;
        Fri, 01 Mar 2019 13:04:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551474290; cv=none;
        d=google.com; s=arc-20160816;
        b=pTRDlpGqOp5oYpRT2jtTj/RlQhE/kxscYsrkHyluEPJfRhUAuH7ylZZruCeOWsBpcq
         xllFtJHbmBMwrwrVyREadFm3I6ppyN0blFbXyhVWqQfrc54G4iemd/iJfl10iCXV2UVk
         ac+JbeNzsHDbxv4Rc9OU0qJ0wW8DibA58L7tR2v+59qhm3DguIFVwAQWrRq0EWcNLv1a
         SMegDY+kckw4G1TQemLfCHowRMLVol++xEsx6WJTH/8vDGzZXl6a5qo93yvAAprqPsss
         vUsdOl+x7u7GE9Po5T70eGbJ1vfjEw0rfNj1Ew/xshxiofOLGRrvAXqpJmwSc7xHrcmy
         5dEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=V8sy0agZ55nRCo9Q2PNXzwo0Hp55JqCS0DxwToQnYBc=;
        b=CnEP+LEVrOKPYAtw97RTp/h0rJkn66WIzxEoKsZab/QSwJSBdEbJOiHJLwTwirphLb
         8eqCzagikT8cHs/yr8hruK6C8ROd5ppfIImK+VkJf4zwrdpYhlh68UP1k5QAgRHZeVOO
         2zCqAnVZRsBk7tDMqIr6rkLZzxW70+fih2NxBBFIemtfYl0sa2Pmnrjbbhg+IiiW43TX
         bvR7Lv/nUPhUnd2BQ8WTBEAkEoRywbKaZMNLvT3fPpNgeL0l/oLNbckxicQi0ids0pOT
         8/cblCo8UJBeM3U0jPssntaQ7UWdqwMjFacvnQZzUtWysrrFTqs9ZZGG3m59ELYasFqD
         Iw7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guillaume.tucker@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=guillaume.tucker@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id v17si5221256wmj.177.2019.03.01.13.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 13:04:50 -0800 (PST)
Received-SPF: pass (google.com: domain of guillaume.tucker@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guillaume.tucker@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=guillaume.tucker@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: gtucker)
	with ESMTPSA id 7B14C27D914
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>,
 Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell
 <sfr@canb.auug.org.au>, khilman@baylibre.com, enric.balletbo@collabora.com,
 Nicholas Piggin <npiggin@gmail.com>,
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
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
 <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
From: Guillaume Tucker <guillaume.tucker@collabora.com>
Message-ID: <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com>
Date: Fri, 1 Mar 2019 21:04:46 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/03/2019 20:41, Andrew Morton wrote:
> On Fri, 1 Mar 2019 09:25:24 +0100 Guillaume Tucker <guillaume.tucker@collabora.com> wrote:
> 
>>>>> Michal had asked if the free space accounting fix up addressed this
>>>>> boot regression? I was awaiting word on that.
>>>>
>>>> hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..
>>
>> bot@kernelci.org is not person, it's a send-only account for
>> automated reports.  So no, it doesn't read emails.
>>
>> I guess the tricky point here is that the authors of the commits
>> found by bisections may not always have the hardware needed to
>> reproduce the problem.  So it needs to be dealt with on a
>> case-by-case basis: sometimes they do have the hardware,
>> sometimes someone else on the list or on CC does, and sometimes
>> it's better for the people who have access to the test lab which
>> ran the KernelCI test to deal with it.
>>
>> This case seems to fall into the last category.  As I have access
>> to the Collabora lab, I can do some quick checks to confirm
>> whether the proposed patch does fix the issue.  I hadn't realised
>> that someone was waiting for this to happen, especially as the
>> BeagleBone Black is a very common platform.  Sorry about that,
>> I'll take a look today.
>>
>> It may be a nice feature to be able to give access to the
>> KernelCI test infrastructure to anyone who wants to debug an
>> issue reported by KernelCI or verify a fix, so they won't need to
>> have the hardware locally.  Something to think about for the
>> future.
> 
> Thanks, that all sounds good.
> 
>>>> Is it possible to determine whether this regression is still present in
>>>> current linux-next?
>>
>> I'll try to re-apply the patch that caused the issue, then see if
>> the suggested change fixes it.  As far as the current linux-next
>> master branch is concerned, KernelCI boot tests are passing fine
>> on that platform.
> 
> They would, because I dropped
> mm-shuffle-default-enable-all-shuffling.patch, so your tests presumably
> now have shuffling disabled.
> 
> Is it possible to add the below to linux-next and try again?

I've actually already done that, and essentially the issue can
still be reproduced by applying that patch.  See this branch:

  https://gitlab.collabora.com/gtucker/linux/commits/next-20190301-beaglebone-black-debug

next-20190301 boots fine but the head fails, using
multi_v7_defconfig + SMP=n in both cases and
SHUFFLE_PAGE_ALLOCATOR=y enabled in the 2nd case as a result
of the change in the default value.

The change suggested by Michal Hocko on Feb 15th has now been
applied in linux-next, it's part of this commit but as
explained above it does not actually resolve the boot failure:

  98cf198ee8ce mm: move buddy list manipulations into helpers

I can send more details on Monday and do a bit of debugging to
help narrowing down the problem.  Please let me know if
there's anything in particular that would seem be worth
trying.

> Or I can re-add this to linux-next.  Where should we go to determine
> the results of such a change?  There are a heck of a lot of results on
> https://kernelci.org/boot/ and entering "beaglebone-black" doesn't get
> me anything.

The BeagleBone Black board was offline for a few days in our
lab, which probably explains why you're not getting much
results from the web interface.  Hopefully we'll see passing
boot results in linux-next tomorrow now that the board is back
on track.

It's quite easy for me to submit test jobs with kernels I've
built myself instead of going through the full linux-next and
KernelCI loop.  So that's the best way to try things out, then
when a fix has been found it can be applied in linux-next on
top of the mm/shuffle change to verify it in KernelCI.

Guillaume

> From: Dan Williams <dan.j.williams@intel.com>
> Subject: mm/shuffle: default enable all shuffling
> 
> Per Andrew's request arrange for all memory allocation shuffling code to
> be enabled by default.
> 
> The page_alloc.shuffle command line parameter can still be used to disable
> shuffling at boot, but the kernel will default enable the shuffling if the
> command line option is not specified.
> 
> Link: http://lkml.kernel.org/r/154943713572.3858443.11206307988382889377.stgit@dwillia2-desk3.amr.corp.intel.com
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Keith Busch <keith.busch@intel.com>
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  init/Kconfig |    4 ++--
>  mm/shuffle.c |    4 ++--
>  mm/shuffle.h |    2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> --- a/init/Kconfig~mm-shuffle-default-enable-all-shuffling
> +++ a/init/Kconfig
> @@ -1709,7 +1709,7 @@ config SLAB_MERGE_DEFAULT
>  	  command line.
>  
>  config SLAB_FREELIST_RANDOM
> -	default n
> +	default y
>  	depends on SLAB || SLUB
>  	bool "SLAB freelist randomization"
>  	help
> @@ -1728,7 +1728,7 @@ config SLAB_FREELIST_HARDENED
>  
>  config SHUFFLE_PAGE_ALLOCATOR
>  	bool "Page allocator randomization"
> -	default SLAB_FREELIST_RANDOM && ACPI_NUMA
> +	default y
>  	help
>  	  Randomization of the page allocator improves the average
>  	  utilization of a direct-mapped memory-side-cache. See section
> --- a/mm/shuffle.c~mm-shuffle-default-enable-all-shuffling
> +++ a/mm/shuffle.c
> @@ -9,8 +9,8 @@
>  #include "internal.h"
>  #include "shuffle.h"
>  
> -DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
> -static unsigned long shuffle_state __ro_after_init;
> +DEFINE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
> +static unsigned long shuffle_state __ro_after_init = 1 << SHUFFLE_ENABLE;
>  
>  /*
>   * Depending on the architecture, module parameter parsing may run
> --- a/mm/shuffle.h~mm-shuffle-default-enable-all-shuffling
> +++ a/mm/shuffle.h
> @@ -19,7 +19,7 @@ enum mm_shuffle_ctl {
>  #define SHUFFLE_ORDER (MAX_ORDER-1)
>  
>  #ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> -DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
> +DECLARE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
>  extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
>  extern void __shuffle_free_memory(pg_data_t *pgdat);
>  static inline void shuffle_free_memory(pg_data_t *pgdat)
> _
> 

