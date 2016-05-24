Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7990F6B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 16:43:48 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so13562572lbb.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 13:43:48 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com. [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id bb5si4234026lbc.124.2016.05.24.13.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 13:43:46 -0700 (PDT)
Received: by mail-lb0-x236.google.com with SMTP id k7so9344121lbm.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 13:43:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524190433.GC3354@mtj.duckdns.org>
References: <5713C0AD.3020102@oracle.com> <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz> <5742F267.3000309@suse.cz> <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz> <20160524153029.GA3354@mtj.duckdns.org> <20160524190433.GC3354@mtj.duckdns.org>
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 24 May 2016 13:43:26 -0700
Message-ID: <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
Subject: Re: bpf: use-after-free in array_map_alloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>

On Tue, May 24, 2016 at 12:04 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> Alexei, can you please verify this patch?  Map extension got rolled
> into balance work so that there's no sync issues between the two async
> operations.

tests look good. No uaf and basic bpf tests exercise per-cpu map are fine.

>
> Thanks.
>
> Index: work/mm/percpu.c
> ===================================================================
> --- work.orig/mm/percpu.c
> +++ work/mm/percpu.c
> @@ -112,7 +112,7 @@ struct pcpu_chunk {
>         int                     map_used;       /* # of map entries used before the sentry */
>         int                     map_alloc;      /* # of map entries allocated */
>         int                     *map;           /* allocation map */
> -       struct work_struct      map_extend_work;/* async ->map[] extension */
> +       struct list_head        map_extend_list;/* on pcpu_map_extend_chunks */
>
>         void                    *data;          /* chunk data */
>         int                     first_free;     /* no free below this */
> @@ -162,10 +162,13 @@ static struct pcpu_chunk *pcpu_reserved_
>  static int pcpu_reserved_chunk_limit;
>
>  static DEFINE_SPINLOCK(pcpu_lock);     /* all internal data structures */
> -static DEFINE_MUTEX(pcpu_alloc_mutex); /* chunk create/destroy, [de]pop */
> +static DEFINE_MUTEX(pcpu_alloc_mutex); /* chunk create/destroy, [de]pop, map ext */
>
>  static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
>
> +/* chunks which need their map areas extended, protected by pcpu_lock */
> +static LIST_HEAD(pcpu_map_extend_chunks);
> +
>  /*
>   * The number of empty populated pages, protected by pcpu_lock.  The
>   * reserved chunk doesn't contribute to the count.
> @@ -395,13 +398,19 @@ static int pcpu_need_to_extend(struct pc
>  {
>         int margin, new_alloc;
>
> +       lockdep_assert_held(&pcpu_lock);
> +
>         if (is_atomic) {
>                 margin = 3;
>
>                 if (chunk->map_alloc <
> -                   chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW &&
> -                   pcpu_async_enabled)
> -                       schedule_work(&chunk->map_extend_work);
> +                   chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
> +                       if (list_empty(&chunk->map_extend_list)) {
> +                               list_add_tail(&chunk->map_extend_list,
> +                                             &pcpu_map_extend_chunks);
> +                               pcpu_schedule_balance_work();
> +                       }
> +               }
>         } else {
>                 margin = PCPU_ATOMIC_MAP_MARGIN_HIGH;
>         }
> @@ -435,6 +444,8 @@ static int pcpu_extend_area_map(struct p
>         size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
>         unsigned long flags;
>
> +       lockdep_assert_held(&pcpu_alloc_mutex);
> +
>         new = pcpu_mem_zalloc(new_size);
>         if (!new)
>                 return -ENOMEM;
> @@ -467,20 +478,6 @@ out_unlock:
>         return 0;
>  }
>
> -static void pcpu_map_extend_workfn(struct work_struct *work)
> -{
> -       struct pcpu_chunk *chunk = container_of(work, struct pcpu_chunk,
> -                                               map_extend_work);
> -       int new_alloc;
> -
> -       spin_lock_irq(&pcpu_lock);
> -       new_alloc = pcpu_need_to_extend(chunk, false);
> -       spin_unlock_irq(&pcpu_lock);
> -
> -       if (new_alloc)
> -               pcpu_extend_area_map(chunk, new_alloc);
> -}
> -
>  /**
>   * pcpu_fit_in_area - try to fit the requested allocation in a candidate area
>   * @chunk: chunk the candidate area belongs to
> @@ -740,7 +737,7 @@ static struct pcpu_chunk *pcpu_alloc_chu
>         chunk->map_used = 1;
>
>         INIT_LIST_HEAD(&chunk->list);
> -       INIT_WORK(&chunk->map_extend_work, pcpu_map_extend_workfn);
> +       INIT_LIST_HEAD(&chunk->map_extend_list);
>         chunk->free_size = pcpu_unit_size;
>         chunk->contig_hint = pcpu_unit_size;
>
> @@ -895,6 +892,9 @@ static void __percpu *pcpu_alloc(size_t
>                 return NULL;
>         }
>
> +       if (!is_atomic)
> +               mutex_lock(&pcpu_alloc_mutex);
> +
>         spin_lock_irqsave(&pcpu_lock, flags);
>
>         /* serve reserved allocations from the reserved chunk if available */
> @@ -967,12 +967,9 @@ restart:
>         if (is_atomic)
>                 goto fail;
>
> -       mutex_lock(&pcpu_alloc_mutex);
> -
>         if (list_empty(&pcpu_slot[pcpu_nr_slots - 1])) {
>                 chunk = pcpu_create_chunk();
>                 if (!chunk) {
> -                       mutex_unlock(&pcpu_alloc_mutex);
>                         err = "failed to allocate new chunk";
>                         goto fail;
>                 }
> @@ -983,7 +980,6 @@ restart:
>                 spin_lock_irqsave(&pcpu_lock, flags);
>         }
>
> -       mutex_unlock(&pcpu_alloc_mutex);
>         goto restart;
>
>  area_found:
> @@ -993,8 +989,6 @@ area_found:
>         if (!is_atomic) {
>                 int page_start, page_end, rs, re;
>
> -               mutex_lock(&pcpu_alloc_mutex);
> -
>                 page_start = PFN_DOWN(off);
>                 page_end = PFN_UP(off + size);
>
> @@ -1005,7 +999,6 @@ area_found:
>
>                         spin_lock_irqsave(&pcpu_lock, flags);
>                         if (ret) {
> -                               mutex_unlock(&pcpu_alloc_mutex);
>                                 pcpu_free_area(chunk, off, &occ_pages);
>                                 err = "failed to populate";
>                                 goto fail_unlock;
> @@ -1045,6 +1038,8 @@ fail:
>                 /* see the flag handling in pcpu_blance_workfn() */
>                 pcpu_atomic_alloc_failed = true;
>                 pcpu_schedule_balance_work();
> +       } else {
> +               mutex_unlock(&pcpu_alloc_mutex);
>         }
>         return NULL;
>  }
> @@ -1129,6 +1124,7 @@ static void pcpu_balance_workfn(struct w
>                 if (chunk == list_first_entry(free_head, struct pcpu_chunk, list))
>                         continue;
>
> +               list_del_init(&chunk->map_extend_list);
>                 list_move(&chunk->list, &to_free);
>         }
>
> @@ -1146,6 +1142,24 @@ static void pcpu_balance_workfn(struct w
>                 pcpu_destroy_chunk(chunk);
>         }
>
> +       do {
> +               int new_alloc = 0;
> +
> +               spin_lock_irq(&pcpu_lock);
> +
> +               chunk = list_first_entry_or_null(&pcpu_map_extend_chunks,
> +                                       struct pcpu_chunk, map_extend_list);
> +               if (chunk) {
> +                       list_del_init(&chunk->map_extend_list);
> +                       new_alloc = pcpu_need_to_extend(chunk, false);
> +               }
> +
> +               spin_unlock_irq(&pcpu_lock);
> +
> +               if (new_alloc)
> +                       pcpu_extend_area_map(chunk, new_alloc);
> +       } while (chunk);
> +
>         /*
>          * Ensure there are certain number of free populated pages for
>          * atomic allocs.  Fill up from the most packed so that atomic
> @@ -1644,7 +1658,7 @@ int __init pcpu_setup_first_chunk(const
>          */
>         schunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
>         INIT_LIST_HEAD(&schunk->list);
> -       INIT_WORK(&schunk->map_extend_work, pcpu_map_extend_workfn);
> +       INIT_LIST_HEAD(&schunk->map_extend_list);
>         schunk->base_addr = base_addr;
>         schunk->map = smap;
>         schunk->map_alloc = ARRAY_SIZE(smap);
> @@ -1673,7 +1687,7 @@ int __init pcpu_setup_first_chunk(const
>         if (dyn_size) {
>                 dchunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
>                 INIT_LIST_HEAD(&dchunk->list);
> -               INIT_WORK(&dchunk->map_extend_work, pcpu_map_extend_workfn);
> +               INIT_LIST_HEAD(&dchunk->map_extend_list);
>                 dchunk->base_addr = base_addr;
>                 dchunk->map = dmap;
>                 dchunk->map_alloc = ARRAY_SIZE(dmap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
