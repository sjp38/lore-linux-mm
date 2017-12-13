Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1436B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:54:41 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n13so1156190wmc.3
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:54:41 -0800 (PST)
Received: from dan.rpsys.net (5751f4a1.skybroadband.com. [87.81.244.161])
        by mx.google.com with ESMTPS id e21si1501829wra.51.2017.12.13.04.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 04:54:39 -0800 (PST)
Message-ID: <1513169674.19417.188.camel@linuxfoundation.org>
Subject: Re: [PATCH 1/2] KVM: x86: fix APIC page invalidation
From: Richard Purdie <richard.purdie@linuxfoundation.org>
Date: Wed, 13 Dec 2017 12:54:34 +0000
In-Reply-To: <20171130180546.4331-1-rkrcmar@redhat.com>
References: <20171130161933.GB1606@flask>
	 <20171130180546.4331-1-rkrcmar@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Fabian =?ISO-8859-1?Q?Gr=FCnbichler?= <f.gruenbichler@proxmox.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, stable <stable@kernel.org>

On Thu, 2017-11-30 at 19:05 +0100, Radim KrA?mA!A? wrote:
> Implementation of the unpinned APIC page didn't update the VMCS
> address
> cache when invalidation was done through range mmu notifiers.
> This became a problem when the page notifier was removed.
> 
> Re-introduce the arch-specific helper and call it from
> ...range_start.
> 
> Fixes: 38b9917350cb ("kvm: vmx: Implement set_apic_access_page_addr")
> Fixes: 369ea8242c0f ("mm/rmap: update to new mmu_notifier semantic
> v2")
> Signed-off-by: Radim KrA?mA!A? <rkrcmar@redhat.com>
> ---
> A arch/x86/include/asm/kvm_host.h |A A 3 +++
> A arch/x86/kvm/x86.cA A A A A A A A A A A A A A | 14 ++++++++++++++
> A virt/kvm/kvm_main.cA A A A A A A A A A A A A |A A 8 ++++++++
> A 3 files changed, 25 insertions(+)

Thanks for this. I've been chasing APIC related hangs booting images
with qemu-system-x86_64 on 4.13 and 4.14 host kernels where the guest
doesn't have x2apic enabled.

I can confirm this fixes issues the Yocto Project automated testing
infrastructure was seeing.

I'd like to add support for backporting this in stable.

Tested-by: Richard Purdie <richard.purdie@linuxfoundation.org>

Cheers,

Richard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
