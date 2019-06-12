Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55F68C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:52:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18D1E20896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:52:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18D1E20896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4DC16B0005; Wed, 12 Jun 2019 07:52:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFE766B0007; Wed, 12 Jun 2019 07:52:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EE336B000A; Wed, 12 Jun 2019 07:52:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52B9D6B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:52:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so10081300edr.13
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:52:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7EM5l5ODuWldDRCPuA7aJ695DXnIy73cRFrGrKlLaDQ=;
        b=IeffpT4fURGl8LBEIZCZRQrrLrNIUKuugiHlm7MgxqXdeIZ4cnFnvcNsRNFuQaI1nz
         A2edskNUsQzMjvdwCCNUi/WYhxtE4HzillF/mkRauhsPG0XEfOXY5Fnil6/YgeiMiASU
         Ax06wtfBS3SAqUFRCXXoCq/KlklFvont6SBEmQBxPqBDKASurMavAXf4xZNj/ua5bkts
         t0JeePmpzna/csJV63j9f2Ouu3E7DQpfxhVUxZnZWPEg3DqjhJVbI0UrrFK1trzJRS+D
         I+/hU8nHjn4u3Q4Ij+tgCpV0ojnHUvyRx7mw4iYvI8ubHPgTRRs6BRoRnPXnwwQK0LfQ
         rL0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAW0y5V6x8ezWVfqcxidqCWnvL/JMkn2ubEOA44FBSQ8kVXewFAn
	3SB8Cyr+tGfvUssmEPnueMa4NYBKHt3WYINURZbj8eV8u9G7WIKSaTHrK/t+tcEoqyMvDEzglXl
	GT+l+UM8kG1S431shJS89gbm6brVU2BbyIiU9mpAUOzuCHj+0vJd9kKRPkXig24gkRA==
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr36199876ejb.34.1560340377658;
        Wed, 12 Jun 2019 04:52:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaxND7hboktRU1lK4nVUtWruHA7qV9skFTE4JzaSQxNvjfgomMT/RIDSUbw5h4cQbTeZGV
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr36199807ejb.34.1560340376558;
        Wed, 12 Jun 2019 04:52:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560340376; cv=none;
        d=google.com; s=arc-20160816;
        b=vnq6za6hEtapMTQpKCSguxnJBxw5ub8eVpm4ZMxtr3lsABOt5bzq6sAooUZ21z+FVS
         vwDI+Og6KlNKpC5dvaOODtkd0B7iX+ljLQp/HD8KBV8fL5cpOeRkLz+2CTuQdxiyE+Z5
         TdTAlWnlYcppl01F5oUXzLRa1M/m7IDjqgrr5xAnQRV5oGfWE/56XlLnIdcDtTIOI1LR
         VvI5/6wmFIh1V4/BRo41MI3jmdD23U37xXdCCqk21mOQNaMueHWw1o9HXkQiKH4B3Agx
         7ni0VfUojH8szxmIq5Yl4isMAU2CaGL2TvZH5xrfAHhBIBD4y2Vddirf//8tee4zdwEf
         TAsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7EM5l5ODuWldDRCPuA7aJ695DXnIy73cRFrGrKlLaDQ=;
        b=acja4XmsN1Nnj9SQCvNXnuPzOFcySIQrhun4fH8P/AJB74PrXXQ6+Q5o0vyrsWvYDg
         FrfKbMXtvxmr62fVz5Pe/enluFwIzBX32PwbdIZjNL/zCQntxSyW6Ujmktx0jacnFKD7
         o5fE+IGET9vjcQDBfZzmi3zWX1LX4m3Oik/9kgoiDDm+ib/DO9mEcadS+cmZMV8nQ/Dp
         VKpNRHwmnUojM/fqMZ1c/SjVrNVBO69j1ptlPFEveD9NaCFMCLHsSe1L6QFY/u9hCcap
         Cuo3BEFQIB1GBiUoq0Z+Z/H+DmL0+BpJabTilIdDZLt8lRM3caqtjIZTmwjRVReFZZbA
         yz8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w28si3524033edc.10.2019.06.12.04.52.56
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 04:52:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 78BEC28;
	Wed, 12 Jun 2019 04:52:55 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2E9883F246;
	Wed, 12 Jun 2019 04:54:33 -0700 (PDT)
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
 Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Will Deacon <will.deacon@arm.com>,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
 Khalid Aziz <khalid.aziz@oracle.com>, linux-kselftest@vger.kernel.org,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Leon Romanovsky <leon@kernel.org>,
 linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dmitry Vyukov <dvyukov@google.com>, Dave Martin <Dave.Martin@arm.com>,
 Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
 Kevin Brodsky <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Alex Williamson <alex.williamson@redhat.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 linux-arm-kernel@lists.infradead.org, Kostya Serebryany <kcc@google.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
 Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>,
 Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
 <20190611145720.GA63588@arrakis.emea.arm.com>
 <d3dc2b1f-e8c9-c60d-f648-0bc9b08f20e4@arm.com>
 <20190612093158.GG10165@c02tf0j2hf1t.cambridge.arm.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <c760f34a-1b99-17bb-8cc8-ea8b0d63fe90@arm.com>
