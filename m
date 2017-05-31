Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAEA46B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 04:49:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y43so1333931wrc.11
        for <linux-mm@kvack.org>; Wed, 31 May 2017 01:49:31 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id u66si944787wrb.292.2017.05.31.01.49.30
        for <linux-mm@kvack.org>;
        Wed, 31 May 2017 01:49:30 -0700 (PDT)
Date: Wed, 31 May 2017 10:49:23 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170531084923.mmlpefxfx53f3okp@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <20170519112703.voajtn4t7uy6nwa3@pd.tnic>
 <7c522f65-c5c8-9362-e1eb-d0765e3ea6c9@amd.com>
 <20170530145459.tyuy6veqxnrqkhgw@pd.tnic>
 <115ca39d-6ae7-f603-a415-ead7c4e8193d@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <115ca39d-6ae7-f603-a415-ead7c4e8193d@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 30, 2017 at 10:37:03AM -0500, Tom Lendacky wrote:
> I can define the command line option and the "on" and "off" values as
> character buffers in the function and initialize them on a per character
> basis (using a static string causes the same issues as referencing a
> string constant), i.e.:
> 
> char cmdline_arg[] = {'m', 'e', 'm', '_', 'e', 'n', 'c', 'r', 'y', 'p', 't', '\0'};
> char cmdline_off[] = {'o', 'f', 'f', '\0'};
> char cmdline_on[] = {'o', 'n', '\0'};
> 
> It doesn't look the greatest, but it works and removes the need for the
> rip-relative addressing.

Well, I'm not thrilled about this one either. It's like being between a
rock and a hard place. :-\

On the one hand, we need the encryption mask before we do the fixups and
OTOH we need to do the fixups in order to access the strings properly.
Yuck.

Well, the only thing I can think of right now is maybe define
"mem_encrypt=" at the end of head_64.S and pass it in from asm to
sme_enable() and then do the "on"/"off" comparsion with local char
buffers. That could make it less ugly...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
