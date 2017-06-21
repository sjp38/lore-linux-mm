Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC3096B03FB
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:53:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so175949315pgn.4
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:53:04 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0070.outbound.protection.outlook.com. [104.47.41.70])
        by mx.google.com with ESMTPS id d17si14553009plj.367.2017.06.21.06.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:53:03 -0700 (PDT)
Subject: Re: [PATCH v7 07/36] x86/mm: Don't use phys_to_virt in ioremap() if
 SME is active
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185104.18967.7867.stgit@tlendack-t1.amdoffice.net>
 <alpine.DEB.2.20.1706202251110.2157@nanos>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <c1072435-e3ad-21ea-b36f-505ff80ed599@amd.com>
Date: Wed, 21 Jun 2017 08:52:53 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706202251110.2157@nanos>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Paolo Bonzini <pbonzini@redhat.com>

On 6/20/2017 3:55 PM, Thomas Gleixner wrote:
> On Fri, 16 Jun 2017, Tom Lendacky wrote:
> 
>> Currently there is a check if the address being mapped is in the ISA
>> range (is_ISA_range()), and if it is then phys_to_virt() is used to
>> perform the mapping.  When SME is active, however, this will result
>> in the mapping having the encryption bit set when it is expected that
>> an ioremap() should not have the encryption bit set. So only use the
>> phys_to_virt() function if SME is not active
> 
> This does not make sense to me. What the heck has phys_to_virt() to do with
> the encryption bit. Especially why would the encryption bit be set on that
> mapping in the first place?

The default is that all entries that get added to the pagetables have
the encryption bit set unless specifically overridden.  Any __va() or
phys_to_virt() calls will result in a pagetable mapping that has the
encryption bit set.  For ioremap, the PAGE_KERNEL_IO protection is used
which will not/does not have the encryption bit set.

> 
> I'm probably missing something, but this want's some coherent explanation
> understandable by mere mortals both in the changelog and the code comment.

I'll add some additional info to the changelog and code.

Thanks,
Tom

> 
> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
