Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7BC6B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:18:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u108so12888813wrb.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 03:18:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s15si10553141wrc.222.2017.03.17.03.18.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 03:18:05 -0700 (PDT)
Date: Fri, 17 Mar 2017 11:17:37 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
Message-ID: <20170317101737.icdois7sdmtutt6b@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedo.suse.de

On Thu, Mar 16, 2017 at 11:25:36PM +0100, Paolo Bonzini wrote:
> The kvmclock memory is initially zero so there is no need for the
> hypervisor to allocate anything; the point of these patches is just to
> access the data in a natural way from Linux source code.

I realize that.

> I also don't really like the patch as is (plus it fails modpost), but
> IMO reusing __change_page_attr and __split_large_page is the right thing
> to do.

Right, so teaching pageattr.c about memblock could theoretically come
around and bite us later when a page allocated with memblock gets freed
with free_page().

And looking at this more, we have all this kernel pagetable preparation
code down the init_mem_mapping() call and the pagetable setup in
arch/x86/mm/init_{32,64}.c

And that code even does some basic page splitting. Oh and it uses
alloc_low_pages() which knows whether to do memblock reservation or the
common __get_free_pages() when slabs are up.

So what would be much cleaner, IMHO, is if one would reuse that code to
change init_mm.pgd mappings early without copying pageattr.c.

init_mem_mapping() gets called before kvm_guest_init() in setup_arch()
so the guest would simply fixup its pagetable right there.

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
