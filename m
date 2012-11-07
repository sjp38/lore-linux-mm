Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id BC4626B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 22:11:29 -0500 (EST)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TVw36-0006Bo-Mo
	for linux-mm@kvack.org; Wed, 07 Nov 2012 03:11:28 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so531843eaa.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 19:11:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121106152354.90150a3b.akpm@linux-foundation.org>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-2-git-send-email-ming.lei@canonical.com>
	<20121106152354.90150a3b.akpm@linux-foundation.org>
Date: Wed, 7 Nov 2012 11:11:24 +0800
Message-ID: <CACVXFVNs2JtEYQ3Y2rA8L89sAaMJ7TO-PxG3h4w+ihcZrBLtpg@mail.gmail.com>
Subject: Re: [PATCH v4 1/6] mm: teach mm by current context info to not do I/O
 during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Nov 7, 2012 at 7:23 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> It's unclear from the description why we're also clearing __GFP_FS in
> this situation.
>
> If we can avoid doing this then there will be a very small gain: there
> are some situations in which a filesystem can clean pagecache without
> performing I/O.

Firstly,  the patch follows the policy in the system suspend/resume situation,
in which the __GFP_FS is cleared, and basically the problem is very similar
with that in system PM path.

Secondly, inside shrink_page_list(), pageout() may be triggered on dirty anon
page if __GFP_FS is set.

IMO, if performing I/O can be completely avoided when __GFP_FS is set, the
flag can be kept, otherwise it is better to clear it in the situation.

>
> It doesn't appear that the patch will add overhead to the alloc/free
> hotpaths, which is good.

Thanks for previous Minchan's comment.

>
>>
>> ...
>>
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1805,6 +1805,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>>  #define PF_FROZEN    0x00010000      /* frozen for system suspend */
>>  #define PF_FSTRANS   0x00020000      /* inside a filesystem transaction */
>>  #define PF_KSWAPD    0x00040000      /* I am kswapd */
>> +#define PF_MEMALLOC_NOIO 0x00080000  /* Allocating memory without IO involved */
>>  #define PF_LESS_THROTTLE 0x00100000  /* Throttle me less: I clean memory */
>>  #define PF_KTHREAD   0x00200000      /* I am a kernel thread */
>>  #define PF_RANDOMIZE 0x00400000      /* randomize virtual address space */
>> @@ -1842,6 +1843,15 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>>  #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>>  #define used_math() tsk_used_math(current)
>>
>> +#define memalloc_noio() (current->flags & PF_MEMALLOC_NOIO)
>> +#define memalloc_noio_save(flag) do { \
>> +     (flag) = current->flags & PF_MEMALLOC_NOIO; \
>> +     current->flags |= PF_MEMALLOC_NOIO; \
>> +} while (0)
>> +#define memalloc_noio_restore(flag) do { \
>> +     current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flag; \
>> +} while (0)
>> +
>
> Again with the ghastly macros.  Please, do this properly in regular old
> C, as previously discussed.  It really doesn't matter what daft things
> local_irq_save() did 20 years ago.  Just do it right!

OK, I will take inline function in -v5.

>
> Also, you can probably put the unlikely() inside memalloc_noio() and
> avoid repeating it at all the callsites.
>
> And it might be neater to do:
>
> /*
>  * Nice comment goes here
>  */
> static inline gfp_t memalloc_noio_flags(gfp_t flags)
> {
>         if (unlikely(current->flags & PF_MEMALLOC_NOIO))
>                 flags &= ~GFP_IOFS;
>         return flags;
> }

But without the check in callsites, some local variables will be write
two times,
so it is better to not do it.

>
>>   * task->jobctl flags
>>   */
>>
>> ...
>>
>> @@ -2304,6 +2304,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>>               .gfp_mask = sc.gfp_mask,
>>       };
>>
>> +     if (unlikely(memalloc_noio())) {
>> +             gfp_mask &= ~GFP_IOFS;
>> +             sc.gfp_mask = gfp_mask;
>> +             shrink.gfp_mask = sc.gfp_mask;
>> +     }
>
> We can avoid writing to shrink.gfp_mask twice.  And maybe sc.gfp_mask
> as well.  Unclear, I didn't think about it too hard ;)

Yes, we can do it by initializing 'shrink' local variable just after the branch,
so one writing is enough. Will do it in -v5.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
