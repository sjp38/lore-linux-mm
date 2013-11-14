Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 330236B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 01:46:17 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so1546231pdj.26
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 22:46:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.191])
        by mx.google.com with SMTP id aq2si773226pbc.10.2013.11.13.22.46.14
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 22:46:15 -0800 (PST)
Message-ID: <52847237.5030405@asianux.com>
Date: Thu, 14 Nov 2013 14:48:23 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] arch: um: kernel: skas: mmu: remove pmd_free() and pud_free()
 for failure processing in init_stub_pte()
References: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils> <528308E8.8040203@asianux.com> <alpine.LNX.2.00.1311132041200.1785@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1311132041200.1785@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, uml-user <user-mode-linux-user@lists.sourceforge.net>


Firstly, thank you for spending your time resources to reply so many
details.


On 11/14/2013 01:20 PM, Hugh Dickins wrote:
> On Wed, 13 Nov 2013, Chen Gang wrote:
> 
>> Unfortunately, p?d_alloc() and p?d_free() are not pair!! If p?d_alloc()
>> succeed, they may be used, so in the next failure, we have to skip them
>> to let exit_mmap() or do_munmap() to process it.
>>
>> According to "Documentation/vm/locking", 'mm->page_table_lock' is for
>> using vma list, so not need it when its related vmas are detached or
>> unmapped from using vma list.
> 
> Hah, don't believe a word of Documentation/vm/locking.  From time to
> time someone or other has updated some part of it, but on the whole
> it represents the state of the art in 1999.  Look at its git history:
> not a lot of activity there.
> 
> And please don't ask me to update it, and please don't try to update
> it yourself.  Delete it?  Maybe.
> 

I agree with you.

> Study the code itself for how mm locking is actually done
> (can you see anywhere we use page_table_lock on the vma list?)
> 

in p?d_alloc() will use page_table_lock, that the reason why I noticed
about it.


>>
>> The related work flow:
>>
>>   exit_mmap() ->
>>     unmap_vmas(); /* so not need mm->page_table_lock */
>>     free_pgtables();
>>
>>   do_munmap()->
>>     detach_vmas_to_be_unmapped(); /* so not need mm->page_table_lock */
>>     unmap_region() ->
>>       free_pgtables();
>>
>>   free_pgtables() ->
>>     free_pgd_range() ->
>>       free_pud_range() ->
>>         free_pmd_range() ->
>>           free_pte_range() ->
>>             pmd_clear();
>>             pte_free_tlb();
>>           pud_clear();
>>           pmd_free_tlb();
>>         pgd_clear(); 
>>         pud_free_tlb();
> 
> I don't think those notes would belong in this patch...
> 

Hmm... maybe what you said above is correct, although it is also the
sample to show how to remove them if pgd is related with real 'mm',
which is not like p?d_free().


>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  arch/um/kernel/skas/mmu.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/um/kernel/skas/mmu.c b/arch/um/kernel/skas/mmu.c
>> index 007d550..3fd1951 100644
>> --- a/arch/um/kernel/skas/mmu.c
>> +++ b/arch/um/kernel/skas/mmu.c
>> @@ -40,9 +40,9 @@ static int init_stub_pte(struct mm_struct *mm, unsigned long proc,
>>  	return 0;
>>  
>>   out_pte:
>> -	pmd_free(mm, pmd);
>> +	/* used by mm->pgd->pud, will free in do_munmap() or exit_mmap() */
>>   out_pmd:
>> -	pud_free(mm, pud);
>> +	/* used by mm->pgd, will free in do_munmap() or exit_mmap() */
>>   out:
>>  	return -ENOMEM;
>>  }
>> -- 
>> 1.7.7.6
> 
> .. but I'm not going to ack this: I just don't share your zest
> for mucking around with what I don't understand, and don't have
> the time to spare to understand it well enough.
> 

OK, I can understand. It belongs both mm area and um, it seems no one
familiar both of them (for me, I am familiar with neither of them).

But, for me, need continue analyzing and discussing.

>>From the look of it, if an error did occur in init_stub_pte(),
> then the special mapping of STUB_CODE and STUB_DATA would not
> be installed, so this area would be invisible to munmap and exit,
> and with your patch then the pages allocated likely to be leaked.
> 

It sounds reasonable to me: "although 'pgd' related with 'mm', but they
are not installed". But just like you said originally: "better get ACK
from some mm guys".


Hmm... is it another issue: "after STUB_CODE succeeds, but STUB_DATA
fails, the STUB_CODE will be leaked".


> Which is not to say that the existing code is actually correct:
> you're probably right that it's technically wrong.  But it would
> be very hard to get init_stub_pte() to fail, and has anyone
> reported a problem with it?  My guess is not, and my own
> inclination to dabble here is zero.
> 

Yeah.

> Hugh
> 
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
