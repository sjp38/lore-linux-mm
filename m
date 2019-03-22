Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CD90C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:53:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BAD6218FE
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:53:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BAD6218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C55316B0006; Fri, 22 Mar 2019 11:53:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C10F76B0007; Fri, 22 Mar 2019 11:53:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACC736B0008; Fri, 22 Mar 2019 11:53:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA956B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:53:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so1145261edo.5
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:53:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=GPK/0v0MIq9yqjFwL9PSWpFI/tJqPVS2v3K0OUzV0Vc=;
        b=DcdvT9kjoJTRosgVV2KIiePQMSStsbdVSKI6siQK9hHaM0CtnQhagBpR23s0R69j+W
         m0i9YeJKoEJOc6PxrJ2wZC7MMvmeg2lLn/Fl1aR0VOjuheSbwGfypPbLmcUMEavhQ/qN
         V597L+zJqeX0GNTqUzGZJAxEaEt4E/zto/s6Ddwj01wawa2JjL4ZKKeJajoujxET4qqg
         5gIPphVo1G0nXiCQVoe8pjDRKdUwxxT+f6kGZbkLtj3TsTJoSb+8KSV8b8O1Hq9rleF2
         tvLu8+nOekjrLHOZxs1et8BKSu1IdrItOwL0Ef3qMR5xuRCWiolRfIfax2LwCtVZAh/g
         gl6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAUKfKCUoAeSZFfYxKFvV4Vsi+c5OXODIgoyPssdjX2HK3L3aRmA
	zYYYkBWvmqHALPPeLbv0fOoK21GH32hm6sU287sGjdj0O5iVO3aSgKgzQwyBYYAGbxcKJ8jta++
	YxXcn3cCExIV7Zs+VrofY5EYaK6Uq0JsMsL1CttsoTBgtZwlBHOtZyPOoIo9XxCeYfQ==
X-Received: by 2002:a17:906:1299:: with SMTP id k25mr5890963ejb.80.1553269980914;
        Fri, 22 Mar 2019 08:53:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2n1vjPdJDwee98B9aVcpw4sZgESLwWTZVosK9eQXaHYbh5oDQqp2qBqwT1KBIDIPU6xkH
X-Received: by 2002:a17:906:1299:: with SMTP id k25mr5890917ejb.80.1553269979760;
        Fri, 22 Mar 2019 08:52:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269979; cv=none;
        d=google.com; s=arc-20160816;
        b=uu166jN7XErtUAL5JKwI+nJ/uNHoOFYoezZsHKxd9fatJZJPSFn3/szqGPviiuXYYT
         zzcO0ILR0lDCELBDx472hOnTos6iyl7cM5zkH1HQ17+GiBiwr50otZcUhPmwolS57xzO
         IfTCnAnhArHX3pxuIXtCSXZDpS3z2mRAeInYt8vfHxh+lgQQB/2Ft1nX68Hn1ZMQUZCs
         JUfp9q2EtaaP/yaNQGQ/P3i+v8oB5xMI3bcOgWzx0i2suHRGETuBd/acvcp0pgOnGlcf
         hhNrNWdm1+AQBHIuESDFB3yZfcBePOQhWBQI33yrvaYLRnPYSOfxmjSQ/MfJ8SJ3aJpk
         tJ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GPK/0v0MIq9yqjFwL9PSWpFI/tJqPVS2v3K0OUzV0Vc=;
        b=dKTOVEjr/2M7WEqv7grcfV1NNsxP8YmFvXV8h09ki8nXyITLTAHlv0VwGH9uUnX4iL
         LdyrhMRwv9YI7ZfLcqKw06gTWTGloFpbzNsb/jDCICV6H/yEQfgMPsQoY/7tNPnejkuS
         mf/k2GecdAVvLNikxdgM4XbyC/A2VuJJm33WZpfYSdEs20KjyjdPd8p8KkXVqZpNcZmv
         DwnOCGBlpEpSdgQWj/EN7m4jSHufAbdGU/R9m/ELHEo6bsZdD4OLYXmoFhXTTc5uZnyG
         jZ8zyFTv+QsuNyeOC4r23j/mGE/JlWNbVMUC2Pw4zFkxySJr+LXeSSqpKoja2Zzk/dTK
         Bqtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w6si2793640edl.434.2019.03.22.08.52.59
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 08:52:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 97542A78;
	Fri, 22 Mar 2019 08:52:58 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 18A143F59C;
	Fri, 22 Mar 2019 08:52:50 -0700 (PDT)
