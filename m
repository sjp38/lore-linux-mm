Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 022CD280018
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 22:15:20 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so6204081pde.8
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 19:15:20 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b10si1662613pdm.209.2014.10.30.19.15.19
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 19:15:19 -0700 (PDT)
Message-ID: <5452EFF7.4090204@intel.com>
Date: Fri, 31 Oct 2014 10:12:07 +0800
From: Ren Qiaowei <qiaowei.ren@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <5452BDD8.2080605@intel.com>
In-Reply-To: <5452BDD8.2080605@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On 10/31/2014 06:38 AM, Dave Hansen wrote:
>> +void do_mpx_bounds(struct pt_regs *regs, siginfo_t *info,
>> +		struct xsave_struct *xsave_buf)
>> +{
>> +	struct mpx_insn insn;
>> +	uint8_t bndregno;
>> +	unsigned long addr_vio;
>> +
>> +	addr_vio = mpx_insn_decode(&insn, regs);
>> +
>> +	bndregno = X86_MODRM_REG(insn.modrm.value);
>> +	if (bndregno > 3)
>> +		return;
>> +
>> +	/* Note: the upper 32 bits are ignored in 32-bit mode. */
>> +	info->si_lower = (void __user *)(unsigned long)
>> +		(xsave_buf->bndregs.bndregs[2*bndregno]);
>> +	info->si_upper = (void __user *)(unsigned long)
>> +		(~xsave_buf->bndregs.bndregs[2*bndregno+1]);
>> +	info->si_addr_lsb = 0;
>> +	info->si_signo = SIGSEGV;
>> +	info->si_errno = 0;
>> +	info->si_code = SEGV_BNDERR;
>> +	info->si_addr = (void __user *)addr_vio;
>> +}
>> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
>> index 611b6ec..b2a916b 100644
>> --- a/arch/x86/kernel/traps.c
>> +++ b/arch/x86/kernel/traps.c
>> @@ -284,6 +284,7 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
>>   	unsigned long status;
>>   	struct xsave_struct *xsave_buf;
>>   	struct task_struct *tsk = current;
>> +	siginfo_t info;
>>
>>   	prev_state = exception_enter();
>>   	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
>> @@ -316,6 +317,11 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
>>   		break;
>>
>>   	case 1: /* Bound violation. */
>> +		do_mpx_bounds(regs, &info, xsave_buf);
>> +		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs,
>> +				error_code, &info);
>> +		break;
>> +
>>   	case 0: /* No exception caused by Intel MPX operations. */
>>   		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, NULL);
>>   		break;
>>
>
> So, siginfo is stack-allocarted here.  do_mpx_bounds() can error out if
> it sees an invalid bndregno.  We still send the signal with the &info
> whether or not we filled the 'info' in do_mpx_bounds().
>
> Can't this leak some kernel stack out in the 'info'?
>

This should check the return value of do_mpx_bounds and should be fixed.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
