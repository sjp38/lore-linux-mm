Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2E04A6B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 22:35:49 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so689134pde.32
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 19:35:48 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c3si833368pat.223.2014.07.22.19.35.47
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 19:35:48 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v7 03/10] x86, mpx: add macro cpu_has_mpx
Date: Wed, 23 Jul 2014 02:35:42 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE0170079E@shsmsx102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
 <1405921124-4230-4-git-send-email-qiaowei.ren@intel.com>
 <53CE8EEC.2090402@intel.com>
In-Reply-To: <53CE8EEC.2090402@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2014-07-23, Hansen, Dave wrote:
> On 07/20/2014 10:38 PM, Qiaowei Ren wrote:
>> +#ifdef CONFIG_X86_INTEL_MPX
>> +#define cpu_has_mpx boot_cpu_has(X86_FEATURE_MPX) #else #define
>> +cpu_has_mpx 0 #endif /* CONFIG_X86_INTEL_MPX */
>=20
> Is this enough checking?  Looking at the extension reference, it says:
>=20
>> 9.3.3 Enabling of Intel MPX States An OS can enable Intel MPX states to
>> support software operation using bounds registers with the following
>> steps: * Verify the processor supports XSAVE/XRSTOR/XSETBV/XGETBV
>> instructions and XCR0 by checking CPUID.1.ECX.XSAVE[bit 26]=3D1.
>=20
> That, I assume the xsave code is already doing.
>=20
>> * Verify the processor supports both Intel MPX states by checking
> CPUID.(EAX=3D0x0D, ECX=3D0):EAX[4:3] is 11b.
>=20
> I see these bits _attempting_ to get set in pcntxt_mask via XCNTXT_MASK.
>  But, I don't see us ever actually checking that they _do_ get set.
> For instance, we do this for:
>=20
>>         if ((pcntxt_mask & XSTATE_FPSSE) !=3D XSTATE_FPSSE) {
>>                 pr_err("FP/SSE not shown under xsave features
> 0x%llx\n",
>>                        pcntxt_mask);
>>                 BUG();
>>         }

The checking about MPX feature should be as follow:

        if (pcntxt_mask & XSTATE_EAGER) {
                if (eagerfpu =3D=3D DISABLE) {
                        pr_err("eagerfpu not present, disabling some xstate=
 features: 0x%llx\n",
                                        pcntxt_mask & XSTATE_EAGER);
                        pcntxt_mask &=3D ~XSTATE_EAGER;
                } else {
                        eagerfpu =3D ENABLE;
                }
        }

This patch was merged into kernel the ending of last year (https://git.kern=
el.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3De7d820a5e549b3=
eb6c3f9467507566565646a669 )

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
