Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29AC1C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:33:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E98932067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E98932067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 639DC6B0003; Tue, 13 Aug 2019 10:33:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 611F26B0006; Tue, 13 Aug 2019 10:33:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 526956B0007; Tue, 13 Aug 2019 10:33:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0001.hostedemail.com [216.40.44.1])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8736B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:33:03 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C37A6180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:33:02 +0000 (UTC)
X-FDA: 75817646604.03.skin77_71d75ddb3e149
X-HE-Tag: skin77_71d75ddb3e149
X-Filterd-Recvd-Size: 4757
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:33:02 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp01.buh.bitdefender.com [10.17.80.75])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E90CD30644BA;
	Tue, 13 Aug 2019 17:33:00 +0300 (EEST)
Received: from localhost (unknown [195.210.4.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id D233E304BD70;
	Tue, 13 Aug 2019 17:33:00 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 75/92] kvm: x86: disable gpa_available optimization
 in emulator_read_write_onepage()
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>
In-Reply-To: <eb748e05-8289-0c05-6907-b6c898f6080b@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-76-alazar@bitdefender.com>
	<eb748e05-8289-0c05-6907-b6c898f6080b@redhat.com>
Date: Tue, 13 Aug 2019 17:33:27 +0300
Message-ID: <1565706807.E3E4656eC.28420.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 10:47:34 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> > If the EPT violation was caused by an execute restriction imposed by =
the
> > introspection tool, gpa_available will point to the instruction point=
er,
> > not the to the read/write location that has to be used to emulate the
> > current instruction.
> >=20
> > This optimization should be disabled only when the VM is introspected=
,
> > not just because the introspection subsystem is present.
> >=20
> > Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
>=20
> The right thing to do is to not set gpa_available for fetch failures in=
=20
> kvm_mmu_page_fault instead:
>=20
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 24843cf49579..1bdca40fa831 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -5364,8 +5364,12 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gv=
a_t cr2, u64 error_code,
>  	enum emulation_result er;
>  	bool direct =3D vcpu->arch.mmu->direct_map;
> =20
> -	/* With shadow page tables, fault_address contains a GVA or nGPA.  */
> -	if (vcpu->arch.mmu->direct_map) {
> +	/*
> +	 * With shadow page tables, fault_address contains a GVA or nGPA.
> +	 * On a fetch fault, fault_address contains the instruction pointer.
> +	 */
> +	if (vcpu->arch.mmu->direct_map &&
> +	    likely(!(error_code & PFERR_FETCH_MASK)) {
>  		vcpu->arch.gpa_available =3D true;
>  		vcpu->arch.gpa_val =3D cr2;
>  	}
>=20
>=20
> Paolo
>=20
> > ---
> >  arch/x86/kvm/x86.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > index 965c4f0108eb..3975331230b9 100644
> > --- a/arch/x86/kvm/x86.c
> > +++ b/arch/x86/kvm/x86.c
> > @@ -5532,7 +5532,7 @@ static int emulator_read_write_onepage(unsigned=
 long addr, void *val,
> >  	 * operation using rep will only have the initial GPA from the NPF
> >  	 * occurred.
> >  	 */
> > -	if (vcpu->arch.gpa_available &&
> > +	if (vcpu->arch.gpa_available && !kvmi_is_present() &&
> >  	    emulator_can_use_gpa(ctxt) &&
> >  	    (addr & ~PAGE_MASK) =3D=3D (vcpu->arch.gpa_val & ~PAGE_MASK)) {
> >  		gpa =3D vcpu->arch.gpa_val;
> >=20
>=20

Sure, but I think we'll have to extend the check.

Searching the logs I've found:

    kvm/x86: re-translate broken translation that caused EPT violation
   =20
    Signed-off-by: Mircea Cirjaliu <mcirjaliu@bitdefender.com>

 arch/x86/kvm/x86.c | 1 +
 1 file changed, 1 insertion(+)

/home/b/kvmi@9cad844~1/arch/x86/kvm/x86.c:4757,4762 - /home/b/kvmi@9cad84=
4/arch/x86/kvm/x86.c:4757,4763
  	 */
  	if (vcpu->arch.gpa_available &&
  	    emulator_can_use_gpa(ctxt) &&
+ 	    (vcpu->arch.error_code & PFERR_GUEST_FINAL_MASK) &&
  	    (addr & ~PAGE_MASK) =3D=3D (vcpu->arch.gpa_val & ~PAGE_MASK)) {
  		gpa =3D vcpu->arch.gpa_val;
  		ret =3D vcpu_is_mmio_gpa(vcpu, addr, gpa, write);

