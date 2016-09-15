Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF906B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 05:57:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l68so34816702wml.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 02:57:15 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id e4si693931wjc.142.2016.09.15.02.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 02:57:11 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id b187so88072542wme.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 02:57:11 -0700 (PDT)
Date: Thu, 15 Sep 2016 10:57:09 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v2 11/20] mm: Access BOOT related data in the clear
Message-ID: <20160915095709.GB16797@codeblueprint.co.uk>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net>
 <CALCETrUk2kRSzKfwhio6KV3iuYaSV2uxybd-e95kK3vY=yTSfg@mail.gmail.com>
 <e30ddb53-df6c-28ee-54fe-f3e52e515acb@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e30ddb53-df6c-28ee-54fe-f3e52e515acb@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andy Lutomirski <luto@amacapital.net>, kasan-dev <kasan-dev@googlegroups.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, iommu@lists.linux-foundation.org, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, kvm list <kvm@vger.kernel.org>, Dave Young <dyoung@redhat.com>

On Wed, 14 Sep, at 09:20:44AM, Tom Lendacky wrote:
> On 09/12/2016 11:55 AM, Andy Lutomirski wrote:
> > On Aug 22, 2016 6:53 PM, "Tom Lendacky" <thomas.lendacky@amd.com> wrote:
> >>
> >> BOOT data (such as EFI related data) is not encyrpted when the system is
> >> booted and needs to be accessed as non-encrypted.  Add support to the
> >> early_memremap API to identify the type of data being accessed so that
> >> the proper encryption attribute can be applied.  Currently, two types
> >> of data are defined, KERNEL_DATA and BOOT_DATA.
> > 
> > What happens when you memremap boot services data outside of early
> > boot?  Matt just added code that does this.
> > 
> > IMO this API is not so great.  It scatters a specialized consideration
> > all over the place.  Could early_memremap not look up the PA to figure
> > out what to do?
> 
> Yes, I could see if the PA falls outside of the kernel usable area and,
> if so, remove the memory encryption attribute from the mapping (for both
> early_memremap and memremap).
> 
> Let me look into that, I would prefer something along that line over
> this change.

So, the last time we talked about using the address to figure out
whether to encrypt/decrypt you said,

 "I looked into this and this would be a large change also to parse
  tables and build lists."

Has something changed that makes this approach easier?

And again, you need to be careful with the EFI kexec code paths, since
you've got a mixture of boot and kernel data being passed. In
particular the EFI memory map is allocated by the firmware on first
boot (BOOT_DATA) but by the kernel on kexec (KERNEL_DATA).

That's one of the reasons I suggested requiring the caller to decide
on BOOT_DATA vs KERNEL_DATA - when you start looking at kexec the
distinction isn't easily made.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
