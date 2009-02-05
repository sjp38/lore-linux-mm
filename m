Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 77EE96B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 21:32:38 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id f25so7153rvb.26
        for <linux-mm@kvack.org>; Wed, 04 Feb 2009 18:32:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090205111507.803B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090204171639.ECCE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090204233543.GA26159@barrios-desktop>
	 <20090205111507.803B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Thu, 5 Feb 2009 11:32:36 +0900
Message-ID: <44c63dc40902041832n47d6a313h6b388c5a08dc58bf@mail.gmail.com>
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
From: MinChan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 5, 2009 at 11:17 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > and, I think current try_to_mlock_page() is correct. no need change.
>> > Why?
>> >
>> > 1. Generally, mmap_sem holding is necessary when vma->vm_flags accessed.
>> >    that's vma's basic rule.
>> > 2. However, try_to_unmap_one() doesn't held mamp_sem. but that's ok.
>> >    it often get incorrect result. but caller consider incorrect value safe.
>> > 3. try_to_mlock_page() need mmap_sem because it obey rule (1).
>> > 4. in try_to_mlock_page(), if down_read_trylock() is failure,
>> >    we can't move the page to unevictable list. but that's ok.
>> >    the page in evictable list is periodically try to reclaim. and
>> >    be called try_to_unmap().
>> >    try_to_unmap() (and its caller) also move the unevictable page to unevictable list.
>> >    Therefore, in long term view, the page leak is not happend.
>>
>> Thanks for clarification.
>> In long term view, you're right.
>>
>> but My concern is that munlock[all] pathes always hold down of mmap_sem.
>> After all, down_read_trylock always wil fail for such cases.
>>
>> So, current task's mlocked pages only can be reclaimed
>> by background or direct reclaim path if the task don't exit.
>>
>> I think it can increase reclaim overhead unnecessary
>> if there are lots of such tasks.
>>
>> What's your opinion ?
>
> I have 2 comment.
>
> 1. typical application never munlock()ed at all.

Sometime application of embedded can do it.
That's becuase they want deterministic page allocation in some situation.
However, It's not a matter in here.

>   and exit() path is already efficient.
>   then, I don't like hacky apploach.
> 2. I think we should drop mmap_sem holding in munlock path in the future.
>   at that time, this issue disappear automatically.
>   it's clean way more.

If we can drop mmap_sem in munlock path, I am happy, too.
Please, CCed me if you make a patch for it.

By that time, I will fold this issue. :)

>
> What do you think it?
>
>
>



-- 
Thanks,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
