Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 763806B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:16:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 6so1412299wrb.15
        for <linux-mm@kvack.org>; Wed, 31 May 2017 02:16:01 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id o23si16469120wra.77.2017.05.31.02.16.00
        for <linux-mm@kvack.org>;
        Wed, 31 May 2017 02:16:00 -0700 (PDT)
Date: Wed, 31 May 2017 11:15:53 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170531091553.jwqcwkfivmmhndwv@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
 <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
 <20170519201651.dhayf2pwjlsnouz4@treble>
 <1ac40d18-a8b2-94eb-35ed-c30768667be8@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1ac40d18-a8b2-94eb-35ed-c30768667be8@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 30, 2017 at 10:48:27AM -0500, Tom Lendacky wrote:
> I'll look at doing that instead of removing the support for the whole
> file.

Right, so I don't think the stack protector is even ready that early -
we do set it up later:

        /* Set up %gs.
         *
         * The base of %gs always points to the bottom of the irqstack
         * union.  If the stack protector canary is enabled, it is
         * located at %gs:40.  Note that, on SMP, the boot cpu uses
         * init data section till per cpu areas are set up.
         */
        movl    $MSR_GS_BASE,%ecx
        movl    initial_gs(%rip),%eax
        movl    initial_gs+4(%rip),%edx
        wrmsr

so I think marking the function "no-stack-protector" is the only option
right now. We can always look at fixing that later.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
