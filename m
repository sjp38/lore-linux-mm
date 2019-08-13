Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12129C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D083B20663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:20:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D083B20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 577D56B026B; Tue, 13 Aug 2019 05:20:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 528916B026C; Tue, 13 Aug 2019 05:20:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F12B6B026D; Tue, 13 Aug 2019 05:20:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDA06B026B
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:20:51 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id AA166181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:20:50 +0000 (UTC)
X-FDA: 75816859860.18.dolls71_74c365b5b714
X-HE-Tag: dolls71_74c365b5b714
X-Filterd-Recvd-Size: 6004
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:20:49 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id p74so809425wme.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:20:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=5WhOyVWdh6QSPNAVErcAEqsYGeEW+/y9GXLU12kMFrw=;
        b=gUDzFw76Dpvm9n4KMZKUtOj1F0ksxB9sDhp9unfukdGJn88tq4DtteEk6R2PqcRZil
         Y65oQZ2bKb1mOtEmO3XGtHzTXQ9e0jJlahPXkoeCj0ffkTEFPnSM0UngrYO9NMyZ+3nY
         OsFRJTgt7xx6MWI+e9wOA8G79RgYOXENeZ+Fy+SFYAhgzxmoVeWXLeznV40agJ+UPKYq
         8Kkc+L+tEwqn4haNwGecLBoPHdCmnAyYzsr8zypyJ2JEe9j1RLdJr1x3pIMN6XSFQajN
         b0V/Xmo2voHVAuUYcCFCwyAjbx5UzgUodhZ2/iCA/4CscEmIn4w6+JQlZdAEgy/X06dC
         8lGQ==
X-Gm-Message-State: APjAAAXbnhkyty2ejTdYKOlIiZpQUvs4dYk0B1KpX6HgIf8Y8RBU8sBY
	9hgdnAXPHR3+WY3Qq4L+IzR5Iw==
X-Google-Smtp-Source: APXvYqy7ZmTsVWHpsqOXwbw3dSaP1W5TTiLRwJljDd+oxKVerUOBaX1bmIlseQ1dv51/PnYJUN17Cw==
X-Received: by 2002:a7b:c7c4:: with SMTP id z4mr1999804wmk.13.1565688048937;
        Tue, 13 Aug 2019 02:20:48 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id z6sm18721496wre.76.2019.08.13.02.20.46
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:20:48 -0700 (PDT)
Subject: Re: [RFC PATCH v6 74/92] kvm: x86: do not unconditionally patch the
 hypercall instruction during emulation
To: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>,
 Joerg Roedel <joro@8bytes.org>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-75-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <1362cc5c-d0cd-6b7c-1151-9df3996fefa9@redhat.com>
Date: Tue, 13 Aug 2019 11:20:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-75-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> From: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
>=20
> It can happened for us to end up emulating the VMCALL instruction as a
> result of the handling of an EPT write fault. In this situation, the
> emulator will try to unconditionally patch the correct hypercall opcode
> bytes using emulator_write_emulated(). However, this last call uses the
> fault GPA (if available) or walks the guest page tables at RIP,
> otherwise. The trouble begins when using KVMI, when we forbid the use o=
f
> the fault GPA and fallback to the guest pt walk: in Windows (8.1 and
> newer) the page that we try to write into is marked read-execute and as
> such emulator_write_emulated() fails and we inject a write #PF, leading
> to a guest crash.
>=20
> The fix is rather simple: check the existing instruction bytes before
> doing the patching. This does not change the normal KVM behaviour, but
> does help when using KVMI as we no longer inject a write #PF.

Fixing the hypercall is just an optimization.  Can we just hush and
return to the guest if emulator_write_emulated returns
X86EMUL_PROPAGATE_FAULT?

Paolo

> CC: Joerg Roedel <joro@8bytes.org>
> Signed-off-by: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> ---
>  arch/x86/kvm/x86.c | 23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 04b1d2916a0a..965c4f0108eb 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -7363,16 +7363,33 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu=
)
>  }
>  EXPORT_SYMBOL_GPL(kvm_emulate_hypercall);
> =20
> +#define KVM_HYPERCALL_INSN_LEN 3
> +
>  static int emulator_fix_hypercall(struct x86_emulate_ctxt *ctxt)
>  {
> +	int err;
>  	struct kvm_vcpu *vcpu =3D emul_to_vcpu(ctxt);
> -	char instruction[3];
> +	char buf[KVM_HYPERCALL_INSN_LEN];
> +	char instruction[KVM_HYPERCALL_INSN_LEN];
>  	unsigned long rip =3D kvm_rip_read(vcpu);
> =20
> +	err =3D emulator_read_emulated(ctxt, rip, buf, sizeof(buf),
> +				     &ctxt->exception);
> +	if (err !=3D X86EMUL_CONTINUE)
> +		return err;
> +
>  	kvm_x86_ops->patch_hypercall(vcpu, instruction);
> +	if (!memcmp(instruction, buf, sizeof(instruction)))
> +		/*
> +		 * The hypercall instruction is the correct one. Retry
> +		 * its execution maybe we got here as a result of an
> +		 * event other than #UD which has been resolved in the
> +		 * mean time.
> +		 */
> +		return X86EMUL_CONTINUE;
> =20
> -	return emulator_write_emulated(ctxt, rip, instruction, 3,
> -		&ctxt->exception);
> +	return emulator_write_emulated(ctxt, rip, instruction,
> +				       sizeof(instruction), &ctxt->exception);
>  }
> =20
>  static int dm_request_for_irq_injection(struct kvm_vcpu *vcpu)
>=20


