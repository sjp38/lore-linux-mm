Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AADC0C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 11:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EDC1214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 11:02:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EDC1214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADC956B0283; Thu, 25 Apr 2019 07:02:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8D096B0284; Thu, 25 Apr 2019 07:02:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A4466B0285; Thu, 25 Apr 2019 07:02:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 494026B0283
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 07:02:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r48so412368eda.11
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:02:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=s+/xu7rM7PB5Rw7qpOJ0WgwMmcHZPCqMnHcMntrHvLU=;
        b=uBWzXUNFKvhgOJ/iZtF47tJ/2jNTok2LQDTmIjcjZ2QSy0C69rYfd3ZrDpS7tuSWTR
         naU3T3uXF+r9dINteJ/mPvuPbURBqqZpS63OMHbs18TnO8EJE6bK/7RpGRBu3bjFnY0j
         vsl+huRlVj/lXDgHZUld0Dm+VPF+pLMQpVOndARHCfz4spZks9NZJX48aPeqR0H9+Rht
         3E+yK0NGkKm75Mq196zm3Xq2P5kbmUzxoQH9sEpoJ4KTbH1jzEewaean9js4CSYejyDn
         3UCIMRN1YXLGg3H5c4b80HNGbsfdqNo5tHqYJ0cLbbDV0eCwAzyzu+ceUi37RIaeyjF0
         ns6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAUTipRGmgl/xoeRWcwei1ZWxq4rJ7OAZ8nux2xfjiexSIezM8rb
	90nmy4uJzvcntcsReFPzEsrwSAhkolhcZBkUkMp50R+X0wcLU9TmZ5FvcYGNJZQHQ2DCJAhBaWF
	3v7xUuJ4Vcz2GD6N7tWh5HmZj7ImcpvpEU/OlYvwzK7DIiVD1f6m/t1aBRcAM0KXvBg==
X-Received: by 2002:a17:906:25d1:: with SMTP id n17mr18490846ejb.257.1556190141551;
        Thu, 25 Apr 2019 04:02:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKdj3XoD2WVF+SU22QEHreMxEnsJLxWQOL/XF/xYDHiRrXlAsqVNiGPi8ikj7wucOY4M2E
X-Received: by 2002:a17:906:25d1:: with SMTP id n17mr18490775ejb.257.1556190140178;
        Thu, 25 Apr 2019 04:02:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556190140; cv=none;
        d=google.com; s=arc-20160816;
        b=qy0dRuyuXyP4gM0xMWbfe1EvgG1RdrzDV2jaDfrszVerRaZPqVSBuwq4MpjN4gMG3N
         SAMe6+Ipc2f6EIaQ28bRx3t9KlM4lxNfIWrEsmPdrj86TPJjOW1Uw54Bu6yFU+wTxm8y
         Rbjb/BROMr+/QUoBP441mIR2tLSDgpO3+fpKElSkZw5e3WT8A2w11WyZiu7yOrWvy2U2
         W4XefflTSU0LlRpd8P2FyYwB3zeW9WWbuJoFZ3zOdXYxhnsic5cdhyyA/RXnpJNapWOp
         eUEQuyhMN/9up2KbIEhn64hjE6eTaXslZ0WMu7cnhYPSiigq5a5ALiq+V0vnZpHmVDlE
         kNYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=s+/xu7rM7PB5Rw7qpOJ0WgwMmcHZPCqMnHcMntrHvLU=;
        b=RByh/DIkGkg5tqKj2QRbEIFNxHTs1cyctFxdztu13pvvPjUv8PN1qX13w0yG9EoFMg
         tUV41HpHtRZs8RoC5NbNp0uKZqQHVnRyLX/c6XKtV86kmFkrDxNq4lB0jjLPCl/1rCW7
         yZb2GYlZu5cfD2qAHdzphDafLULK49VKYwwBHmVK467soVeqaOa5jts8rB1sTOjch51x
         zZCKN3rvf8RqyIy/ZFigf+TK9By8aLMAygAQapgoCKRicOvb7bxWfc04qIPOQg/3VmqD
         ylnDl57D+DvY7vRx1ixYGA7pFWdyxveB5EWwf3RnQ2iLaZSQGyOB8aRozzMjTjZvogn7
         qB0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 65si442877edm.158.2019.04.25.04.02.19
        for <linux-mm@kvack.org>;
        Thu, 25 Apr 2019 04:02:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CA3E8374;
	Thu, 25 Apr 2019 04:02:18 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 11F493F5C1;
	Thu, 25 Apr 2019 04:02:13 -0700 (PDT)
