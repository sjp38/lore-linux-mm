Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B63536B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:40:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s130so5400325lfs.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:40:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l72si22107629wmb.89.2016.05.24.01.40.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:40:55 -0700 (PDT)
Subject: Re: bpf: use-after-free in array_map_alloc
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com> <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz> <20160523213501.GA5383@mtj.duckdns.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57441396.2050607@suse.cz>
Date: Tue, 24 May 2016 10:40:54 +0200
MIME-Version: 1.0
In-Reply-To: <20160523213501.GA5383@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, marco.gra@gmail.com

[+CC Marco who reported the CVE, forgot that earlier]

On 05/23/2016 11:35 PM, Tejun Heo wrote:
> Hello,
>
> Can you please test whether this patch resolves the issue?  While
> adding support for atomic allocations, I reduced alloc_mutex covered
> region too much.
>
> Thanks.

Ugh, this makes the code even more head-spinning than it was.

> diff --git a/mm/percpu.c b/mm/percpu.c
> index 0c59684..bd2df70 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -162,7 +162,7 @@ static struct pcpu_chunk *pcpu_reserved_chunk;
>   static int pcpu_reserved_chunk_limit;
>
>   static DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
> -static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop */
> +static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map extension */
>
>   static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
>
> @@ -435,6 +435,8 @@ static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
>   	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
>   	unsigned long flags;
>
> +	lockdep_assert_held(&pcpu_alloc_mutex);

I don't see where the mutex gets locked when called via 
pcpu_map_extend_workfn? (except via the new cancel_work_sync() call below?)

Also what protects chunks with scheduled work items from being removed?

> +
>   	new = pcpu_mem_zalloc(new_size);
>   	if (!new)
>   		return -ENOMEM;
> @@ -895,6 +897,9 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>   		return NULL;
>   	}
>
> +	if (!is_atomic)
> +		mutex_lock(&pcpu_alloc_mutex);

BTW I noticed that
	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;

this is too pessimistic IMHO. Reclaim is possible even without __GFP_FS 
and __GFP_IO. Could you just use gfpflags_allow_blocking(gfp) here?

> +
>   	spin_lock_irqsave(&pcpu_lock, flags);
>
>   	/* serve reserved allocations from the reserved chunk if available */
> @@ -967,12 +972,11 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>   	if (is_atomic)
>   		goto fail;
>
> -	mutex_lock(&pcpu_alloc_mutex);
> +	lockdep_assert_held(&pcpu_alloc_mutex);
>
>   	if (list_empty(&pcpu_slot[pcpu_nr_slots - 1])) {
>   		chunk = pcpu_create_chunk();
>   		if (!chunk) {
> -			mutex_unlock(&pcpu_alloc_mutex);
>   			err = "failed to allocate new chunk";
>   			goto fail;
>   		}
> @@ -983,7 +987,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>   		spin_lock_irqsave(&pcpu_lock, flags);
>   	}
>
> -	mutex_unlock(&pcpu_alloc_mutex);
>   	goto restart;
>
>   area_found:
> @@ -993,8 +996,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>   	if (!is_atomic) {
>   		int page_start, page_end, rs, re;
>
> -		mutex_lock(&pcpu_alloc_mutex);
> -
>   		page_start = PFN_DOWN(off);
>   		page_end = PFN_UP(off + size);
>
> @@ -1005,7 +1006,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>
>   			spin_lock_irqsave(&pcpu_lock, flags);
>   			if (ret) {
> -				mutex_unlock(&pcpu_alloc_mutex);
>   				pcpu_free_area(chunk, off, &occ_pages);
>   				err = "failed to populate";
>   				goto fail_unlock;
> @@ -1045,6 +1045,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>   		/* see the flag handling in pcpu_blance_workfn() */
>   		pcpu_atomic_alloc_failed = true;
>   		pcpu_schedule_balance_work();
> +	} else {
> +		mutex_unlock(&pcpu_alloc_mutex);
>   	}
>   	return NULL;
>   }
> @@ -1137,6 +1139,8 @@ static void pcpu_balance_workfn(struct work_struct *work)
>   	list_for_each_entry_safe(chunk, next, &to_free, list) {
>   		int rs, re;
>
> +		cancel_work_sync(&chunk->map_extend_work);

This deserves some comment?

> +
>   		pcpu_for_each_pop_region(chunk, rs, re, 0, pcpu_unit_pages) {
>   			pcpu_depopulate_chunk(chunk, rs, re);
>   			spin_lock_irq(&pcpu_lock);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
