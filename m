Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC3AEC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:35:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 729EE215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:35:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 729EE215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BFBF6B0008; Wed, 12 Jun 2019 11:35:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 771666B000A; Wed, 12 Jun 2019 11:35:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 661026B000D; Wed, 12 Jun 2019 11:35:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 15B606B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:35:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c27so11211972edn.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:35:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UNc9sSdaRfqiwYc3yxNfJgP71w2aJkw8TZvMeTBkLH4=;
        b=dWhzfeGE4kVdTr1KUtU+Dn/ou7z4PfnxnFKxb91RG/bg4LKFbmRcm+u7TXx9uFbBVQ
         Q9yPqJMmYwYB5STPSDiU4L0lLaoyZb6d5puTlotG4JohoMrSxV7eZlcHCd5Wg8HDGXxD
         O4DsByCozenVCvlfim9s+Emqz8QIHUEI+PErqfb+iFuxmpybF0vOEabUIqQ0lkh/PpXK
         ca5qDdkCc5JfvGT1fWf/lOb7n0FdIlR2fU3Uv+4ZdZsfG7zuAXXUoP+lsNh0SRqUPmOt
         Yp9mR/CGMfnF11YzHohN3LdrAvA6y/p2JE0igQ6HMEWyVA6qWAMme7lzA6RWIc+akdKP
         fDow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXtFzJ4ZDZOR8/zs5JvGxnWyPaSGJ0z+1HXaoi28ZHXhWFl7+Td
	YYFPF0fwhQ5RytR0BCgqsnF2rK/1Rcttw5FzX2s080rd4H43eXfWG09Hp4KmyrcE6/Yqf5bhUEY
	JC5eF2Cih1XAMPTYIjRwhbxWLqD2JlxCQL/giWd4jtH6txBOInrY0FsYKRxnwPlBr8w==
X-Received: by 2002:a50:90e7:: with SMTP id d36mr88350816eda.202.1560353754623;
        Wed, 12 Jun 2019 08:35:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziNpMuJGgBntF33hnjRn7nxgUH0zByI0D7ZfLtqfM1TitKOgY5GNaW+jAK9gYpCF0FxlIE
X-Received: by 2002:a50:90e7:: with SMTP id d36mr88350424eda.202.1560353751104;
        Wed, 12 Jun 2019 08:35:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560353751; cv=none;
        d=google.com; s=arc-20160816;
        b=l1CzoQOmnhEyHZzEiYUhWaunEpYHuXulXWFErCRwHK7moPJ2T85RjVsIlieWYERd+6
         R70uq494qk+xK67eflEeYeo6WxCquEvie3zFjydPFJNnQ8WamZqlj20QsF2g0R4urWjO
         wL4tB5SjPD0b5f7jamwvz8FtxZ+kpt9y5TnuBQ8JUm6FTRZFK+3dtyIUYzyq6xqcTl8C
         A5+QYIbg/GH0LQG1fxPQqaTXMTvG0+6DwI9zwTYbcYE+UUBjb3+NqPTWOnoBc7pvxvAu
         7sYCjCB8hfu+xOHcW8NyFcE21SKwTfKa+Alxrz/62Ft2i4o0r+Uyt1szw5Wcg1iU8Lyt
         BQDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UNc9sSdaRfqiwYc3yxNfJgP71w2aJkw8TZvMeTBkLH4=;
        b=JCH+opFi+am22imnj5U/EX1Q3kktwy0Z2qWowMSI8/0g+6Ow9CprIHbL87dbNQ++s1
         Hbia6xMEqj6YgsGvdRb7mgxq9mLyNB3emgMxzwcDgTPidjm2NI3q2tO27t3lpufzSZb2
         t7vV13cZpGA4TXeAkwhlb5jgnR5lgQQuY9w0CvACFKk7maeFj6pSDETxEnLsXmLOdsbC
         oPXggb0Z206w6tkSXDm/u4VhIFX1LsoYOILkobTl+MmSJzvfi6uOMPi+HFIuVTukKhdi
         Vd++hTvdv+3xIBIwTMZuRXpmWsv36pm+bqGUgyRk8Oe/8xrnDBXPbJieaOjTXOaPhiKQ
         wtGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w20si184585ejj.239.2019.06.12.08.35.50
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 08:35:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DFFE7337;
	Wed, 12 Jun 2019 08:35:49 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C44B63F73C;
	Wed, 12 Jun 2019 08:35:46 -0700 (PDT)
Date: Wed, 12 Jun 2019 16:35:39 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190612153538.GL28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612142111.28161-2-vincenzo.frascino@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Vincenzo,

Some minor comments below but it looks fine to me overall. Cc'ing
Szabolcs as well since I'd like a view from the libc people.

