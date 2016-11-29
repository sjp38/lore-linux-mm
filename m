Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 438866B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:56:21 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so28522700wjc.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:56:21 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id u184si3930089wmb.168.2016.11.29.11.56.19
        for <linux-mm@kvack.org>;
        Tue, 29 Nov 2016 11:56:20 -0800 (PST)
Date: Tue, 29 Nov 2016 20:56:18 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 20/20] x86: Add support to make use of Secure
 Memory Encryption
Message-ID: <20161129195618.ewuiw5rdsu26yf7w@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
 <20161126204703.wlcd6cw7dxzvpxyc@pd.tnic>
 <4cffdd71-dcc6-35e9-2654-e39067a525a8@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4cffdd71-dcc6-35e9-2654-e39067a525a8@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Nov 29, 2016 at 12:48:17PM -0600, Tom Lendacky wrote:
> > One more thing: just like we're adding an =on switch, we'd need an =off
> > switch in case something's wrong with the SME code. IOW, if a user
> > supplies "mem_encrypt=off", we do not encrypt.
> 
> Well, we can document "off", but if the exact string "mem_encrypt=on"
> isn't specified on the command line then the encryption won't occur.

So you have this:

+       /*
+        * Fixups have not been to applied phys_base yet, so we must obtain
+        * the address to the SME command line option in the following way.
+        */
+       asm ("lea sme_cmdline_arg(%%rip), %0"
+            : "=r" (cmdline_arg)
+            : "p" (sme_cmdline_arg));
+       cmdline_ptr = bp->hdr.cmd_line_ptr | ((u64)bp->ext_cmd_line_ptr << 32);
+       if (cmdline_find_option_bool((char *)cmdline_ptr, cmdline_arg))
+               sme_me_mask = 1UL << (ebx & 0x3f);

If I parse this right, we will enable SME *only* if mem_encrypt=on is
explicitly supplied on the command line.

Which means, users will have to *know* about that cmdline switch first.
Which then means, we have to go and tell them. Do you see where I'm
going with this?

I know we talked about this already but I still think we should enable
it by default and people who don't want it will use the =off switch. We
can also do something like CONFIG_AMD_SME_ENABLED_BY_DEFAULT which we
can be selected during build for the different setups.

Hmmm.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
