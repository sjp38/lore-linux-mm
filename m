Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9302928092C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 11:35:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 67so170723162pfg.0
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 08:35:45 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0081.outbound.protection.outlook.com. [104.47.34.81])
        by mx.google.com with ESMTPS id q87si3409727pfk.243.2017.03.10.08.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 08:35:44 -0800 (PST)
Subject: Re: [RFC PATCH v2 12/32] x86: Add early boot support when running
 with SEV active
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
 <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
 <5d62b16f-16ef-1bd7-1551-f0c4c43573f4@redhat.com>
 <20170309162942.jwtb3l33632zhbaz@pd.tnic>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <1fe1e177-f588-fe5a-dc13-e9fde00e8958@amd.com>
Date: Fri, 10 Mar 2017 10:35:30 -0600
MIME-Version: 1.0
In-Reply-To: <20170309162942.jwtb3l33632zhbaz@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Paolo Bonzini <pbonzini@redhat.com>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

Hi Boris and Paolo,

On 03/09/2017 10:29 AM, Borislav Petkov wrote:
> On Thu, Mar 09, 2017 at 05:13:33PM +0100, Paolo Bonzini wrote:
>> This is not how you check if running under a hypervisor; you should
>> check the HYPERVISOR bit, i.e. bit 31 of cpuid(1).ecx.  This in turn
>> tells you if leaf 0x40000000 is valid.
>
> Ah, good point, I already do that in the microcode loader :)
>
>         /*
>          * CPUID(1).ECX[31]: reserved for hypervisor use. This is still not
>          * completely accurate as xen pv guests don't see that CPUID bit set but
>          * that's good enough as they don't land on the BSP path anyway.
>          */
>         if (native_cpuid_ecx(1) & BIT(31))
>                 return *res;
>
>> That said, the main issue with this function is that it hardcodes the
>> behavior for KVM.  It is possible that another hypervisor defines its
>> 0x40000001 leaf in such a way that KVM_FEATURE_SEV has a different meaning.
>>
>> Instead, AMD should define a "well-known" bit in its own space (i.e.
>> 0x800000xx) that is only used by hypervisors that support SEV.  This is
>> similar to how Intel defined one bit in leaf 1 to say "is leaf
>> 0x40000000 valid".
>>
>>> +	if (eax > 0x40000000) {
>>> +		eax = 0x40000001;
>>> +		ecx = 0;
>>> +		native_cpuid(&eax, &ebx, &ecx, &edx);
>>> +		if (!(eax & BIT(KVM_FEATURE_SEV)))
>>> +			goto out;
>>> +
>>> +		eax = 0x8000001f;
>>> +		ecx = 0;
>>> +		native_cpuid(&eax, &ebx, &ecx, &edx);
>>> +		if (!(eax & 1))
>
> Right, so this is testing CPUID_0x8000001f_ECX(0)[0], SME. Why not
> simply set that bit for the guest too, in kvm?
>

CPUID_8000_001F[EAX] indicates whether the feature is supported.
CPUID_0x8000001F[EAX]:
  * Bit 0 - SME supported
  * Bit 1 - SEV supported
  * Bit 3 - SEV-ES supported

We can use MSR_K8_SYSCFG[MemEncryptionModeEnc] to check if memory encryption is enabled.
Currently, KVM returns zero when guest OS read MSR_K8_SYSCFG. I can update my patch sets
to set this bit for SEV enabled guests.

We could update this patch to use the below logic:

  * CPUID(0) - Check for AuthenticAMD
  * CPID(1) - Check if under hypervisor
  * CPUID(0x80000000) - Check for highest supported leaf
  * CPUID(0x8000001F).EAX - Check for SME and SEV support
  * rdmsr (MSR_K8_SYSCFG)[MemEncryptionModeEnc] - Check if SMEE is set


Paolo,

One question, do we need "AuthenticAMD" check when we are running under hypervisor ?
I was looking at qemu code and found that qemu exposes parameters to change the CPU
vendor id. The above check will fail if user changes the vendor id while launching
the SEV guest.

-Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
