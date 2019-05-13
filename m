Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9794DC04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:01:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46E892147A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:01:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YBdQmFv+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46E892147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 093406B0280; Mon, 13 May 2019 12:01:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 043F46B0282; Mon, 13 May 2019 12:01:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E755E6B0284; Mon, 13 May 2019 12:01:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B19036B0280
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:01:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 63so9415792pga.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:01:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ljy/U+bZu7KOD/jm5h/Nov5oW0yZ5jBLjvuaOwjQBsk=;
        b=hFHzPOwgCupdldAR7+X1mmEkPMB/EzxDTRHscri++qZb91RbVSqR1hU4bY3KiU/33X
         EAn2wMpBpI5k6VwShhEw+bQijFbiyqN3ONIZ1hqb1+SaoN+/p3EwEtODWe/nTZktH0xa
         +H6xnWKoZzxJpaP+0eb2j31gBZJRBVm1Q6iiWMtydfE+z4FqrurGwa8PLkuGqxPPSl+2
         U1+JGIItmPCjHKKCbyg8/v1xvMAbyeSBh74OaIOS24b+3p9mshjbafdwbZL5L6aa98N/
         NnM+MvXlQWzjW2ng0ed3/C0vzqXxDknpODl10ptn0HDFR+SCeryIRA1j2eRqqq7f4V1p
         nOkw==
X-Gm-Message-State: APjAAAUizvdddw5slXIO9AhIvs1wMBlBPJfAZ/sj3O+4C+H6kx4lhxSM
	SfMgqEnT5S3EPPWwGMKba+9PXP5rAa/D1D71WJ8Gep5UxDHM3kb37SBwlkjywkjXqgYdUVgEAOu
	w3S2pPNjp9dTDK50uYhGHreBj4LIfX5YOz41opliIkGm1YQ0xjYXkbljmyFr5CO1+hw==
X-Received: by 2002:a17:902:b614:: with SMTP id b20mr30369905pls.200.1557763291392;
        Mon, 13 May 2019 09:01:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQYp7hA4AI5l+PAXXs/Fjyk6t6XI96LdGfy/zTJtOMLYzXlWOUIgBb6xnVh/d6aF1G8R1q
X-Received: by 2002:a17:902:b614:: with SMTP id b20mr30369820pls.200.1557763290718;
        Mon, 13 May 2019 09:01:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557763290; cv=none;
        d=google.com; s=arc-20160816;
        b=ctUOJUjGXnh8VnsGmxST5rVzA5mkbYjzpb63VWfd8myvmouwFAVOrDZXSgfyOVgtk4
         yaof4qw90ah9N48cMTd7XaUkBB/Iry5ytnv+eUMTSR/udedWm3At9w4dNnQxVfa0jhr2
         n90U+VwL/6pFniCBurEnzU9LFMbdiTXjsJYJttH+XWZvET8WvOXitKGwpu5HrO/HFKmA
         GpAsNdi5uEEGZEJ3ljTaX+ryByHnOgS36hmSE2t6rxkH1FbdBUUM5dbp7l8M/1nJ49mW
         bv0nZo7P62HLHH6y9cFrpvyHUX3i3GG8EDj0CK20oD7iVwQVo2/YMSTkqLpIhYDdLeKJ
         XqZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ljy/U+bZu7KOD/jm5h/Nov5oW0yZ5jBLjvuaOwjQBsk=;
        b=KTNicf/GeZL5VBBJ9eYHt34Qgq0hK4dT+iIXSZDup4FXuebwwdQSccy+fnL+ZvS3z6
         +kVTtM9WkvJ80y5MPpdKKDD9zn3ZXvhcADgfOEzYBTLuRBkRAfI/hM/GVdUNL7/Fpgp6
         rbM8UauKUjIR7mTGCLvDpOdeyoc29Oqd0ZPbisBnhQbUj6v674LBC7pGmOWvbZSmJHwZ
         cnvKfVC8JM7GLllp+jnB6k2TZ4OOkYklSNeJMtmBgMV2OeNlUh3XvePUHAXTWvQP5b2U
         tV6PkzDaLkoHs6v6OUe1G5YQoSUanxS0e8gsb5IiGi0OGEqwn8M1Nwr4XGhrfXZDFgMh
         GBwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YBdQmFv+;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v40si16502367plg.409.2019.05.13.09.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:01:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YBdQmFv+;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2370E21655
	for <linux-mm@kvack.org>; Mon, 13 May 2019 16:01:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557763290;
	bh=lEibKcwC5gVE6uqe1w9PcI6jNFCNtyn0TO/fffg8YH8=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=YBdQmFv+6f0ehcqPTdycmmzLGxIGw7o9OdfJad+Pew98TJbknjnEOFU5Ia677bZeP
	 7yQRnNXKQ7beIL8WyMqISTgRWj+CyN9f5Tkextzwte6J/imWrq8bxznyj77y8IXwbR
	 0OGW+acgJQTjsK+TkAhuAsfAx54+ZMBW+kf/71MQ=
