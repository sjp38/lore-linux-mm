Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB3FCC4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 10:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74B4521850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 10:30:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kq4ViJhU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74B4521850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFFFF6B0003; Fri,  5 Jul 2019 06:30:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB0E98E0003; Fri,  5 Jul 2019 06:30:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C79468E0001; Fri,  5 Jul 2019 06:30:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9576B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 06:30:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h27so5355760pfq.17
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 03:30:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kmyuJLU/dXW7+nImn7rvRrGCgJTcvaxcN4OBseykhCk=;
        b=ERDbK2zg3TFLKpF1mWtrlN+yAm6gYsBp8L2TitZ7XE7YNkJMtNrgefhqiCVvVtnj4p
         lIqVJQu9Imko5F1iVB45GIFI12KJFjPB/XNJuYFhONBejK8MNDDBKSrvzzcD0yK/GHrX
         rMvA5N1EIrOZrK2gnp1sfhdZtlFQ138ZFQ6XQ34xWtpHaobHrPZqHJhaM7CXgRyDVa0p
         wVqGBoxN0fnmgM+Y63JkVGPg6Z/yiFrB89v7OBVev4Ss7j70S8el5EEerW9vfISqTvy/
         +jO1BPEk8EeP0az13JXGnTgQ3hEriZP171eSpz6S7NkCR2NJccT6UP/zwHQPVu71QZR8
         X3ag==
X-Gm-Message-State: APjAAAXwzkIayzTfg/EfXqg60dA+LchWL50+bOgUhnVzu1NEmsrQi9/H
	uZrK6dZUePKwxmr29IQK7Xw+ANeM8IFMi92VLNLUe92UklaDXIkCucgz7EVCAkMI/u2glYFCN21
	DF8pqbik0vsrqOnJFg07yqbH1UYZTfrLgMYjiFk28Ked/qs8p3DwVzAtbmZgCBa8StQ==
X-Received: by 2002:a17:902:d891:: with SMTP id b17mr4580859plz.48.1562322642996;
        Fri, 05 Jul 2019 03:30:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNvXADVYu4IAGv6Tt8hydsuE6+Hwpz/LUqlx1J/4+AA++46Hf3QSEgHjMnaAbJcejFu2hj
