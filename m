Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 099ABC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B843E217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:31:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B843E217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BB7C8E000E; Tue, 26 Feb 2019 12:31:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345178E0001; Tue, 26 Feb 2019 12:31:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E6598E000E; Tue, 26 Feb 2019 12:31:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B70F08E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:31:04 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x13so3554652edq.11
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:31:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=5NZHHJIShEBKX3j9ds5OZtMVqmHwvxVjDwhh6434jpM=;
        b=NZcNrWHlxRaxnKR/hUQKMFBS/xMTNssoOgzw0FYaL9UJ6Sqdez/7wLGZGvLOYNrbco
         pH6LOVzdjDIgeP3uFEEpQBO328T4OJwHqu7/yq80nzt21aavPWOyAQdbnID/CECJ81Xt
         XVpUQ/g4FvK/9irpTCxyUmgIXQM82PsTnNVo7tmTbLiFYuo0SbBI4jiULC/JYdzWZUIP
         1TOxH+zVVDIxhK96EvmFLdwYsPK8Oa5KZTKYAdoWjG7E3LE/iAuwrvQ2wCthD8PhrYoc
         8OMmg/5O1KFe/SWLfDhtPlpVtmhICVfJTWCQMioqXCxJqKitSFttwsKr8URF46oNwduz
         lNTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: AHQUAuaeHysY+uuItfUtX4S//+pNm5mgAB4ErW6PaUhC6sWlEXv5OcON
	k95zCElOs+t3UyBClCDT+U6f2O6MVDcdbivZ2rX2p5QWlvHuhltqBdxmJN3OGahoJCnZ6INS1Cm
	Ys4togTe78KWH6WqOFzSBqfv/+nAQxfsPkfk35BmGfBux0t2EdZmM7RcQkafJ/NcjAg==
X-Received: by 2002:a17:906:3e54:: with SMTP id t20mr17893543eji.82.1551202264283;
        Tue, 26 Feb 2019 09:31:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0aPB5G8364pJGeK1R99iLJBfzv8DTKT6QpRIS4YWrO04jM7usSuOgBhJ6rvQpPb2SDYQT
X-Received: by 2002:a17:906:3e54:: with SMTP id t20mr17893469eji.82.1551202262995;
        Tue, 26 Feb 2019 09:31:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551202262; cv=none;
        d=google.com; s=arc-20160816;
        b=LcYH3ST7pW7wOsQLBUSnnkuGDfOUPoRvbf3vmtkOd6eo+mwRpjVAJ5FuyV4D8DoiZn
         PIJ4rWBws3okBa4peJ8BpbtqOS28VlhINYLfAktqe9l/rTxvYpJsw5WmdO9/exv0tbIZ
         w3cA2O1BkrPREoB9AnGObPULYMFjOtWImlUlIYd5+3wczn8xEVE3H0Yj/jznrUhW5ZGl
         v495pgp/UhS/2nuBZT4zwJvVnqyfL/xy10iVK07DNeCa5SIYbLRfQvJAU+6e7z7hWGzL
         wQx/LwQECWcKMp1xbKpdGQFLjl9iybsLX6UF/Vx94c9vNYjdvG4oH+msxqaxHysXEaI4
         +IFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5NZHHJIShEBKX3j9ds5OZtMVqmHwvxVjDwhh6434jpM=;
        b=HyIUOkIpeXy6Vxt+zGG2D/4KG78X7mSH0oHTX7vQZnm4occbIy/Falvy8GHUwjD0mv
         Wfx0AEAwGyevugLkI59RntVWHebndzqQkDVaXdShlArDuZCrCIcEEO28l78gHLzSISpw
         7p4sNIl99H9YOIzpfa9criEbTk6LpGjmzm/czv1gPZe5bebCUJfBmy5mnWuuXeRM8CrD
         mpia7CEk/P74nvhQH9NSBGIBD3nBKzxgrRgk4cuvZ+iIsGHrNjYCiq6kiPCbWQm05AKO
         63jjj70o7cFTFDkStS25gM9lDK8nuiJhQO7M/W0Sq9nr1gRw2cutLKdqMxwhANbpTe4g
         4k5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i21si784256edg.95.2019.02.26.09.31.02
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 09:31:02 -0800 (PST)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8278B80D;
	Tue, 26 Feb 2019 09:31:01 -0800 (PST)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6D92C3F738;
	Tue, 26 Feb 2019 09:30:56 -0800 (PST)
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>
Cc: nd <nd@arm.com>, Evgenii Stepanov <eugenis@google.com>,
 Dave P Martin <Dave.Martin@arm.com>, Mark Rutland <Mark.Rutland@arm.com>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 Will Deacon <Will.Deacon@arm.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Vincenzo Frascino <Vincenzo.Frascino@arm.com>, Shuah Khan
 <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
 linux-arch <linux-arch@vger.kernel.org>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>,
 Kees Cook <keescook@chromium.org>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Kostya Serebryany <kcc@google.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Robin Murphy <Robin.Murphy@arm.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
References: <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
 <ac8f4e3b-84b8-6067-6a7a-fac7dc48daea@arm.com>
 <20190225165720.GA79300@arrakis.emea.arm.com>
 <7afa18b8-f135-036d-943c-b6216e7da481@arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <4a301222-e6bd-dda8-ebef-da724bb15028@arm.com>
