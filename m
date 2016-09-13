Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E06D36B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:56:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so117000259lfb.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:56:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy7si20008137wjc.70.2016.09.13.02.56.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Sep 2016 02:56:09 -0700 (PDT)
Date: Tue, 13 Sep 2016 11:56:04 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 01/28] kvm: svm: Add support for additional SVM
 NPF error codes
Message-ID: <20160913095604.GB19076@nazgul.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190822443.9523.7814744422402462127.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <147190822443.9523.7814744422402462127.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Mon, Aug 22, 2016 at 07:23:44PM -0400, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> AMD hardware adds two additional bits to aid in nested page fault handling.
> 
> Bit 32 - NPF occurred while translating the guest's final physical address
> Bit 33 - NPF occurred while translating the guest page tables
> 
> The guest page tables fault indicator can be used as an aid for nested
> virtualization. Using V0 for the host, V1 for the first level guest and
> V2 for the second level guest, when both V1 and V2 are using nested paging
> there are currently a number of unnecessary instruction emulations. When
> V2 is launched shadow paging is used in V1 for the nested tables of V2. As
> a result, KVM marks these pages as RO in the host nested page tables. When
> V2 exits and we resume V1, these pages are still marked RO.
> 
> Every nested walk for a guest page table is treated as a user-level write
> access and this causes a lot of NPFs because the V1 page tables are marked
> RO in the V0 nested tables. While executing V1, when these NPFs occur KVM
> sees a write to a read-only page, emulates the V1 instruction and unprotects
> the page (marking it RW). This patch looks for cases where we get a NPF due
> to a guest page table walk where the page was marked RO. It immediately
> unprotects the page and resumes the guest, leading to far fewer instruction
> emulations when nested virtualization is used.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/kvm_host.h |   11 ++++++++++-
>  arch/x86/kvm/mmu.c              |   20 ++++++++++++++++++--
>  arch/x86/kvm/svm.c              |    2 +-
>  3 files changed, 29 insertions(+), 4 deletions(-)

FWIW: Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