Date: Thu, 25 Apr 2019 12:02:11 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [RFC PATCH v6 22/26] x86/cet/shstk: ELF header parsing of Shadow
 Stack
Message-ID: <20190425110211.GZ3567@e103592.cambridge.arm.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-23-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119214809.6086-23-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 19, 2018 at 01:48:05PM -0800, Yu-cheng Yu wrote:
> Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
> to be enabled for the task.

What's the status of this series?  I don't see anything in linux-next
yet.

For describing ELF features, Arm has recently adopted
NT_GNU_PROPERTY_TYPE_0, with properties closely modelled on
GNU_PROPERTY_X86_FEATURE_1_AND etc. [1]

So, arm64 will be need something like this patch for supporting new
features (such as the Branch Target Identification feature of ARMv8.5-A
[2]).

If this series isn't likely to merge soon, can we split this patch into
generic and x86-specific parts and handle them separately?

It would be good to see the generic ELF note parsing move to common
code -- I'll take a look and comment in more detail.

[...]

> diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> index 69c0f892e310..557ed0ba71c7 100644
> --- a/arch/x86/include/asm/elf.h
> +++ b/arch/x86/include/asm/elf.h
> @@ -381,4 +381,9 @@ struct va_alignment {
>  
>  extern struct va_alignment va_align;
>  extern unsigned long align_vdso_addr(unsigned long);
> +
> +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> +extern int arch_setup_features(void *ehdr, void *phdr, struct file *file,
> +			       bool interp);
> +#endif
>  #endif /* _ASM_X86_ELF_H */
> diff --git a/arch/x86/include/uapi/asm/elf_property.h b/arch/x86/include/uapi/asm/elf_property.h
> new file mode 100644
> index 000000000000..af361207718c
> --- /dev/null
> +++ b/arch/x86/include/uapi/asm/elf_property.h
> @@ -0,0 +1,15 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _UAPI_ASM_X86_ELF_PROPERTY_H
> +#define _UAPI_ASM_X86_ELF_PROPERTY_H
> +
> +/*
> + * pr_type
> + */
> +#define GNU_PROPERTY_X86_FEATURE_1_AND (0xc0000002)
> +
> +/*
> + * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
> + */
> +#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
> +

Generally we seem to collect all ELF definitions in <linux/uapi/elf.h>,
including arch-specific ones.

Is a new header really needed here?

[...]

> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 54207327f98f..007ff0fbae84 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -1081,6 +1081,21 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  		goto out_free_dentry;
>  	}
>  
> +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> +	if (interpreter) {
> +		retval = arch_setup_features(&loc->interp_elf_ex,
> +					     interp_elf_phdata,
> +					     interpreter, true);

Can we dummy no-op functions in the common headers to avoid this
ifdeffery?  Logically all arches will always do this step, even if it's
a no-op today.

> +	} else {
> +		retval = arch_setup_features(&loc->elf_ex,
> +					     elf_phdata,
> +					     bprm->file, false);
> +	}
> +
> +	if (retval < 0)
> +		goto out_free_dentry;
> +#endif
> +
>  	if (elf_interpreter) {
>  		unsigned long interp_map_addr = 0;
>  
> diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
> index c5358e0ae7c5..5ef25a565e88 100644
> --- a/include/uapi/linux/elf.h
> +++ b/include/uapi/linux/elf.h
> @@ -372,6 +372,7 @@ typedef struct elf64_shdr {
>  #define NT_PRFPREG	2
>  #define NT_PRPSINFO	3
>  #define NT_TASKSTRUCT	4
> +#define NT_GNU_PROPERTY_TYPE_0 5

IIUC, note type codes are namespaced by the note name.  This section
currently only seems to have codes for name == "LINUX".

There are conflicts: for example NT_GNU_ABI_TAG == NT_PRSTATUS.

We should probably split out the codes for name == "GNU" into a separate
list, otherwise people are likely to get confused.

As noted above, can the GNU_PRPOERTY_<arch>_* definitions just go in
here instead of a separate header?

[...]

Cheers
---Dave

[1] https://developer.arm.com/docs/ihi0056/latest/elf-for-the-arm-64-bit-architecture-aarch64-abi-2019q1-documentation

[2] https://community.arm.com/developer/ip-products/processors/b/processors-ip-blog/posts/arm-a-profile-architecture-2018-developments-armv85a

