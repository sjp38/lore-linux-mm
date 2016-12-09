Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E41346B0267
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:01:34 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so2428402wms.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:01:34 -0800 (PST)
Received: from mail-wj0-x241.google.com (mail-wj0-x241.google.com. [2a00:1450:400c:c01::241])
        by mx.google.com with ESMTPS id k8si32364429wjv.25.2016.12.08.21.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 21:01:33 -0800 (PST)
Received: by mail-wj0-x241.google.com with SMTP id he10so736150wjc.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:01:33 -0800 (PST)
Date: Fri, 9 Dec 2016 06:01:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
Message-ID: <20161209050130.GC2595@gmail.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> x86-64 is currently limited to 256 TiB of virtual address space and 64 TiB
> of physical address space. We are already bumping into this limit: some
> vendors offers servers with 64 TiB of memory today.
> 
> To overcome the limitation upcoming hardware will introduce support for
> 5-level paging[1]. It is a straight-forward extension of the current page
> table structure adding one more layer of translation.
> 
> It bumps the limits to 128 PiB of virtual address space and 4 PiB of
> physical address space. This "ought to be enough for anybody" A(C).
> 
> This patchset is still very early. There are a number of things missing
> that we have to do before asking anyone to merge it (listed below).
> It would be great if folks can start testing applications now (in QEMU) to
> look for breakage.
> Any early comments on the design or the patches would be appreciated as
> well.
> 
> More details on the design and whata??s left to implement are below.

The patches don't look too painful, so no big complaints from me - kudos!

> There is still work to do:
> 
>   - Boot-time switch between 4- and 5-level paging.
> 
>     We assume that distributions will be keen to avoid returning to the
>     i386 days where we shipped one kernel binary for each page table
>     layout.

Absolutely.

>     As page table format is the same for 4- and 5-level paging it should
>     be possible to have single kernel binary and switch between them at
>     boot-time without too much hassle.
> 
>     For now I only implemented compile-time switch.
> 
>     I hoped to bring this feature with separate patchset once basic
>     enabling is in upstream.
> 
>     Is it okay?

LGTM, but we would eventually want to convert this kind of crazy open coding:

        pgd_t *pgd, *pgd_ref;
        p4d_t *p4d, *p4d_ref;
        pud_t *pud, *pud_ref;
        pmd_t *pmd, *pmd_ref;
        pte_t *pte, *pte_ref;

To something saner that iterates and navigates the page table hierarchy in an 
extensible fashion. That would also make it (much) easier to make the paging depth 
boot time switchable.

Somehow I'm quite certain we'll see requests for more than 4 PiB memory in our 
lifetimes.

In a decade or two once global warming really gets going, especially after Trump & 
Republicans & Old Energy implement their billionaire welfare policies to mine, 
sell and burn even more coal & oil without paying for the damage caused, the U.S. 
meteorology clusters tracking Category 6 hurricanes in the Atlantic (capable of 1+ 
trillion dollars damage) in near real time at 1 meter resolution will have to run 
on something capable, right?

>   - Handle opt-in wider address space for userspace.
> 
>     Not all userspace is ready to handle addresses wider than current
>     47-bits. At least some JIT compiler make use of upper bits to encode
>     their info.
> 
>     We need to have an interface to opt-in wider addresses from userspace
>     to avoid regressions.
> 
>     For now, I've included testing-only patch which bumps TASK_SIZE to
>     56-bits. This can be handy for testing to see what breaks if we max-out
>     size of virtual address space.

So this is just a detail - but it sounds a bit limiting to me to provide an 'opt 
in' flag for something that will work just fine on the vast majority of 64-bit 
software.

Please make this an opt out compatibility flag instead: similar to how we handle 
address space layout limitations/quirks ABI details, such as ADDR_LIMIT_32BIT, 
ADDR_LIMIT_3GB, ADDR_COMPAT_LAYOUT, READ_IMPLIES_EXEC, etc.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
