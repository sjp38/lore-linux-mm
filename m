Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB64C6B026F
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:59:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w84so73422713wmg.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:59:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 79si2824263wmo.143.2016.09.22.07.59.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 07:59:56 -0700 (PDT)
Date: Thu, 22 Sep 2016 16:59:47 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
Message-ID: <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, thomas.lendacky@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Sep 22, 2016 at 04:45:51PM +0200, Paolo Bonzini wrote:
> The main difference between the SME and SEV encryption, from the point
> of view of the kernel, is that real-mode always writes unencrypted in
> SME and always writes encrypted in SEV.  But UEFI can run in 64-bit mode
> and learn about the C bit, so EFI boot data should be unprotected in SEV
> guests.

Actually, it is different: you can start fully encrypted in SME, see:

https://lkml.kernel.org/r/20160822223539.29880.96739.stgit@tlendack-t1.amdoffice.net

The last paragraph alludes to a certain transparent mode where you're
already encrypted and only certain pieces like EFI is not encrypted. I
think the aim is to have the transparent mode be the default one, which
makes most sense anyway.

The EFI regions are unencrypted for obvious reasons and you need to
access them as such.

> Because the firmware volume is written to high memory in encrypted
> form, and because the PEI phase runs in 32-bit mode, the firmware
> code will be encrypted; on the other hand, data that is placed in low
> memory for the kernel can be unencrypted, thus limiting differences
> between SME and SEV.

When you run fully encrypted, you still need to access EFI tables in the
clear. That's why I'm confused about this patch here.

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
