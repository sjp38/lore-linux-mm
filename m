Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 738CA6B00A7
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 04:12:07 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id um1so132580pbc.36
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 01:12:07 -0800 (PST)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id hk1si22779969pbb.281.2013.11.13.01.12.04
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 01:12:05 -0800 (PST)
Message-ID: <528342E5.2030300@asianux.com>
Date: Wed, 13 Nov 2013 17:14:13 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] arch: um: kernel: skas: mmu: remove pmd_free() and pud_free()
 for failure processing in init_stub_pte()
References: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils> <528308E8.8040203@asianux.com> <52834138.7050005@nod.at>
In-Reply-To: <52834138.7050005@nod.at>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, uml-user <user-mode-linux-user@lists.sourceforge.net>

On 11/13/2013 05:07 PM, Richard Weinberger wrote:
> Am 13.11.2013 06:06, schrieb Chen Gang:
>> Unfortunately, p?d_alloc() and p?d_free() are not pair!! If p?d_alloc()
>> succeed, they may be used, so in the next failure, we have to skip them
>> to let exit_mmap() or do_munmap() to process it.
>>
>> According to "Documentation/vm/locking", 'mm->page_table_lock' is for
>> using vma list, so not need it when its related vmas are detached or
>> unmapped from using vma list.
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
>>
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> 
> Sounds reasonable to me.
> *But* there are patches you from out there that tried to fix similar issues and got reverted later.
> Now I'm a bit nervous and want a ACK from mm folks to have this verified.
> It's not that I don't trust you, but I really don't trust you. ;-)
> 

OK, thanks.

> Thanks,
> //richard
> 
> 

-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