Received: by mail-wm1-f50.google.com with SMTP id f2so14279677wmj.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:01:30 -0700 (PDT)
X-Received: by 2002:a7b:c844:: with SMTP id c4mr5457540wml.108.1557763286508;
 Mon, 13 May 2019 09:01:26 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-26-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-26-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 09:01:14 -0700
X-Gmail-Original-Message-ID: <CALCETrWmvcrO0bBEw7iL-GnCED6hTz=FD+nANZkdQRo2R-w_3Q@mail.gmail.com>
Message-ID: <CALCETrWmvcrO0bBEw7iL-GnCED6hTz=FD+nANZkdQRo2R-w_3Q@mail.gmail.com>
Subject: Re: [RFC KVM 25/27] kvm/isolation: implement actual KVM isolation enter/exit
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, 
	X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:40 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
> From: Liran Alon <liran.alon@oracle.com>
>
> KVM isolation enter/exit is done by switching between the KVM address
> space and the kernel address space.
>
> Signed-off-by: Liran Alon <liran.alon@oracle.com>
> Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
> ---
>  arch/x86/kvm/isolation.c |   30 ++++++++++++++++++++++++------
>  arch/x86/mm/tlb.c        |    1 +
>  include/linux/sched.h    |    1 +
>  3 files changed, 26 insertions(+), 6 deletions(-)
>
> diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
> index db0a7ce..b0c789f 100644
> --- a/arch/x86/kvm/isolation.c
> +++ b/arch/x86/kvm/isolation.c
> @@ -1383,11 +1383,13 @@ static bool kvm_page_fault(struct pt_regs *regs, unsigned long error_code,
>         printk(KERN_DEFAULT "KVM isolation: page fault %ld at %pS on %lx (%pS) while switching mm\n"
>                "  cr3=%lx\n"
>                "  kvm_mm=%px pgd=%px\n"
> -              "  active_mm=%px pgd=%px\n",
> +              "  active_mm=%px pgd=%px\n"
> +              "  kvm_prev_mm=%px pgd=%px\n",
>                error_code, (void *)regs->ip, address, (void *)address,
>                cr3,
>                &kvm_mm, kvm_mm.pgd,
> -              active_mm, active_mm->pgd);
> +              active_mm, active_mm->pgd,
> +              current->kvm_prev_mm, current->kvm_prev_mm->pgd);
>         dump_stack();
>
>         return false;
> @@ -1649,11 +1651,27 @@ void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu)
>         kvm_isolation_exit();
>  }
>
> +static void kvm_switch_mm(struct mm_struct *mm)
> +{
> +       unsigned long flags;
> +
> +       /*
> +        * Disable interrupt before updating active_mm, otherwise if an
> +        * interrupt occurs during the switch then the interrupt handler
> +        * can be mislead about the mm effectively in use.
> +        */
> +       local_irq_save(flags);
> +       current->kvm_prev_mm = current->active_mm;

Peter's NAK aside, why on Earth is this in task_struct?  You cannot
possibly context switch while in isolation mode.

--Andy

