Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 20B8B6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 03:36:37 -0400 (EDT)
Message-ID: <4FB0B61E.6040902@kernel.org>
Date: Mon, 14 May 2012 16:37:02 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Allow migration of mlocked page?
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>  <4FB0866D.4020203@kernel.org> <1336978573.2443.13.camel@twins>
In-Reply-To: <1336978573.2443.13.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On 05/14/2012 03:56 PM, Peter Zijlstra wrote:

> On Mon, 2012-05-14 at 13:13 +0900, Minchan Kim wrote:
>> On 05/11/2012 06:20 PM, Peter Zijlstra wrote:
>>
>>> On Fri, 2012-05-11 at 13:37 +0900, Minchan Kim wrote:
>>>> I hope hear opinion from rt guys, too.
>>>
>>> Its a problem yes, not sure your solution is any good though. As it
>>> stands mlock() simply doesn't guarantee no faults, all it does is
>>> guarantee no major faults.
>>
>>
>> I can't find such definition from man pages
>> "
>>        Real-time  processes  that are using mlockall() to prevent delays on page faults should
>>        reserve enough locked stack pages before entering the time-critical section, so that no
>>        page fault can be caused by function calls
>> "
>> So I didn't expect it. Is your definition popular available on server RT?
>> At least, embedded guys didn't expect it.
> 
> Sod the manpage, the opengroup.org definition only states the page will
> not be paged-out.
> 
>   http://pubs.opengroup.org/onlinepubs/009604599/functions/mlock.html
> 
> It only states: 'shall be memory resident' that very much implies no
> major faults. But I cannot make that mean no minor faults.


Yes and I saw this
'Upon successful return from mlock(), pages in the specified range shall be locked and memory-resident' 
It said "locked and memory-resident".

What's the meaning of "locked"? Isn't it pinning?

> 
> 
> Also, no clue what the userspace guys know or think to know, in my
> experience they get it wrong anyway, regardless of what the manpage/spec
> says.
> 
> But I've been telling the -rt folks for a long while that mlock only
> guarantees no major faults for a while now (although apparently that's
> not entirely true with current kernels, but see below).
> 
>>> Its sad that mlock() doesn't take a flags argument, so I'd rather
>>> introduce a new madvise() flag for -rt, something like MADV_UNMOVABLE
>>> (or whatever) which will basically copy the pages to an un-movable page
>>> block and really pin the things.
>>
>>
>> 1) We don't have space of vm_flags in 32bit machine and Konstantin
>>    have sorted out but not sure it's merged. Anyway, Okay. It couldn't be a problem.
> 
> Or we just make the thing u64... :-)
> 
>> 2) It needs application's fix and as Mel said, we might get new bug reports about latency.
>>    Doesn't it break current mlock semantic? - " no page fault can be caused by function calls"
>>    Otherwise, we should fix man page like your saying -   "no major page fault can be caused by function calls" 
> 
> Well, if you look at v2.6.18:mm/rmap.c it would actually migrate mlocked
> pages (which is what I remembered):
> 
>         if (!migration && ((vma->vm_flags & VM_LOCKED) ||
>                         (ptep_clear_flush_young(vma, address, pte)))) {
>                 ret = SWAP_FAIL;
>                 goto out_unmap;
>         }
> 
> So somewhere someone changed mlock() semantics already.


Yes. migrate_pages, cpuset_migrate_mm and memcg alreay seem to break it.
I think they all is done by under user's control while compaction happens regardless of user's intention.
I'm not sure they could be excused althoug it's done by user's control. :(


> 
> But yes, its going to cause pain whichever way around.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
