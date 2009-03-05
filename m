Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8CB6A6B00D0
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 17:23:46 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id k29so132043rvb.26
        for <linux-mm@kvack.org>; Thu, 05 Mar 2009 14:23:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0903042350210.5511@xanadu.home>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
	 <20090304171429.c013013c.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
	 <20090305080717.f7832c63.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903042129140.5511@xanadu.home>
	 <20090305132054.888396da.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903042350210.5511@xanadu.home>
Date: Fri, 6 Mar 2009 07:23:44 +0900
Message-ID: <28c262360903051423g1fbf5067i9835099d4bf324ae@mail.gmail.com>
Subject: Re: [RFC] atomic highmem kmap page pinning
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nicolas Pitre <nico@cam.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Russell King - ARM Linux <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 5, 2009 at 1:57 PM, Nicolas Pitre <nico@cam.org> wrote:
> On Thu, 5 Mar 2009, Minchan Kim wrote:
>
>> On Wed, 04 Mar 2009 21:37:43 -0500 (EST)
>> Nicolas Pitre <nico@cam.org> wrote:
>>
>> > My assertion is that the cost is negligible. =C2=A0This is why I'm ask=
ing you
>> > why you think this is a big cost.
>>
>> Of course, I am not sure whether it's big cost or not.
>> But I thought it already is used in many fs, driver.
>> so, whether it's big cost depends on workload type .
>>
>> However, This patch is needed for VIVT and no coherent cache.
>> Is right ?
>>
>> If it is right, it will add unnessary overhead in other architecture
>> which don't have this problem.
>>
>> I think it's not desirable although it is small cost.
>> If we have a other method which avoids unnessary overhead, It would be b=
etter.
>> Unfortunately, I don't have any way to solve this, now.
>
> OK. =C2=A0What about this patch then:

It looks good to me except one thing below.
Reviewed-by: MinChan Kim <minchan.kim@gmail.com>

> From c4db60c3a2395476331b62e08cf1f64fc9af8d54 Mon Sep 17 00:00:00 2001
> From: Nicolas Pitre <nico@cam.org>
> Date: Wed, 4 Mar 2009 22:49:41 -0500
> Subject: [PATCH] atomic highmem kmap page pinning
>
> Most ARM machines have a non IO coherent cache, meaning that the
> dma_map_*() set of functions must clean and/or invalidate the affected
> memory manually before DMA occurs. =C2=A0And because the majority of thos=
e
> machines have a VIVT cache, the cache maintenance operations must be
> performed using virtual
> addresses.
>
> When a highmem page is kunmap'd, its mapping (and cache) remains in place
> in case it is kmap'd again. However if dma_map_page() is then called with
> such a page, some cache maintenance on the remaining mapping must be
> performed. In that case, page_address(page) is non null and we can use
> that to synchronize the cache.
>
> It is unlikely but still possible for kmap() to race and recycle the
> virtual address obtained above, and use it for another page before some
> on-going cache invalidation loop in dma_map_page() is done. In that case,
> the new mapping could end up with dirty cache lines for another page,
> and the unsuspecting cache invalidation loop in dma_map_page() might
> simply discard those dirty cache lines resulting in data loss.
>
> For example, let's consider this sequence of events:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- dma_map_page(..., DMA_FROM_DEVICE) is called=
 on a highmem page.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0--> =C2=A0 =C2=A0 - vaddr =3D page_address(pag=
e) is non null. In this case
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0it is likely that =
the page has valid cache lines
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0associated with va=
ddr. Remember that the cache is VIVT.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0--> =C2=A0 =C2=A0 =
for (i =3D vaddr; i < vaddr + PAGE_SIZE; i +=3D 32)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0invalidate_cache_line(i);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*** preemption occurs in the middle of the loo=
p above ***
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- kmap_high() is called for a different page.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0--> =C2=A0 =C2=A0 - last_pkmap_nr wraps to zer=
o and flush_all_zero_pkmaps()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0is called. =
=C2=A0The pkmap_count value for the page passed
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0to dma_map_=
page() above happens to be 1, so the page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0is unmapped=
. =C2=A0But prior to that, flush_cache_kmaps()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cleared the=
 cache for it. =C2=A0So far so good.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- A fresh pkmap en=
