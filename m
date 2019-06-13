Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F627C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:03:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4010520679
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:03:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4010520679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF4DC6B026A; Thu, 13 Jun 2019 10:03:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA4296B026B; Thu, 13 Jun 2019 10:03:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6F328E0001; Thu, 13 Jun 2019 10:03:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD4A6B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:03:18 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id n25so1786910wmc.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:03:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UVX8Y2nZSU8wr6vWWKjaM2uzfMrT8CwvBAXqnr/WTgc=;
        b=iTIqjWMHi+lVz+R0Ne5t6Ed7JqkFryhO6jSZGqBdT/VbiV2Z5/mDUtZ161niT1hBJU
         dRZ+abBHiv15j3sJuUy69y1DM8o6FKb8FCP9pXPduh1lb13DPO7NeB+e6LKOtIwiDH76
         f7vZM31TTK1lz54TT41J5crxtabGfI6r8VML9J8mVSkYbsYL2JvxNLx5Fi1SonXU4tDF
         Kw1CetXPTGEtNUMBf5voHYlDHUQ4tELhRCReDcCnSw6hZGHxCqoSxA8yUGS4Hmn2wK+H
         wZ0TqPGBosfh2L9sVBlQqzhz95Mt0N/qPl7fWQYoFLNIUxZ9ddXSpY/qlzIsBG639Pn5
         gi3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUGho6FCTaICSd1boawVDNwuJgiQltHIm2Hnue2ZwF6EnppKGqG
	yGUYiyq/L9ePU1uvSml/mu0euabopSo/NYTOrn8KEqWqQ5lx2664gnPAOVQX3SEnqNkBWa1ybQK
	kgCeJNDEr4FgJLDGYgrwRHPfCh+ONyLgzzbbbaR8OWiWy75rPpZF9dJ90g05ofnkl3w==
X-Received: by 2002:adf:814d:: with SMTP id 71mr11042058wrm.50.1560434597771;
        Thu, 13 Jun 2019 07:03:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcswOxERu72l00Zf683Ohmra8C66UTLHwzwV7zXHYUAzur7x8sVScJPpD6jVPj4/k97d04
X-Received: by 2002:adf:814d:: with SMTP id 71mr11041983wrm.50.1560434596971;
        Thu, 13 Jun 2019 07:03:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560434596; cv=none;
        d=google.com; s=arc-20160816;
        b=Lzk4QxdkR5QunzwwvBg1BF5DCcUnAziaFqO9jry8+POv7kHsSUedif6/+8n9cTmRbx
         1CCI4jfAgrOFfooQFwygZh3dmBBJwZLNY/5gHSU/XAN3h0ediycuPkHeVB/ImOOV6knk
         zA85qg9sf1DzjGwJYmgn5Y3tjtcvw5dnr9M0ZLHGFarzQWovFdQfAV24vMrayPsa4GRd
         PMiOx/uqw75dK0nzX2V/1RkHzDGOrCfT5IZQCma4Eg3UC0ciOlzFVpFy/uEjZDrHpwq1
         h8+61EbyaJnuWZnlWCwFmDXuEHepdGQkujuFDnMUYgqBGfJjFGbHZTElWzk9K4FARYFM
         NI+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=UVX8Y2nZSU8wr6vWWKjaM2uzfMrT8CwvBAXqnr/WTgc=;
        b=oySg7aYGC7MqZIATf/3NjJwg65Ipx0hrNqogyVceMAa7K2XDHgAQ5P1CC9TDby9rLx
         WTRg7DIBWk+Rx7yOzFWfBxbEv1SjRstUKf94V02y/MRfTSR+ou3pEuQb2R+9MnaBElV2
         FSRuqmqV0ELdPiBw0D/U4cOwpOjDl25TeZwfp8HOtAkfX3yy4aihfDKNq0zS8wfRGf4i
         amuaahAJ9ehHrtw8suzJRua3fePO4i0pE2quuCjtTH572SBWZM8iTV8+ksBDTsqjlGZU
         UWJPwv8jBMXAIbHF7PYOWLFuFYS3mWTFJXjgN68bJVHV5a9xjU0o32DtlZRKxzRBtMGD
         D7Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h32si2511419edb.97.2019.06.13.07.03.16
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 07:03:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 852BC3EF;
	Thu, 13 Jun 2019 07:03:15 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1320D3F718;
	Thu, 13 Jun 2019 07:03:13 -0700 (PDT)
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>
Cc: nd <nd@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
 "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Will Deacon <Will.Deacon@arm.com>, Andrey Konovalov <andreyknvl@google.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <a90da586-8ff6-4bed-d940-9306d517a18c@arm.com>
 <20190613092054.GO28951@C02TF0J2HF1T.local>
 <dee7f192-d0f0-558e-3007-eba805c6f2da@arm.com>
 <6ebbda37-5dd9-d0d5-d9cb-286c7a5b7f8e@arm.com>
 <8e3c9537-de10-0d0d-f5bb-c33bde92443f@arm.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <5963d144-be9b-78d8-9130-ef92bc66b1fd@arm.com>
