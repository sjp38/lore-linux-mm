Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C05B6B0272
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:00:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n132so83720038oih.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:00:01 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0087.outbound.protection.outlook.com. [104.47.38.87])
        by mx.google.com with ESMTPS id c184si2866223oia.229.2016.09.22.11.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 11:59:48 -0700 (PDT)
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
 <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <23fcb1d7-e9f8-26b8-bfb7-b2d525e49bae@amd.com>
Date: Thu, 22 Sep 2016 13:59:35 -0500
MIME-Version: 1.0
In-Reply-To: <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On 09/22/2016 09:59 AM, Borislav Petkov wrote:
> On Thu, Sep 22, 2016 at 04:45:51PM +0200, Paolo Bonzini wrote:
>> The main difference between the SME and SEV encryption, from the point
>> of view of the kernel, is that real-mode always writes unencrypted in
>> SME and always writes encrypted in SEV.  But UEFI can run in 64-bit mode
>> and learn about the C bit, so EFI boot data should be unprotected in SEV
>> guests.
> 
> Actually, it is different: you can start fully encrypted in SME, see:
> 
> https://lkml.kernel.org/r/20160822223539.29880.96739.stgit@tlendack-t1.amdoffice.net
> 
> The last paragraph alludes to a certain transparent mode where you're
> already encrypted and only certain pieces like EFI is not encrypted. I
> think the aim is to have the transparent mode be the default one, which
> makes most sense anyway.

There is a new Transparent SME mode that is now part of the overall
SME support, but I'm not alluding to that in the documentation at all.
In TSME mode, everything that goes through the memory controller would
be encrypted and that would include EFI data, etc.  TSME would be
enabled through a BIOS option, thus allowing legacy OSes to benefit.

> 
> The EFI regions are unencrypted for obvious reasons and you need to
> access them as such.
> 
>> Because the firmware volume is written to high memory in encrypted
>> form, and because the PEI phase runs in 32-bit mode, the firmware
>> code will be encrypted; on the other hand, data that is placed in low
>> memory for the kernel can be unencrypted, thus limiting differences
>> between SME and SEV.
> 
> When you run fully encrypted, you still need to access EFI tables in the
> clear. That's why I'm confused about this patch here.

This patch assumes that the EFI regions of a guest would be encrypted.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
