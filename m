Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F984C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:47:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A1A620679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:47:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A1A620679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBD396B0006; Tue, 13 Aug 2019 04:47:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6DC86B0007; Tue, 13 Aug 2019 04:47:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B83DD6B0008; Tue, 13 Aug 2019 04:47:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id 974516B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:47:39 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 42CD5180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:47:39 +0000 (UTC)
X-FDA: 75816776238.26.seat63_891c3bce5912
X-HE-Tag: seat63_891c3bce5912
X-Filterd-Recvd-Size: 5089
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:47:38 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id v19so717467wmj.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:47:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=dot1gc/mMlmPmCzz2QNsuI+h9x0oQ5vgk6vGPP9o7BE=;
        b=grcgEB0mV987V1Tezonlm+PqjrOj3E/LDE0dJD/fRz0BrcfPhlUTXPbbuARTtU6Ifd
         mqEcrjHesxmCkklFffZ+6CfYr+vStLE2ZMpXSepz9H1Uek1f08axgIcCu0YhhGwmgy0h
         QshNBxx3DnZDWg5OK3/Qou+fcVO8yamsx65bKKGOz0qqiSv3tnMYAEEm/L36pUqnTWrP
         kDevQKUg7p7P6O/39WoseecsU1sP4n3KalBLm5aNAfLqhKxK5JUJODcKXpC/w3JGigzQ
         dB3D3lg+JseyPcFYn9L7oakl4218CSRPV0ruQEb1X8aTSBwHzytPWHGLEN27C2pI1kXD
         K0qA==
X-Gm-Message-State: APjAAAXGgYfms5zif07Wz/AXJMyw1tqejp9Gdtxg450eym86YseGfTMC
	MetHm/NYu3VsUiByxM+1x25aOQ==
X-Google-Smtp-Source: APXvYqzu741BNphc7Bkte8hG3txzzfxmRNvj7kUnHgJredomsRJ9fKepXbx6ZmCo5ts7buHZQwE5Qw==
X-Received: by 2002:a1c:2ec6:: with SMTP id u189mr1791329wmu.67.1565686057680;
        Tue, 13 Aug 2019 01:47:37 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id w15sm832270wmi.19.2019.08.13.01.47.36
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 01:47:37 -0700 (PDT)
Subject: Re: [RFC PATCH v6 75/92] kvm: x86: disable gpa_available optimization
 in emulator_read_write_onepage()
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
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-76-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <eb748e05-8289-0c05-6907-b6c898f6080b@redhat.com>
Date: Tue, 13 Aug 2019 10:47:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-76-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> If the EPT violation was caused by an execute restriction imposed by th=
e
> introspection tool, gpa_available will point to the instruction pointer=
,
> not the to the read/write location that has to be used to emulate the
> current instruction.
>=20
> This optimization should be disabled only when the VM is introspected,
> not just because the introspection subsystem is present.
>=20
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>

The right thing to do is to not set gpa_available for fetch failures in=20
kvm_mmu_page_fault instead:

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 24843cf49579..1bdca40fa831 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -5364,8 +5364,12 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_=
t cr2, u64 error_code,
 	enum emulation_result er;
 	bool direct =3D vcpu->arch.mmu->direct_map;
=20
-	/* With shadow page tables, fault_address contains a GVA or nGPA.  */
-	if (vcpu->arch.mmu->direct_map) {
+	/*
+	 * With shadow page tables, fault_address contains a GVA or nGPA.
+	 * On a fetch fault, fault_address contains the instruction pointer.
+	 */
+	if (vcpu->arch.mmu->direct_map &&
+	    likely(!(error_code & PFERR_FETCH_MASK)) {
 		vcpu->arch.gpa_available =3D true;
 		vcpu->arch.gpa_val =3D cr2;
 	}


Paolo

> ---
>  arch/x86/kvm/x86.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 965c4f0108eb..3975331230b9 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -5532,7 +5532,7 @@ static int emulator_read_write_onepage(unsigned l=
ong addr, void *val,
>  	 * operation using rep will only have the initial GPA from the NPF
>  	 * occurred.
>  	 */
> -	if (vcpu->arch.gpa_available &&
> +	if (vcpu->arch.gpa_available && !kvmi_is_present() &&
>  	    emulator_can_use_gpa(ctxt) &&
>  	    (addr & ~PAGE_MASK) =3D=3D (vcpu->arch.gpa_val & ~PAGE_MASK)) {
>  		gpa =3D vcpu->arch.gpa_val;
>=20


