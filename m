Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 411508E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 20:17:26 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so493512edd.11
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 17:17:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b27sor9998865edn.5.2019.01.14.17.17.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 17:17:24 -0800 (PST)
Date: Tue, 15 Jan 2019 02:17:12 +0100
From: Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-ID: <20190115011712.GA22681@andrea>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115002305.15402-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, dan.carpenter@oracle.com, shli@kernel.org, ying.huang@intel.com, dave.hansen@linux.intel.com, sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org, ak@linux.intel.com, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com, stern@rowland.harvard.edu, peterz@infradead.org, will.deacon@arm.com

On Mon, Jan 14, 2019 at 07:23:05PM -0500, Daniel Jordan wrote:
> Dan Carpenter reports a potential NULL dereference in
> get_swap_page_of_type:
> 
>   Smatch complains that the NULL checks on "si" aren't consistent.  This
>   seems like a real bug because we have not ensured that the type is
>   valid and so "si" can be NULL.
> 
> Add the missing check for NULL, taking care to use a read barrier to
> ensure CPU1 observes CPU0's updates in the correct order:
> 
>         CPU0                           CPU1
>         alloc_swap_info()              if (type >= nr_swapfiles)
>           swap_info[type] = p              /* handle invalid entry */
>           smp_wmb()                    smp_rmb()
>           ++nr_swapfiles               p = swap_info[type]
> 
> Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
> CPU0's write to swap_info[type] and read NULL from swap_info[type].
> 
> Ying Huang noticed that other places don't order these reads properly.
> Introduce swap_type_to_swap_info to encourage correct usage.
> 
> Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
> (see tools/memory-model/Documentation/explanation.txt).
> 
> This ordering need not be enforced in places where swap_lock is held
> (e.g. si_swapinfo) because swap_lock serializes updates to nr_swapfiles
> and the swap_info array.
> 
> This is a theoretical problem, no actual reports of it exist.
> 
> Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Omar Sandoval <osandov@fb.com>
> Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Will Deacon <will.deacon@arm.com>

Please feel free to add:

Reviewed-by: Andrea Parri <andrea.parri@amarulasolutions.com>

  Andrea


> 
> ---
> 
> I'd appreciate it if someone more familiar with memory barriers could
> check this over.  Thanks.
> 
> Probably no need for stable, this is all theoretical.
> 
> Against linux-mmotm tag v5.0-rc1-mmotm-2019-01-09-13-40
> 
>  mm/swapfile.c | 43 +++++++++++++++++++++++++++----------------
>  1 file changed, 27 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index f0edf7244256..dad52fc67045 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -99,6 +99,15 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
>  
>  atomic_t nr_rotate_swap = ATOMIC_INIT(0);
>  
> +static struct swap_info_struct *swap_type_to_swap_info(int type)
> +{
> +	if (type >= READ_ONCE(nr_swapfiles))
> +		return NULL;
> +
> +	smp_rmb();	/* Pairs with smp_wmb in alloc_swap_info. */
> +	return READ_ONCE(swap_info[type]);
> +}
> +
>  static inline unsigned char swap_count(unsigned char ent)
>  {
>  	return ent & ~SWAP_HAS_CACHE;	/* may include COUNT_CONTINUED flag */
> @@ -1045,12 +1054,14 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[], int entry_size)
>  /* The only caller of this function is now suspend routine */
>  swp_entry_t get_swap_page_of_type(int type)
>  {
> -	struct swap_info_struct *si;
> +	struct swap_info_struct *si = swap_type_to_swap_info(type);
>  	pgoff_t offset;
>  
> -	si = swap_info[type];
> +	if (!si)
> +		goto fail;
> +
>  	spin_lock(&si->lock);
> -	if (si && (si->flags & SWP_WRITEOK)) {
> +	if (si->flags & SWP_WRITEOK) {
>  		atomic_long_dec(&nr_swap_pages);
>  		/* This is called for allocating swap entry, not cache */
>  		offset = scan_swap_map(si, 1);
> @@ -1061,6 +1072,7 @@ swp_entry_t get_swap_page_of_type(int type)
>  		atomic_long_inc(&nr_swap_pages);
>  	}
>  	spin_unlock(&si->lock);
> +fail:
>  	return (swp_entry_t) {0};
>  }
>  
> @@ -1072,9 +1084,9 @@ static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
>  	if (!entry.val)
>  		goto out;
>  	type = swp_type(entry);
> -	if (type >= nr_swapfiles)
> +	p = swap_type_to_swap_info(type);
> +	if (!p)
>  		goto bad_nofile;
> -	p = swap_info[type];
>  	if (!(p->flags & SWP_USED))
>  		goto bad_device;
>  	offset = swp_offset(entry);
> @@ -1212,9 +1224,9 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
>  	if (!entry.val)
>  		goto out;
>  	type = swp_type(entry);
> -	if (type >= nr_swapfiles)
> +	si = swap_type_to_swap_info(type);
> +	if (!si)
>  		goto bad_nofile;
> -	si = swap_info[type];
>  
>  	preempt_disable();
>  	if (!(si->flags & SWP_VALID))
> @@ -1765,10 +1777,9 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
>  sector_t swapdev_block(int type, pgoff_t offset)
>  {
>  	struct block_device *bdev;
> +	struct swap_info_struct *si = swap_type_to_swap_info(type);
>  
> -	if ((unsigned int)type >= nr_swapfiles)
> -		return 0;
> -	if (!(swap_info[type]->flags & SWP_WRITEOK))
> +	if (!si || !(si->flags & SWP_WRITEOK))
>  		return 0;
>  	return map_swap_entry(swp_entry(type, offset), &bdev);
>  }
> @@ -2799,9 +2810,9 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
>  	if (!l)
>  		return SEQ_START_TOKEN;
>  
> -	for (type = 0; type < nr_swapfiles; type++) {
> +	for (type = 0; type < READ_ONCE(nr_swapfiles); type++) {
>  		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> -		si = swap_info[type];
> +		si = READ_ONCE(swap_info[type]);
>  		if (!(si->flags & SWP_USED) || !si->swap_map)
>  			continue;
>  		if (!--l)
> @@ -2821,9 +2832,9 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
>  	else
>  		type = si->type + 1;
>  
> -	for (; type < nr_swapfiles; type++) {
> +	for (; type < READ_ONCE(nr_swapfiles); type++) {
>  		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> -		si = swap_info[type];
> +		si = READ_ONCE(swap_info[type]);
>  		if (!(si->flags & SWP_USED) || !si->swap_map)
>  			continue;
>  		++*pos;
> @@ -2930,14 +2941,14 @@ static struct swap_info_struct *alloc_swap_info(void)
>  	}
>  	if (type >= nr_swapfiles) {
>  		p->type = type;
> -		swap_info[type] = p;
> +		WRITE_ONCE(swap_info[type], p);
>  		/*
>  		 * Write swap_info[type] before nr_swapfiles, in case a
>  		 * racing procfs swap_start() or swap_next() is reading them.
>  		 * (We never shrink nr_swapfiles, we never free this entry.)
>  		 */
>  		smp_wmb();
> -		nr_swapfiles++;
> +		WRITE_ONCE(nr_swapfiles, nr_swapfiles + 1);
>  	} else {
>  		kvfree(p);
>  		p = swap_info[type];
> -- 
> 2.20.0
> 
