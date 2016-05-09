Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id C69636B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 11:13:47 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id r185so300689404ywf.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 08:13:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si18960034qge.102.2016.05.09.08.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 08:13:46 -0700 (PDT)
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <CALCETrUdrMAmE6Vgj6_PALdmRZVVKa3QDwJtO=YDTOQdox=rhQ@mail.gmail.com>
 <57211CAB.9040902@amd.com>
 <CALCETrWAP5hxQeVSwNx-XkO53-X3bX0LasjOuHxeRWCTob7JAA@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <5730A91E.6040601@redhat.com>
Date: Mon, 9 May 2016 17:13:34 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrWAP5hxQeVSwNx-XkO53-X3bX0LasjOuHxeRWCTob7JAA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>



On 02/05/2016 20:31, Andy Lutomirski wrote:
> And did the SEV implementation remember to encrypt the guest register
> state?  Because, if not, everything of importance will leak out
> through the VMCB and/or GPRs.

No, it doesn't.  And SEV is very limited unless you paravirtualize
everything.

For example, the hypervisor needs to read some instruction bytes from
memory, and instruction bytes are always encrypted (15.34.5 in the APM).
 So you're pretty much restricted to IN/OUT operations (not even
INS/OUTS) on emulated (non-assigned) devices, paravirtualized MSRs, and
hypercalls.  These are the only operations that connect the guest and
the hypervisor, where the vmexit doesn't have the need to e.g. walk
guest page tables (also always encrypted).  It possibly can be made to
work once the guest boots, and a modern UEFI firmware probably can cope
with it too just like a kernel can, but you need to ensure that your
hardware has no memory BARs for example.  And I/O port space is not very
abundant.

Even in order to emulate I/O ports or RDMSR/WRMSR or process hypercalls,
the hypervisor needs to read the GPRs.  The VMCB doesn't store guest
GPRs, not even on SEV-enabled processors.  Accordingly, the hypervisor
has access to the guest GPRs on every exit.

In general, SEV provides mitigation only.  Even if the hypervisor cannot
write known plaintext directly to memory, an accomplice virtual machine
can e.g. use the network to spray the attacked VM's memory.  At least
it's not as easy as "disable NX under the guest's feet and redirect RIP"
(pte.nx is reserved if efer.nxe=0, all you get is a #PF).  But the
hypervisor can still disable SMEP and SMAP, it can use hardware
breakpoints to leak information through the registers, and it can do all
the other attacks you mentioned.  If AMD had rdrand/rdseed, it could
replace the output with not so random values, and so on.

It's surely better than nothing, but "encryption that really is nothing
more than mitigation" is pretty weird.  I'm waiting for cloud vendors to
sell this as the best thing since sliced bread, when in reality it's
just mitigation.  I wonder how wise it is to merge SEV in its current
state---and since security is not my specialty I am definitely looking
for advice on this.

Paolo

ps: I'm now reminded of this patch:

    commit dab429a798a8ab3377136e09dda55ea75a41648d
    Author: David Kaplan <David.Kaplan@amd.com>
    Date:   Mon Mar 2 13:43:37 2015 -0600

    kvm: svm: make wbinvd faster

    No need to re-decode WBINVD since we know what it is from the
    intercept.

    Signed-off-by: David Kaplan <David.Kaplan@amd.com>
    [extracted from larger unlrelated patch, forward ported,
     tested,style cleanup]
    Signed-off-by: Joel Schopp <joel.schopp@amd.com>
    Reviewed-by: Radim KrA?mA!A? <rkrcmar@redhat.com>
    Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

and I wonder if the larger unlrelated patch had anything to do with SEV!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
