Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 470456B020A
	for <linux-mm@kvack.org>; Thu, 13 May 2010 07:26:26 -0400 (EDT)
Date: Thu, 13 May 2010 12:26:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/5] extend KSM refcounts to the anon_vma root
Message-ID: <20100513112603.GB27949@csn.ul.ie>
References: <20100512134111.467fb6c2@annuminas.surriel.com> <20100512210706.GQ24989@csn.ul.ie> <4BEB18FE.1090808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BEB18FE.1090808@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 12, 2010 at 05:09:18PM -0400, Rik van Riel wrote:
> On 05/12/2010 05:07 PM, Mel Gorman wrote:
>> On Wed, May 12, 2010 at 01:41:11PM -0400, Rik van Riel wrote:
>>> Subject: extend KSM refcounts to the anon_vma root
>>>
>>> KSM reference counts can cause an anon_vma to exist after the processe
>>> it belongs to have already exited.  Because the anon_vma lock now lives
>>> in the root anon_vma, we need to ensure that the root anon_vma stays
>>> around until after all the "child" anon_vmas have been freed.
>>>
>>> The obvious way to do this is to have a "child" anon_vma take a
>>> reference to the root in anon_vma_fork.  When the anon_vma is freed
>>> at munmap or process exit, we drop the refcount in anon_vma_unlink
>>> and possibly free the root anon_vma.
>>>
>>> The KSM anon_vma reference count function also needs to be modified
>>> to deal with the possibility of freeing 2 levels of anon_vma.  The
>>> easiest way to do this is to break out the KSM magic and make it
>>> generic.
>>>
>>> When compiling without CONFIG_KSM, this code is compiled out.
>>>
>>> Signed-off-by: Rik van Riel<riel@redhat.com>
>>> ---
>>>   include/linux/rmap.h |   12 ++++++++++++
>>>   mm/ksm.c             |   17 ++++++-----------
>>>   mm/rmap.c            |   45 ++++++++++++++++++++++++++++++++++++++++++++-
>>>   3 files changed, 62 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>>> index 33ffe14..387d40c 100644
>>> --- a/include/linux/rmap.h
>>> +++ b/include/linux/rmap.h
>>> @@ -126,6 +126,18 @@ int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
>>>   void __anon_vma_link(struct vm_area_struct *);
>>>   void anon_vma_free(struct anon_vma *);
>>>
>>> +#ifdef CONFIG_KSM
>>> +static inline void get_anon_vma(struct anon_vma *anon_vma)
>>> +{
>>> +	atomic_inc(&anon_vma->ksm_refcount);
>>> +}
>>> +
>>> +void drop_anon_vma(struct anon_vma *);
>>> +#else
>>> +#define get_anon_vma(x)		do {} while(0)
>>> +#define drop_anon_vma(x)	do {} while(0)
>>> +#endif
>>> +
>>>   static inline void anon_vma_merge(struct vm_area_struct *vma,
>>>   				  struct vm_area_struct *next)
>>>   {
>>> diff --git a/mm/ksm.c b/mm/ksm.c
>>> index 7ca0dd7..9f2acc9 100644
>>> --- a/mm/ksm.c
>>> +++ b/mm/ksm.c
>>> @@ -318,19 +318,14 @@ static void hold_anon_vma(struct rmap_item *rmap_item,
>>>   			  struct anon_vma *anon_vma)
>>>   {
>>>   	rmap_item->anon_vma = anon_vma;
>>> -	atomic_inc(&anon_vma->ksm_refcount);
>>> +	get_anon_vma(anon_vma);
>>>   }
>>
>> I'm not quite getting this. Here, we get the local anon_vma so we
>> increment its reference count and later we drop it but without a
>> refcount taken on the root anon_vma, why is it guaranteed to stay
>> around?
>
> Because anon_vma_fork takes a reference count on the root anon_vma,
> the VMA we take a refcount on will either have a refcount on the
> root, or it is the root.
>

Sorry, I'm still not getting it. anon_vma_fork keeps the refcount around
during fork but what about during exit? Lets say anon_vma_unlink is called
on the following arrangement;

root_anon_vma->refcounted_anon_vma

We walk the list but the root_anon_vma doesn't have a refcount so it
gets freed. drop_anon_vma gets called on refcounted_anon_vma which does

if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->root->lock))

but the root anon_vma is now gone. Are you depending on the lifecycle of
anon_vma's within KSM for this to work? If so, then the migration-related
fixes in mmotm that take a refcount on anon_vma during migration will also
need to take a refcount on the root.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
