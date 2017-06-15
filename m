Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF256B0313
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:41:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so2303053wrc.7
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 02:41:21 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id n65si53154wmd.152.2017.06.15.02.41.19
        for <linux-mm@kvack.org>;
        Thu, 15 Jun 2017 02:41:19 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:41:12 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
Message-ID: <20170615094111.wga334kg2bhxqib3@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
 <20170614174208.p2yr5exs4b6pjxhf@pd.tnic>
 <0611d01a-19f8-d6ae-2682-932789855518@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <0611d01a-19f8-d6ae-2682-932789855518@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 14, 2017 at 03:40:28PM -0500, Tom Lendacky wrote:
> I was trying to keep all the logic for it here in the SME related files
> rather than put it in the iommu code itself. But it is easy enough to
> move if you think it's worth it.

Yes please - the less needlessly global symbols, the better.

> > Also, you said in another mail on this subthread that c->microcode
> > is not yet set. Are you saying, that the iommu init gunk runs before
> > init_amd(), where we do set c->microcode?
> > 
> > If so, we can move the setting to early_init_amd() or so.
> 
> I'll look into that.

And I don't think c->microcode is not set by the time we init the iommu
because, AFAICT, we do the latter in pci_iommu_init() and that's a
rootfs_initcall() which happens later then the CPU init stuff.

> I'll look into simplifying the checks.

Something like this maybe?

	if (rev >= 0x1205)
		return true;

	if (rev <= 0x11ff && rev >= 0x1126)
		return true;

	return false;

> > WARNING: Use of volatile is usually wrong: see Documentation/process/volatile-considered-harmful.rst
> > #134: FILE: drivers/iommu/amd_iommu.c:866:
> > +static void build_completion_wait(struct iommu_cmd *cmd, volatile u64 *sem)
> > 
> 
> The semaphore area is written to by the device so the use of volatile is
> appropriate in this case.

Do you mean this is like the last exception case in that document above:

"
  - Pointers to data structures in coherent memory which might be modified
    by I/O devices can, sometimes, legitimately be volatile.  A ring buffer
    used by a network adapter, where that adapter changes pointers to
    indicate which descriptors have been processed, is an example of this
    type of situation."

?

If so, it did work fine until now, without the volatile. Why is it
needed now, all of a sudden?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
