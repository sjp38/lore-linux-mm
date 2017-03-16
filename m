Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C76BC6B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:28:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u9so12017676wme.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:28:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 47si7735509wrc.11.2017.03.16.11.28.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 11:28:57 -0700 (PDT)
Date: Thu, 16 Mar 2017 19:28:36 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
Message-ID: <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Fri, Mar 10, 2017 at 04:41:56PM -0600, Brijesh Singh wrote:
> I can take a look at fixing those warning. In my initial attempt was to create
> a new function to clear encryption bit but it ended up looking very similar to
> __change_page_attr_set_clr() hence decided to extend the exiting function to
> use memblock_alloc().

... except that having all that SEV-specific code in main code paths is
yucky and I'd like to avoid it, if possible.

> Early in boot process, guest kernel allocates some structure (its either
> statically allocated or dynamic allocated via memblock_alloc). And shares the physical
> address of these structure with hypervisor. Since entire guest memory area is mapped
> as encrypted hence those structure's are mapped as encrypted memory range. We need
> a method to clear the encryption bit. Sometime these structure maybe part of 2M pages
> and need to split into smaller pages.

So how hard would it be if the hypervisor allocated that memory for the
guest instead? It would allocate it decrypted and guest would need to
access it decrypted too. All in preparation for SEV-ES which will need a
block of unencrypted memory for the guest anyway...

> In most cases, guest and hypervisor communication starts as soon as guest provides
> the physical address to hypervisor. So we must map the pages as decrypted before
> sharing the physical address to hypervisor.

See above: so purely theoretically speaking, the hypervisor could prep
that decrypted range for the guest. I'd look in Paolo's direction,
though, for the feasibility of something like that.

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
