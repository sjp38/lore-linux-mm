Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B35096B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:29:09 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id s128so12530347itb.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:29:09 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0071.outbound.protection.outlook.com. [104.47.38.71])
        by mx.google.com with ESMTPS id s141si3608226itb.110.2017.03.16.07.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 07:29:08 -0700 (PDT)
Subject: Re: [RFC PATCH v2 12/32] x86: Add early boot support when running
 with SEV active
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
 <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
 <5d62b16f-16ef-1bd7-1551-f0c4c43573f4@redhat.com>
 <20170309162942.jwtb3l33632zhbaz@pd.tnic>
 <1fe1e177-f588-fe5a-dc13-e9fde00e8958@amd.com>
 <20170316101656.dcwgtn4qdtyp5hip@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <b27126ee-aff0-ab11-706b-fc6d8d4901db@amd.com>
Date: Thu, 16 Mar 2017 09:28:58 -0500
MIME-Version: 1.0
In-Reply-To: <20170316101656.dcwgtn4qdtyp5hip@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On 3/16/2017 5:16 AM, Borislav Petkov wrote:
> On Fri, Mar 10, 2017 at 10:35:30AM -0600, Brijesh Singh wrote:
>> We could update this patch to use the below logic:
>>
>>  * CPUID(0) - Check for AuthenticAMD
>>  * CPID(1) - Check if under hypervisor
>>  * CPUID(0x80000000) - Check for highest supported leaf
>>  * CPUID(0x8000001F).EAX - Check for SME and SEV support
>>  * rdmsr (MSR_K8_SYSCFG)[MemEncryptionModeEnc] - Check if SMEE is set
>
> Actually, it is still not clear to me *why* we need to do anything
> special wrt SEV in the guest.
>
> Lemme clarify: why can't the guest boot just like a normal Linux on
> baremetal and use the SME(!) detection code to set sme_enable and so
> on? IOW, I'd like to avoid all those checks whether we're running under
> hypervisor and handle all that like we're running on baremetal.

Because there are differences between how SME and SEV behave
(instruction fetches are always decrypted under SEV, DMA to an
encrypted location is not supported under SEV, etc.) we need to
determine which mode we are in so that things can be setup properly
during boot. For example, if SEV is active the kernel will already
be encrypted and so we don't perform that step or the trampoline area
for bringing up an AP must be decrypted for SME but encrypted for SEV.
The hypervisor check will provide that ability to determine how we
handle things.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
