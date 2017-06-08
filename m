Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56D586B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 02:06:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s3so7344753oia.4
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 23:06:05 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s142si1542634oie.116.2017.06.07.23.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 23:06:04 -0700 (PDT)
Received: from mail-vk0-f44.google.com (mail-vk0-f44.google.com [209.85.213.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ACB9223A02
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:06:03 +0000 (UTC)
Received: by mail-vk0-f44.google.com with SMTP id g66so13184470vki.1
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 23:06:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net> <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 7 Jun 2017 23:05:42 -0700
Message-ID: <CALCETrVVhMf=zkiDNn_-hKDZLGXKFiwxuWkPmD5RJgHa5VUMiQ@mail.gmail.com>
Subject: Re: [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use __va() against
 just the physical address in cr3
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, kexec@lists.infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 7, 2017 at 12:14 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
> The cr3 register entry can contain the SME encryption bit that indicates
> the PGD is encrypted.  The encryption bit should not be used when creating
> a virtual address for the PGD table.
>
> Create a new function, read_cr3_pa(), that will extract the physical
> address from the cr3 register. This function is then used where a virtual
> address of the PGD needs to be created/used from the cr3 register.

This is going to conflict with:

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=x86/pcid&id=555c81e5d01a62b629ec426a2f50d27e2127c1df

We're both encountering the fact that CR3 munges the page table PA
with some other stuff, and some readers want to see the actual CR3
value and other readers just want the PA.  The thing I prefer about my
patch is that I get rid of read_cr3() entirely, forcing the patch to
update every single reader, making review and conflict resolution much
safer.

I'd be willing to send a patch tomorrow that just does the split into
__read_cr3() and read_cr3_pa() (I like your name better) and then we
can both base on top of it.  Would that make sense?

Also:

> +static inline unsigned long read_cr3_pa(void)
> +{
> +       return (read_cr3() & PHYSICAL_PAGE_MASK);
> +}

Is there any guarantee that the magic encryption bit is masked out in
PHYSICAL_PAGE_MASK?  The docs make it sound like it could be any bit.
(But if it's one of the low 12 bits, that would be quite confusing.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
