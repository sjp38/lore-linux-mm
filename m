Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64CE26B0253
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 18:39:08 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so538521366pfa.3
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 15:39:08 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 81si17331034pfh.264.2017.01.31.15.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 15:39:07 -0800 (PST)
Subject: Re: [PATCH v5 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1485362562.git.khalid.aziz@oracle.com>
 <cover.1485362562.git.khalid.aziz@oracle.com>
 <0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
 <20170130.171531.1973857503703372714.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <6c514e7e-338a-f1cd-140d-d4980ea6ac0f@oracle.com>
Date: Tue, 31 Jan 2017 16:38:49 -0700
MIME-Version: 1.0
In-Reply-To: <20170130.171531.1973857503703372714.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: corbet@lwn.net, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, keescook@chromium.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

On 01/30/2017 03:15 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Wed, 25 Jan 2017 12:57:16 -0700
>
>> +static inline void enable_adi(void)
>> +{
>  ...
>> +	__asm__ __volatile__(
>> +		"rdpr %%pstate, %%g1\n\t"
>> +		"or %%g1, %0, %%g1\n\t"
>> +		"wrpr %%g1, %%g0, %%pstate\n\t"
>> +		".word 0x83438000\n\t"	/* rd %mcdper, %g1 */
>> +		".word 0xaf900001\n\t"	/* wrpr  %g0, %g1, %pmcdper */
>> +		:
>> +		: "i" (PSTATE_MCDE)
>> +		: "g1");
>> +}
>
> This is _crazy_ expensive.
>
> This is 4 privileged register operations, every single one incurs a full
> pipline flush and virtual cpu thread yield.
>
> And we do this around _every_ single userspace access from the kernel
> when the thread has ADI enabled.

Hi Dave,

Thanks for the feedback. This is very helpful. I checked and it indeed 
can cost 50+ cycles even on M7 processor for PSTATE accesses.

>
> I think if the kernel manages the ADI metadata properly, you can get rid
> of all of this.
>
> On etrap, you change ESTATE_PSTATE{1,2} to have the MCDE bit enabled.
> Then the kernel always runs with ADI enabled.

Running the kernel with PSTATE.mcde=1 can possibly be problematic as we 
had discussed earlier in this thread where keeping PSTATE.mcde enabled 
might mean kernel having to keep track of which pages still have tags 
set on them or flush tags on every page on free. I will go through the 
code again to see if it PSTATE.mcde can be turned on in kernel all the 
time, which might be the case if we can ensure kernel accesses pages 
with TTE.mcd cleared.

>
> Furthermore, since the %mcdper register should be set to whatever the
> current task has asked for, you should be able to avoid touching it
> as well assuming that traps do not change %mcdper's value.

When running in privileged mode, it is the value of %pmcdper that 
matter, not %mcdper, hence I added code to sync %pmcdper with %mcdper 
when entering privileged mode. Nevertheless, one of the HW designers has 
suggested I might be able to get away without having to futz with 
%pmcdper by using membar before exiting privileged mode which might 
still get me the same effect I am looking for without the cost.

--
Khalid

>
> Then you don't need to do anything special during userspace accesses
> which seems to be the way this was designed to be used.
> --
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
