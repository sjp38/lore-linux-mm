Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E317AC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:06:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFB752083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFB752083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46BCF6B0007; Wed, 14 Aug 2019 08:06:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41C196B0008; Wed, 14 Aug 2019 08:06:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 332BD6B000A; Wed, 14 Aug 2019 08:06:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id 12CFF6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:06:57 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AA3C1180AD805
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:06:56 +0000 (UTC)
X-FDA: 75820907232.09.day37_3c901d642c530
X-HE-Tag: day37_3c901d642c530
X-Filterd-Recvd-Size: 4745
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:06:55 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 5685F3016E65;
	Wed, 14 Aug 2019 15:06:54 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 43A20305B7A0;
	Wed, 14 Aug 2019 15:06:54 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 74/92] kvm: x86: do not unconditionally patch the
 hypercall instruction during emulation
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>, Joerg Roedel
	<joro@8bytes.org>
In-Reply-To: <1362cc5c-d0cd-6b7c-1151-9df3996fefa9@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-75-alazar@bitdefender.com>
	<1362cc5c-d0cd-6b7c-1151-9df3996fefa9@redhat.com>
Date: Wed, 14 Aug 2019 15:07:21 +0300
Message-ID: <1565784441.a239ff581.26157.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Mailer: void
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 11:20:45 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> > From: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> >=20
> > It can happened for us to end up emulating the VMCALL instruction as =
a
> > result of the handling of an EPT write fault. In this situation, the
> > emulator will try to unconditionally patch the correct hypercall opco=
de
> > bytes using emulator_write_emulated(). However, this last call uses t=
he
> > fault GPA (if available) or walks the guest page tables at RIP,
> > otherwise. The trouble begins when using KVMI, when we forbid the use=
 of
> > the fault GPA and fallback to the guest pt walk: in Windows (8.1 and
> > newer) the page that we try to write into is marked read-execute and =
as
> > such emulator_write_emulated() fails and we inject a write #PF, leadi=
ng
> > to a guest crash.
> >=20
> > The fix is rather simple: check the existing instruction bytes before
> > doing the patching. This does not change the normal KVM behaviour, bu=
t
> > does help when using KVMI as we no longer inject a write #PF.
>=20
> Fixing the hypercall is just an optimization.  Can we just hush and
> return to the guest if emulator_write_emulated returns
> X86EMUL_PROPAGATE_FAULT?
>=20
> Paolo

Something like this?

	err =3D emulator_write_emulated(...);
	if (err =3D=3D X86EMUL_PROPAGATE_FAULT)
		err =3D X86EMUL_CONTINUE;
	return err;

> > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > index 04b1d2916a0a..965c4f0108eb 100644
> > --- a/arch/x86/kvm/x86.c
> > +++ b/arch/x86/kvm/x86.c
> > @@ -7363,16 +7363,33 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vc=
pu)
> >  }
> >  EXPORT_SYMBOL_GPL(kvm_emulate_hypercall);
> > =20
> > +#define KVM_HYPERCALL_INSN_LEN 3
> > +
> >  static int emulator_fix_hypercall(struct x86_emulate_ctxt *ctxt)
> >  {
> > +	int err;
> >  	struct kvm_vcpu *vcpu =3D emul_to_vcpu(ctxt);
> > -	char instruction[3];
> > +	char buf[KVM_HYPERCALL_INSN_LEN];
> > +	char instruction[KVM_HYPERCALL_INSN_LEN];
> >  	unsigned long rip =3D kvm_rip_read(vcpu);
> > =20
> > +	err =3D emulator_read_emulated(ctxt, rip, buf, sizeof(buf),
> > +				     &ctxt->exception);
> > +	if (err !=3D X86EMUL_CONTINUE)
> > +		return err;
> > +
> >  	kvm_x86_ops->patch_hypercall(vcpu, instruction);
> > +	if (!memcmp(instruction, buf, sizeof(instruction)))
> > +		/*
> > +		 * The hypercall instruction is the correct one. Retry
> > +		 * its execution maybe we got here as a result of an
> > +		 * event other than #UD which has been resolved in the
> > +		 * mean time.
> > +		 */
> > +		return X86EMUL_CONTINUE;
> > =20
> > -	return emulator_write_emulated(ctxt, rip, instruction, 3,
> > -		&ctxt->exception);
> > +	return emulator_write_emulated(ctxt, rip, instruction,
> > +				       sizeof(instruction), &ctxt->exception);
> >  }

