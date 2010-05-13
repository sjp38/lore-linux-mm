Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9C60F6B0225
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:12:04 -0400 (EDT)
Message-ID: <4BEBFA82.2000301@redhat.com>
Date: Thu, 13 May 2010 09:11:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] extend KSM refcounts to the anon_vma root
References: <20100512134111.467fb6c2@annuminas.surriel.com> <20100512210706.GQ24989@csn.ul.ie> <4BEB18FE.1090808@redhat.com> <20100513112603.GB27949@csn.ul.ie>
In-Reply-To: <20100513112603.GB27949@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/13/2010 07:26 AM, Mel Gorman wrote:
> On Wed, May 12, 2010 at 05:09:18PM -0400, Rik van Riel wrote:
>> On 05/12/2010 05:07 PM, Mel Gorman wrote:
>>> On Wed, May 12, 2010 at 01:41:11PM -0400, Rik van Riel wrote:
>>>> Subject: extend KSM refcounts to the anon_vma root
>>>>
>>>> KSM reference counts can cause an anon_vma to exist after the processe
>>>> it belongs to have already exited.  Because the anon_vma lock now lives
>>>> in the root anon_vma, we need to ensure that the root anon_vma stays
>>>> around until after all the "child" anon_vmas have been freed.
>>>>
>>>> The obvious way to do this is to have a "child" anon_vma take a
>>>> reference to the root in anon_vma_fork.  When the anon_vma is freed
>>>> at munmap or process exit, we drop the refcount in anon_vma_unlink
>>>> and possibly free the root anon_vma.
>>>>
>>>> The KSM anon_vma reference count function also needs to be modified
>>>> to deal with the possibility of freeing 2 levels of anon_vma.  The
>>>> easiest way to do this is to break out the KSM magic and make it
>>>> generic.
>>>>
>>>> When compiling without CONFIG_KSM, this code is compiled out.
>>>>
>>>> Signed-off-by: Rik van Riel<riel@redhat.com>
>>>> ---
>>>>    include/linux/rmap.h |   12 ++++++++++++
>>>>    mm/ksm.c             |   17 ++++++-----------
>>>>    mm/rmap.c            |   45 ++++++++++++++++++++++++++++++++++++++++++++-
>>>>    3 files changed, 62 insertions(+), 12 deletions(-)
>>>>
>>>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>>>> index 33ffe14..387d40c 100644
>>>> --- a/include/linux/rmap.h
>>>> +++ b/include/linux/rmap.h
>>>> @@ -126,6 +126,18 @@ int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
>>>>    void __anon_vma_link(struct vm_area_struct *);
>>>>    void anon_vma_free(struct anon_vma *);
>>>>
>>>> +#ifdef CONFIG_KSM
>>>> +static inline void get_anon_vma(struct anon_vma *anon_vma)
>>>> +{
>>>> +	atomic_inc(&anon_vma->ksm_refcount);
>>>> +}
>>>> +
>>>> +void drop_anon_vma(struct anon_vma *);
>>>> +#else
>>>> +#define get_anon_vma(x)		do {} while(0)
>>>> +#define drop_anon_vma(x)	do {} while(0)
>>>> +#endif
>>>> +
>>>>    static inline void anon_vma_merge(struct vm_area_struct *vma,
>>>>    				  struct vm_area_struct *next)
>>>>    {
>>>> diff --git a/mm/ksm.c b/mm/ksm.c
>>>> index 7ca0dd7..9f2acc9 100644
>>>> --- a/mm/ksm.c
>>>> +++ b/mm/ksm.c
>>>> @@ -318,19 +318,14 @@ static void hold_anon_vma(struct rmap_item *rmap_item,
>>>>    			  struct anon_vma *anon_vma)
>>>>    {
>>>>    	rmap_item->anon_vma = anon_vma;
>>>> -	atomic_inc(&anon_vma->ksm_refcount);
>>>> +	get_anon_vma(anon_vma);
>>>>    }
>>>
>>> I'm not quite getting this. Here, we get the local anon_vma so we
>>> increment its reference count and later we drop it but without a
>>> refcount taken on the root anon_vma, why is it guaranteed to stay
>>> around?
>>
>> Because anon_vma_fork takes a reference count on the root anon_vma,
>> the VMA we take a refcount on will either have a refcount on the
>> root, or it is the root.
>>
>
> Sorry, I'm still not getting it. anon_vma_fork keeps the refcount around
> during fork but what about during exit?

It is kept around all the way from fork until exit.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
