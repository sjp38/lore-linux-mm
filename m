Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13C376B02B4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 16:34:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b6so109896494oia.14
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:34:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v32si3953816otd.256.2017.06.21.13.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 13:34:33 -0700 (PDT)
Received: from mail-ua0-f169.google.com (mail-ua0-f169.google.com [209.85.217.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CD94022B48
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 20:34:32 +0000 (UTC)
Received: by mail-ua0-f169.google.com with SMTP id 70so59965753uau.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:34:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706211127460.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211127460.2328@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 13:34:10 -0700
Message-ID: <CALCETrVCJo8dNBnEA2p3dhgymfcfMN=uhMz0XXn047=tsQNnFw@mail.gmail.com>
Subject: Re: [PATCH v3 10/11] x86/mm: Enable CR4.PCIDE on supported systems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Wed, Jun 21, 2017 at 2:39 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 20 Jun 2017, Andy Lutomirski wrote:
>> +     /* Set up PCID */
>> +     if (cpu_has(c, X86_FEATURE_PCID)) {
>> +             if (cpu_has(c, X86_FEATURE_PGE)) {
>> +                     cr4_set_bits(X86_CR4_PCIDE);
>
> So I assume that you made sure that the PCID bits in CR3 are zero under all
> circumstances as setting PCIDE would cause a #GP if not.

Yes.  All existing code just shoves a PA of a page table in there.  As
far as I know, neither Linux nor anyone else uses the silly PCD and
PWT bits.  It's not even clear to me that they are functional if PAT
is enabled.

>
> And what happens on kexec etc? We need to reset the asid and PCIDE I assume.
>

I assume it works roughly the same way as suspend, etc --
mmu_cr4_features has the desired CR4 and the init code deals with it.
And PGE, PKE, etc all work correctly.  I'm not sure why PCIDE needs to
be cleared -- the init code will work just fine even if PCIDE is
unexpectedly set.

That being said, I haven't managed to understand what exactly the
kexec code is doing.  But I think the relevant bit is here in
relocate_kernel_64.S:

        /*
         * Set cr4 to a known state:
         *  - physical address extension enabled
         */
        movl    $X86_CR4_PAE, %eax
        movq    %rax, %cr4

Kexec folks, is it safe to assume that kexec can already deal with the
new and old kernels disagreeing on what CR4 should be?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
