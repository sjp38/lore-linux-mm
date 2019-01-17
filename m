Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 379248E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:47:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v12so5463126plp.16
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 22:47:08 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x1si836055pfn.111.2019.01.16.22.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 22:47:06 -0800 (PST)
Date: Thu, 17 Jan 2019 15:47:01 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 01/17] Fix
 "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
Message-Id: <20190117154701.78aa8e9d0130716e0d9ac026@kernel.org>
In-Reply-To: <20190117003259.23141-2-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-2-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>

On Wed, 16 Jan 2019 16:32:43 -0800
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> From: Nadav Amit <namit@vmware.com>
> 
> text_mutex is currently expected to be held before text_poke() is
> called, but we kgdb does not take the mutex, and instead *supposedly*
> ensures the lock is not taken and will not be acquired by any other core
> while text_poke() is running.
> 
> The reason for the "supposedly" comment is that it is not entirely clear
> that this would be the case if gdb_do_roundup is zero.
> 
> This patch creates two wrapper functions, text_poke() and
> text_poke_kgdb() which do or do not run the lockdep assertion
> respectively.
> 
> While we are at it, change the return code of text_poke() to something
> meaningful. One day, callers might actually respect it and the existing
> BUG_ON() when patching fails could be removed. For kgdb, the return
> value can actually be used.

Looks good to me.

Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>

Thank you,

> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Fixes: 9222f606506c ("x86/alternatives: Lockdep-enforce text_mutex in text_poke*()")
> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/include/asm/text-patching.h |  1 +
>  arch/x86/kernel/alternative.c        | 52 ++++++++++++++++++++--------
>  arch/x86/kernel/kgdb.c               | 11 +++---
>  3 files changed, 45 insertions(+), 19 deletions(-)
> 
> diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
> index e85ff65c43c3..f8fc8e86cf01 100644
> --- a/arch/x86/include/asm/text-patching.h
> +++ b/arch/x86/include/asm/text-patching.h
> @@ -35,6 +35,7 @@ extern void *text_poke_early(void *addr, const void *opcode, size_t len);
>   * inconsistent instruction while you patch.
>   */
>  extern void *text_poke(void *addr, const void *opcode, size_t len);
> +extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
>  extern int poke_int3_handler(struct pt_regs *regs);
>  extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
>  extern int after_bootmem;
> diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
> index ebeac487a20c..c6a3a10a2fd5 100644
> --- a/arch/x86/kernel/alternative.c
> +++ b/arch/x86/kernel/alternative.c
> @@ -678,18 +678,7 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
>  	return addr;
>  }
>  
> -/**
> - * text_poke - Update instructions on a live kernel
> - * @addr: address to modify
> - * @opcode: source of the copy
> - * @len: length to copy
> - *
> - * Only atomic text poke/set should be allowed when not doing early patching.
> - * It means the size must be writable atomically and the address must be aligned
> - * in a way that permits an atomic write. It also makes sure we fit on a single
> - * page.
> - */
> -void *text_poke(void *addr, const void *opcode, size_t len)
> +static void *__text_poke(void *addr, const void *opcode, size_t len)
>  {
>  	unsigned long flags;
>  	char *vaddr;
> @@ -702,8 +691,6 @@ void *text_poke(void *addr, const void *opcode, size_t len)
>  	 */
>  	BUG_ON(!after_bootmem);
>  
> -	lockdep_assert_held(&text_mutex);
> -
>  	if (!core_kernel_text((unsigned long)addr)) {
>  		pages[0] = vmalloc_to_page(addr);
>  		pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
> @@ -732,6 +719,43 @@ void *text_poke(void *addr, const void *opcode, size_t len)
>  	return addr;
>  }
>  
> +/**
> + * text_poke - Update instructions on a live kernel
> + * @addr: address to modify
> + * @opcode: source of the copy
> + * @len: length to copy
> + *
> + * Only atomic text poke/set should be allowed when not doing early patching.
> + * It means the size must be writable atomically and the address must be aligned
> + * in a way that permits an atomic write. It also makes sure we fit on a single
> + * page.
> + */
> +void *text_poke(void *addr, const void *opcode, size_t len)
> +{
> +	lockdep_assert_held(&text_mutex);
> +
> +	return __text_poke(addr, opcode, len);
> +}
> +
> +/**
> + * text_poke_kgdb - Update instructions on a live kernel by kgdb
> + * @addr: address to modify
> + * @opcode: source of the copy
> + * @len: length to copy
> + *
> + * Only atomic text poke/set should be allowed when not doing early patching.
> + * It means the size must be writable atomically and the address must be aligned
> + * in a way that permits an atomic write. It also makes sure we fit on a single
> + * page.
> + *
> + * Context: should only be used by kgdb, which ensures no other core is running,
> + *	    despite the fact it does not hold the text_mutex.
> + */
> +void *text_poke_kgdb(void *addr, const void *opcode, size_t len)
> +{
> +	return __text_poke(addr, opcode, len);
> +}
> +
>  static void do_sync_core(void *info)
>  {
>  	sync_core();
> diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
> index 5db08425063e..1461544cba8b 100644
> --- a/arch/x86/kernel/kgdb.c
> +++ b/arch/x86/kernel/kgdb.c
> @@ -758,13 +758,13 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
>  	if (!err)
>  		return err;
>  	/*
> -	 * It is safe to call text_poke() because normal kernel execution
> +	 * It is safe to call text_poke_kgdb() because normal kernel execution
>  	 * is stopped on all cores, so long as the text_mutex is not locked.
>  	 */
>  	if (mutex_is_locked(&text_mutex))
>  		return -EBUSY;
> -	text_poke((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
> -		  BREAK_INSTR_SIZE);
> +	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
> +		       BREAK_INSTR_SIZE);
>  	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
>  	if (err)
>  		return err;
> @@ -783,12 +783,13 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
>  	if (bpt->type != BP_POKE_BREAKPOINT)
>  		goto knl_write;
>  	/*
> -	 * It is safe to call text_poke() because normal kernel execution
> +	 * It is safe to call text_poke_kgdb() because normal kernel execution
>  	 * is stopped on all cores, so long as the text_mutex is not locked.
>  	 */
>  	if (mutex_is_locked(&text_mutex))
>  		goto knl_write;
> -	text_poke((void *)bpt->bpt_addr, bpt->saved_instr, BREAK_INSTR_SIZE);
> +	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
> +		       BREAK_INSTR_SIZE);
>  	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
>  	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
>  		goto knl_write;
> -- 
> 2.17.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