On Wed, Jun 12, 2019 at 03:21:10PM +0100, Vincenzo Frascino wrote:
> diff --git a/Documentation/arm64/tagged-address-abi.txt b/Documentation/arm64/tagged-address-abi.txt
> new file mode 100644
> index 000000000000..96e149e2c55c
> --- /dev/null
> +++ b/Documentation/arm64/tagged-address-abi.txt
> @@ -0,0 +1,111 @@
> +ARM64 TAGGED ADDRESS ABI
> +========================
> +
> +This document describes the usage and semantics of the Tagged Address
> +ABI on arm64.
> +
> +1. Introduction
> +---------------
> +
> +On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64 kernel,
> +hence the userspace (EL0) is allowed to set a non-zero value in the top

I'd be clearer here: "userspace (EL0) is allowed to perform a user
memory access through a 64-bit pointer with a non-zero top byte" (or
something along the lines). Otherwise setting a non-zero top byte is
allowed on any architecture, dereferencing it is a problem.

> +byte but the resulting pointers are not allowed at the user-kernel syscall
> +ABI boundary.
> +
> +This document describes a relaxation of the ABI with which it is possible

"relaxation of the ABI that makes it possible to..."

> +to pass tagged tagged pointers to the syscalls, when these pointers are in
> +memory ranges obtained as described in paragraph 2.

"section 2" is better. There are a lot more paragraphs.

> +
> +Since it is not desirable to relax the ABI to allow tagged user addresses
> +into the kernel indiscriminately, arm64 provides a new sysctl interface
> +(/proc/sys/abi/tagged_addr) that is used to prevent the applications from
> +enabling the relaxed ABI and a new prctl() interface that can be used to
> +enable or disable the relaxed ABI.
> +
> +The sysctl is meant also for testing purposes in order to provide a simple
> +way for the userspace to verify the return error checking of the prctl()
> +command without having to reconfigure the kernel.
> +
> +The ABI properties are inherited by threads of the same application and
> +fork()'ed children but cleared when a new process is spawn (execve()).

"spawned".

I guess you could drop these three paragraphs here and mention the
inheritance properties when introducing the prctl() below. You can also
mention the global sysctl switch after the prctl() was introduced.

> +
> +2. ARM64 Tagged Address ABI
> +---------------------------
> +
> +From the kernel syscall interface prospective, we define, for the purposes
> +of this document, a "valid tagged pointer" as a pointer that either it has

"either has" (no 'it') sounds slightly better but I'm not a native
English speaker either.

> +a zero value set in the top byte or it has a non-zero value, it is in memory
> +ranges privately owned by a userspace process and it is obtained in one of
> +the following ways:
> +  - mmap() done by the process itself, where either:
> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
> +      file or "/dev/zero"
> +  - a mapping below sbrk(0) done by the process itself
> +  - any memory mapped by the kernel in the process's address space during
> +    creation and following the restrictions presented above (i.e. data, bss,
> +    stack).
> +
> +The ARM64 Tagged Address ABI is an opt-in feature, and an application can
> +control it using the following prctl()s:
> +  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable the Tagged Address ABI.

enable or disable (not sure we need the latter but it doesn't heart).

I'd add the arg2 description here as well.

> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
> +                             Address ABI.
> +
> +As a consequence of invoking PR_SET_TAGGED_ADDR_CTRL prctl() by an applications,
> +the ABI guarantees the following behaviours:
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

I'd think we need to qualify the context here in which the kernel
preserves the tagged pointers. Did you mean on the syscall return?

> +
> +A definition of the meaning of tagged pointers on arm64 can be found in:
> +Documentation/arm64/tagged-pointers.txt.
> +
> +3. ARM64 Tagged Address ABI Exceptions
> +--------------------------------------
> +
> +The behaviours described in paragraph 2, with particular reference to the

"section 2"

> +acceptance by the syscalls of any valid tagged pointer are not applicable
> +to the following cases:
> +  - mmap() addr parameter.
> +  - mremap() new_address parameter.
> +  - prctl_set_mm() struct prctl_map fields.
> +  - prctl_set_mm_map() struct prctl_map fields.
> +
> +4. Example of correct usage
> +---------------------------
> +
> +void main(void)
> +{
> +	static int tbi_enabled = 0;
> +	unsigned long tag = 0;
> +
> +	char *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
> +			 MAP_ANONYMOUS, -1, 0);
> +
> +	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE,
> +		  0, 0, 0) == 0)
> +		tbi_enabled = 1;
> +
> +	if (!ptr)
> +		return -1;
> +
> +	if (tbi_enabled)
> +		tag = rand() & 0xff;
> +
> +	ptr = (char *)((unsigned long)ptr | (tag << TAG_SHIFT));
> +
> +	*ptr = 'a';
> +
> +	...
> +}
> +
> -- 
> 2.21.0

-- 
Catalin

