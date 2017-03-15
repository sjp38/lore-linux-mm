Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E349C6B038D
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 13:01:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w37so18944225wrc.2
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 10:01:19 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id f3si7759657wme.93.2017.03.18.10.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Mar 2017 10:01:18 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id l37so12993093wrc.3
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 10:01:18 -0700 (PDT)
Date: Wed, 15 Mar 2017 17:51:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Message-ID: <20170315145126.4xgvhuavtf5icjdc@node.shutemov.name>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
 <20170314074729.GA23151@gmail.com>
 <CA+55aFzALboaXe5TWv8=3QZBPJCVAVBmfxTjQEi-aAnHKYAuPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzALboaXe5TWv8=3QZBPJCVAVBmfxTjQEi-aAnHKYAuPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 14, 2017 at 10:48:51AM -0700, Linus Torvalds wrote:
> On Tue, Mar 14, 2017 at 12:47 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > I've also applied the GUP patch, with the assumption that you'll address Linus's
> > request to switch x86 over to the generic version.
> 
> Note that switching over to the generic version is somewhat fraught
> with subtle issues:
> 
>  (a) we need to make sure that x86 actually matches the required
> semantics for the generic GUP.
> 
>  (b) we need to make sure the atomicity of the page table reads is ok.
> 
>  (c) need to verify the maximum VM address properly
> 
> I _think_ (a) is ok. The code (and the config option name) talks about
> freeing page tables using RCU, but in fact I don't think it relies on
> it, and it's sufficient that it disables interrupts and that that will
> block any IPI's.
> 
> In contrast, I think (b) needs real work to make sure it's ok on
> 32-bit PAE with 64-bit pte entries. The generic code currently just
> does READ_ONCE(), while the x86 code does gup_get_pte().

+ Andrea.

Looking on gup_get_pte() makes me thinkg, why don't we need the same
approach for pmd level (pud is not relevant for PAE)?

Looks like a bug to me.

We have pmd_read_atomic() to address the issue in other places. The helper
doesn't match required for GUP_fast() semantics, but we clearly need to
address the issue.

pgd deference doesn't look good too on PAE. Or am I missing something?

Heck, we don't even have READ_ONCE() on x86 for page table entry
dereference. Looks like a bug waiting to explode. And not only on PAE.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