Date: Tue, 26 Feb 2019 17:30:54 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <7afa18b8-f135-036d-943c-b6216e7da481@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25/02/2019 18:02, Szabolcs Nagy wrote:
> On 25/02/2019 16:57, Catalin Marinas wrote:
>> On Tue, Feb 19, 2019 at 06:38:31PM +0000, Szabolcs Nagy wrote:
>>> i think these rules work for the cases i care about, a more
>>> tricky question is when/how to check for the new syscall abi
>>> and when/how the TCR_EL1.TBI0 setting may be turned off.
>> I don't think turning TBI0 off is critical (it's handy for PAC with
>> 52-bit VA but then it's short-lived if you want more security features
>> like MTE).
> yes, i made a mistake assuming TBI0 off is
> required for (or at least compatible with) MTE.
>
> if TBI0 needs to be on for MTE then some of my
> analysis is wrong, and i expect TBI0 to be on
> in the foreseeable future.
>
>>> consider the following cases (tb == top byte):
>>>
>>> binary 1: user tb = any, syscall tb = 0
>>>    tbi is on, "legacy binary"
>>>
>>> binary 2: user tb = any, syscall tb = any
>>>    tbi is on, "new binary using tb"
>>>    for backward compat it needs to check for new syscall abi.
>>>
>>> binary 3: user tb = 0, syscall tb = 0
>>>    tbi can be off, "new binary",
>>>    binary is marked to indicate unused tb,
>>>    kernel may turn tbi off: additional pac bits.
>>>
>>> binary 4: user tb = mte, syscall tb = mte
>>>    like binary 3, but with mte, "new binary using mte"
> so this should be "like binary 2, but with mte".
>
>>>    does it have to check for new syscall abi?
>>>    or MTE HWCAP would imply it?
>>>    (is it possible to use mte without new syscall abi?)
>> I think MTE HWCAP should imply it.
>>
>>> in userspace we want most binaries to be like binary 3 and 4
>>> eventually, i.e. marked as not-relying-on-tbi, if a dso is
>>> loaded that is unmarked (legacy or new tb user), then either
>>> the load fails (e.g. if mte is already used? or can we turn
>>> mte off at runtime?) or tbi has to be enabled (prctl? does
>>> this work with pac? or multi-threads?).
>> We could enable it via prctl. That's the plan for MTE as well (in
>> addition maybe to some ELF flag).
>>
>>> as for checking the new syscall abi: i don't see much semantic
>>> difference between AT_HWCAP and AT_FLAGS (either way, the user
>>> has to check a feature flag before using the feature of the
>>> underlying system and it does not matter much if it's a syscall
>>> abi feature or cpu feature), but i don't see anything wrong
>>> with AT_FLAGS if the kernel prefers that.
>> The AT_FLAGS is aimed at capturing binary 2 case above, i.e. the
>> relaxation of the syscall ABI to accept tb = any. The MTE support will
>> have its own AT_HWCAP, likely in addition to AT_FLAGS. Arguably,
>> AT_FLAGS is either redundant here if MTE implies it (and no harm in
>> keeping it around) or the meaning is different: a tb != 0 may be checked
>> by the kernel against the allocation tag (i.e. get_user() could fail,
>> the tag is not entirely ignored).
>>
>>> the discussion here was mostly about binary 2,
>> That's because passing tb != 0 into the syscall ABI is the main blocker
>> here that needs clearing out before merging the MTE support. There is,
>> of course, a variation of binary 1 for MTE:
>>
>> binary 5: user tb = mte, syscall tb = 0
>>
>> but this requires a lot of C lib changes to support properly.
> yes, i don't think we want to do that.
>
> but it's ok to have both syscall tbi AT_FLAGS and MTE HWCAP.
>
>>> but for
>>> me the open question is if we can make binary 3/4 work.
>>> (which requires some elf binary marking, that is recognised
>>> by the kernel and dynamic loader, and efficient handling of
>>> the TBI0 bit, ..if it's not possible, then i don't see how
>>> mte will be deployed).
>> If we ignore binary 3, we can keep TBI0 = 1 permanently, whether we have
>> MTE or not.
>>
>>> and i guess on the kernel side the open question is if the
>>> rules 1/2/3/4 can be made to work in corner cases e.g. when
>>> pointers embedded into structs are passed down in ioctl.
>> We've been trying to track these down since last summer and we came to
>> the conclusion that it should be (mostly) fine for the non-weird memory
>> described above.
> i think an interesting case is when userspace passes
> a pointer to the kernel and later gets it back,
> which is why i proposed rule 4 (kernel has to keep
> the tag then).
>
> but i wonder what's the right thing to do for sp
> (user can malloc thread/sigalt/makecontext stack
> which will be mte tagged in practice with mte on)
> does tagged sp work? should userspace untag the
> stack memory before setting it up as a stack?
> (but then user pointers to that allocation may get
> broken..)

Tagged SP does work, and it is actually a good idea (it avoids using the default tag 
for the stack). It would be quite easy for the kernel to tag the initial SP and the 
stack on execve(). For other stacks, it is up to userspace, as you say, and would be 
made easier by making it possible to choose how a mapping should be tagged by the 
kernel via a new mmap() flag. Some software that makes too many assumptions on the 
address of stack variables will be disturbed by a tagged SP, but this should be 
fairly rare.

In any case, I don't think this impacts this ABI proposal (beyond the fact that 
passing tagged pointers to the stack needs to be allowed).

Kevin

