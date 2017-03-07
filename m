Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD446B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 19:31:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g2so8319785pge.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:31:58 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 21si20568831pfs.216.2017.03.06.16.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 16:31:57 -0800 (PST)
Subject: Re: [PATCH v6 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1488232591.git.khalid.aziz@oracle.com>
 <cover.1488232591.git.khalid.aziz@oracle.com>
 <85d8a35b577915945703ff84cec6f7f4d85ec214.1488232598.git.khalid.aziz@oracle.com>
 <AA645D3A-5FB0-4768-977F-D0725AE5CEC7@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <f57a7108-188b-7b77-1a47-52fac5f3aed7@oracle.com>
Date: Mon, 6 Mar 2017 17:31:38 -0700
MIME-Version: 1.0
In-Reply-To: <AA645D3A-5FB0-4768-977F-D0725AE5CEC7@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: davem@davemloft.net, corbet@lwn.net, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 03/06/2017 05:13 PM, Anthony Yznaga wrote:
>
>> On Feb 28, 2017, at 10:35 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>
>> diff --git a/arch/sparc/kernel/etrap_64.S b/arch/sparc/kernel/etrap_64.S
>> index 1276ca2..7be33bf 100644
>> --- a/arch/sparc/kernel/etrap_64.S
>> +++ b/arch/sparc/kernel/etrap_64.S
>> @@ -132,7 +132,33 @@ etrap_save:	save	%g2, -STACK_BIAS, %sp
>> 		stx	%g6, [%sp + PTREGS_OFF + PT_V9_G6]
>> 		stx	%g7, [%sp + PTREGS_OFF + PT_V9_G7]
>> 		or	%l7, %l0, %l7
>> -		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>> +661:		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>> +		/*
>> +		 * If userspace is using ADI, it could potentially pass
>> +		 * a pointer with version tag embedded in it. To maintain
>> +		 * the ADI security, we must enable PSTATE.mcde. Userspace
>> +		 * would have already set TTE.mcd in an earlier call to
>> +		 * kernel and set the version tag for the address being
>> +		 * dereferenced. Setting PSTATE.mcde would ensure any
>> +		 * access to userspace data through a system call honors
>> +		 * ADI and does not allow a rogue app to bypass ADI by
>> +		 * using system calls. Setting PSTATE.mcde only affects
>> +		 * accesses to virtual addresses that have TTE.mcd set.
>> +		 * Set PMCDPER to ensure any exceptions caused by ADI
>> +		 * version tag mismatch are exposed before system call
>> +		 * returns to userspace. Setting PMCDPER affects only
>> +		 * writes to virtual addresses that have TTE.mcd set and
>> +		 * have a version tag set as well.
>> +		 */
>> +		.section .sun_m7_1insn_patch, "ax"
>> +		.word	661b
>> +		sethi	%hi(TSTATE_TSO | TSTATE_PEF | TSTATE_MCDE), %l0
>> +		.previous
>> +661:		nop
>> +		.section .sun_m7_1insn_patch, "ax"
>> +		.word	661b
>> +		.word 0xaf902001	/* wrpr %g0, 1, %pmcdper */
>
> Since PMCDPER is never cleared, setting it here is quickly going to set it on all CPUs and then become an expensive "nop" that burns ~50 cycles each time through etrap.  Consider setting it at boot time and when a CPU is DR'd into the system.
>
> Anthony
>

I considered that possibility. What made me uncomfortable with that is 
there is no way to prevent a driver/module or future code elsewhere in 
kernel from clearing PMCDPER with possibly good reason. If that were to 
happen, setting PMCDPER here ensures kernel will always see consistent 
behavior with system calls. It does come at a cost. Is that cost 
unacceptable to ensure consistent behavior?

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
