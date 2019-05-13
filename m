Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5000C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF3F72085A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:17:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="M73groKW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF3F72085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C1BA6B0008; Mon, 13 May 2019 14:17:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44BC16B000A; Mon, 13 May 2019 14:17:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ECBA6B000C; Mon, 13 May 2019 14:17:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA68A6B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:17:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o1so9683619pgv.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RXmaEukWCV36ZGd13nL2HHyXvZXbzVLzc6CzdUvQtq0=;
        b=grAy0KNe91GT5N1DlzzH6e2qaUdU5jzXcKU3uisSIUmHgS9A0ppwAiqQ7K5hklrkWx
         3OtjtiCwZWkXiOoxk0JKZxOje2nvsNUvus7PsHFZrWT+NJ/exlpd3zVRF0vyPd5qVQLn
         z8dmbJwTAPQPSQZ/brG2miZtOTt9Il7Z9uZxeL3Y4HH9JAmqY9KzbvlOHfuukD1Xan3I
         gMeb0BR4cgr71vh3dTLV0I+8OtdT9ydclUq+8CuJZ+Y33cKFPFjL1TmyC3tp+JYlfgnC
         wll3x0H9P2sgBl8JCgB4Ax5fFDI9hp/KjUm2v1eoWenEIfiMQE/7RH90RPKAKV9MlKSA
         kSPw==
X-Gm-Message-State: APjAAAXTUlnFjdzDPscmcuIluNMaYX/ekMWwFnIxNL+el2pg2Cr2NZaH
	YGtilQoE4D4/xcyOEvtewF/PFOSitYF47XuwD5VjIbJRj8QsKSk6+3ikG2wfsEqktHeudsngLel
	2VEzY73+pfsuwdFagDvViHmiiu2PmayJeBPeoUa9vpR4oUkXMf81aGrMz2K8I0X1mfA==
X-Received: by 2002:aa7:928b:: with SMTP id j11mr35551712pfa.200.1557771449396;
        Mon, 13 May 2019 11:17:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJiOuaDiJwQ5tIqUPF3MQB61zJyiUaVhgf+gG45WzzDZ9Xmnpo3TFvkpa3HW7XyWo5/4MK
X-Received: by 2002:aa7:928b:: with SMTP id j11mr35551469pfa.200.1557771447402;
        Mon, 13 May 2019 11:17:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557771447; cv=none;
        d=google.com; s=arc-20160816;
        b=uIuyvARcr58esCw9Ai8hAyr0rpombPRSeGJWAud0l2BwiKRFCKhJvgbWEa57c88KcK
         oW1tLMddAG3+6ROqLJZU1yexehMNyjfRUMlgdq6MIfT3rNoFV0qBbeD3cjGcBEHrGekF
         5J4+p41pd1OEfOHJlajyluDsesYb21ofd+MFoYzQqrkj0/crxS9GYU1FzU9noZnlWWA3
         FOwhvJ0S39rQ6itCKhCTsCzeJYm56azf+3L+f9oTsaiq4TfhR9OuurO+My4iaWgnQYR+
         XVg/VzNn4G4WOGKJCVWbn9fL3Tc3sKrgiKQfy0UMR0kLx18URRei1bwef+ZzbQtSXk4M
         +08A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RXmaEukWCV36ZGd13nL2HHyXvZXbzVLzc6CzdUvQtq0=;
        b=VCW/nd35UHNO7vZAlqh3elV2vRMI4+ea3pYxOzjoktpgI45+ml5yEuU3YB2SpThrlR
         aPSVx6ifFpsdk3WwRi79P8JRcoc66aDkJA4TpswU7SlnviR0dd1x9+0VHv3zU8Qtg7rq
         rs4V0ueYOWVFhRTOGebCe1UKrV1qYf8y0QTIwoK11pSCg8GMWWXXiqeIknhzEpZ1RbfB
         kFzRgkfqId9T6qeNuQshiQk18rfuPsFvFNM0KzQEXKU7lC9EaxT5rCER0MaSiFGW9ZVL
         PFnfFww3aX9wtYoaFNwsi1MfK9UpS8jPGuGvCIe90jPNXNMqy8yyfDyTVY8Grm4w2MyD
         /Slg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=M73groKW;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f12si17368950pgo.388.2019.05.13.11.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 11:17:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=M73groKW;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C7C2A21019
	for <linux-mm@kvack.org>; Mon, 13 May 2019 18:17:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557771447;
	bh=lPPXPrlCXnec9ArL5Smn4WZ7XgjTRPHq0b2cg72c7do=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=M73groKWN7tiM88HUylA0BevMADMrkXxMAX5GrLV+GI8cDdt8upEqFbWjtmTbBtWf
	 B1fbMLLC4Ig6Ha6q/7u8EsjeSgkgTLTRZg/th8dDdkCQSgF5F8U6hLZj14iprJmgc3
	 c3GN5DwMXPdaJcryEnpckEV58wfnaOyIRu/KMP3g=
Received: by mail-wm1-f52.google.com with SMTP id i3so303360wml.4
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:17:26 -0700 (PDT)
X-Received: by 2002:a1c:eb18:: with SMTP id j24mr17403247wmh.32.1557771445393;
 Mon, 13 May 2019 11:17:25 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 11:17:14 -0700
X-Gmail-Original-Message-ID: <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
Message-ID: <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
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

> I expect that the KVM address space can eventually be expanded to include
> the ioctl syscall entries. By doing so, and also adding the KVM page table
> to the process userland page table (which should be safe to do because the
> KVM address space doesn't have any secret), we could potentially handle the
> KVM ioctl without having to switch to the kernel pagetable (thus effectively
> eliminating KPTI for KVM). Then the only overhead would be if a VM-Exit has
> to be handled using the full kernel address space.
>

In the hopefully common case where a VM exits and then gets re-entered
without needing to load full page tables, what code actually runs?
I'm trying to understand when the optimization of not switching is
actually useful.

Allowing ioctl() without switching to kernel tables sounds...
extremely complicated.  It also makes the dubious assumption that user
memory contains no secrets.

