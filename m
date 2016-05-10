Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDFB56B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 07:23:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so8495021lfq.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:23:40 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id dm2si2058716wjb.137.2016.05.10.04.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 04:23:39 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id e201so2143827wme.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:23:39 -0700 (PDT)
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <CALCETrUdrMAmE6Vgj6_PALdmRZVVKa3QDwJtO=YDTOQdox=rhQ@mail.gmail.com>
 <57211CAB.9040902@amd.com>
 <CALCETrWAP5hxQeVSwNx-XkO53-X3bX0LasjOuHxeRWCTob7JAA@mail.gmail.com>
 <5730A91E.6040601@redhat.com> <5730FC33.2060804@amd.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <5731C4B7.9000209@redhat.com>
Date: Tue, 10 May 2016 13:23:35 +0200
MIME-Version: 1.0
In-Reply-To: <5730FC33.2060804@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Andy Lutomirski <luto@amacapital.net>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>



On 09/05/2016 23:08, Tom Lendacky wrote:
> On 05/09/2016 10:13 AM, Paolo Bonzini wrote:
>>
>>
>> On 02/05/2016 20:31, Andy Lutomirski wrote:
>>> And did the SEV implementation remember to encrypt the guest register
>>> state?  Because, if not, everything of importance will leak out
>>> through the VMCB and/or GPRs.
>>
>> No, it doesn't.  And SEV is very limited unless you paravirtualize
>> everything.
>>
>> For example, the hypervisor needs to read some instruction bytes from
>> memory, and instruction bytes are always encrypted (15.34.5 in the APM).
>>  So you're pretty much restricted to IN/OUT operations (not even
>> INS/OUTS) on emulated (non-assigned) devices, paravirtualized MSRs, and
>> hypercalls.  These are the only operations that connect the guest and
>> the hypervisor, where the vmexit doesn't have the need to e.g. walk
>> guest page tables (also always encrypted).  It possibly can be made to
>> work once the guest boots, and a modern UEFI firmware probably can cope
>> with it too just like a kernel can, but you need to ensure that your
>> hardware has no memory BARs for example.  And I/O port space is not very
>> abundant.
> 
> The instruction bytes stored in the VMCB at offset 0xd0 for a data
> side #NPF are stored un-encrypted (which is not clearly documented in
> the APM). This allows for the hypervisor to perform MMIO on emulated
> devices. Because the hardware provides enough information on VMEXIT
> events, such as exit codes, decode assist, etc., the hypervisor has
> the information it needs to perform the operation

Ok, that helps.

>> In general, SEV provides mitigation only.  Even if the hypervisor cannot
>> write known plaintext directly to memory, an accomplice virtual machine
>> can e.g. use the network to spray the attacked VM's memory.  At least
> 
> Can you elaborate further on this? The accomplice VM will not have
> access to the encryption key of the target VM and cannot accomplish
> any spraying that the hypervisor itself cannot do.

It can send plaintext packets that will be stored encrypted in memory.
(Of course the hypervisor can do that too if it has access to the guest
network).  This was my first thought on attacking SEV, but luckily NX is
designed well.

> In this first generation of SEV, we are targeting a threat model very
> similar to the one used by SMEP and SMAP.

And that's great!  However, it is very different from "virtual machines
need not fully trust the hypervisor and administrator of their host
system" as said in the whitepaper.  SEV protects pretty well from
sibling VMs, but by design this generation of SEV leaks a lot of
information to an evil host---probably more than enough to mount a ROP
attack or to do evil stuff that Andy outlined.

My problem is that people will read AMD's whitepaper, not your message
on LKML, and may put more trust in SEV than (for now) they should.

Thanks,

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
