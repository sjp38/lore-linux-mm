Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 9F70F6B0044
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 02:59:37 -0400 (EDT)
Message-ID: <504C3DCF.9090702@mellanox.com>
Date: Sun, 9 Sep 2012 09:57:19 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix compile warning of mmotm-2012-09-06-16-46
References: <1346979430-23110-1-git-send-email-minchan@kernel.org> <20120907130605.be86f2a9.akpm@linux-foundation.org>
In-Reply-To: <20120907130605.be86f2a9.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Sagi Grimberg <sagig@mellanox.com>

On Sep 7 2012 23:06, Andrew Morton wrote:
> On Fri,  7 Sep 2012 09:57:10 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
>> When I compiled today, I met following warning.
>> Correct it.
>>
>> mm/memory.c: In function ___copy_page_range___:
>> include/linux/mmu_notifier.h:235:38: warning: ___mmun_end___ may be used uninitialized in this function [-Wuninitialized]
>> mm/memory.c:1043:16: note: ___mmun_end___ was declared here
>> include/linux/mmu_notifier.h:235:38: warning: ___mmun_start___ may be used uninitialized in this function [-Wuninitialized]
>> mm/memory.c:1042:16: note: ___mmun_start___ was declared here
>>   LD      mm/built-in.o
>>
>> Cc: Sagi Grimberg <sagig@mellanox.com>
>> Cc: Haggai Eran <haggaie@mellanox.com>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  mm/memory.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 10e9b38..d000449 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1039,8 +1039,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>>  	unsigned long next;
>>  	unsigned long addr = vma->vm_start;
>>  	unsigned long end = vma->vm_end;
>> -	unsigned long mmun_start;	/* For mmu_notifiers */
>> -	unsigned long mmun_end;		/* For mmu_notifiers */
>> +	unsigned long uninitialized_var(mmun_start);	/* For mmu_notifiers */
>> +	unsigned long uninitialized_var(mmun_end);	/* For mmu_notifiers */
>>  	int ret;
>>  
> 
> Well yes, but a) uninitialized_var is a bit ugly and has some potential
> to hide real bugs and b) it's not completely obvious that
> is_cow_mapping() is stable across those two calls.
I thought that code that changed the vm_flags would need mmap_sem locked
exclusively, and copy_page_range is also called with the mmap_sem
locked, so that would prevent is_cow_mapping() from changing, wouldn't it?

> 
> I think a better approach is this:
> 
> --- a/mm/memory.c~mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix-fix
> +++ a/mm/memory.c
> @@ -1041,6 +1041,7 @@ int copy_page_range(struct mm_struct *ds
>  	unsigned long end = vma->vm_end;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> +	bool is_cow;
>  	int ret;
>  
>  	/*
> @@ -1074,7 +1075,8 @@ int copy_page_range(struct mm_struct *ds
>  	 * parent mm. And a permission downgrade will only happen if
>  	 * is_cow_mapping() returns true.
>  	 */
> -	if (is_cow_mapping(vma->vm_flags)) {
> +	is_cow = is_cow_mapping(vma->vm_flags);
> +	if (is_cow) {
>  		mmun_start = addr;
>  		mmun_end   = end;
>  		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
> @@ -1095,7 +1097,7 @@ int copy_page_range(struct mm_struct *ds
>  		}
>  	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
>  
> -	if (is_cow_mapping(vma->vm_flags))
> +	if (is_cow)
>  		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
>  	return ret;
>  }
> 
> Unfortunately, my (old) versions of gcc are so stupid that they *still*
> generate the warning even when the code is as obviously correct as this :(
> 
> Can you please test it with your compiler?
With GCC 4.4.4 I still get these warnings, even with the is_cow
variable. Sorry I haven't noticed that before. Perhaps I can move the
initialization of mmun_start/end before the if.

By the way, with GCC 4.4.4 I don't get the warning in do_wp_page.

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
