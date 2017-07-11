Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27F636B04B2
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 01:57:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so29125192wrb.6
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 22:57:11 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id k4si8542359wmi.44.2017.07.10.22.57.09
        for <linux-mm@kvack.org>;
        Mon, 10 Jul 2017 22:57:10 -0700 (PDT)
Date: Tue, 11 Jul 2017 07:56:59 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v9 04/38] x86/CPU/AMD: Add the Secure Memory Encryption
 CPU feature
Message-ID: <20170711055659.GA4554@nazgul.tnic>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
 <20170707133850.29711.29549.stgit@tlendack-t1.amdoffice.net>
 <CAMzpN2j-gXvx2wAp3EvQB70Mr_oz0MSUzG=c-mhu-bnRiQGaFQ@mail.gmail.com>
 <f5657d4a-aa15-9602-bb36-1a3cfe7fbcc1@amd.com>
 <CAMzpN2hqYMVwhDRTGEhcUxqN2+6ToMmy6NBUutYJgPoOJEH4uQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAMzpN2hqYMVwhDRTGEhcUxqN2+6ToMmy6NBUutYJgPoOJEH4uQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, kexec@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, Linux-MM <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Tue, Jul 11, 2017 at 01:07:46AM -0400, Brian Gerst wrote:
> > If I make the scattered feature support conditional on CONFIG_X86_64
> > (based on comment below) then cpu_has() will always be false unless
> > CONFIG_X86_64 is enabled. So this won't need to be wrapped by the
> > #ifdef.
> 
> If you change it to use cpu_feature_enabled(), gcc will see that it is
> disabled and eliminate the dead code at compile time.

Just do this:

       if (cpu_has(c, X86_FEATURE_SME)) {
	       if (IS_ENABLED(CONFIG_X86_32)) {
                       clear_cpu_cap(c, X86_FEATURE_SME);
	       } else {
		       u64 msr;

		       /* Check if SME is enabled */
	              rdmsrl(MSR_K8_SYSCFG, msr);
	              if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
	                      clear_cpu_cap(c, X86_FEATURE_SME);
	       }
       }

so that it is explicit that we disable it on 32-bit and we can save us
the ifdeffery elsewhere.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
