Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 339BA6B0100
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:10:24 -0400 (EDT)
Message-ID: <4F9AFD28.2030801@hp.com>
Date: Fri, 27 Apr 2012 16:10:16 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: prevent validate_slab() error due to race condition
References: <1335466658-29063-1-git-send-email-Waiman.Long@hp.com> <alpine.DEB.2.00.1204270911080.29198@router.home>
In-Reply-To: <alpine.DEB.2.00.1204270911080.29198@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Morris, Donald George (HP-UX Cupertino)" <don.morris@hp.com>

On 4/27/2012 10:59 AM, Christoph Lameter wrote:
> On Thu, 26 Apr 2012, Waiman Long wrote:
>
>> The SLUB memory allocator was changed substantially from 3.0 to 3.1 by
>> replacing some of page locking codes for updating the free object list
>> of the slab with double-quadword atomic exchange (cmpxchg_double_slab)
>> or a pseudo one using a page lock when debugging is turned on.  In the
>> normal case, that should be enough to make sure that the slab is in a
>> consistent state. However, when CONFIG_SLUB_DEBUG is turned on and the
>> Redzone debugging flag is set, the Redzone bytes are also used to mark
>> if an object is free or allocated. The extra state information in those
>> Redzone bytes is not protected by the cmpxchg_double_slab(). As a
>> result,
>> validate_slab() may report a Redzone error if the validation is
>> performed
>> while racing with a free to a debugged slab.
> Right. The problem is unique to validate_slab because no one else outside
> the slab has access to that object that is to be freed.
>
>> This patch fixes the BUG message by acquiring the node-level lock for
>> slabs flagged for debugging to avoid this possible racing condition.
>> The locking is done on the node-level lock instead of the more granular
>> page lock because the new code may speculatively acquire the node-level
>> lock later on. Acquiring the page lock and then the node lock may lead
>> to potential deadlock.
> Correct that would address the issue.
>
>> As the increment of slab node count and insertion of the new slab into
>> the partial or full slab list is not an atomic operation, there is a
>> small time window where the two may not match. This patch temporarily
>> works around this problem by allowing the node count to be one larger
>> than the number of slab presents in the lists. This workaround may not
>> work if more than one CPU is actively adding slab to the same node,
>> but it should be good enough to workaround the problem in most cases.
> Well yeah that is not a real fix. Its been racy for a long time.
>
>> To really fix the issue, the overall synchronization between debug slub
>> operations and slub validation needs a revisit.
> True. The sync between validation and concurrent operations was not in
> focus so far. Validation was used (at least by me) so far only to validate
> that the slab structures are still okay after running some tests.
>
> Lets just do this in steps. First patch here is a simple taking of the
> node lock in free_debug_processing. This is similar to what you have done
> but the changes are made to the debugging function instead. Then we can
> look at how to address the slab counting issue in a separate patch.
>

Thank for the quick response. I have no problem for moving the node-lock 
taking into free_debug_processing. Of the 2 problems that are reported, 
this is a more serious one and so need to be fixed sooner rather than 
later. For the other one, we can take more time to find a better solution.

So are you going to integrate your change to the mainline?

> Subject: slub: Take node lock during object free checks
>
> This is needed for proper synchronization with validate_slab()
> as pointed out by Waiman Long<Waiman.Long@hp.com>
>
> Reported-by: Waiman Long<Waiman.Long@hp.com>
> Signed-off-by: Christoph Lameter<cl@linux.com>
>
>
> ---
>   mm/slub.c |   30 ++++++++++++++++++------------
>   1 file changed, 18 insertions(+), 12 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2012-04-27 09:40:00.000000000 -0500
> +++ linux-2.6/mm/slub.c	2012-04-27 09:50:15.000000000 -0500
> @@ -1082,13 +1082,13 @@ bad:
>   	return 0;
>   }
>
> -static noinline int free_debug_processing(struct kmem_cache *s,
> -		 struct page *page, void *object, unsigned long addr)
> +static noinline struct kmem_cache_node *free_debug_processing(
> +	struct kmem_cache *s, struct page *page, void *object,
> +	unsigned long addr, unsigned long *flags)
>   {
> -	unsigned long flags;
> -	int rc = 0;
> +	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
>
> -	local_irq_save(flags);
> +	spin_lock_irqsave(&n->list_lock, *flags);
>   	slab_lock(page);
>
>   	if (!check_slab(s, page))
> @@ -1126,15 +1126,19 @@ static noinline int free_debug_processin
>   		set_track(s, object, TRACK_FREE, addr);
>   	trace(s, page, object, 0);
>   	init_object(s, object, SLUB_RED_INACTIVE);
> -	rc = 1;
>   out:
>   	slab_unlock(page);
> -	local_irq_restore(flags);
> -	return rc;
> +	/*
> +	 * Keep node_lock to preserve integrity
> +	 * until the object is actually freed
> +	 */
> +	return n;
>
>   fail:
> +	slab_unlock(page);
> +	spin_unlock_irqrestore(&n->list_lock, *flags);
>   	slab_fix(s, "Object at 0x%p not freed", object);
> -	goto out;
> +	return NULL;
>   }
>
>   static int __init setup_slub_debug(char *str)
> @@ -1227,8 +1231,9 @@ static inline void setup_object_debug(st
>   static inline int alloc_debug_processing(struct kmem_cache *s,
>   	struct page *page, void *object, unsigned long addr) { return 0; }
>
> -static inline int free_debug_processing(struct kmem_cache *s,
> -	struct page *page, void *object, unsigned long addr) { return 0; }
> +static inline struct kmem_cache_node *free_debug_processing(
> +	struct kmem_cache *s, struct page *page, void *object,
> +	unsigned long addr, unsigned long *flags) { return NULL; }
>
>   static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
>   			{ return 1; }
> @@ -2445,7 +2450,8 @@ static void __slab_free(struct kmem_cach
>
>   	stat(s, FREE_SLOWPATH);
>
> -	if (kmem_cache_debug(s)&&  !free_debug_processing(s, page, x, addr))
> +	if (kmem_cache_debug(s)&&
> +		!(n = free_debug_processing(s, page, x, addr,&flags)))
>   		return;
>
>   	do {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
