Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6992F6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 14:31:44 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d62so339391iof.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:31:44 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id v9si12117193ota.123.2016.05.02.11.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 11:31:43 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id k142so201475763oib.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:31:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57211CAB.9040902@amd.com>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <CALCETrUdrMAmE6Vgj6_PALdmRZVVKa3QDwJtO=YDTOQdox=rhQ@mail.gmail.com> <57211CAB.9040902@amd.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 2 May 2016 11:31:23 -0700
Message-ID: <CALCETrWAP5hxQeVSwNx-XkO53-X3bX0LasjOuHxeRWCTob7JAA@mail.gmail.com>
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Apr 27, 2016 at 1:10 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
> On 04/27/2016 09:39 AM, Andy Lutomirski wrote:
>> On Tue, Apr 26, 2016 at 3:55 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>>> This RFC patch series provides support for AMD's new Secure Memory
>>> Encryption (SME) feature.
>>>
>>> SME can be used to mark individual pages of memory as encrypted through the
>>> page tables. A page of memory that is marked encrypted will be automatically
>>> decrypted when read from DRAM and will be automatically encrypted when
>>> written to DRAM. Details on SME can found in the links below.
>>
>> Having read through the docs briefly, some questions:
>>
>> 1. How does the crypto work?  Is it straight AES-ECB?  Is it a
>> tweakable mode?  If so, what does into the tweak?  For example, if I
>> swap the ciphertext of two pages, does the plaintext of the pages get
>> swapped?  If not, why not?
>
> The AES crypto uses a tweak such that two identical plaintexts at
> different locations will have different ciphertext. So swapping the
> ciphertext of two pages will not result in the plaintext being swapped.

OK, makes sense.

>
>>
>> 2. In SEV mode, how does the hypervisor relocate a physical backing
>> page?  Does it simple move it and update the 2nd-level page tables?
>> If so, is the result of decryption guaranteed to be garbage if it
>> relocates a page and re-inserts it at the wrong guest physical
>> address?
>
> For SEV mode, relocating a physical backing page takes extra steps.
> There are APIs that are used to have the AMD Secure Processor create a
> transportable encrypted page that can then be moved to a new location
> in memory. After moving it to the new location the APIs are used to
> haves the AMD Secure Processor re-encrypt the page for use with the
> guests SEV key. Based on #1 above, just moving a page without invoking
> the necessary APIs will result in the decryption returning garbage.
>
>>
>> 3. In SEV mode, does anything prevent the hypervisor from resuming a
>> guest with the wrong ASID, or is this all relying on the resulting
>> corruption of the guest code and data to cause a crash?
>
> There is nothing that prevents resuming a guest with the wrong ASID.
> This relies on the resulting corruption of the guest code/data to
> cause a crash.

This all seems somewhat useful, but I almost guarantee that if there
is ever anything economically important (or important for national
security reasons, or simply something that sounds fun for an
enterprising kid to break) that it *will* be broken in many creative
ways.

Someone will break it by replaying old data through the VM, either to
confuse control flow or to use some part of the VM code as an oracle
with which to attack another part.

Someone else will break it by installing a #UD / #PF handler and using
the resulting exceptions as an oracle.

A third clever person will break it by carefully constructing a
scenario in which randomizing 16 bytes of data has a high probability
of letting then pwn your system.  (For example, what if the secured VM
creates an RSA key and you can carefully interrupt it right after
generating p and q.  Replace 16 bytes from the middle of both p and q
(32 bytes total) with random garbage.  With reasonably high
probability, the resulting p and q will no longer be prime.)

Depending on how strong your ASID protection is, a fourth clever
person will break it by replacing a bunch of the VM out from under the
target while leaving the sensitive data in place and then will use
some existing exploit or design issue to gain code execution in the
modified VM.

Also, I really hope that your tweakable cipher mode is at least CCA2
secure, because attackers can absolutely hit it with adaptive chosen
ciphertext attacks.  (Actually, attackers can alternate between
adaptive chosen ciphertext and adaptive chosen plaintext.)

And did the SEV implementation remember to encrypt the guest register
state?  Because, if not, everything of importance will leak out
through the VMCB and/or GPRs.

But I guess it's better than nothing.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
