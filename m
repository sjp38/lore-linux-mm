Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5775C6B006A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 07:31:44 -0500 (EST)
Date: Mon, 2 Nov 2009 12:31:39 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 1/1] MM: swapfile, fix crash on double swapon
In-Reply-To: <1257155103-9189-1-git-send-email-jirislaby@gmail.com>
Message-ID: <Pine.LNX.4.64.0911021222010.32400@sister.anvils>
References: <1257155103-9189-1-git-send-email-jirislaby@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, Jiri Slaby wrote:

> Double swapon on a device causes a crash:
> BUG: unable to handle kernel NULL pointer dereference at (null)

Thanks a lot for finding that: it doesn't just happen with a double
swapon of the same device, it happens with most kinds of error in
the swapon sequence.  I thought I was being nice and tidy moving
that initialization, but actually I was just being careless.

> IP: [<ffffffff810af160>] sys_swapon+0x1f0/0xc60
> PGD 1dc0b067 PUD 1dc09067 PMD 0
> Oops: 0000 [#1] SMP
> last sysfs file:
> CPU 1
> Modules linked in:
> Pid: 562, comm: swapon Tainted: G        W  2.6.32-rc5-mm1_64 #867
> RIP: 0010:[<ffffffff810af160>]  [<ffffffff810af160>] sys_swapon+0x1f0/0xc60
> ...
> 
> It is due to swap_info_struct->first_swap_extent.list not being
> initialized. ->next is NULL in such a situation and
> destroy_swap_extents fails to iterate over the list with the BUG
> above.
> 
> Introduced by swap_info-include-first_swap_extent.patch. Revert the
> INIT_LIST_HEAD move.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  mm/swapfile.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 93e71cf..26ef6a2 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1313,7 +1313,6 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
>  	if (start_page == 0) {
>  		se = &sis->first_swap_extent;
>  		sis->curr_swap_extent = se;
> -		INIT_LIST_HEAD(&se->list);
>  		se->start_page = 0;
>  		se->nr_pages = nr_pages;
>  		se->start_block = start_block;
> @@ -1769,6 +1768,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		kfree(p);
>  		goto out;
>  	}
> +	INIT_LIST_HEAD(&p->first_swap_extent.list);
>  	if (type >= nr_swapfiles) {
>  		p->type = type;
>  		swap_info[type] = p;
> -- 
> 1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
