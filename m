Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3D46B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:39:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so8745842pfg.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:39:58 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o20si367816pgn.150.2017.03.07.07.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:39:57 -0800 (PST)
Subject: Re: [PATCH v6 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1488232591.git.khalid.aziz@oracle.com>
 <cover.1488232591.git.khalid.aziz@oracle.com>
 <85d8a35b577915945703ff84cec6f7f4d85ec214.1488232598.git.khalid.aziz@oracle.com>
 <AA645D3A-5FB0-4768-977F-D0725AE5CEC7@oracle.com>
 <f57a7108-188b-7b77-1a47-52fac5f3aed7@oracle.com>
 <C9588390-704B-452D-BB52-FBF2EF892DBB@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <0dc0280e-4d3c-961b-0d2b-bfd099b8d8cd@oracle.com>
Date: Tue, 7 Mar 2017 08:39:38 -0700
MIME-Version: 1.0
In-Reply-To: <C9588390-704B-452D-BB52-FBF2EF892DBB@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Yznaga <anthony.yznaga@oracle.com>, davem@davemloft.net
Cc: corbet@lwn.net, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 03/06/2017 06:25 PM, Anthony Yznaga wrote:
> 
>> On Mar 6, 2017, at 4:31 PM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>
>> On 03/06/2017 05:13 PM, Anthony Yznaga wrote:
>>>
>>>> On Feb 28, 2017, at 10:35 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>>>
>>>> diff --git a/arch/sparc/kernel/etrap_64.S b/arch/sparc/kernel/etrap_64.S
>>>> index 1276ca2..7be33bf 100644
>>>> --- a/arch/sparc/kernel/etrap_64.S
>>>> +++ b/arch/sparc/kernel/etrap_64.S
>>>> @@ -132,7 +132,33 @@ etrap_save:	save	%g2, -STACK_BIAS, %sp
>>>> 		stx	%g6, [%sp + PTREGS_OFF + PT_V9_G6]
>>>> 		stx	%g7, [%sp + PTREGS_OFF + PT_V9_G7]
>>>> 		or	%l7, %l0, %l7
>>>> -		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>>>> +661:		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>>>> +		/*
>>>> +		 * If userspace is using ADI, it could potentially pass
>>>> +		 * a pointer with version tag embedded in it. To maintain
>>>> +		 * the ADI security, we must enable PSTATE.mcde. Userspace
>>>> +		 * would have already set TTE.mcd in an earlier call to
>>>> +		 * kernel and set the version tag for the address being
>>>> +		 * dereferenced. Setting PSTATE.mcde would ensure any
>>>> +		 * access to userspace data through a system call honors
>>>> +		 * ADI and does not allow a rogue app to bypass ADI by
>>>> +		 * using system calls. Setting PSTATE.mcde only affects
>>>> +		 * accesses to virtual addresses that have TTE.mcd set.
>>>> +		 * Set PMCDPER to ensure any exceptions caused by ADI
>>>> +		 * version tag mismatch are exposed before system call
>>>> +		 * returns to userspace. Setting PMCDPER affects only
>>>> +		 * writes to virtual addresses that have TTE.mcd set and
>>>> +		 * have a version tag set as well.
>>>> +		 */
>>>> +		.section .sun_m7_1insn_patch, "ax"
>>>> +		.word	661b
>>>> +		sethi	%hi(TSTATE_TSO | TSTATE_PEF | TSTATE_MCDE), %l0
>>>> +		.previous
>>>> +661:		nop
>>>> +		.section .sun_m7_1insn_patch, "ax"
>>>> +		.word	661b
>>>> +		.word 0xaf902001	/* wrpr %g0, 1, %pmcdper */
>>>
>>> Since PMCDPER is never cleared, setting it here is quickly going to set it on all CPUs and then become an expensive "nop" that burns ~50 cycles each time through etrap.  Consider setting it at boot time and when a CPU is DR'd into the system.
>>>
>>> Anthony
>>>
>>
>> I considered that possibility. What made me uncomfortable with that is there is no way to prevent a driver/module or future code elsewhere in kernel from clearing PMCDPER with possibly good reason. If that were to happen, setting PMCDPER here ensures kernel will always see consistent behavior with system calls. It does come at a cost. Is that cost unacceptable to ensure consistent behavior?
> 
> Aren't you still at risk if the thread relinquishes the CPU while in the kernel and is then rescheduled on a CPU where PMCDPER has erroneously been left cleared?  You may need to save and restore PMCDPER as well as MCDPER on context switch, but I don't know if that will cover you completely.
> 

You mean something like this?

--- arch/sparc/include/asm/mmu_context_64.h	2017-03-03 14:05:30.398573081 -0700
+++ /tmp/mmu_context_64.h	2017-03-07 08:26:20.582124798 -0700
@@ -193,6 +193,7 @@
 		__asm__ __volatile__(
 			"mov %0, %%g1\n\t"
 			".word 0x9d800001\n\t"	/* wr %g0, %g1, %mcdper" */
+			".word 0xaf902001\n\t"	/* wrpr %g0, 1, %pmcdper */
 			:
 			: "ir" (tmp_mcdper)
 			: "g1");

> Alternatively you can avoid problems from buggy code and avoid the performance hit when storing to ADI enabled memory with precise mode enabled (e.g. when reading from a file into an ADI-enabled buffer) by handling disrupting mismatches that happen in copy_to_user() or put_user().  That does require adding error barriers and appropriate exception table entries, though, to deal with the nature of disrupting exceptions.
> 

put_user() can be called for writing just one word of data to the userspace
and memory barrier for that is as expensive as running with the worst case 
with PMCDPER set. PMCDPER being set only affects writes to ADI-enabled
userpsace VAs while barrier affects every write. A memory barrier before
we return from kernel can ensure any exceptions due to userspace memory
access are exposed while we are still in the kernel but the cost is high
and it affects writes to non-ADI enabled memory as well. Doing this for
copy_to_user() makes more sense due to larger number of writes. I still
think it is more effective to run in the kernel with PMCDPER set, and
clear it in NG4copy_to_user() for the larger number of copies. Clearing
can be done conditionally if any of the memory kernel is about to write
to is ADI enabled. This can be done as a separate optimization patch if
it makes sense. This does add more code to NG4copy_to_user(). Thoughts?

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