Subject: Re: [PATCH v2 2/4] arm64: Define Documentation/arm64/elf_at_flags.txt
To: Vincenzo Frascino <vincenzo.frascino@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
 Alexei Starovoitov <ast@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Andrey Konovalov <andreyknvl@google.com>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Branislav Rankov <Branislav.Rankov@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Dave Martin <Dave.Martin@arm.com>,
 "David S. Miller" <davem@davemloft.net>, Dmitry Vyukov <dvyukov@google.com>,
 Eric Dumazet <edumazet@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Graeme Barnes <Graeme.Barnes@arm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Kees Cook <keescook@chromium.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Shuah Khan <shuah@kernel.org>,
 Steven Rostedt <rostedt@goodmis.org>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
 Will Deacon <will.deacon@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <20190318163533.26838-1-vincenzo.frascino@arm.com>
 <20190318163533.26838-3-vincenzo.frascino@arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <859341c2-b352-e914-312a-d3de652495b6@arm.com>
Date: Fri, 22 Mar 2019 15:52:49 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190318163533.26838-3-vincenzo.frascino@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/03/2019 16:35, Vincenzo Frascino wrote:
> On arm64 the TCR_EL1.TBI0 bit has been always enabled hence
> the userspace (EL0) is allowed to set a non-zero value in the
> top byte but the resulting pointers are not allowed at the
> user-kernel syscall ABI boundary.
>
> With the relaxed ABI proposed through this document, it is now possible
> to pass tagged pointers to the syscalls, when these pointers are in
> memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap() or brk().
>
> This change in the ABI requires a mechanism to inform the userspace
> that such an option is available.
>
> Specify and document the way in which AT_FLAGS can be used to advertise
> this feature to the userspace.
>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> CC: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
>
> Squash with "arm64: Define Documentation/arm64/elf_at_flags.txt"
> ---
>   Documentation/arm64/elf_at_flags.txt | 133 +++++++++++++++++++++++++++
>   1 file changed, 133 insertions(+)
>   create mode 100644 Documentation/arm64/elf_at_flags.txt
>
> diff --git a/Documentation/arm64/elf_at_flags.txt b/Documentation/arm64/elf_at_flags.txt
> new file mode 100644
> index 000000000000..9b3494207c14
> --- /dev/null
> +++ b/Documentation/arm64/elf_at_flags.txt
> @@ -0,0 +1,133 @@
> +ARM64 ELF AT_FLAGS
> +==================
> +
> +This document describes the usage and semantics of AT_FLAGS on arm64.
> +
> +1. Introduction
> +---------------
> +
> +AT_FLAGS is part of the Auxiliary Vector, contains the flags and it
> +is set to zero by the kernel on arm64 unless one or more of the
> +features detailed in paragraph 2 are present.
> +
> +The auxiliary vector can be accessed by the userspace using the
> +getauxval() API provided by the C library.
> +getauxval() returns an unsigned long and when a flag is present in
> +the AT_FLAGS, the corresponding bit in the returned value is set to 1.
> +
> +The AT_FLAGS with a "defined semantics" on arm64 are exposed to the
> +userspace via user API (uapi/asm/atflags.h).
> +The AT_FLAGS bits with "undefined semantics" are set to zero by default.
> +This means that the AT_FLAGS bits to which this document does not assign
> +an explicit meaning are to be intended reserved for future use.
> +The kernel will populate all such bits with zero until meanings are
> +assigned to them. If and when meanings are assigned, it is guaranteed
> +that they will not impact the functional operation of existing userspace
> +software. Userspace software should ignore any AT_FLAGS bit whose meaning
> +is not defined when the software is written.
> +
> +The userspace software can test for features by acquiring the AT_FLAGS
> +entry of the auxiliary vector, and testing whether a relevant flag
> +is set.
> +
> +Example of a userspace test function:
> +
> +bool feature_x_is_present(void)
> +{
> +	unsigned long at_flags = getauxval(AT_FLAGS);
> +	if (at_flags & FEATURE_X)
> +		return true;
> +
> +	return false;
> +}
> +
> +Where the software relies on a feature advertised by AT_FLAGS, it
> +must check that the feature is present before attempting to
> +use it.
> +
> +2. Features exposed via AT_FLAGS
> +--------------------------------
> +
> +bit[0]: ARM64_AT_FLAGS_SYSCALL_TBI
> +
> +    On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64
> +    kernel, hence the userspace (EL0) is allowed to set a non-zero value
> +    in the top byte but the resulting pointers are not allowed at the
> +    user-kernel syscall ABI boundary.
> +    When bit[0] is set to 1 the kernel is advertising to the userspace
> +    that a relaxed ABI is supported hence this type of pointers are now
> +    allowed to be passed to the syscalls, when these pointers are in
> +    memory ranges privately owned by a process and obtained by the
> +    process in accordance with the definition of "valid tagged pointer"
> +    in paragraph 3.
> +    In these cases the tag is preserved as the pointer goes through the
> +    kernel. Only when the kernel needs to check if a pointer is coming
> +    from userspace an untag operation is required.

