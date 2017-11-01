Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51C906B025E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 14:28:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j3so3241732pga.5
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 11:28:09 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x6si1514437pgq.460.2017.11.01.11.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 11:28:08 -0700 (PDT)
Subject: Re: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3
 switching
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223148.5334003A@viggo.jf.intel.com>
 <20171101181805.3jjzfe6vhmgorjtp@pd.tnic>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d991c9c0-ad36-929b-ae1b-05cc97aff19f@linux.intel.com>
Date: Wed, 1 Nov 2017 11:27:48 -0700
MIME-Version: 1.0
In-Reply-To: <20171101181805.3jjzfe6vhmgorjtp@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/01/2017 11:18 AM, Borislav Petkov wrote:
>> +.macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
>> +	movq	%cr3, %r\scratch_reg
>> +	movq	%r\scratch_reg, \save_reg
> 
> So one of the args gets passed as "ax", for example, which then gets
> completed to a register with the "%r" prepended and the other is a full
> register: %r14.
> 
> What for? Can we stick with one format pls?

This allows for a tiny optimization of Andy's that I realize I must have
blown away at some point.  It lets us do a 32-bit-register instruction
(and using %eXX) when checking KAISER_SWITCH_MASK instead of a 64-bit
register via %rXX.

I don't feel strongly about maintaining that optimization it looks weird
and surely doesn't actually do much.

>> diff -puN arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64_compat.S
>> --- a/arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work	2017-10-31 15:03:48.107007348 -0700
>> +++ b/arch/x86/entry/entry_64_compat.S	2017-10-31 15:03:48.113007631 -0700
>> @@ -48,8 +48,13 @@
>>  ENTRY(entry_SYSENTER_compat)
>>  	/* Interrupts are off on entry. */
>>  	SWAPGS_UNSAFE_STACK
>> +
>>  	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
>>  
>> +	pushq	%rdi
>> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
>> +	popq	%rdi
> 
> So we switch to kernel CR3 right after we've setup kernel stack...
> 
>> +
>>  	/*
>>  	 * User tracing code (ptrace or signal handlers) might assume that
>>  	 * the saved RAX contains a 32-bit number when we're invoking a 32-bit
>> @@ -91,6 +96,9 @@ ENTRY(entry_SYSENTER_compat)
>>  	pushq   $0			/* pt_regs->r15 = 0 */
>>  	cld
>>  
>> +	pushq	%rdi
>> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
>> +	popq	%rdi
> 
> ... and switch here *again*, after pushing pt_regs?!? What's up?
> 
>>  	/*
>>  	 * SYSENTER doesn't filter flags, so we need to clear NT and AC
>>  	 * ourselves.  To save a few cycles, we can check whether

Thanks for catching that.  We can kill one of these.  I'm inclined to
kill the first one.  Looking at the second one since we've just saved
off ptregs, that should make %rdi safe to clobber without the push/pop
at all.

Does that seem like it would work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
