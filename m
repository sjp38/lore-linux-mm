Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01CBE6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:36:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z55so5428521wrz.2
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:36:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor191755wrc.83.2017.10.20.01.36.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 01:36:45 -0700 (PDT)
Date: Fri, 20 Oct 2017 10:36:42 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv3, RFC] x86/boot/compressed/64: Handle 5-level paging
 boot if kernel is above 4G
Message-ID: <20171020083641.vfzxklj6cyxcyaqs@gmail.com>
References: <20171016145209.60233-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171016145209.60233-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> [
>   The patch is based on my boot-time switching patchset and would not apply
>   directly to current upstream, but I would appreciate early feedback.
> ]
> 
> This patch addresses shortcoming in current boot process on machines
> that supports 5-level paging.
> 
> If bootloader enables 64-bit mode with 4-level paging, we need to
> switch over to 5-level paging. The switching requires disabling paging.
> It works fine if kernel itself is loaded below 4G.
> 
> If bootloader put the kernel above 4G (not sure if anybody does this),
> we would loose control as soon as paging is disabled as code becomes
> unreachable.
> 
> This patch implements trampoline in lower memory to handle this
> situation.
> 
> Apart from trampoline itself we also need place to store top level page
> table in lower memory as we don't have a way to load 64-bit value into
> CR3 from 32-bit mode. We only really need 8-bytes there as we only use
> the very first entry of the page table. but we allocate whole page
> anyway. We cannot have the code in the same because, there's hazard that
> a CPU would read page table speculatively and get confused seeing
> garbage.
> 
> We only need the memory for very short time, until main kernel image
> setup its own page tables.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S   | 83 ++++++++++++++++++++++--------------
>  arch/x86/boot/compressed/pagetable.c | 45 +++++++++++++++++++
>  arch/x86/boot/compressed/pagetable.h | 16 +++++++
>  3 files changed, 111 insertions(+), 33 deletions(-)
>  create mode 100644 arch/x86/boot/compressed/pagetable.h

Yeah, things like this is what I'd like to see, but could we please structure it a 
bit differently. Splitting it up more is very important, as 100+ lines difficult 
commits are difficult to debug after the fact. I'd suggest the following split-up:

 patch 1: introduce place_trampoline(), call it from the assembly - but don't do anything
 patch 2: move as much existing assembly code to C code in place_trampoline() as possible
 patch 3: modify remaining assembly code for dynamic 5-level pagetable support
 patch 4: modify place_trampoline() for dynamic 5-level pagetable support

Also, if you can think of more boot code in that file to move to C reasonably, 
please do it, even if it's unrelated to 5-level paging at the moment. The more 
boot assembly code you manage to move to C, the better x86 maintainers will like 
your patch-set. We are easy to corrupt with such patches! :-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
