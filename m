Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3B7BC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:06:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6770720679
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:06:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6770720679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1EE6B0005; Mon, 12 Aug 2019 17:06:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79446B0006; Mon, 12 Aug 2019 17:06:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D68A86B0007; Mon, 12 Aug 2019 17:06:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0227.hostedemail.com [216.40.44.227])
	by kanga.kvack.org (Postfix) with ESMTP id B63D66B0005
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:06:04 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 66B218248AA1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:06:04 +0000 (UTC)
X-FDA: 75815008248.22.bulb39_8c4240e9fda1c
X-HE-Tag: bulb39_8c4240e9fda1c
X-Filterd-Recvd-Size: 4890
Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:06:03 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 14:05:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="327476751"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by orsmga004.jf.intel.com with ESMTP; 12 Aug 2019 14:05:01 -0700
Date: Mon, 12 Aug 2019 14:05:01 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>
Subject: Re: [RFC PATCH v6 55/92] kvm: introspection: add KVMI_CONTROL_MSR
 and KVMI_EVENT_MSR
Message-ID: <20190812210501.GD1437@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-56-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190809160047.8319-56-alazar@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 07:00:10PM +0300, Adalbert Laz=C4=83r wrote:
> From: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm=
_host.h
> index 22f08f2732cc..91cd43a7a7bf 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -1013,6 +1013,8 @@ struct kvm_x86_ops {
>  	bool (*has_emulated_msr)(int index);
>  	void (*cpuid_update)(struct kvm_vcpu *vcpu);
> =20
> +	void (*msr_intercept)(struct kvm_vcpu *vcpu, unsigned int msr,
> +				bool enable);

This should be toggle_wrmsr_intercept(), or toggle_msr_intercept() with
a paramter to control RDMSR vs. WRMSR.

>  	void (*cr3_write_exiting)(struct kvm_vcpu *vcpu, bool enable);
>  	bool (*nested_pagefault)(struct kvm_vcpu *vcpu);
>  	bool (*spt_fault)(struct kvm_vcpu *vcpu);
> @@ -1621,6 +1623,8 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
>  #define put_smstate(type, buf, offset, val)                      \
>  	*(type *)((buf) + (offset) - 0x7e00) =3D val
> =20
> +void kvm_arch_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
> +				bool enable);
>  bool kvm_mmu_nested_pagefault(struct kvm_vcpu *vcpu);
>  bool kvm_spt_fault(struct kvm_vcpu *vcpu);
>  void kvm_control_cr3_write_exiting(struct kvm_vcpu *vcpu, bool enable)=
;
> diff --git a/arch/x86/include/asm/kvmi_host.h b/arch/x86/include/asm/kv=
mi_host.h
> index 83a098dc8939..8285d1eb0db6 100644

...

> diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
> index b3cab0db6a70..5dba4f87afef 100644
> --- a/arch/x86/kvm/kvmi.c
> +++ b/arch/x86/kvm/kvmi.c
> @@ -9,6 +9,133 @@
>  #include <asm/vmx.h>
>  #include "../../../virt/kvm/kvmi_int.h"
> =20
> +static unsigned long *msr_mask(struct kvm_vcpu *vcpu, unsigned int *ms=
r)
> +{
> +	switch (*msr) {
> +	case 0 ... 0x1fff:
> +		return IVCPU(vcpu)->msr_mask.low;
> +	case 0xc0000000 ... 0xc0001fff:
> +		*msr &=3D 0x1fff;
> +		return IVCPU(vcpu)->msr_mask.high;
> +	}
> +
> +	return NULL;
> +}

...

> diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
> index 6450c8c44771..0306c7ef3158 100644
> --- a/arch/x86/kvm/vmx/vmx.c
> +++ b/arch/x86/kvm/vmx/vmx.c
> @@ -7784,6 +7784,15 @@ static __exit void hardware_unsetup(void)
>  	free_kvm_area();
>  }
> =20
> +static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
> +			      bool enable)
> +{
> +	struct vcpu_vmx *vmx =3D to_vmx(vcpu);
> +	unsigned long *msr_bitmap =3D vmx->vmcs01.msr_bitmap;
> +
> +	vmx_set_intercept_for_msr(msr_bitmap, msr, MSR_TYPE_W, enable);
> +}

Unless I overlooked a check, this will allow userspace to disable WRMSR
interception for any MSR in the above range, i.e. userspace can use KVM
to gain full write access to pretty much all the interesting MSRs.  This
needs to only disable interception if KVM had interception disabled befor=
e
introspection started modifying state.

