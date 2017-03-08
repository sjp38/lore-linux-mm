Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8FF831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 03:46:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d66so8947591wmi.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 00:46:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 124si3917189wmc.106.2017.03.08.00.46.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 00:46:29 -0800 (PST)
Date: Wed, 8 Mar 2017 09:46:02 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 09/32] x86: Change early_ioremap to early_memremap
 for BOOT data
Message-ID: <20170308084602.z6t44k2izdum3w3v@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846763334.2349.9327692408737971533.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <148846763334.2349.9327692408737971533.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 02, 2017 at 10:13:53AM -0500, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> In order to map BOOT data with the proper encryption bit, the

Btw, what does that all-caps spelling "BOOT" denote? Something I'm
missing?

> early_ioremap() function calls are changed to early_memremap() calls.
> This allows the proper access for both SME and SEV.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/acpi/boot.c |    4 ++--
>  arch/x86/kernel/mpparse.c   |   10 +++++-----
>  drivers/sfi/sfi_core.c      |    6 +++---
>  3 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 35174c6..468c25a 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -124,7 +124,7 @@ char *__init __acpi_map_table(unsigned long phys, unsigned long size)
>  	if (!phys || !size)
>  		return NULL;
>  
> -	return early_ioremap(phys, size);
> +	return early_memremap(phys, size);

Right, the question will keep popping up why we can simply replace
memremap with ioremap and the general difference wrt to SME/SEV. So it
would be a good idea to have a comment in, say, arch/x86/mm/ioremap.c,
explaining the general situation.

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
