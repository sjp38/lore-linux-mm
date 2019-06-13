Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EBE0C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:15:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3AF321744
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:15:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3AF321744
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47AA16B0271; Thu, 13 Jun 2019 06:15:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 450EA6B0272; Thu, 13 Jun 2019 06:15:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31AD86B0274; Thu, 13 Jun 2019 06:15:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D66C76B0271
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:15:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c27so14981731edn.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:15:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4nwWXG13vzH2Kq0JeIN6rrlqEn7te6dBRcoJlvEogqQ=;
        b=oWhgvJ9HO9oQO2Ip5asUtpLvqYTnin/IVVoNiOc9JsIpjKzdPemub8cp5JZeHooBSp
         suzVlqnlicqWMgEbeYmsZVIc31sUt2ZL7y5b5JXhy4stbXxv6gvO+bqlby9rzLARPVIx
         dyOoeUQaXwhaTV1nApdDVF009Qx5UYsBA6xCM9yzkui3qjfEW3tXwj90fVn9gxrn8yC1
         ZVVXKybEXfmN7mMWu/SQe6T6gFLi2+CxH00j3CECupDd8U5ccL+/VwcDzJl5Bf6Ztjn9
         HpDI5nO4XjqnZABXI0B4QDAKXWdU4fuHtMc+6bxdUMHsYaqW7D8C+SWhbUfLYdMaKWd2
         f3rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUzIC/6ULrcIAs7MbIj3vE2BoWqZIqKl7ADQT5vMW53HMvQ+FZT
	OMqX/flNp+37PSfEOOQyCunguiUdkQ1VGrA3D2wzz5MEDLyuoG2v50pZGdR41OqtRpH+KsKjhP+
	JYNYjA+HM5liLWSQiPdFN11eQ7+4YcZBr5KjuUTVchm3/LttNmW06fj+GtBNCnPKZYA==
X-Received: by 2002:aa7:d781:: with SMTP id s1mr22104253edq.20.1560420940293;
        Thu, 13 Jun 2019 03:15:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyfRpusy4M0eH8owUW+XY24Jxz1bTs/gQZXHm4mINhfSkCpDzIz96MzahMHvO0ObldUncM
X-Received: by 2002:aa7:d781:: with SMTP id s1mr22104081edq.20.1560420938660;
        Thu, 13 Jun 2019 03:15:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560420938; cv=none;
        d=google.com; s=arc-20160816;
        b=MhXYX1f6N5agO0auwRPwK9wiVLEftGXozQtgzCFkVLQOvBEwc3YT1zsGoM2xFCFOPH
         R13pFphUgSTDAwqBxmFi+t0dEwOTyOSGzs2V8RYTvcrLwUzhvWu7HhNTMyHNt7dJ0knK
         Qru/M9b2sj8lAk+i2vU1ngYgjoSadfgIBd+6zWiqvP8ZCB1wA1yd3y5ouZZQUz7jaDeP
         w131n6rKcSCLsfQDTBQIwRiuPM069WintLLVyioNkvf9Ph7djc7aAGqi9EF73oZb+jUJ
         GyJQeErm+sbcx4aITTLyTLJsxJQ6kgIPlADp5x5kLOzmKeH8+8xibSclTYpYUqKELPJI
         z2PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4nwWXG13vzH2Kq0JeIN6rrlqEn7te6dBRcoJlvEogqQ=;
        b=EB6TVh+3LimE+joaJBHGr5j/FKowg2EQNP8fXxWMOmJu5EQeSa8ttt9/qAXjm5FgGG
         eSpRpZK5My3Tny3wQUKVmyZP8UJDngBCf2rQ/krIh2ApfOXTtcBBlOZgxlET9zMtU7XV
         MwvgOpMtx6vjjoVL3Y2TiYibqtyY4KzpihG447gylBiFnUjFRPN6pqChIE/SAPO+pNF5
         DxxVowfJZgSveMKUKO90PQGv2npV22mhXoRoI2KmTMTGLOZSx0v8EXOg2RPpdeMLyuHz
         qiQrKEXLWeQNzPDLPKhP0zBxt0rQ6oz7FWBTk+yTD1kkwWQacbhzEepsWBHVJ71Xt2dh
         JIBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p18si1756499eju.281.2019.06.13.03.15.37
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 03:15:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4D58E367;
	Thu, 13 Jun 2019 03:15:37 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F29693F694;
	Thu, 13 Jun 2019 03:17:18 -0700 (PDT)
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
 Will Deacon <will.deacon@arm.com>, Andrey Konovalov <andreyknvl@google.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Szabolcs Nagy <szabolcs.nagy@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <20190612153538.GL28951@C02TF0J2HF1T.local>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <141c740a-94c2-2243-b6d1-b44ffee43791@arm.com>
Date: Thu, 13 Jun 2019 11:15:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190612153538.GL28951@C02TF0J2HF1T.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Catalin,

On 12/06/2019 16:35, Catalin Marinas wrote:
> Hi Vincenzo,
> 
> Some minor comments below but it looks fine to me overall. Cc'ing
> Szabolcs as well since I'd like a view from the libc people.
> 

Thanks for this, I saw Szabolcs comments.

