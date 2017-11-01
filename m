Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD7E86B0268
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:12:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d28so1644696pfe.1
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:12:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i6si4108786pgt.798.2017.11.01.01.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 01:12:45 -0700 (PDT)
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 318EF21871
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:12:45 +0000 (UTC)
Received: by mail-io0-f181.google.com with SMTP id h70so4396155ioi.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:12:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031180757.8B5DA496@viggo.jf.intel.com>
References: <20171031180757.8B5DA496@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 01:12:24 -0700
Message-ID: <CALCETrVw5nJoK99FQ+n4SiJPKEQ6umDBYat9zesaxFLLcE+yZg@mail.gmail.com>
Subject: Re: [PATCH] x86, mm: make alternatives code do stronger TLB flush
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andrew Lutomirski <luto@kernel.org>

On Tue, Oct 31, 2017 at 11:07 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> local_flush_tlb() does a CR3 write.  But, that kind of TLB flush is
> not guaranteed to invalidate global pages.  The entire kernel is
> mapped with global pages.
>
> Also, now that we have PCIDs, local_flush_tlb() will only flush the
> *current* PCID.  It would not flush the entries for all PCIDs.
> At the moment, this is a moot point because all kernel pages are
> _PAGE_GLOBAL which do not really *have* a particular PCID.
>
> Use the stronger __flush_tlb_all() which does flush global pages.
>
> This was found because of a warning I added to __native_flush_tlb()
> to look for calls to it when PCIDs are enabled.  This patch does
> not fix any bug known to be hit in practice.

I'm very confused here.  set_fixmap() does a flush.  clear_fixmap()
calls set_fixmap() and therefore also flushes.  So I don't see why the
flush you're modifying is needed at all.  Could you just delete it
instead?

If your KAISER series were applied, then the situation is slightly
different.  We have this code:

static void __set_pte_vaddr(pud_t *pud, unsigned long vaddr, pte_t new_pte)
{
        pmd_t *pmd = fill_pmd(pud, vaddr);
        pte_t *pte = fill_pte(pmd, vaddr);

        set_pte(pte, new_pte);

        /*
         * It's enough to flush this one mapping.
         * (PGE mappings get flushed as well)
         */
        __flush_tlb_one(vaddr);
}

and that is no longer correct.  You may need to add a helper
__flush_tlb_kernel_one() that does the right thing.  For the
alternatives case, you could skip it since you know that the mapping
never got propagated to any other PCID slot on the current CPU, but
that's probably not worth trying to optimize.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
