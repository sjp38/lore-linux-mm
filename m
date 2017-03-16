Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A732F6B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:10:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so11150221wme.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:10:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k90si4890203wmc.91.2017.03.16.08.10.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 08:10:18 -0700 (PDT)
Date: Thu, 16 Mar 2017 16:09:57 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 12/32] x86: Add early boot support when running
 with SEV active
Message-ID: <20170316150957.dos6wp3pmhos4hkj@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
 <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
 <5d62b16f-16ef-1bd7-1551-f0c4c43573f4@redhat.com>
 <20170309162942.jwtb3l33632zhbaz@pd.tnic>
 <1fe1e177-f588-fe5a-dc13-e9fde00e8958@amd.com>
 <20170316101656.dcwgtn4qdtyp5hip@pd.tnic>
 <b27126ee-aff0-ab11-706b-fc6d8d4901db@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b27126ee-aff0-ab11-706b-fc6d8d4901db@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 16, 2017 at 09:28:58AM -0500, Tom Lendacky wrote:
> Because there are differences between how SME and SEV behave
> (instruction fetches are always decrypted under SEV, DMA to an
> encrypted location is not supported under SEV, etc.) we need to
> determine which mode we are in so that things can be setup properly
> during boot. For example, if SEV is active the kernel will already
> be encrypted and so we don't perform that step or the trampoline area
> for bringing up an AP must be decrypted for SME but encrypted for SEV.

So with SEV enabled, it seems to me a guest doesn't know anything about
encryption and can run as if SME is disabled. So sme_active() will be
false. And then the kernel can bypass all that code dealing with SME.

So a guest should simply run like on baremetal with no SME, IMHO.

But then there's that part: "instruction fetches are always decrypted
under SEV". What does that mean exactly? And how much of that code can
be reused so that

* SME on baremetal
* SEV on guest

use the same logic?

Having the larger SEV preparation part on the kvm host side is perfectly
fine. But I'd like to keep kernel initialization paths clean.

Thanks.

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
