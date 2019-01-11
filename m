Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41EC98E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:41:33 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id a2so13816424ioq.9
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:41:33 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n21si682189jad.38.2019.01.11.09.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 09:41:32 -0800 (PST)
Date: Fri, 11 Jan 2019 09:41:28 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH] mm, swap: Potential NULL dereference in
 get_swap_page_of_type()
Message-ID: <20190111174128.oak64htbntvp7j6y@ca-dmjordan1.us.oracle.com>
References: <20190111095919.GA1757@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111095919.GA1757@kadam>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, Huang Ying <ying.huang@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Omar Sandoval <osandov@fb.com>, Tejun Heo <tj@kernel.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, andrea.parri@amarulasolutions.com

On Fri, Jan 11, 2019 at 12:59:19PM +0300, Dan Carpenter wrote:
> Smatch complains that the NULL checks on "si" aren't consistent.  This
> seems like a real bug because we have not ensured that the type is
> valid and so "si" can be NULL.
> 
> Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
>  mm/swapfile.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index f0edf7244256..21e92c757205 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1048,9 +1048,12 @@ swp_entry_t get_swap_page_of_type(int type)
>  	struct swap_info_struct *si;
>  	pgoff_t offset;
>  
> +	if (type >= nr_swapfiles)
> +		goto fail;
> +

As long as we're worrying about NULL, I think there should be an smp_rmb here
to ensure swap_info[type] isn't NULL in case of an (admittedly unlikely) racing
swapon that increments nr_swapfiles.  See smp_wmb in alloc_swap_info and the
matching smp_rmb's in the file.  And READ_ONCE's on either side of the barrier
per LKMM.

I'm adding Andrea (randomly selected from the many LKMM folks to avoid spamming
all) who can correct me if I'm wrong about any of this.

>  	si = swap_info[type];
>  	spin_lock(&si->lock);
> -	if (si && (si->flags & SWP_WRITEOK)) {
> +	if (si->flags & SWP_WRITEOK) {
>  		atomic_long_dec(&nr_swap_pages);
>  		/* This is called for allocating swap entry, not cache */
>  		offset = scan_swap_map(si, 1);
> @@ -1061,6 +1064,7 @@ swp_entry_t get_swap_page_of_type(int type)
>  		atomic_long_inc(&nr_swap_pages);
>  	}
>  	spin_unlock(&si->lock);
> +fail:
>  	return (swp_entry_t) {0};
>  }
>  
> -- 
> 2.17.1
> 
