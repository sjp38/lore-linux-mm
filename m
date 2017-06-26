Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 598436B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:46:10 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so29064238wrc.8
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:46:10 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id a3si73447wmi.183.2017.06.26.08.46.08
        for <linux-mm@kvack.org>;
        Mon, 26 Jun 2017 08:46:08 -0700 (PDT)
Date: Mon, 26 Jun 2017 17:45:43 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 34/36] x86/mm: Add support to encrypt the kernel
 in-place
Message-ID: <20170626154543.fsuxfhxidytgo2ia@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185619.18967.38945.stgit@tlendack-t1.amdoffice.net>
 <20170623100013.upd4or6esjvulmvg@pd.tnic>
 <af9a50f7-17ea-a840-6456-b6479e5d7e82@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <af9a50f7-17ea-a840-6456-b6479e5d7e82@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 23, 2017 at 12:44:46PM -0500, Tom Lendacky wrote:
> Normally the __p4d() macro would be used and that would be ok whether
> CONFIG_X86_5LEVEL is defined or not. But since __p4d() is part of the
> paravirt ops path I have to use native_make_p4d().

So __p4d is in !CONFIG_PARAVIRT path.

Regardless, we use the native_* variants in generic code to mean, not
paravirt. Just define it in a separate patch like the rest of the p4*
machinery and use it in your code. Sooner or later someone else will
need it.

> True, 5-level will only be turned on for specific hardware which is why
> I originally had this as only 4-level pagetables. But in a comment from
> you back on the v5 version you said it needed to support 5-level. I
> guess we should have discussed this more,

AFAIR, I said something along the lines of "what about 5-level page
tables?" and whether we care.

> but I also thought that should our hardware ever support 5-level
> paging in the future then this would be good to go.

There it is :-)

> The macros work great if you are not running identity mapped. You could
> use p*d_offset() to move easily through the tables, but those functions
> use __va() to generate table virtual addresses. I've seen where
> boot/compressed/pagetable.c #defines __va() to work with identity mapped
> pages but that would only work if I create a separate file just for this
> function.
> 
> Given when this occurs it's very similar to what __startup_64() does in
> regards to the IS_ENABLED(CONFIG_X86_5LEVEL) checks.

Ok.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
