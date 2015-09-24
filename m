Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFE682F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:15:08 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so11821234pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:15:08 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id jv8si19632478pbc.136.2015.09.24.10.15.06
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 10:15:06 -0700 (PDT)
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56042F96.6030107@sr71.net>
Date: Thu, 24 Sep 2015 10:15:02 -0700
MIME-Version: 1.0
In-Reply-To: <20150924092320.GA26876@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, borntraeger@de.ibm.com

Christian, can you tell us how big s390's storage protection keys are?
See the discussion below about siginfo...

On 09/24/2015 02:23 AM, Ingo Molnar wrote:
>> +static u16 fetch_pkey(unsigned long address, struct task_struct *tsk)
>> +{
...
>> +		struct vm_area_struct *vma = find_vma(tsk->mm, address);
>> +		if (vma) {
>> +			ret = vma_pkey(vma);
>> +		} else {
>> +			WARN_ONCE(1, "no PTE or VMA @ %lx\n", address);
>> +			ret = 0;
>> +		}
>> +	}
>> +	return ret;
> 
> Yeah, so I have three observations:
> 
> 1)
> 
> I don't think this warning is entirely right, because this is a fundamentally racy 
> op.
> 
> fetch_pkey(), called by force_sign_info_fault(), can be called while not holding 
> the vma - and if we race with any other thread of the mm, the vma might be gone 
> already.
> 
> So any threaded app using pkeys and vmas in parallel could trigger that WARN_ON().

Agreed.  I'll remove the warning.

> 2)
> 
> And note that this is a somewhat new scenario: in regular page faults, 
> 'error_code' always carries a then-valid cause of the page fault with itself. So 
> we can put that into the siginfo and can be sure that it's the reason for the 
> fault.
> 
> With the above pkey code, we fetch the pte separately from the fault, and without 
> synchronizing with the fault - and we cannot do that, nor do we want to.
> 
> So I think this code should just accept the fact that races may happen. Perhaps 
> warn if we get here with only a single mm user. (but even that would be a bit racy 
> as we don't serialize against exit())

Good point.

> 3)
> 
> For user-space that somehow wants to handle pkeys dynamically and drive them via 
> faults, this seems somewhat inefficient: we already do a find_vma() in the primary 
> fault lookup - and with the typical pkey usecase it will find a vma, just with the 
> wrong access permissions. But when we generate the siginfo here, why do we do a 
> find_vma() again? Why not pass the vma to the siginfo generating function?

My assumption was that the signal generation case was pretty slow.
find_vma() is almost guaranteed to hit the vmacache, and we already hold
mmap_sem, so the cost is pretty tiny.

I'm happy to change it if you're really concerned, but I didn't think it
would be worth the trouble of plumbing it down.

>> --- a/include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo	2015-09-16 10:48:15.584161859 -0700
>> +++ b/include/uapi/asm-generic/siginfo.h	2015-09-16 10:48:15.592162222 -0700
>> @@ -95,6 +95,13 @@ typedef struct siginfo {
>>  				void __user *_lower;
>>  				void __user *_upper;
>>  			} _addr_bnd;
>> +			int _pkey; /* FIXME: protection key value??
>> +				    * Do we really need this in here?
>> +				    * userspace can get the PKRU value in
>> +				    * the signal handler, but they do not
>> +				    * easily have access to the PKEY value
>> +				    * from the PTE.
>> +				    */
>>  		} _sigfault;
> 
> A couple of comments:
> 
> 1)
> 
> Please use our ABI types - this one should be 'u32' I think.
> 
> We could use 'u8' as well here, and mark another 3 bytes next to it as reserved 
> for future flags. Right now protection keys use 4 bits, but do you really think 
> they'll ever grow beyond 8 bits? PTE bits are a scarce resource in general.

I don't expect them to get bigger, at least with anything resembling the
current architecture.  Agreed about the scarcity of PTE bits.

siginfo.h is shared everywhere, so I'd ideally like to put a type in
there that all the other architectures can use.

> 3)
> 
> Please add suitable self-tests to tools/tests/selftests/x86/ that both documents 
> the preferred usage of pkeys, demonstrates all implemented aspects the new ABI and 
> provokes a fault and prints the resulting siginfo, etc.
> 
>> @@ -206,7 +214,8 @@ typedef struct siginfo {
>>  #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
>>  #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
>>  #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
>> -#define NSIGSEGV	3
>> +#define SEGV_PKUERR	(__SI_FAULT|4)  /* failed address bound checks */
>> +#define NSIGSEGV	4
> 
> You copy & pasted the MPX comment here, it should read something like:
> 
>    #define SEGV_PKUERR	(__SI_FAULT|4)  /* failed protection keys checks */

Whoops.  Will fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
