Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 49D906B0099
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:56:58 -0500 (EST)
Date: Wed, 01 Dec 2010 09:57:23 -0800 (PST)
Message-Id: <20101201.095723.193718753.davem@davemloft.net>
Subject: Re: Flushing whole page instead of work for ptrace
From: David Miller <davem@davemloft.net>
In-Reply-To: <4CF68174.10301@petalogix.com>
References: <4CEFA8AE.2090804@petalogix.com>
	<20101130233250.35603401C8@magilla.sf.frob.com>
	<4CF68174.10301@petalogix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: michal.simek@petalogix.com
Cc: roland@redhat.com, oleg@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, john.williams@petalogix.com, edgar.iglesias@gmail.com
List-ID: <linux-mm.kvack.org>

From: Michal Simek <michal.simek@petalogix.com>
Date: Wed, 01 Dec 2010 18:10:12 +0100

> Roland McGrath wrote:
>> This is a VM question more than a ptrace question.  I can't give you
>> any authoritative answers about the VM issues.
>> Documentation/cachetlb.txt says:
>> 	Any time the kernel writes to a page cache page, _OR_
>> 	the kernel is about to read from a page cache page and
>> 	user space shared/writable mappings of this page potentially
>> 	exist, this routine is called.
>> In your case, the kernel is only reading (write=0 passed to
>> access_process_vm and get_user_pages).  In normal situations,
>> the page in question will have only a private and read-only
>> mapping in user space.  So the call should not be required in
>> these cases--if the code can tell that's so.
>> Perhaps something like the following would be safe.
>> But you really need some VM folks to tell you for sure.
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 02e48aa..2864ee7 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1484,7 +1484,8 @@ int __get_user_pages(struct task_struct *tsk,
>> struct mm_struct *mm,
>>  				pages[i] = page;
>>   				flush_anon_page(vma, page, start);
>> -				flush_dcache_page(page);
>> + if ((vm_flags & VM_WRITE) || (vma->vm_flags & VM_SHARED)
>> +					flush_dcache_page(page);
>>  			}
>>  			if (vmas)
>>  				vmas[i] = vma;
>> Thanks,
>> Roland
> 
> Andrew any comment?

I don't have any comments on this specific patch but I will note
that special care is needed _after_ the access to kick out aliases
so that other future accesses to this page, which are oblivious to
what ptrace did, don't see illegal D-cache aliases.

Have a look at arch/sparc/kernel/ptrace_64.c:flush_ptrace_access().

Also, another issue is that much of the time ptrace() is just fetching
very small chunks (perhaps, a stack frame, or some variable in the
program image), so doing an entire page flush when we only copy
a few bytes out of the page is overkill.

Sparc64's flush_ptrace_access() tries to address this as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
