Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B960A6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:33:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n18so4053048wra.11
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:33:32 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id i62si430018wmd.155.2017.06.15.08.33.31
        for <linux-mm@kvack.org>;
        Thu, 15 Jun 2017 08:33:31 -0700 (PDT)
Date: Thu, 15 Jun 2017 17:33:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
Message-ID: <20170615153322.nwylo3dzn4fdx6n6@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
 <20170614174208.p2yr5exs4b6pjxhf@pd.tnic>
 <0611d01a-19f8-d6ae-2682-932789855518@amd.com>
 <20170615094111.wga334kg2bhxqib3@pd.tnic>
 <921153f5-1528-31d8-b815-f0419e819aeb@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <921153f5-1528-31d8-b815-f0419e819aeb@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Jun 15, 2017 at 09:59:45AM -0500, Tom Lendacky wrote:
> Actually the detection routine, amd_iommu_detect(), is part of the
> IOMMU_INIT_FINISH macro support which is called early through mm_init()
> from start_kernel() and that routine is called before init_amd().

Ah, we do that there too:

	for (p = __iommu_table; p < __iommu_table_end; p++) {

Can't say that that code with the special section and whatnot is
obvious. :-\

Oh, well, early_init_amd() then. That is called in
start_kernel->setup_arch->early_cpu_init and thus before mm_init().

> > If so, it did work fine until now, without the volatile. Why is it
> > needed now, all of a sudden?
> 
> If you run checkpatch against the whole amd_iommu.c file you'll see that

I'm, of course, not talking about the signature change: I'm *actually*
questioning the need to make this argument volatile, all of a sudden.

If there's a need, please explain why. It worked fine until now. If it
didn't, we would've seen it.

If it is a bug, then it needs a proper explanation, a *separate* patch
and so on. But not like now, a drive-by change in an IOMMU enablement
patch.

If it is wrong, then wait_on_sem() needs to be fixed too. AFAICT,
wait_on_sem() gets called in both cases with interrupts disabled, while
holding a lock so I'd like to pls know why, even in that case, does this
variable need to be volatile.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
