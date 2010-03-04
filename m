Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F6796B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 02:01:17 -0500 (EST)
Received: by pzk10 with SMTP id 10so1558938pzk.11
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 23:01:16 -0800 (PST)
Message-ID: <4B8F5A82.2030805@gmail.com>
Date: Thu, 04 Mar 2010 15:00:18 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swapfile : fix the wrong return value
References: <1267501102-24190-1-git-send-email-shijie8@gmail.com> <alpine.LSU.2.00.1003040029210.28735@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1003040029210.28735@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>> If the __swap_duplicate returns a negative value except of the -ENOMEM,
>> but the err is zero at this time, the return value of swap_duplicate is
>> wrong in this situation.
>>
>> The caller, such as try_to_unmap_one(), will do the wrong operations too
>> in this situation.
>>
>> This patch fix it.
>>
>> Signed-off-by: Huang Shijie<shijie8@gmail.com>
>> ---
>>   mm/swapfile.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 6c0585b..191d8fa 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -2161,7 +2161,7 @@ int swap_duplicate(swp_entry_t entry)
>>   {
>>   	int err = 0;
>>
>> -	while (!err&&  __swap_duplicate(entry, 1) == -ENOMEM)
>> +	while (!err&&  (err = __swap_duplicate(entry, 1)) == -ENOMEM)
>>   		err = add_swap_count_continuation(entry, GFP_ATOMIC);
>>   	return err;
>>   }
>> -- 
>>      
> I was on the point of Ack'ing your patch, and despairing at my confusion,
> when I realized what's actually going on here - the key is (look at 2.6.32)
> swap_duplicate() used to be a void function (no error code whatsoever),
> until I added the -ENOMEM for swap_count_continuation.  And in fact your
> patch is wrong, copy_one_pte() does not want to add swap_count_continuation
>    
Yes,you are right, my patch is wrong in this situation.
> in the case when it hits a corrupt pte (one which looks like a swap entry).
>
> But you're absolutely right that it cries out for a comment:
>
>
> [PATCH] mm: add comment on swap_duplicate's error code
>
> swap_duplicate()'s loop appears to miss out on returning the error code
> from __swap_duplicate(), except when that's -ENOMEM.  In fact this is
> intentional: prior to -ENOMEM for swap_count_continuation, swap_duplicate()
> was void (and the case only occurs when copy_one_pte() hits a corrupt pte).
>    
only?

There are several paths calling the try_to_unmap(), Could you sure that
the swap entries are valid in all the paths ?

For the sake of the stability of the system, I perfer to export all the 
error value,
and check it carefully.

What about my following patch?

> But that's surprising behaviour, which certainly deserves a comment.
>
> Reported-by: Huang Shijie<shijie8@gmail.com>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>
>   mm/swapfile.c |    6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> --- 2633/mm/swapfile.c	2010-02-24 18:52:17.000000000 +0000
> +++ linux/mm/swapfile.c	2010-03-04 00:11:35.000000000 +0000
> @@ -2155,7 +2155,11 @@ void swap_shmem_alloc(swp_entry_t entry)
>   }
>
>   /*
> - * increase reference count of swap entry by 1.
> + * Increase reference count of swap entry by 1.
> + * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
> + * but could not be atomically allocated.  Returns 0, just as if it succeeded,
> + * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
> + * might occur if a page table entry has got corrupted.
>    */
>   int swap_duplicate(swp_entry_t entry)
>   {
>
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