I would leave this last sentence out, because:
1. It is an implementation detail that doesn't impact this user ABI.
2. It is not entirely accurate: untagging the pointer may be needed for various kinds 
of address lookup (like finding the corresponding VMA), at which point the kernel 
usually already knows it is a userspace pointer.

> +
> +3. ARM64_AT_FLAGS_SYSCALL_TBI
> +-----------------------------
> +
> +From the kernel syscall interface prospective, we define, for the purposes
> +of this document, a "valid tagged pointer" as a pointer that either it has
> +a zero value set in the top byte or it has a non-zero value, it is in memory
> +ranges privately owned by a userspace process and it is obtained in one of
> +the following ways:
> +  - mmap() done by the process itself, where either:
> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
> +      file or "/dev/zero"
> +  - a mapping below sbrk(0) done by the process itself

I don't think that's very clear, this doesn't say how the mapping is obtained. Maybe 
"a mapping obtained by the process using brk() or sbrk()"?

> +  - any memory mapped by the kernel in the process's address space during
> +    creation and following the restrictions presented above (i.e. data, bss,
> +    stack).

With the rules above, the code section is included as well. Replacing "i.e." with 
"e.g." would avoid having to list every single section (which is probably not a good 
idea anyway).

Kevin

> +
> +When the ARM64_AT_FLAGS_SYSCALL_TBI flag is set by the kernel, the following
> +behaviours are guaranteed by the ABI:
> +
> +  - Every current or newly introduced syscall can accept any valid tagged
> +    pointers.
> +
> +  - If a non valid tagged pointer is passed to a syscall then the behaviour
> +    is undefined.
> +
> +  - Every valid tagged pointer is expected to work as an untagged one.
> +
> +  - The kernel preserves any valid tagged pointers and returns them to the
> +    userspace unchanged in all the cases except the ones documented in the
> +    "Preserving tags" paragraph of tagged-pointers.txt.
> +
> +A definition of the meaning of tagged pointers on arm64 can be found in:
> +Documentation/arm64/tagged-pointers.txt.
> +
> +Example of correct usage (pseudo-code) for a userspace application:
> +
> +bool arm64_syscall_tbi_is_present(void)
> +{
> +	unsigned long at_flags = getauxval(AT_FLAGS);
> +	if (at_flags & ARM64_AT_FLAGS_SYSCALL_TBI)
> +			return true;
> +
> +	return false;
> +}
> +
> +void main(void)
> +{
> +	char *addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
> +			  MAP_ANONYMOUS, -1, 0);
> +
> +	int fd = open("test.txt", O_WRONLY);
> +
> +	/* Check if the relaxed ABI is supported */
> +	if (arm64_syscall_tbi_is_present()) {
> +		/* Add a tag to the pointer */
> +		addr = tag_pointer(addr);
> +	}
> +
> +	strcpy("Hello World\n", addr);
> +
> +	/* Write to a file */
> +	write(fd, addr, sizeof(addr));
> +
> +	close(fd);
> +}
> +

