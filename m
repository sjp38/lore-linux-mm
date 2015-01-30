Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA796B006E
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:30:54 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id gm9so23745712lab.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 05:30:53 -0800 (PST)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id wn10si10099718lac.76.2015.01.30.05.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jan 2015 05:30:52 -0800 (PST)
Message-ID: <54CB8789.9040206@yandex-team.ru>
Date: Fri, 30 Jan 2015 16:30:49 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't account shared file pages in user_reserve_pages
References: <1422532287-23601-1-git-send-email-klamm@yandex-team.ru> <20150129201147.GB9331@scruffy>
In-Reply-To: <20150129201147.GB9331@scruffy>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>, Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>

On 29.01.2015 23:11, Andrew Shewmaker wrote:
> On Thu, Jan 29, 2015 at 02:51:27PM +0300, Roman Gushchin wrote:
>> Shared file pages are never accounted in memory overcommit code,
>> so it isn't reasonable to count them in a code that limits the
>> maximal size of a process in OVERCOMMIT_NONE mode.
>>
>> If a process has few large file mappings, the consequent attempts
>> to allocate anonymous memory may unexpectedly fail with -ENOMEM,
>> while there is free memory and overcommit limit if significantly
>> larger than the committed amount (as displayed in /proc/meminfo).
>>
>> The problem is significantly smoothed by commit c9b1d0981fcc
>> ("mm: limit growth of 3% hardcoded other user reserve"),
>> which limits the impact of this check with 128Mb (tunable via sysctl),
>> but it can still be a problem on small machines.
>>
>> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Andrew Shewmaker <agshew@gmail.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> ---
>>   mm/mmap.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 7f684d5..151fadf 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -220,7 +220,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>>   	 */
>>   	if (mm) {
>>   		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
>> -		allowed -= min(mm->total_vm / 32, reserve);
>> +		allowed -= min((mm->total_vm - mm->shared_vm) / 32, reserve);
>>   	}
>>
>>   	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
>> --
>> 2.1.0
>
> You're two patches conflict, don't they? Maybe you should resend
> them as a patch series such that they can both be applied?

I think arithmetic overflow is more important. Upper bound 128M
for user reserve makes mis-accounting of shared memory mostly invisible.

>
> Does mm->shared_vm include memory that's mapped MAP_ANONYMOUS in
> conjunction with MAP_SHARED? If so, then subtracting it could
> overcommit the system OVERCOMMIT_NEVER mode.

Yep.

Moreover shared_vm also includes file mappings with MAP_PRIVATE.
It works more likely as "maybe shared", upper bound for "file-rss"
(MM_FILEPAGES).

I think we need here total size of vmas where VM_ACCOUNT is set --
writable private mappings mapped without MAP_NORESERVE or something
like that. But total_vm after limiting with 128Mb gives almost always
the same or similar value. So, let's keep it as is.

-- 
Konstantin

>
> -Andrew
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