X-Received: by 2002:a17:902:d891:: with SMTP id b17mr4580722plz.48.1562322641922;
        Fri, 05 Jul 2019 03:30:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562322641; cv=none;
        d=google.com; s=arc-20160816;
        b=uTqW1HMYdcLl8ZI5BNeTNsO/JEeSuuf4wRGIpvsgesQC4O3FGHddxyCFKcaNZG6Z+1
         Q8Y8mfwb4Kgvkzm03UK4D/oNkrC+xSakCWgpomS7HOFa/F6oEK7p4r0rzJ7ajH7Wles1
         MPvgBn2e6FFclFMlMcIf/Ht6UdDJp9YzTaW5gUWmp7fnwknep5b3rRtk5kt1CarMfWeO
         GtXyi3LuNi7/XOCEoW+BTJeHUp9rB5lgZGLbaj7n4cFoKS4CKQn60i0TSX/nOzmj91xx
         DKhuDPrnsLDwx//MMLDsIYPXudx5Iyp+Chsv8l0n7nVEO1xT+DahZ6zz9Mv0R/cqxmhv
         hwbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kmyuJLU/dXW7+nImn7rvRrGCgJTcvaxcN4OBseykhCk=;
        b=twAtEJ4FNs9bG6qyj7pQlTyxcIxjCfmiUTivtqbnW0xWvYO43B4rDOKcxso+eMTO31
         m9sVUgBZ6qYjMMjCzQ4MoL50Z4wPiICJkX7v/j0rrQOFoglviIhwXlf4vwwQUTi7UPqh
         rbb2uSlPuScGTydOs6ZceCm1zrrUBy2W/v41Wcpq8oqqwW6+dCO60gvQnUExaC7yeF2Y
         huKWWaLgNO/9sj2C54+7MmLILErYmY9pxnu6RONjYpWYi+7vo3nPAZYzUHYRNagAXfi2
         KdisjXQzbMbS5awqtd6qIJyPAL1CDJ5M0sH72xfnutPzIBLTBEfReYcemrAxk9KFfDVG
         AmmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Kq4ViJhU;
       spf=pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=mhiramat@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b20si9185379pfo.108.2019.07.05.03.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 03:30:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Kq4ViJhU;
       spf=pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=mhiramat@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from devnote2 (NE2965lan1.rev.em-net.ne.jp [210.141.244.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A56D620989;
	Fri,  5 Jul 2019 10:30:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562322641;
	bh=vdie7+J+Qf4GNlmeSDn4F1crcE1sfbOq0CuCbskf0vU=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Kq4ViJhUXTwy17K6QtkI7Vgvv3oSdL+I0TLtGx+v8EUfeovLTzNfzVXLQgNLninxb
	 qLlMDKh4k7qQItlyyCTgMVv4xap+V6ywI1evbHEnkc1K9O5rl74j9XCgX8/BPQ/gN3
	 o754U8Rqt58OFPXq3KHQSJj8NWK6R4Yt4ZpRe8AE=
Date: Fri, 5 Jul 2019 19:30:28 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Vineet Gupta <vgupta@synopsys.com>, Russell King
 <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton
 <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
 <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov
 <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Naveen N. Rao"
 <naveen.n.rao@linux.ibm.com>, Anil S Keshavamurthy
 <anil.s.keshavamurthy@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>,
 Allison Randal <allison@lohutok.net>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Enrico Weigelt <info@metux.net>, Richard
 Fontana <rfontana@redhat.com>, Kate Stewart <kstewart@linuxfoundation.org>,
 Mark Rutland <mark.rutland@arm.com>, Andrew Morton
 <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>,
 x86@kernel.org, linux-snps-arc@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org
Subject: Re: [PATCH] mm/kprobes: Add generic kprobe_fault_handler() fallback
 definition
Message-Id: <20190705193028.f9e08fe9cf1ee86bc5c0bb82@kernel.org>
In-Reply-To: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
References: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Fri,  5 Jul 2019 11:00:29 +0530
Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> Architectures like parisc enable CONFIG_KROBES without having a definition
> for kprobe_fault_handler() which results in a build failure.

Hmm, as far as I can see, kprobe_fault_handler() is closed inside each arch
specific code. The reason why include/linux/kprobes.h defines
dummy inline function is only for !CONFIG_KPROBES case.

> Arch needs to
> provide kprobe_fault_handler() as it is platform specific and cannot have
> a generic working alternative. But in the event when platform lacks such a
> definition there needs to be a fallback.

Wait, indeed that each arch need to implement it, but that is for calling
kprobe->fault_handler() as user expected.
Hmm, why not fixing those architecture implementations?

> This adds a stub kprobe_fault_handler() definition which not only prevents
> a build failure but also makes sure that kprobe_page_fault() if called will
> always return negative in absence of a sane platform specific alternative.

I don't like introducing this complicated macro only for avoiding (not fixing)
build error. To fix that, kprobes on parisc should implement kprobe_fault_handler
correctly (and call kprobe->fault_handler).

BTW, even if you need such generic stub, please use a weak function instead
of macros for every arch headers.

> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
> just be dropped. Only on x86 it needs to be added back locally as it gets
> used in a !CONFIG_KPROBES function do_general_protection().

If you want to remove kprobes_built_in(), you should replace it with
IS_ENABLED(CONFIG_KPROBES), instead of this...

Thank you,

> 
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>
> Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Cc: Allison Randal <allison@lohutok.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Enrico Weigelt <info@metux.net>
> Cc: Richard Fontana <rfontana@redhat.com>
> Cc: Kate Stewart <kstewart@linuxfoundation.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: x86@kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arc/include/asm/kprobes.h     |  1 +
>  arch/arm/include/asm/kprobes.h     |  1 +
>  arch/arm64/include/asm/kprobes.h   |  1 +
>  arch/ia64/include/asm/kprobes.h    |  1 +
>  arch/mips/include/asm/kprobes.h    |  1 +
>  arch/powerpc/include/asm/kprobes.h |  1 +
>  arch/s390/include/asm/kprobes.h    |  1 +
>  arch/sh/include/asm/kprobes.h      |  1 +
>  arch/sparc/include/asm/kprobes.h   |  1 +
>  arch/x86/include/asm/kprobes.h     |  6 ++++++
>  include/linux/kprobes.h            | 32 ++++++++++++++++++------------
>  11 files changed, 34 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/arc/include/asm/kprobes.h b/arch/arc/include/asm/kprobes.h
> index 2134721dce44..ee8efe256675 100644
> --- a/arch/arc/include/asm/kprobes.h
> +++ b/arch/arc/include/asm/kprobes.h
> @@ -45,6 +45,7 @@ struct kprobe_ctlblk {
>  	struct prev_kprobe prev_kprobe;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  int kprobe_fault_handler(struct pt_regs *regs, unsigned long cause);
>  void kretprobe_trampoline(void);
>  void trap_is_kprobe(unsigned long address, struct pt_regs *regs);
> diff --git a/arch/arm/include/asm/kprobes.h b/arch/arm/include/asm/kprobes.h
> index 213607a1f45c..660f877b989f 100644
> --- a/arch/arm/include/asm/kprobes.h
> +++ b/arch/arm/include/asm/kprobes.h
> @@ -38,6 +38,7 @@ struct kprobe_ctlblk {
>  	struct prev_kprobe prev_kprobe;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  void arch_remove_kprobe(struct kprobe *);
>  int kprobe_fault_handler(struct pt_regs *regs, unsigned int fsr);
>  int kprobe_exceptions_notify(struct notifier_block *self,
> diff --git a/arch/arm64/include/asm/kprobes.h b/arch/arm64/include/asm/kprobes.h
> index 97e511d645a2..667773f75616 100644
> --- a/arch/arm64/include/asm/kprobes.h
> +++ b/arch/arm64/include/asm/kprobes.h
> @@ -42,6 +42,7 @@ struct kprobe_ctlblk {
>  	struct kprobe_step_ctx ss_ctx;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  void arch_remove_kprobe(struct kprobe *);
>  int kprobe_fault_handler(struct pt_regs *regs, unsigned int fsr);
>  int kprobe_exceptions_notify(struct notifier_block *self,
> diff --git a/arch/ia64/include/asm/kprobes.h b/arch/ia64/include/asm/kprobes.h
> index c5cf5e4fb338..c321e8585089 100644
> --- a/arch/ia64/include/asm/kprobes.h
> +++ b/arch/ia64/include/asm/kprobes.h
> @@ -106,6 +106,7 @@ struct arch_specific_insn {
>  	unsigned short slot;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
>  extern int kprobe_exceptions_notify(struct notifier_block *self,
>  				    unsigned long val, void *data);
> diff --git a/arch/mips/include/asm/kprobes.h b/arch/mips/include/asm/kprobes.h
> index 68b1e5d458cf..d1efe991ea22 100644
> --- a/arch/mips/include/asm/kprobes.h
> +++ b/arch/mips/include/asm/kprobes.h
> @@ -40,6 +40,7 @@ do {									\
>  
>  #define kretprobe_blacklist_size 0
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  void arch_remove_kprobe(struct kprobe *p);
>  int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
>  
> diff --git a/arch/powerpc/include/asm/kprobes.h b/arch/powerpc/include/asm/kprobes.h
> index 66b3f2983b22..c94f375ec957 100644
> --- a/arch/powerpc/include/asm/kprobes.h
> +++ b/arch/powerpc/include/asm/kprobes.h
> @@ -84,6 +84,7 @@ struct arch_optimized_insn {
>  	kprobe_opcode_t *insn;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  extern int kprobe_exceptions_notify(struct notifier_block *self,
>  					unsigned long val, void *data);
>  extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> diff --git a/arch/s390/include/asm/kprobes.h b/arch/s390/include/asm/kprobes.h
> index b106aa29bf55..0ecaebb78092 100644
> --- a/arch/s390/include/asm/kprobes.h
> +++ b/arch/s390/include/asm/kprobes.h
> @@ -73,6 +73,7 @@ struct kprobe_ctlblk {
>  void arch_remove_kprobe(struct kprobe *p);
>  void kretprobe_trampoline(void);
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
>  int kprobe_exceptions_notify(struct notifier_block *self,
>  	unsigned long val, void *data);
> diff --git a/arch/sh/include/asm/kprobes.h b/arch/sh/include/asm/kprobes.h
> index 6171682f7798..637a698393c0 100644
> --- a/arch/sh/include/asm/kprobes.h
> +++ b/arch/sh/include/asm/kprobes.h
> @@ -45,6 +45,7 @@ struct kprobe_ctlblk {
>  	struct prev_kprobe prev_kprobe;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
>  extern int kprobe_exceptions_notify(struct notifier_block *self,
>  				    unsigned long val, void *data);
> diff --git a/arch/sparc/include/asm/kprobes.h b/arch/sparc/include/asm/kprobes.h
> index bfcaa6326c20..9aa4d25a45a8 100644
> --- a/arch/sparc/include/asm/kprobes.h
> +++ b/arch/sparc/include/asm/kprobes.h
> @@ -47,6 +47,7 @@ struct kprobe_ctlblk {
>  	struct prev_kprobe prev_kprobe;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  int kprobe_exceptions_notify(struct notifier_block *self,
>  			     unsigned long val, void *data);
>  int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> diff --git a/arch/x86/include/asm/kprobes.h b/arch/x86/include/asm/kprobes.h
> index 5dc909d9ad81..1af2b6db13bd 100644
> --- a/arch/x86/include/asm/kprobes.h
> +++ b/arch/x86/include/asm/kprobes.h
> @@ -101,11 +101,17 @@ struct kprobe_ctlblk {
>  	struct prev_kprobe prev_kprobe;
>  };
>  
> +#define kprobe_fault_handler kprobe_fault_handler
>  extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
>  extern int kprobe_exceptions_notify(struct notifier_block *self,
>  				    unsigned long val, void *data);
>  extern int kprobe_int3_handler(struct pt_regs *regs);
>  extern int kprobe_debug_handler(struct pt_regs *regs);
> +#else
> +static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
> +{
> +	return 0;
> +}
>  
>  #endif /* CONFIG_KPROBES */
>  #endif /* _ASM_X86_KPROBES_H */
> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
> index 04bdaf01112c..e106f3018804 100644
> --- a/include/linux/kprobes.h
> +++ b/include/linux/kprobes.h
> @@ -182,11 +182,19 @@ DECLARE_PER_CPU(struct kprobe_ctlblk, kprobe_ctlblk);
>  /*
>   * For #ifdef avoidance:
>   */
> -static inline int kprobes_built_in(void)
> +
> +/*
> + * Architectures need to override this with their own implementation
> + * if they care to call kprobe_page_fault(). This will just ensure
> + * that kprobe_page_fault() returns false when called without having
> + * a proper platform specific definition for kprobe_fault_handler().
> + */
> +#ifndef kprobe_fault_handler
> +static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
>  {
> -	return 1;
> +	return 0;
>  }
> -
> +#endif
>  #ifdef CONFIG_KRETPROBES
>  extern void arch_prepare_kretprobe(struct kretprobe_instance *ri,
>  				   struct pt_regs *regs);
> @@ -375,14 +383,6 @@ void free_insn_page(void *page);
>  
>  #else /* !CONFIG_KPROBES: */
>  
> -static inline int kprobes_built_in(void)
> -{
> -	return 0;
> -}
> -static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
> -{
> -	return 0;
> -}
>  static inline struct kprobe *get_kprobe(void *addr)
>  {
>  	return NULL;
> @@ -458,12 +458,11 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>  }
>  #endif
>  
> +#ifdef CONFIG_KPROBES
>  /* Returns true if kprobes handled the fault */
>  static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>  					      unsigned int trap)
>  {
> -	if (!kprobes_built_in())
> -		return false;
>  	if (user_mode(regs))
>  		return false;
>  	/*
> @@ -476,5 +475,12 @@ static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>  		return false;
>  	return kprobe_fault_handler(regs, trap);
>  }
> +#else
> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
> +					      unsigned int trap)
> +{
> +	return false;
> +}
> +#endif
>  
>  #endif /* _LINUX_KPROBES_H */
> -- 
> 2.20.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>