Date: Thu, 13 Jun 2019 15:03:12 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <8e3c9537-de10-0d0d-f5bb-c33bde92443f@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 13/06/2019 13:28, Szabolcs Nagy wrote:
> On 13/06/2019 12:16, Vincenzo Frascino wrote:
>> Hi Szabolcs,
>>
>> thank you for your review.
>>
>> On 13/06/2019 11:14, Szabolcs Nagy wrote:
>>> On 13/06/2019 10:20, Catalin Marinas wrote:
>>>> Hi Szabolcs,
>>>>
>>>> On Wed, Jun 12, 2019 at 05:30:34PM +0100, Szabolcs Nagy wrote:
>>>>> On 12/06/2019 15:21, Vincenzo Frascino wrote:
>>>>>> +2. ARM64 Tagged Address ABI
>>>>>> +---------------------------
>>>>>> +
>>>>>> +From the kernel syscall interface prospective, we define, for the purposes
>>>>>                                      ^^^^^^^^^^^
>>>>> perspective
>>>>>
>>>>>> +of this document, a "valid tagged pointer" as a pointer that either it has
>>>>>> +a zero value set in the top byte or it has a non-zero value, it is in memory
>>>>>> +ranges privately owned by a userspace process and it is obtained in one of
>>>>>> +the following ways:
>>>>>> +  - mmap() done by the process itself, where either:
>>>>>> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
>>>>>> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
>>>>>> +      file or "/dev/zero"
>>>>>
>>>>> this does not make it clear if MAP_FIXED or other flags are valid
>>>>> (there are many map flags i don't know, but at least fixed should work
>>>>> and stack/growsdown. i'd expect anything that's not incompatible with
>>>>> private|anon to work).
>>>>
>>>> Just to clarify, this document tries to define the memory ranges from
>>>> where tagged addresses can be passed into the kernel in the context
>>>> of TBI only (not MTE); that is for hwasan support. FIXED or GROWSDOWN
>>>> should not affect this.
>>>
>>> yes, so either the text should list MAP_* flags that don't affect
>>> the pointer tagging semantics or specify private|anon mapping
>>> with different wording.
>>>
>>
>> Good point. Could you please propose a wording that would be suitable for this case?
> 
> i don't know all the MAP_ magic, but i think it's enough to change
> the "flags =" to
> 
> * flags have MAP_PRIVATE and MAP_ANONYMOUS set or
> * flags have MAP_PRIVATE set and the file descriptor refers to...
> 
> 

Fine by me.  I will add it the next iterations.

>>>>>> +  - a mapping below sbrk(0) done by the process itself
>>>>>
>>>>> doesn't the mmap rule cover this?
>>>>
>>>> IIUC it doesn't cover it as that's memory mapped by the kernel
>>>> automatically on access vs a pointer returned by mmap(). The statement
>>>> above talks about how the address is obtained by the user.
>>>
>>> ok i read 'mapping below sbrk' as an mmap (possibly MAP_FIXED)
>>> that happens to be below the heap area.
>>>
>>> i think "below sbrk(0)" is not the best term to use: there
>>> may be address range below the heap area that can be mmapped
>>> and thus below sbrk(0) and sbrk is a posix api not a linux
>>> syscall, the libc can implement it with mmap or whatever.
>>>
>>> i'm not sure what the right term for 'heap area' is
>>> (the address range between syscall(__NR_brk,0) at
>>> program startup and its current value?)
>>>
>>
>> I used sbrk(0) with the meaning of "end of the process's data segment" not
>> implying that this is a syscall, but just as a useful way to identify the mapping.
>> I agree that it is a posix function implemented by libc but when it is used with
>> 0 finds the current location of the program break, which can be changed by brk()
>> and depending on the new address passed to this syscall can have the effect of
>> allocating or deallocating memory.
>>
>> Will changing sbrk(0) with "end of the process's data segment" make it more clear?
> 
> i don't understand what's the relevance of the *end*
> of the data segment.
> 
> i'd expect the text to say something about the address
> range of the data segment.
> 
> i can do
> 
> mmap((void*)65536, 65536, PROT_READ|PROT_WRITE, MAP_FIXED|MAP_SHARED|MAP_ANON, -1, 0);
> 
> and it will be below the end of the data segment.
>

As far as I understand the data segment "lives" below the program break, hence
it is a way of describing the range from which the user can obtain a valid
tagged pointer.

Said that, I am not really sure on how do you want me to document this (my aim
is for this to be clear to the userspace developers). Could you please propose
something?

>>
>> I will add what you are suggesting about the heap area.
>>

-- 
Regards,
Vincenzo

