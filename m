Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60D6BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:27:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FEC20811
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:27:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FEC20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAD2C6B0005; Mon, 18 Mar 2019 09:27:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5CBE6B0006; Mon, 18 Mar 2019 09:27:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D27166B0007; Mon, 18 Mar 2019 09:27:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77F586B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:27:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x21so6567171edr.17
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:27:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=k8V6NxAlu75osrnEr3PKsMahY8inQJRflwo5EogmLqo=;
        b=VHVzFzFWemOX8kIX/tXOuI71WIen+i2eCJ1C5T5aXUVKekkRO5nrASc8mXj+jRMR8Z
         UJ1AKeOiNEjM5cWJJ9oB9J5nn3nr3BSqsCITWXTvPZ4gXBmbvJFBn09zX+xMh3TKwfUs
         a0ei2MxKj4ih87wn91npxpyaW5iUlVtd68IqRk2vWLf4Rpn58cvru4b5bt6Ei2qlv59a
         UVqi4i34CdYSWiFoYUgQ+kL66mfTCGvwzdLB2VCFBP1AEIik7PSvI0YtvrnZ+Kiv4Kzc
         CFunXCWGjtgICPpU70fOpC0RjsgMAGQtlIQ/jd0RF9tnL+qa3pYaQJzaAfaOkY0LYwwS
         39AQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAXsE4leSV5OngZIX1XIIeDHPMYWYEYxWSDdM/vT8In0P5NvoNJV
	krfdWnSs+IkWgJeAGnGN3DaohIJVb34C3Uxk5zB3EZ7NDLPCjMqf890YIyUvJTlKf0Sc/HV9nSt
	gb2fEo5W3T+mR442MXhwh3c5yF8Tv5VKJ4Jqi7/DGvUcf2tu9KmzCxHzZmqlzIQOIIw==
X-Received: by 2002:a50:eac4:: with SMTP id u4mr13302484edp.238.1552915620057;
        Mon, 18 Mar 2019 06:27:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4Gp6PkLPKYV0kkceks4Axa/JC4otsW9QBSVHz+FJtsejQaJzY5rm8HBlkALgGLDRI05lv
X-Received: by 2002:a50:eac4:: with SMTP id u4mr13302427edp.238.1552915618962;
        Mon, 18 Mar 2019 06:26:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552915618; cv=none;
        d=google.com; s=arc-20160816;
        b=Abq3cpF/lXnoFdTneyvm+JtRCHsGnltqdek9KHL/sHAbx3RaBfjZEOP79ktLZBjnwX
         +WpafXs/geeSsjMl2DGhOVv+uE0/mJrOlbTHScgRZpkGb7do+1GPVSB3Ce+/I6fQCENn
         ZTjKAEqrvelWCMSc8r4sFPEeqpZaFGMoBDMZuFtNFJXhutjGe7aLvNeNyU11QRcTX1qp
         kiRz5IUAnA0BcHdGG31smtXo8R3wUWsOgr0iRupUHfeV5HYZ46uQj/Zy/o25Z6OqFJqq
         crQyRQkTPlTwMmptyo7CWRFkyaePLtDzHY3p8lVK+UdpTIBXAp5EpeNWNg+S/D5wxjmo
         Zlvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=k8V6NxAlu75osrnEr3PKsMahY8inQJRflwo5EogmLqo=;
        b=c7EXF1hmyo6G3NsJxMLCVZWZ5bnNL4yI8MYqTyBFKleEs4APXPA6Q6s+951F3CGc/c
         U2wS/J5x7WRYOBtGK2NtfALq0z8V8jrWsP221xfXwhot0D64lo1thSCBCZzb7bqEMyvj
         geDi13sdfeaUQYekSkhbPYlz460RIYI8OwrH/MYf3iKAGfe27IWWGkvHSY4TspDbodHi
         emLhl0MZ4wkQU5A/ZXuPrVo8I5T8HT061viGRpJ674pnAmIgcsc976iPAhKKUmLCYYMf
         KycK19nndkgHtaI5qEjJmBL0rjpOOsSqgGWeTPov2Kygamr65UwWAxrZaudbPT0CBSoh
         mBPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m5si299273ejk.213.2019.03.18.06.26.58
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 06:26:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A984FEBD;
	Mon, 18 Mar 2019 06:26:57 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4DF053F71A;
	Mon, 18 Mar 2019 06:26:51 -0700 (PDT)
Subject: Re: [PATCH v11 13/14] arm64: update
 Documentation/arm64/tagged-pointers.txt
To: Andrey Konovalov <andreyknvl@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org,
 bpf@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <bf0abceeaf32e6b9cdbc9dde45cc5966b5747ec4.1552679409.git.andreyknvl@google.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <81bc3110-b638-4545-1270-26baec3d59e7@arm.com>
Date: Mon, 18 Mar 2019 13:26:48 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <bf0abceeaf32e6b9cdbc9dde45cc5966b5747ec4.1552679409.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15/03/2019 19:51, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> Document the ABI changes in Documentation/arm64/tagged-pointers.txt.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>   Documentation/arm64/tagged-pointers.txt | 18 ++++++++----------
>   1 file changed, 8 insertions(+), 10 deletions(-)
>
> diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
> index a25a99e82bb1..07fdddeacad0 100644
> --- a/Documentation/arm64/tagged-pointers.txt
> +++ b/Documentation/arm64/tagged-pointers.txt
> @@ -17,13 +17,15 @@ this byte for application use.
>   Passing tagged addresses to the kernel
>   --------------------------------------
>   
> -All interpretation of userspace memory addresses by the kernel assumes
> -an address tag of 0x00.
> +The kernel supports tags in pointer arguments (including pointers in
> +structures) of syscalls, however such pointers must point to memory ranges
> +obtained by anonymous mmap() or brk().
>   
> -This includes, but is not limited to, addresses found in:
> +The kernel supports tags in user fault addresses. However the fault_address
> +field in the sigcontext struct will contain an untagged address.
>   
> - - pointer arguments to system calls, including pointers in structures
> -   passed to system calls,
> +All other interpretations of userspace memory addresses by the kernel
> +assume an address tag of 0x00, in particular:
>   
>    - the stack pointer (sp), e.g. when interpreting it to deliver a
>      signal,
> @@ -33,11 +35,7 @@ This includes, but is not limited to, addresses found in:
>   
>   Using non-zero address tags in any of these locations may result in an
>   error code being returned, a (fatal) signal being raised, or other modes
> -of failure.
> -
> -For these reasons, passing non-zero address tags to the kernel via
> -system calls is forbidden, and using a non-zero address tag for sp is
> -strongly discouraged.
> +of failure. Using a non-zero address tag for sp is strongly discouraged.

I don't understand why we should keep such a limitation. For MTE, tagging SP is 
something we are definitely considering. This does bother userspace software in some 
rare cases, but I'm not sure in what way it bothers the kernel.

Kevin

>   
>   Programs maintaining a frame pointer and frame records that use non-zero
>   address tags may suffer impaired or inaccurate debug and profiling