Date: Wed, 12 Jun 2019 12:52:49 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190612093158.GG10165@c02tf0j2hf1t.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Catalin,

On 12/06/2019 10:32, Catalin Marinas wrote:
> Hi Vincenzo,
> 
> On Tue, Jun 11, 2019 at 06:09:10PM +0100, Vincenzo Frascino wrote:
>>> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
>>> index 3767fb21a5b8..69d0be1fc708 100644
>>> --- a/arch/arm64/kernel/process.c
>>> +++ b/arch/arm64/kernel/process.c
>>> @@ -30,6 +30,7 @@
>>>  #include <linux/kernel.h>
>>>  #include <linux/mm.h>
>>>  #include <linux/stddef.h>
>>> +#include <linux/sysctl.h>
>>>  #include <linux/unistd.h>
>>>  #include <linux/user.h>
>>>  #include <linux/delay.h>
>>> @@ -323,6 +324,7 @@ void flush_thread(void)
>>>  	fpsimd_flush_thread();
>>>  	tls_thread_flush();
>>>  	flush_ptrace_hw_breakpoint(current);
>>> +	clear_thread_flag(TIF_TAGGED_ADDR);
>>
>> Nit: in line we the other functions in thread_flush we could have something like
>> "tagged_addr_thread_flush", maybe inlined.
> 
> The other functions do a lot more than clearing a TIF flag, so they
> deserved their own place. We could do this when adding MTE support. I
> think we also need to check what other TIF flags we may inadvertently
> pass on execve(), maybe have a mask clearing.
> 

Agreed. All the comments I provided are meant to simplify the addition of MTE
support.

>>> diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
>>> index 094bb03b9cc2..2e927b3e9d6c 100644
>>> --- a/include/uapi/linux/prctl.h
>>> +++ b/include/uapi/linux/prctl.h
>>> @@ -229,4 +229,9 @@ struct prctl_mm_map {
>>>  # define PR_PAC_APDBKEY			(1UL << 3)
>>>  # define PR_PAC_APGAKEY			(1UL << 4)
>>>  
>>> +/* Tagged user address controls for arm64 */
>>> +#define PR_SET_TAGGED_ADDR_CTRL		55
>>> +#define PR_GET_TAGGED_ADDR_CTRL		56
>>> +# define PR_TAGGED_ADDR_ENABLE		(1UL << 0)
>>> +
>>>  #endif /* _LINUX_PRCTL_H */
>>> diff --git a/kernel/sys.c b/kernel/sys.c
>>> index 2969304c29fe..ec48396b4943 100644
>>> --- a/kernel/sys.c
>>> +++ b/kernel/sys.c
>>> @@ -124,6 +124,12 @@
>>>  #ifndef PAC_RESET_KEYS
>>>  # define PAC_RESET_KEYS(a, b)	(-EINVAL)
>>>  #endif
>>> +#ifndef SET_TAGGED_ADDR_CTRL
>>> +# define SET_TAGGED_ADDR_CTRL(a)	(-EINVAL)
>>> +#endif
>>> +#ifndef GET_TAGGED_ADDR_CTRL
>>> +# define GET_TAGGED_ADDR_CTRL()		(-EINVAL)
>>> +#endif
>>>  
>>>  /*
>>>   * this is where the system-wide overflow UID and GID are defined, for
>>> @@ -2492,6 +2498,16 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>>>  			return -EINVAL;
>>>  		error = PAC_RESET_KEYS(me, arg2);
>>>  		break;
>>> +	case PR_SET_TAGGED_ADDR_CTRL:
>>> +		if (arg3 || arg4 || arg5)
>>> +			return -EINVAL;
>>> +		error = SET_TAGGED_ADDR_CTRL(arg2);
>>> +		break;
>>> +	case PR_GET_TAGGED_ADDR_CTRL:
>>> +		if (arg2 || arg3 || arg4 || arg5)
>>> +			return -EINVAL;
>>> +		error = GET_TAGGED_ADDR_CTRL();
>>> +		break;
>>
>> Why do we need two prctl here? We could have only one and use arg2 as set/get
>> and arg3 as a parameter. What do you think?
> 
> This follows the other PR_* options, e.g. PR_SET_VL/GET_VL,
> PR_*_FP_MODE. We will use other bits in arg2, for example to set the
> precise vs imprecise MTE trapping.
> 

Indeed. I was not questioning the pre-existing interface definition, but trying
more to reduce the changes to the ABI to the minimum since:
 - prctl does not mandate how to use the arg[2-5]
 - prctl interface is flexible enough for the problem to be solved with only one
   PR_ command.

I agree on reusing the interface for MTE for the purposes you specified.

-- 
Regards,
Vincenzo

