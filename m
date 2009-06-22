Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ECE456B004D
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 23:49:15 -0400 (EDT)
Received: by pzk34 with SMTP id 34so3000963pzk.12
        for <linux-mm@kvack.org>; Sun, 21 Jun 2009 20:50:48 -0700 (PDT)
Message-ID: <4A3EFF93.4000100@gmail.com>
Date: Mon, 22 Jun 2009 11:50:43 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove unused line for mmap_region()
References: <1245595421-3441-1-git-send-email-shijie8@gmail.com> <Pine.LNX.4.64.0906211917350.4583@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906211917350.4583@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> On Sun, 21 Jun 2009, Huang Shijie wrote:
>
>   
>> 	The variable pgoff is not used in the following codes.
>> 	So, just remove the line.
>>
>> Signed-off-by: Huang Shijie <shijie8@gmail.com>
>>     
>
> Hmm, hmm, well, I suppose a grudging Ack, though I'd happily be overruled.
>
> Of course you are right, so why am I so reluctant to acknowledge it?
>
> Because it's exceptional for addr and pgoff to be different after
> coming back from the file's ->mmap method, and if someone adds a
> use for pgoff lower down (there was, of course, a use for pgoff
> in vma_merge lower down, until Linus moved that higher in 2.6.29),
> it's a fair bet that they'll forget to restore the update you're
> removing, and a fair bet that nobody will notice that it's gone
> wrong for a while.
>
>   
I knew the file's ->mmap method can change addr and pgoff, but I think 
the comment of
DavidM is enough to remind the person who wants to use pgoff lower down 
that pgoff maybe
go wrong for a while.

But now, it (this line) looks like a big fly on 'Mona Lisa'. :)
> However, what would be likely to need pgoff lower down, other than
> another attempt at vma_merge?  And given how we're now working with
> the vma_merge higher up (before pgoff had a chance to be adjusted),
> I think we can conclude that anything needing to meddle with pgoff
> would be setting some vm_flags that prevent merging anyway.
>
>   
Could you tell some drivers which will meddle with pgoff?
If a driver changes pgoff,the work done by vma_merge higher up will be 
invalidated.
The process gets a wrong memory map.
> So I can just about bring myself to Ack your patch, but...
>
> Hugh
>
>   
>> ---
>>  mm/mmap.c |    1 -
>>  1 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 34579b2..1dd6aaa 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1210,7 +1210,6 @@ munmap_back:
>>  	 *         f_op->mmap method. -DaveM
>>  	 */
>>  	addr = vma->vm_start;
>> -	pgoff = vma->vm_pgoff;
>>  	vm_flags = vma->vm_flags;
>>  
>>  	if (vma_wants_writenotify(vma))
>> -- 
>> 1.6.0.6
>>     
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
