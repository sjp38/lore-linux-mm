Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D595E6B004D
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 22:21:23 -0400 (EDT)
Received: by pxi1 with SMTP id 1so2164604pxi.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 19:21:30 -0700 (PDT)
Message-ID: <4AADA8A5.6040603@gmail.com>
Date: Mon, 14 Sep 2009 10:21:25 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmap : save some cycles for the shared anonymous mapping
References: <1252633966-20541-1-git-send-email-shijie8@gmail.com> <20090911154630.6fd232f1.akpm@linux-foundation.org> <Pine.LNX.4.64.0909131932440.27988@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909131932440.27988@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins write:
> On Fri, 11 Sep 2009, Andrew Morton wrote:
>   
>> On Fri, 11 Sep 2009 09:52:46 +0800
>> Huang Shijie <shijie8@gmail.com> wrote:
>>
>>     
>>> The shmem_zere_setup() does not change vm_start, pgoff or vm_flags,
>>> only some drivers change them (such as /driver/video/bfin-t350mcqb-fb.c).
>>>
>>> Moving these codes to a more proper place to save cycles for shared
>>> anonymous mapping.
>>>       
>
> (Actually it's saving them for any !file mapping.
>  Though I doubt it's a significant saving myself.)
>
>   
yes.
>>> Signed-off-by: Huang Shijie <shijie8@gmail.com>
>>>       
>
> Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
>
>   
>>> ---
>>>  mm/mmap.c |   18 +++++++++---------
>>>  1 files changed, 9 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>> index 8101de4..840e91e 100644
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -1195,21 +1195,21 @@ munmap_back:
>>>  			goto unmap_and_free_vma;
>>>  		if (vm_flags & VM_EXECUTABLE)
>>>  			added_exe_file_vma(mm);
>>> +
>>> +		/* Can addr have changed??
>>> +		 *
>>> +		 * Answer: Yes, several device drivers can do it in their
>>> +		 *         f_op->mmap method. -DaveM
>>> +		 */
>>> +		addr = vma->vm_start;
>>> +		pgoff = vma->vm_pgoff;
>>> +		vm_flags = vma->vm_flags;
>>>  	} else if (vm_flags & VM_SHARED) {
>>>  		error = shmem_zero_setup(vma);
>>>  		if (error)
>>>  			goto free_vma;
>>>  	}
>>>  
>>> -	/* Can addr have changed??
>>> -	 *
>>> -	 * Answer: Yes, several device drivers can do it in their
>>> -	 *         f_op->mmap method. -DaveM
>>> -	 */
>>> -	addr = vma->vm_start;
>>> -	pgoff = vma->vm_pgoff;
>>> -	vm_flags = vma->vm_flags;
>>> -
>>>  	if (vma_wants_writenotify(vma))
>>>  		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
>>>  
>>>       
>> hm, maybe we should nuke those locals and just use vma->foo everywhere.
>>
>> Local variable pgoff never gets used again anyway.
>>     
>
> I think it was me who Nak'ed an earlier patch to remove the update
> of pgoff, out of fear that we might add a later reference sometime
> in future, and not notice for a long time that it then needed that
> update again.
>
>   
my patch.
> addr and pgoff start off as args to do_mmap_pgoff(), so we'd better
> not nuke them!  And if we changed all the lines below that point to
> refer to vma->vm_start and vma->vm_flags, I think there's still a
> danger we'd unthinkingly add a reference to addr or vm_flags later.
>
>   
If we nuke them, there is potential problem to notice :
    Some drivers change the vm->vm_end, so (vm->vm_end - vm->vm_start) 
changes against the length of MMAP.

> If any change is to be made here, I think I prefer Shijie's:
> shmem_zero_setup isn't likely to change to modify any of those,
> and that patch has the great virtue of retaining DaveM's comment,
> which draws attention to the issue.
>
> Hugh
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