try is assigned for this kmap request.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0The Murphy =
law says this pkmap entry will eventually
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0happen to u=
se the same vaddr as the one which used to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0belong to t=
he other page being processed by
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_map_pag=
e() in the preempted thread above.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- The kmap_high() caller start dirtying the ca=
che using the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0just assigned virtual mapping for its p=
age.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*** the first thread is rescheduled ***
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0- The for(...) loop is resumed, but now cached
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0data belonging to a different physical page is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0being discarded !
>
> And this is not only a preemption issue as ARM can be SMP as well,
> making the above scenario just as likely. Hence the need for some kind
> of pkmap page pinning which can be used in any context, primarily for
> the benefit of dma_map_page() on ARM.
>
> This provides the necessary interface to cope with the above issue if
> ARCH_NEEDS_KMAP_HIGH_GET is defined, otherwise the resulting code is
> unchanged.
>
> Signed-off-by: Nicolas Pitre <nico@marvell.com>
>
> diff --git a/mm/highmem.c b/mm/highmem.c
> index b36b83b..cc61399 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -67,6 +67,25 @@ pte_t * pkmap_page_table;
>
> =C2=A0static DECLARE_WAIT_QUEUE_HEAD(pkmap_map_wait);
>
> +/*
> + * Most architectures have no use for kmap_high_get(), so let's abstract
> + * the disabling of IRQ out of the locking in that case to save on a
> + * potential useless overhead.
> + */
> +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
> +#define spin_lock_kmap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_=
lock_irq(&kmap_lock)
> +#define spin_unlock_kmap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unloc=
k_irq(&kmap_lock)
> +#define spin_lock_kmap_any(flags) =C2=A0 =C2=A0spin_lock_irqsave(&kmap_l=
ock, flags)
> +#define spin_unlock_kmap_any(flags) =C2=A0spin_unlock_irqrestore(&kmap_l=
ock, flags)
> +#else
> +#define spin_lock_kmap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_=
lock(&kmap_lock)
> +#define spin_unlock_kmap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unloc=
k(&kmap_lock)
> +#define spin_lock_kmap_any(flags) =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 do { spin_lock(&kmap_lock); (void)(flags); } while=
 (0)
> +#define spin_unlock_kmap_any(flags) =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 do { spin_unlock(&kmap_lock); (void)(flags); } whi=
le (0)
> +#endif
> +
> =C2=A0static void flush_all_zero_pkmaps(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> @@ -113,9 +132,9 @@ static void flush_all_zero_pkmaps(void)
> =C2=A0*/
> =C2=A0void kmap_flush_unused(void)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 spin_lock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_kmap();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0flush_all_zero_pkmaps();
> - =C2=A0 =C2=A0 =C2=A0 spin_unlock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_kmap();
> =C2=A0}
>
> =C2=A0static inline unsigned long map_new_virtual(struct page *page)
> @@ -145,10 +164,10 @@ start:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__set_current_state(TASK_UNINTERRUPTIBLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0add_wait_queue(&pkmap_map_wait, &wait);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock_kmap();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0schedule();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0remove_wait_queue(&pkmap_map_wait, &wait);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_lock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_lock_kmap();
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* Somebody else might have mapped it while we slept */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (page_address(page))
> @@ -184,29 +203,59 @@ void *kmap_high(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * For highmem pages, we can't trust "virtual"=
 until
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * after we have the lock.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 spin_lock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_kmap();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0vaddr =3D (unsigned long)page_address(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!vaddr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vaddr =3D map_new_=
virtual(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pkmap_count[PKMAP_NR(vaddr)]++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 2);
> - =C2=A0 =C2=A0 =C2=A0 spin_unlock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_kmap();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return (void*) vaddr;
> =C2=A0}
>
> =C2=A0EXPORT_SYMBOL(kmap_high);
>
> +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
> +/**
> + * kmap_high_get - pin a highmem page into memory
> + * @page: &struct page to pin
> + *
> + * Returns the page's current virtual memory address, or NULL if no mapp=
ing
> + * exists. =C2=A0When and only when a non null address is returned then =
a
> + * matching call to kunmap_high() is necessary.
> + *
> + * This can be called from any context.
> + */
> +void *kmap_high_get(struct page *page)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long vaddr, flags;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_kmap_any(flags);
> + =C2=A0 =C2=A0 =C2=A0 vaddr =3D (unsigned long)page_address(page);
> + =C2=A0 =C2=A0 =C2=A0 if (vaddr) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(pkmap_count[PKM=
AP_NR(vaddr)] < 1);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pkmap_count[PKMAP_NR(v=
addr)]++;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_kmap_any(flags);
> + =C2=A0 =C2=A0 =C2=A0 return (void*) vaddr;
> +}
> +#endif

Let's add empty function for architecture of no ARCH_NEEDS_KMAP_HIGH_GET,

> +
> =C2=A0/**
> =C2=A0* kunmap_high - map a highmem page into memory
> =C2=A0* @page: &struct page to unmap
> + *
> + * If ARCH_NEEDS_KMAP_HIGH_GET is not defined then this may be called
> + * only from user context.
> =C2=A0*/
> =C2=A0void kunmap_high(struct page *page)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int need_wakeup;
>
> - =C2=A0 =C2=A0 =C2=A0 spin_lock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_kmap_any(flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0vaddr =3D (unsigned long)page_address(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!vaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr =3D PKMAP_NR(vaddr);
> @@ -232,7 +281,7 @@ void kunmap_high(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0need_wakeup =3D wa=
itqueue_active(&pkmap_map_wait);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 spin_unlock(&kmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_kmap_any(flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* do wake-up, if needed, race-free outside of=
 the spin lock */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (need_wakeup)
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
