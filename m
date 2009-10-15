Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 792F26B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 22:47:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9F2kwDV013157
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Oct 2009 11:46:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FE9245DE52
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:46:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F09F345DE4F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:46:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D13881DB8038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:46:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80D4BE38004
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:46:57 +0900 (JST)
Date: Thu, 15 Oct 2009 11:44:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] swap_info: swap_map of chars not shorts
Message-Id: <20091015114435.9470890a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910150152330.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150152330.3291@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009 01:53:52 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> Halve the vmalloc'ed swap_map array from unsigned shorts to unsigned
> chars: it's still very unusual to reach a swap count of 126, and the
> next patch allows it to be extended indefinitely.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
> 
>  include/linux/swap.h |    8 ++++----
>  mm/swapfile.c        |   40 +++++++++++++++++++++++-----------------
>  2 files changed, 27 insertions(+), 21 deletions(-)
> 
> --- si5/include/linux/swap.h	2009-10-14 21:26:42.000000000 +0100
> +++ si6/include/linux/swap.h	2009-10-14 21:26:49.000000000 +0100
> @@ -151,9 +151,9 @@ enum {
>  
>  #define SWAP_CLUSTER_MAX 32
>  
> -#define SWAP_MAP_MAX	0x7ffe
> -#define SWAP_MAP_BAD	0x7fff
> -#define SWAP_HAS_CACHE  0x8000		/* There is a swap cache of entry. */
> +#define SWAP_MAP_MAX	0x7e
> +#define SWAP_MAP_BAD	0x7f
> +#define SWAP_HAS_CACHE	0x80		/* There is a swap cache of entry. */
>  
>  /*
>   * The in-memory structure used to track swap areas.
> @@ -167,7 +167,7 @@ struct swap_info_struct {
>  	struct block_device *bdev;
>  	struct swap_extent first_swap_extent;
>  	struct swap_extent *curr_swap_extent;
> -	unsigned short *swap_map;
> +	unsigned char *swap_map;
>  	unsigned int lowest_bit;
>  	unsigned int highest_bit;
>  	unsigned int lowest_alloc;	/* while preparing discard cluster */
> --- si5/mm/swapfile.c	2009-10-14 21:26:42.000000000 +0100
> +++ si6/mm/swapfile.c	2009-10-14 21:26:49.000000000 +0100
> @@ -53,7 +53,7 @@ static struct swap_info_struct *swap_inf
>  
>  static DEFINE_MUTEX(swapon_mutex);
>  
> -static inline int swap_count(unsigned short ent)
> +static inline unsigned char swap_count(unsigned char ent)
>  {
>  	return ent & ~SWAP_HAS_CACHE;
>  }
> @@ -203,7 +203,7 @@ static int wait_for_discard(void *word)
>  #define LATENCY_LIMIT		256
>  
>  static inline unsigned long scan_swap_map(struct swap_info_struct *si,
> -					  unsigned short usage)
> +					  unsigned char usage)
>  {
>  	unsigned long offset;
>  	unsigned long scan_base;
> @@ -531,12 +531,12 @@ out:
>  	return NULL;
>  }
>  
> -static unsigned short swap_entry_free(struct swap_info_struct *p,
> -			   swp_entry_t entry, unsigned short usage)
> +static unsigned char swap_entry_free(struct swap_info_struct *p,
> +				     swp_entry_t entry, unsigned char usage)
>  {
>  	unsigned long offset = swp_offset(entry);
> -	unsigned short count;
> -	unsigned short has_cache;
> +	unsigned char count;
> +	unsigned char has_cache;
>  
>  	count = p->swap_map[offset];
>  	has_cache = count & SWAP_HAS_CACHE;
> @@ -591,7 +591,7 @@ void swap_free(swp_entry_t entry)
>  void swapcache_free(swp_entry_t entry, struct page *page)
>  {
>  	struct swap_info_struct *p;
> -	unsigned short count;
> +	unsigned char count;
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> @@ -975,7 +975,7 @@ static unsigned int find_next_to_unuse(s
>  {
>  	unsigned int max = si->max;
>  	unsigned int i = prev;
> -	int count;
> +	unsigned char count;
>  
>  	/*
>  	 * No need for swap_lock here: we're just looking
> @@ -1013,8 +1013,8 @@ static int try_to_unuse(unsigned int typ
>  {
>  	struct swap_info_struct *si = swap_info[type];
>  	struct mm_struct *start_mm;
> -	unsigned short *swap_map;
> -	unsigned short swcount;
> +	unsigned char *swap_map;
> +	unsigned char swcount;
>  	struct page *page;
>  	swp_entry_t entry;
>  	unsigned int i = 0;
> @@ -1175,6 +1175,12 @@ static int try_to_unuse(unsigned int typ
>  		 * If that's wrong, then we should worry more about
>  		 * exit_mmap() and do_munmap() cases described above:
>  		 * we might be resetting SWAP_MAP_MAX too early here.
> +		 *
> +		 * Yes, that's wrong: though very unlikely, swap count 0x7ffe
> +		 * could surely occur if pid_max raised from PID_MAX_DEFAULT;

Just a nitpick.

Hmm, logically, our MAX COUNT is 0x7e after this patch. Then, how about not
mentioning to 0x7ffe and PID_MAX ? as..

Yes, that's wrong: we now use SWAP_MAP_MAX as 0x7e, very easy to overflow.
next patch will...


Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> +		 * and we are now lowering SWAP_MAP_MAX to 0x7e, making it
> +		 * much easier to reach.  But the next patch will fix that.
> +		 *
>  		 * We know "Undead"s can happen, they're okay, so don't
>  		 * report them; but do report if we reset SWAP_MAP_MAX.
>  		 */
> @@ -1494,7 +1500,7 @@ bad_bmap:
>  SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  {
>  	struct swap_info_struct *p = NULL;
> -	unsigned short *swap_map;
> +	unsigned char *swap_map;
>  	struct file *swap_file, *victim;
>  	struct address_space *mapping;
>  	struct inode *inode;
> @@ -1764,7 +1770,7 @@ SYSCALL_DEFINE2(swapon, const char __use
>  	sector_t span;
>  	unsigned long maxpages = 1;
>  	unsigned long swapfilepages;
> -	unsigned short *swap_map = NULL;
> +	unsigned char *swap_map = NULL;
>  	struct page *page = NULL;
>  	struct inode *inode = NULL;
>  	int did_down = 0;
> @@ -1939,13 +1945,13 @@ SYSCALL_DEFINE2(swapon, const char __use
>  		goto bad_swap;
>  
>  	/* OK, set up the swap map and apply the bad block list */
> -	swap_map = vmalloc(maxpages * sizeof(short));
> +	swap_map = vmalloc(maxpages);
>  	if (!swap_map) {
>  		error = -ENOMEM;
>  		goto bad_swap;
>  	}
>  
> -	memset(swap_map, 0, maxpages * sizeof(short));
> +	memset(swap_map, 0, maxpages);
>  	for (i = 0; i < swap_header->info.nr_badpages; i++) {
>  		int page_nr = swap_header->info.badpages[i];
>  		if (page_nr <= 0 || page_nr >= swap_header->info.last_page) {
> @@ -2083,12 +2089,12 @@ void si_swapinfo(struct sysinfo *val)
>   * - swap-cache reference is requested but there is already one. -> EEXIST
>   * - swap-cache reference is requested but the entry is not used. -> ENOENT
>   */
> -static int __swap_duplicate(swp_entry_t entry, unsigned short usage)
> +static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>  {
>  	struct swap_info_struct *p;
>  	unsigned long offset, type;
> -	unsigned short count;
> -	unsigned short has_cache;
> +	unsigned char count;
> +	unsigned char has_cache;
>  	int err = -EINVAL;
>  
>  	if (non_swap_entry(entry))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
