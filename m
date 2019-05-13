Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45FB6C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:00:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 042C1208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:00:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AD3U09r7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 042C1208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6526B0280; Mon, 13 May 2019 12:00:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 797496B0282; Mon, 13 May 2019 12:00:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ADD26B0284; Mon, 13 May 2019 12:00:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 329206B0280
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:00:28 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b8so8623624pls.22
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:00:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9cwGdwpNsId3jbcdh2kF6oX2uSsyHzellJ1hwDZnCY8=;
        b=dKHOaezpcSOqp9NhpOrQO/w3OhthAJbJTJVjCZ0T3fUBAxWiu6eFYYfh5PjFaStkod
         RbpcZINqGojG1J/xROGDvrSlT2rfWlOELgSq6yIilpnj3H62xJkTdhzzdh2L63659aHz
         1GV8aq+7AN6WJRj1bCvCui9FkzSvlrrlFRLwUkkJLTZyT4F+HnVuW8mfDfRslH45lvv4
         ksc5EVeXlCD4NtfDEeYadmKEweBM7wBh60bcLvAwB06elP0N/5sEuQAE2N2qzm210nkW
         ETU4lKgzI/6ev8dxn3ts18RjedmkyWxFmL/BXCMulx6bxUVTwa0x7Q1H6PxQKBk9IAUw
         K0VA==
X-Gm-Message-State: APjAAAULQN8Q12bjxBbzFab8KL/KIR++fYP5kNU5wnr+eFSaw8TkTbpa
	vKKsFcT+loRjXdvYH7fAowz/OVX2Ar5OVA2NxHJo4kbHxUFCPwhF6GK0nS3p7qmNqIofGRMoSXy
	OW7Rn9iqfdToFbSstym6yHQz9LOKUJCs8YloyNWHB5CoJb9UghNyh8QNskEiGBLf4NQ==
X-Received: by 2002:a62:414a:: with SMTP id o71mr34958654pfa.240.1557763227814;
        Mon, 13 May 2019 09:00:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHpBSAYlHELxhexi0gUTgeoF/aDjod5rcIGlVCPghiqe74R8GDSbhS/FqJeeMD1DZLm2rZ
X-Received: by 2002:a62:414a:: with SMTP id o71mr34958497pfa.240.1557763226822;
        Mon, 13 May 2019 09:00:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557763226; cv=none;
        d=google.com; s=arc-20160816;
        b=bODDqBsfVjjFvMr5Duq2Eg6JAE3Oh5X3YBg3XOJHCXEyh4XRcdKI48zyo7VVu79GV+
         N2uzWx8eOJ9UiLzGuGElVisOltfhoqY0ciqTiLRELg1Tbdudq1t9eTGWbV3kynAdtdcq
         Y79mb9gkpXdb3p6zSeHx2wQU6QZ767636BDTPhtiW+8KtrlTglK5lcOGvg+H7nirguKF
         GR6ajnxpqGBEjBbdKUrDcCM+1qon3+kWKR1FxGrAV3JzTatskgjd0vH79izvfrtrmptB
         vjzfACS4uASOgQ/37b+mxAoj7cW0Hnfzm8ZWmAnvBmy9FhH1eT3u/6Mp/vXZ7uKvTbjO
         9T4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9cwGdwpNsId3jbcdh2kF6oX2uSsyHzellJ1hwDZnCY8=;
        b=gCjUCH9B1UiGmXnCBaM0ExBPAmF2K23996w5oJ2D1TMnP8/kSC0nCfyM2B3JOgBWWX
         9g5Hq4py0deF906KkM7L7fMIbd0as0c+9vZVoi9JqfKnPYxol6RFDCEH2l0vbp5POy0V
         ojfcKOUez+CUjyWaZUaHJQDUE3zRpRruzl9KP2Z2WFxRYfxrFdqKjqAnIwtx/RhdgkkY
         ZdG0/itAWXIGw5MBTSJawUMUzA+UzVMhcjAB+EeB5GuFIAz7HT0mKr2s2R8wNWqtz9u3
         ttMI6kKTMpgG2XVdv+5oouQL36fWVFCr6B+eREydtD9p+2dYTizeZMMs71vUejmOREyV
         76iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AD3U09r7;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j12si16785749pgp.118.2019.05.13.09.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:00:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AD3U09r7;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3A494214C6
	for <linux-mm@kvack.org>; Mon, 13 May 2019 16:00:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557763226;
	bh=4bcLIFwRGdrxUSdLyYcDKBhiisD8Iba6LGdB6inApCI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=AD3U09r7iadGQx9xKbeGtVco8OzKuPg56V0gCnVoJ/QhP1NKeI/l6NioJQod0RAw5
	 efv1W0cVsndHHYOXwwIWp0FMOC+k8HgKKyi06hYNpjbnnmrFVtYZKLTdjORICG+SZu
	 mNQUApnmoJ+bqhQLGnlM/Z/jq/ZnhSyCSOdz5iAQ=