> On Wed, Jun 12, 2019 at 03:21:10PM +0100, Vincenzo Frascino wrote:
>> diff --git a/Documentation/arm64/tagged-address-abi.txt b/Documentation/arm64/tagged-address-abi.txt
>> new file mode 100644
>> index 000000000000..96e149e2c55c
>> --- /dev/null
>> +++ b/Documentation/arm64/tagged-address-abi.txt
>> @@ -0,0 +1,111 @@
>> +ARM64 TAGGED ADDRESS ABI
>> +========================
>> +
>> +This document describes the usage and semantics of the Tagged Address
>> +ABI on arm64.
>> +
>> +1. Introduction
>> +---------------
>> +
>> +On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64 kernel,
>> +hence the userspace (EL0) is allowed to set a non-zero value in the top
> 
> I'd be clearer here: "userspace (EL0) is allowed to perform a user
> memory access through a 64-bit pointer with a non-zero top byte" (or
> something along the lines). Otherwise setting a non-zero top byte is
> allowed on any architecture, dereferencing it is a problem.
> 

Ok.

>> +byte but the resulting pointers are not allowed at the user-kernel syscall
>> +ABI boundary.
>> +
>> +This document describes a relaxation of the ABI with which it is possible
> 
> "relaxation of the ABI that makes it possible to..."
> 
>> +to pass tagged tagged pointers to the syscalls, when these pointers are in
>> +memory ranges obtained as described in paragraph 2.
> 
> "section 2" is better. There are a lot more paragraphs.
> 

Agree.

>> +
>> +Since it is not desirable to relax the ABI to allow tagged user addresses
>> +into the kernel indiscriminately, arm64 provides a new sysctl interface
>> +(/proc/sys/abi/tagged_addr) that is used to prevent the applications from
>> +enabling the relaxed ABI and a new prctl() interface that can be used to
>> +enable or disable the relaxed ABI.
>> +
>> +The sysctl is meant also for testing purposes in order to provide a simple
>> +way for the userspace to verify the return error checking of the prctl()
>> +command without having to reconfigure the kernel.
>> +
>> +The ABI properties are inherited by threads of the same application and
>> +fork()'ed children but cleared when a new process is spawn (execve()).
> 
> "spawned".
> 
> I guess you could drop these three paragraphs here and mention the
> inheritance properties when introducing the prctl() below. You can also
> mention the global sysctl switch after the prctl() was introduced.
> 

I will move the last two (rewording them) to the _section_ 2, but I would still
prefer the Introduction to give an overview of the solution as well.

>> +
>> +2. ARM64 Tagged Address ABI
>> +---------------------------
>> +
>> +From the kernel syscall interface prospective, we define, for the purposes
>> +of this document, a "valid tagged pointer" as a pointer that either it has
> 
> "either has" (no 'it') sounds slightly better but I'm not a native
> English speaker either.
> 
>> +a zero value set in the top byte or it has a non-zero value, it is in memory
>> +ranges privately owned by a userspace process and it is obtained in one of
>> +the following ways:
>> +  - mmap() done by the process itself, where either:
>> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
>> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
>> +      file or "/dev/zero"
>> +  - a mapping below sbrk(0) done by the process itself
>> +  - any memory mapped by the kernel in the process's address space during
>> +    creation and following the restrictions presented above (i.e. data, bss,
>> +    stack).
>> +
>> +The ARM64 Tagged Address ABI is an opt-in feature, and an application can
>> +control it using the following prctl()s:
>> +  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable the Tagged Address ABI.
> 
> enable or disable (not sure we need the latter but it doesn't heart).
> 
> I'd add the arg2 description here as well.
> 

Good point I missed this.

>> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
>> +                             Address ABI.
>> +
>> +As a consequence of invoking PR_SET_TAGGED_ADDR_CTRL prctl() by an applications,
>> +the ABI guarantees the following behaviours:
>> +
>> +  - Every current or newly introduced syscall can accept any valid tagged
>> +    pointers.
>> +
>> +  - If a non valid tagged pointer is passed to a syscall then the behaviour
>> +    is undefined.
>> +
>> +  - Every valid tagged pointer is expected to work as an untagged one.
>> +
>> +  - The kernel preserves any valid tagged pointers and returns them to the
>> +    userspace unchanged in all the cases except the ones documented in the
>> +    "Preserving tags" paragraph of tagged-pointers.txt.
> 
> I'd think we need to qualify the context here in which the kernel
> preserves the tagged pointers. Did you mean on the syscall return?
> 

What this means is that on syscall return the tags are preserved, but if for
example you have tagged pointers inside siginfo_t, they will not because
according to tagged-pointers.txt non-zero tags are not preserved when delivering
signals.

>> +
>> +A definition of the meaning of tagged pointers on arm64 can be found in:
>> +Documentation/arm64/tagged-pointers.txt.
>> +
>> +3. ARM64 Tagged Address ABI Exceptions
>> +--------------------------------------
>> +
>> +The behaviours described in paragraph 2, with particular reference to the
> 
> "section 2"
> 
>> +acceptance by the syscalls of any valid tagged pointer are not applicable
>> +to the following cases:
>> +  - mmap() addr parameter.
>> +  - mremap() new_address parameter.
>> +  - prctl_set_mm() struct prctl_map fields.
>> +  - prctl_set_mm_map() struct prctl_map fields.
>> +
>> +4. Example of correct usage
>> +---------------------------
>> +
>> +void main(void)
>> +{
>> +	static int tbi_enabled = 0;
>> +	unsigned long tag = 0;
>> +
>> +	char *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
>> +			 MAP_ANONYMOUS, -1, 0);
>> +
>> +	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE,
>> +		  0, 0, 0) == 0)
>> +		tbi_enabled = 1;
>> +
>> +	if (!ptr)
>> +		return -1;
>> +
>> +	if (tbi_enabled)
>> +		tag = rand() & 0xff;
>> +
>> +	ptr = (char *)((unsigned long)ptr | (tag << TAG_SHIFT));
>> +
>> +	*ptr = 'a';
>> +
>> +	...
>> +}
>> +
>> -- 
>> 2.21.0
> 

-- 
Regards,
Vincenzo

