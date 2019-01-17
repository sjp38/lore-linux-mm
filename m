Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id A79A88E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 16:16:39 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id g145so4799116yba.13
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:16:39 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id d79si1904984ywa.346.2019.01.17.13.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 13:16:37 -0800 (PST)
Date: Thu, 17 Jan 2019 13:15:54 -0800
In-Reply-To: <20190117154701.78aa8e9d0130716e0d9ac026@kernel.org>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com> <20190117003259.23141-2-rick.p.edgecombe@intel.com> <20190117154701.78aa8e9d0130716e0d9ac026@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 01/17] Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
From: hpa@zytor.com
Message-ID: <F3B332DA-4637-4A3B-93F9-C7903C1D9FF9@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>

On January 16, 2019 10:47:01 PM PST, Masami Hiramatsu <mhiramat@kernel=2Eor=
g> wrote:
>On Wed, 16 Jan 2019 16:32:43 -0800
>Rick Edgecombe <rick=2Ep=2Eedgecombe@intel=2Ecom> wrote:
>
>> From: Nadav Amit <namit@vmware=2Ecom>
>>=20
>> text_mutex is currently expected to be held before text_poke() is
>> called, but we kgdb does not take the mutex, and instead *supposedly*
>> ensures the lock is not taken and will not be acquired by any other
>core
>> while text_poke() is running=2E
>>=20
>> The reason for the "supposedly" comment is that it is not entirely
>clear
>> that this would be the case if gdb_do_roundup is zero=2E
>>=20
>> This patch creates two wrapper functions, text_poke() and
>> text_poke_kgdb() which do or do not run the lockdep assertion
>> respectively=2E
>>=20
>> While we are at it, change the return code of text_poke() to
>something
>> meaningful=2E One day, callers might actually respect it and the
>existing
>> BUG_ON() when patching fails could be removed=2E For kgdb, the return
>> value can actually be used=2E
>
>Looks good to me=2E
>
>Reviewed-by: Masami Hiramatsu <mhiramat@kernel=2Eorg>
>
>Thank you,
>
>>=20
>> Cc: Andy Lutomirski <luto@kernel=2Eorg>
>> Cc: Kees Cook <keescook@chromium=2Eorg>
>> Cc: Dave Hansen <dave=2Ehansen@intel=2Ecom>
>> Cc: Masami Hiramatsu <mhiramat@kernel=2Eorg>
>> Fixes: 9222f606506c ("x86/alternatives: Lockdep-enforce text_mutex in
>text_poke*()")
>> Suggested-by: Peter Zijlstra <peterz@infradead=2Eorg>
>> Acked-by: Jiri Kosina <jkosina@suse=2Ecz>
>> Signed-off-by: Nadav Amit <namit@vmware=2Ecom>
>> Signed-off-by: Rick Edgecombe <rick=2Ep=2Eedgecombe@intel=2Ecom>
>> ---
>>  arch/x86/include/asm/text-patching=2Eh |  1 +
>>  arch/x86/kernel/alternative=2Ec        | 52
>++++++++++++++++++++--------
>>  arch/x86/kernel/kgdb=2Ec               | 11 +++---
>>  3 files changed, 45 insertions(+), 19 deletions(-)
>>=20
>> diff --git a/arch/x86/include/asm/text-patching=2Eh
>b/arch/x86/include/asm/text-patching=2Eh
>> index e85ff65c43c3=2E=2Ef8fc8e86cf01 100644
>> --- a/arch/x86/include/asm/text-patching=2Eh
>> +++ b/arch/x86/include/asm/text-patching=2Eh
>> @@ -35,6 +35,7 @@ extern void *text_poke_early(void *addr, const void
>*opcode, size_t len);
>>   * inconsistent instruction while you patch=2E
>>   */
>>  extern void *text_poke(void *addr, const void *opcode, size_t len);
>> +extern void *text_poke_kgdb(void *addr, const void *opcode, size_t
>len);
>>  extern int poke_int3_handler(struct pt_regs *regs);
>>  extern void *text_poke_bp(void *addr, const void *opcode, size_t
>len, void *handler);
>>  extern int after_bootmem;
>> diff --git a/arch/x86/kernel/alternative=2Ec
>b/arch/x86/kernel/alternative=2Ec
>> index ebeac487a20c=2E=2Ec6a3a10a2fd5 100644
>> --- a/arch/x86/kernel/alternative=2Ec
>> +++ b/arch/x86/kernel/alternative=2Ec
>> @@ -678,18 +678,7 @@ void *__init_or_module text_poke_early(void
>*addr, const void *opcode,
>>  	return addr;
>>  }
>> =20
>> -/**
>> - * text_poke - Update instructions on a live kernel
>> - * @addr: address to modify
>> - * @opcode: source of the copy
>> - * @len: length to copy
>> - *
>> - * Only atomic text poke/set should be allowed when not doing early
>patching=2E
>> - * It means the size must be writable atomically and the address
>must be aligned
>> - * in a way that permits an atomic write=2E It also makes sure we fit
>on a single
>> - * page=2E
>> - */
>> -void *text_poke(void *addr, const void *opcode, size_t len)
>> +static void *__text_poke(void *addr, const void *opcode, size_t len)
>>  {
>>  	unsigned long flags;
>>  	char *vaddr;
>> @@ -702,8 +691,6 @@ void *text_poke(void *addr, const void *opcode,
>size_t len)
>>  	 */
>>  	BUG_ON(!after_bootmem);
>> =20
>> -	lockdep_assert_held(&text_mutex);
>> -
>>  	if (!core_kernel_text((unsigned long)addr)) {
>>  		pages[0] =3D vmalloc_to_page(addr);
>>  		pages[1] =3D vmalloc_to_page(addr + PAGE_SIZE);
>> @@ -732,6 +719,43 @@ void *text_poke(void *addr, const void *opcode,
>size_t len)
>>  	return addr;
>>  }
>> =20
>> +/**
>> + * text_poke - Update instructions on a live kernel
>> + * @addr: address to modify
>> + * @opcode: source of the copy
>> + * @len: length to copy
>> + *
>> + * Only atomic text poke/set should be allowed when not doing early
>patching=2E
>> + * It means the size must be writable atomically and the address
>must be aligned
>> + * in a way that permits an atomic write=2E It also makes sure we fit
>on a single
>> + * page=2E
>> + */
>> +void *text_poke(void *addr, const void *opcode, size_t len)
>> +{
>> +	lockdep_assert_held(&text_mutex);
>> +
>> +	return __text_poke(addr, opcode, len);
>> +}
>> +
>> +/**
>> + * text_poke_kgdb - Update instructions on a live kernel by kgdb
>> + * @addr: address to modify
>> + * @opcode: source of the copy
>> + * @len: length to copy
>> + *
>> + * Only atomic text poke/set should be allowed when not doing early
>patching=2E
>> + * It means the size must be writable atomically and the address
>must be aligned
>> + * in a way that permits an atomic write=2E It also makes sure we fit
>on a single
>> + * page=2E
>> + *
>> + * Context: should only be used by kgdb, which ensures no other core
>is running,
>> + *	    despite the fact it does not hold the text_mutex=2E
>> + */
>> +void *text_poke_kgdb(void *addr, const void *opcode, size_t len)
>> +{
>> +	return __text_poke(addr, opcode, len);
>> +}
>> +
>>  static void do_sync_core(void *info)
>>  {
>>  	sync_core();
>> diff --git a/arch/x86/kernel/kgdb=2Ec b/arch/x86/kernel/kgdb=2Ec
>> index 5db08425063e=2E=2E1461544cba8b 100644
>> --- a/arch/x86/kernel/kgdb=2Ec
>> +++ b/arch/x86/kernel/kgdb=2Ec
>> @@ -758,13 +758,13 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt
>*bpt)
>>  	if (!err)
>>  		return err;
>>  	/*
>> -	 * It is safe to call text_poke() because normal kernel execution
>> +	 * It is safe to call text_poke_kgdb() because normal kernel
>execution
>>  	 * is stopped on all cores, so long as the text_mutex is not
>locked=2E
>>  	 */
>>  	if (mutex_is_locked(&text_mutex))
>>  		return -EBUSY;
>> -	text_poke((void *)bpt->bpt_addr, arch_kgdb_ops=2Egdb_bpt_instr,
>> -		  BREAK_INSTR_SIZE);
>> +	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops=2Egdb_bpt_instr,
>> +		       BREAK_INSTR_SIZE);
>>  	err =3D probe_kernel_read(opc, (char *)bpt->bpt_addr,
>BREAK_INSTR_SIZE);
>>  	if (err)
>>  		return err;
>> @@ -783,12 +783,13 @@ int kgdb_arch_remove_breakpoint(struct
>kgdb_bkpt *bpt)
>>  	if (bpt->type !=3D BP_POKE_BREAKPOINT)
>>  		goto knl_write;
>>  	/*
>> -	 * It is safe to call text_poke() because normal kernel execution
>> +	 * It is safe to call text_poke_kgdb() because normal kernel
>execution
>>  	 * is stopped on all cores, so long as the text_mutex is not
>locked=2E
>>  	 */
>>  	if (mutex_is_locked(&text_mutex))
>>  		goto knl_write;
>> -	text_poke((void *)bpt->bpt_addr, bpt->saved_instr,
>BREAK_INSTR_SIZE);
>> +	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
>> +		       BREAK_INSTR_SIZE);
>>  	err =3D probe_kernel_read(opc, (char *)bpt->bpt_addr,
>BREAK_INSTR_SIZE);
>>  	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
>>  		goto knl_write;
>> --=20
>> 2=2E17=2E1
>>=20

If you are reorganizing this code, please do so so that the caller doesn't=
 have to worry about if it should call text_poke_bp() or text_poke_early()=
=2E Right now the caller had to know that, which makes no sense=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E
