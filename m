Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 721EA2808EA
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 11:30:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y51so22300639wry.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 08:30:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b31si9301472wrd.314.2017.03.09.08.30.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 08:30:08 -0800 (PST)
Date: Thu, 9 Mar 2017 17:29:42 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 12/32] x86: Add early boot support when running
 with SEV active
Message-ID: <20170309162942.jwtb3l33632zhbaz@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
 <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
 <5d62b16f-16ef-1bd7-1551-f0c4c43573f4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5d62b16f-16ef-1bd7-1551-f0c4c43573f4@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 09, 2017 at 05:13:33PM +0100, Paolo Bonzini wrote:
> This is not how you check if running under a hypervisor; you should
> check the HYPERVISOR bit, i.e. bit 31 of cpuid(1).ecx.  This in turn
> tells you if leaf 0x40000000 is valid.

Ah, good point, I already do that in the microcode loader :)

        /*
         * CPUID(1).ECX[31]: reserved for hypervisor use. This is still not
         * completely accurate as xen pv guests don't see that CPUID bit set but
         * that's good enough as they don't land on the BSP path anyway.
         */
        if (native_cpuid_ecx(1) & BIT(31))
                return *res;

> That said, the main issue with this function is that it hardcodes the
> behavior for KVM.  It is possible that another hypervisor defines its
> 0x40000001 leaf in such a way that KVM_FEATURE_SEV has a different meaning.
> 
> Instead, AMD should define a "well-known" bit in its own space (i.e.
> 0x800000xx) that is only used by hypervisors that support SEV.  This is
> similar to how Intel defined one bit in leaf 1 to say "is leaf
> 0x40000000 valid".
> 
> > +	if (eax > 0x40000000) {
> > +		eax = 0x40000001;
> > +		ecx = 0;
> > +		native_cpuid(&eax, &ebx, &ecx, &edx);
> > +		if (!(eax & BIT(KVM_FEATURE_SEV)))
> > +			goto out;
> > +
> > +		eax = 0x8000001f;
> > +		ecx = 0;
> > +		native_cpuid(&eax, &ebx, &ecx, &edx);
> > +		if (!(eax & 1))

Right, so this is testing CPUID_0x8000001f_ECX(0)[0], SME. Why not
simply set that bit for the guest too, in kvm?

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
