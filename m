Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A536A6B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 13:25:38 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z109so7111406wrb.1
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 10:25:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si3860682wmg.64.2017.04.06.10.25.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 10:25:37 -0700 (PDT)
Date: Thu, 6 Apr 2017 19:25:20 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
Message-ID: <20170406172520.iyjjtz56u3jlnjhq@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
 <f46ff1e1-1cc7-1907-74a0-e2709fa1e5fb@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f46ff1e1-1cc7-1907-74a0-e2709fa1e5fb@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedo.suse.de

Hi Brijesh,

On Thu, Apr 06, 2017 at 09:05:03AM -0500, Brijesh Singh wrote:
> I looked into arch/x86/mm/init_{32,64}.c and as you pointed the file contains
> routines to do basic page splitting. I think it sufficient for our usage.

Good :)

> I should be able to drop the memblock patch from the series and update the
> Patch 15 [1] to use the kernel_physical_mapping_init().
> 
> The kernel_physical_mapping_init() creates the page table mapping using
> default KERNEL_PAGE attributes, I tried to extend the function by passing
> 'bool enc' flags to hint whether to clr or set _PAGE_ENC when splitting the
> pages. The code did not looked clean hence I dropped that idea.

Or, you could have a

__kernel_physical_mapping_init_prot(..., prot)

helper which gets a protection argument and hands it down. The lower
levels already hand down prot which is good.

The interface kernel_physical_mapping_init() will then itself call:

	__kernel_physical_mapping_init_prot(..., PAGE_KERNEL);

for the normal cases.

That in a pre-patch of course.

How does that sound?

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
