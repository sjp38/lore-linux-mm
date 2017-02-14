Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFB9C6B039E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:28:10 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id u25so138780656qki.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:28:10 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00117.outbound.protection.outlook.com. [40.107.0.117])
        by mx.google.com with ESMTPS id e13si763142pgn.345.2017.02.14.07.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 07:28:09 -0800 (PST)
Subject: Re: [PATCHv4 3/5] x86/mm: fix 32-bit mmap() for 64-bit ELF
References: <20170130120432.6716-1-dsafonov@virtuozzo.com>
 <20170130120432.6716-4-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1702111513460.3734@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <397ddf67-92bb-f210-bb8b-09580db41385@virtuozzo.com>
Date: Tue, 14 Feb 2017 18:24:23 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1702111513460.3734@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On 02/11/2017 10:49 PM, Thomas Gleixner wrote:
> On Mon, 30 Jan 2017, Dmitry Safonov wrote:
>
>> Fix 32-bit compat_sys_mmap() mapping VMA over 4Gb in 64-bit binaries
>> and 64-bit sys_mmap() mapping VMA only under 4Gb in 32-bit binaries.
>> Introduced new bases for compat syscalls in mm_struct:
>> mmap_compat_base and mmap_compat_legacy_base for top-down and
>> bottom-up allocations accordingly.
>> Taught arch_get_unmapped_area{,_topdown}() to use the new mmap_bases
>> in compat syscalls for high/low limits in vm_unmapped_area().
>>
>> I discovered that bug on ZDTM tests for compat 32-bit C/R.
>> Working compat sys_mmap() in 64-bit binaries is really needed for that
>> purpose, as 32-bit applications are restored from 64-bit CRIU binary.
>
> Again that changelog sucks.
>
> Explain the problem/bug first. Then explain the way to fix it and do not
> tell fairy tales about what you did without explaing the bug in the first
> place.
>
> Documentation....SubittingPatches explains that very well.

Rewrote changelog.

>> +config HAVE_ARCH_COMPAT_MMAP_BASES
>> +	bool
>> +	help
>> +	  If this is set, one program can do native and compatible syscall
>> +	  mmap() on architecture. Thus kernel has different bases to
>> +	  compute high and low virtual address limits for allocation.
>
> Sigh. How is a user supposed to decode this?
>
> 	  This allows 64bit applications to invoke syscalls in 64bit and
> 	  32bit mode. Required for ....

Ok

>>
>> @@ -113,10 +114,19 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
>>  		if (current->flags & PF_RANDOMIZE) {
>>  			*begin = randomize_page(*begin, 0x02000000);
>>  		}
>> -	} else {
>> -		*begin = current->mm->mmap_legacy_base;
>> -		*end = TASK_SIZE;
>> +		return;
>>  	}
>> +
>> +#ifdef CONFIG_COMPAT
>
> Can you please find a solution which does not create that ifdef horror in
> the code? Just a few accessors to those compat fields are required to do
> that.

I'll try

>> +
>> +#ifdef CONFIG_COMPAT
>> +	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
>> +			arch_compat_rnd(), IA32_PAGE_OFFSET);
>> +#endif
>
> Ditto
>
> Thanks,
>
> 	tglx
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