Received: by mail-wm1-f48.google.com with SMTP id 198so14404043wme.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:00:26 -0700 (PDT)
X-Received: by 2002:a1c:eb18:: with SMTP id j24mr17012407wmh.32.1557763224812;
 Mon, 13 May 2019 09:00:24 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com> <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
In-Reply-To: <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 09:00:13 -0700
X-Gmail-Original-Message-ID: <CALCETrXYW-CfixanL3Wk5v_5Ex7WMe+7POV0VfBVHujfb6cvtQ@mail.gmail.com>
Message-ID: <CALCETrXYW-CfixanL3Wk5v_5Ex7WMe+7POV0VfBVHujfb6cvtQ@mail.gmail.com>
Subject: Re: [RFC KVM 19/27] kvm/isolation: initialize the KVM page table with
 core mappings
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, 
	Radim Krcmar <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
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

On Mon, May 13, 2019 at 8:50 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> > +     /*
> > +      * Copy the mapping for all the kernel text. We copy at the PMD
> > +      * level since the PUD is shared with the module mapping space.
> > +      */
> > +     rv = kvm_copy_mapping((void *)__START_KERNEL_map, KERNEL_IMAGE_SIZE,
> > +          PGT_LEVEL_PMD);
> > +     if (rv)
> > +             goto out_uninit_page_table;
>
> Could you double-check this?  We (I) have had some repeated confusion
> with the PTI code and kernel text vs. kernel data vs. __init.
> KERNEL_IMAGE_SIZE looks to be 512MB which is quite a bit bigger than
> kernel text.
>
> > +     /*
> > +      * Copy the mapping for cpu_entry_area and %esp fixup stacks
> > +      * (this is based on the PTI userland address space, but probably
> > +      * not needed because the KVM address space is not directly
> > +      * enterered from userspace). They can both be copied at the P4D
> > +      * level since they each have a dedicated P4D entry.
> > +      */
> > +     rv = kvm_copy_mapping((void *)CPU_ENTRY_AREA_PER_CPU, P4D_SIZE,
> > +          PGT_LEVEL_P4D);
> > +     if (rv)
> > +             goto out_uninit_page_table;
>
> cpu_entry_area is used for more than just entry from userspace.  The gdt
> mapping, for instance, is needed everywhere.  You might want to go look
> at 'struct cpu_entry_area' in some more detail.
>
> > +#ifdef CONFIG_X86_ESPFIX64
> > +     rv = kvm_copy_mapping((void *)ESPFIX_BASE_ADDR, P4D_SIZE,
> > +          PGT_LEVEL_P4D);
> > +     if (rv)
> > +             goto out_uninit_page_table;
> > +#endif
>
> Why are these mappings *needed*?  I thought we only actually used these
> fixup stacks for some crazy iret-to-userspace handling.  We're certainly
> not doing that from KVM context.
>
> Am I forgetting something?
>
> > +#ifdef CONFIG_VMAP_STACK
> > +     /*
> > +      * Interrupt stacks are vmap'ed with guard pages, so we need to
> > +      * copy mappings.
> > +      */
> > +     for_each_possible_cpu(cpu) {
> > +             stack = per_cpu(hardirq_stack_ptr, cpu);
> > +             pr_debug("IRQ Stack %px\n", stack);
> > +             if (!stack)
> > +                     continue;
> > +             rv = kvm_copy_ptes(stack - IRQ_STACK_SIZE, IRQ_STACK_SIZE);
> > +             if (rv)
> > +                     goto out_uninit_page_table;
> > +     }
> > +
> > +#endif
>
> I seem to remember that the KVM VMENTRY/VMEXIT context is very special.
>  Interrupts (and even NMIs?) are disabled.  Would it be feasible to do
> the switching in there so that we never even *get* interrupts in the KVM
> context?

That would be nicer.

Looking at this code, it occurs to me that mapping the IRQ stacks
seems questionable.  As it stands, this series switches to a normal
CR3 in some C code somewhere moderately deep in the APIC IRQ code.  By
that time, I think you may have executed traceable code, and, if that
happens, you lose.  i hate to say this, but any shenanigans like this
patch does might need to happen in the entry code *before* even
switching to the IRQ stack.  Or perhaps shortly thereafter.

We've talked about moving context tracking to C.  If we go that route,
then this KVM context mess could go there, too -- we'd have a
low-level C wrapper for each entry that would deal with getting us
ready to run normal C code.

(We need to do something about terminology.  This kvm_mm thing isn't
an mm in the normal sense.  An mm has normal kernel mappings and
varying user mappings.  For example, the PTI "userspace" page tables
aren't an mm.  And we really don't want a situation where the vmalloc
fault code runs with the "kvm_mm" mm active -- it will totally
malfunction.)

