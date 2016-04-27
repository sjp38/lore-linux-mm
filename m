Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 915166B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:40:00 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id fn8so104224110igb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:40:00 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id g132si1264341oib.62.2016.04.27.07.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 07:40:00 -0700 (PDT)
Received: by mail-ob0-x22a.google.com with SMTP id n10so20820531obb.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:39:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 27 Apr 2016 07:39:24 -0700
Message-ID: <CALCETrUdrMAmE6Vgj6_PALdmRZVVKa3QDwJtO=YDTOQdox=rhQ@mail.gmail.com>
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 26, 2016 at 3:55 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
> This RFC patch series provides support for AMD's new Secure Memory
> Encryption (SME) feature.
>
> SME can be used to mark individual pages of memory as encrypted through the
> page tables. A page of memory that is marked encrypted will be automatically
> decrypted when read from DRAM and will be automatically encrypted when
> written to DRAM. Details on SME can found in the links below.

Having read through the docs briefly, some questions:

1. How does the crypto work?  Is it straight AES-ECB?  Is it a
tweakable mode?  If so, what does into the tweak?  For example, if I
swap the ciphertext of two pages, does the plaintext of the pages get
swapped?  If not, why not?

2. In SEV mode, how does the hypervisor relocate a physical backing
page?  Does it simple move it and update the 2nd-level page tables?
If so, is the result of decryption guaranteed to be garbage if it
relocates a page and re-inserts it at the wrong guest physical
address?

3. In SEV mode, does anything prevent the hypervisor from resuming a
guest with the wrong ASID, or is this all relying on the resulting
corruption of the guest code and data to cause a crash?

4. As I understand it, the caches are all unencrypted, and they're
tagged with the physical address, *including* the SME bit (bit 47).
In SEV mode, are they also tagged with the ASID?  I.e. if I have a
page in cache for ASID 1 and I try to read it with ASID 2, will I get
a fresh copy decrypted with ASID 2's key?  If so, will the old ASID 1
copy be evicted, or will it stay in cache and be non-coherent?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
