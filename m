Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 851326B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 01:30:52 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k104so3450718wrc.19
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 22:30:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m128sor1349721wmm.76.2017.12.06.22.30.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 22:30:51 -0800 (PST)
Date: Thu, 7 Dec 2017 07:30:48 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 3/4] x86/boot/compressed/64: Introduce
 place_trampoline()
Message-ID: <20171207063048.w46rrq2euzhtym3j@gmail.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
 <20171205135942.24634-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205135942.24634-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> If a bootloader enables 64-bit mode with 4-level paging, we might need to
> switch over to 5-level paging. The switching requires disabling paging.
> It works fine if kernel itself is loaded below 4G.

s/The switching requires disabling paging.
 /The switching requires the disabling of paging.

> But if the bootloader put the kernel above 4G (not sure if anybody does
> this), we would loose control as soon as paging is disabled as code
> becomes unreachable.

Yeah, so instead of the double 'as' which is syntactically right but a bit 
confusing to read, how about something like:

  But if the bootloader put the kernel above 4G (not sure if anybody does
  this), we would loose control as soon as paging is disabled, because the
  code becomes unreachable to the CPU.

?

> To handle the situation, we need a trampoline in lower memory that would
> take care about switching on 5-level paging.

s/would take care about
 /would take care of

> Apart from the trampoline code itself we also need a place to store top
> level page table in lower memory as we don't have a way to load 64-bit
> value into CR3 from 32-bit mode. We only really need 8-bytes there as we
> only use the very first entry of the page table. But we allocate whole
> page anyway.

s/64-bit value
 /64-bit values

s/into CR3 from 32-bit mode
 /into CR3 in 32-bit mode

s/We only really need 8-bytes there
 /We only really need 8 bytes there

s/But we allocate whole page anyway.
 /But we allocate a whole page anyway.

> We cannot have code in the same page as page table because there's
> hazard that a CPU would read page table speculatively and get confused
> seeing garbage.

How about:

  We cannot have the code in the same page as the page table because there's
  a risk that a CPU would read the page table speculatively and get confused
  by seeing garbage. It's never a good idea to have junk in PTE entries
  visible to the CPU.

? (Assuming it's the PTEs that are stored in that page.)

> We also need a small stack in the trampoline to re-enable long mode via
> long return. But stack and code can share the page just fine.

BTW., I'm not sure this is necessarily a good idea: it means writable+executable 
memory, which we generally try to avoid. How complicated would it be to have them 
separate?

> This patch introduces paging_prepare() that checks if we need to enable
> 5-level paging and then finds a right spot in lower memory for the
> trampoline. Then it copies trampoline code there and setups new top
> level page table for 5-level paging.

s/Then it copies trampoline code there
 /Then it copies the trampoline code there

s/and setups new top level page table
 /and sets up the new top level page table

> At this point we do all the preparation, but not yet use trampoline.
> It will be done in the following patch.

s/but not yet use trampoline
 /but don't use trampoline yet

> The trampoline will be used even on 4-level paging machine. This way we
> will get better coverage and keep trampoline code in shape.

s/even on 4-level paging machine
 /even on 4-level paging machines

s/better coverage
 /better test coverage

s/and keep trampoline code in shape
 /and keep the trampoline code in shape

> +	/*
> +	 * paging_prepare() would setup trampoline and check if we need to
> +	 * enable 5-level paging.

s/would setup trampoline
 /would set up the trampoline

>  	 *
> +	 * Address of the trampoline is returned in RAX. The bit 0 is used
> +	 * to encode if we need to enabled 5-level paging.
>  	 *
> +	 * RSI holds real mode data and need to be preserved across
> +	 * a function call.
>  	 */


s/The bit 0
 /Bit 0

s/if we need to enabled 5-level paging
 /if we need to enable 5-level paging

> +	/* Save trampoline address in RCX */

s/Save trampoline address
 /Save the trampoline address

>  	/* Setup data and stack segments */

While at it:

s/Setup
 /Set up

> +	/* Check if la57 is desired and supported */

Please capitalize LA57 consistently!

> +	/*
> +	 * Find a suitable spot for the trampoline.
> +	 * Code is based on reserve_bios_regions().

s/Code is based on
 /This code is based on

> +	/*
> +	 * For 5-level paging, setup current CR3 as the first and
> +	 * the only entry in a new top level page table.

s/setup
 /set up

> +	 *
> +	 * For 4-level paging, trampoline wouldn't touch CR3.
> +	 * KASLR relies on CR3 pointing to _pgtable.
> +	 * See initialize_identity_maps.

Please refer to functions with '...()'

> +	 */
> +	if (l5_required) {
> +		trampoline[TRAMPOLINE_32BIT_PGTABLE_OFF] =
> +			__native_read_cr3() + _PAGE_TABLE_NOENC;

Please don't break lines nonsensically ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
