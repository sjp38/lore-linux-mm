Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id F047C6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 04:30:25 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so1534540eek.40
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 01:30:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si7249079eew.228.2014.04.24.01.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 01:30:24 -0700 (PDT)
Date: Thu, 24 Apr 2014 09:30:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] swap: change swap_info singly-linked list to
 list_head
Message-ID: <20140424083018.GO23991@suse.de>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1397336454-13855-2-git-send-email-ddstreet@ieee.org>
 <20140423103400.GH23991@suse.de>
 <20140424001705.GA8066@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140424001705.GA8066@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Shaohua Li <shli@fusionio.com>, Weijie Yang <weijieut@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 24, 2014 at 08:17:05AM +0800, Shaohua Li wrote:
> On Wed, Apr 23, 2014 at 11:34:00AM +0100, Mel Gorman wrote:
> > > @@ -366,7 +361,7 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
> > >  		}
> > >  		vm_unacct_memory(pages);
> > >  		*unused = pages_to_unuse;
> > > -		*swapid = type;
> > > +		*swapid = si->type;
> > >  		ret = 0;
> > >  		break;
> > >  	}
> > > @@ -413,7 +408,7 @@ void frontswap_shrink(unsigned long target_pages)
> > >  	/*
> > >  	 * we don't want to hold swap_lock while doing a very
> > >  	 * lengthy try_to_unuse, but swap_list may change
> > > -	 * so restart scan from swap_list.head each time
> > > +	 * so restart scan from swap_list_head each time
> > >  	 */
> > >  	spin_lock(&swap_lock);
> > >  	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
> > > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > > index 4a7f7e6..b958645 100644
> > > --- a/mm/swapfile.c
> > > +++ b/mm/swapfile.c
> > > @@ -51,14 +51,14 @@ atomic_long_t nr_swap_pages;
> > >  /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
> > >  long total_swap_pages;
> > >  static int least_priority;
> > > -static atomic_t highest_priority_index = ATOMIC_INIT(-1);
> > >  
> > >  static const char Bad_file[] = "Bad swap file entry ";
> > >  static const char Unused_file[] = "Unused swap file entry ";
> > >  static const char Bad_offset[] = "Bad swap offset entry ";
> > >  static const char Unused_offset[] = "Unused swap offset entry ";
> > >  
> > > -struct swap_list_t swap_list = {-1, -1};
> > > +/* all active swap_info */
> > > +LIST_HEAD(swap_list_head);
> > >  
> > >  struct swap_info_struct *swap_info[MAX_SWAPFILES];
> > >  
> > > @@ -640,66 +640,50 @@ no_page:
> > >  
> > >  swp_entry_t get_swap_page(void)
> > >  {
> > > -	struct swap_info_struct *si;
> > > +	struct swap_info_struct *si, *next;
> > >  	pgoff_t offset;
> > > -	int type, next;
> > > -	int wrapped = 0;
> > > -	int hp_index;
> > > +	struct list_head *tmp;
> > >  
> > >  	spin_lock(&swap_lock);
> > >  	if (atomic_long_read(&nr_swap_pages) <= 0)
> > >  		goto noswap;
> > >  	atomic_long_dec(&nr_swap_pages);
> > >  
> > > -	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> > > -		hp_index = atomic_xchg(&highest_priority_index, -1);
> > > -		/*
> > > -		 * highest_priority_index records current highest priority swap
> > > -		 * type which just frees swap entries. If its priority is
> > > -		 * higher than that of swap_list.next swap type, we use it.  It
> > > -		 * isn't protected by swap_lock, so it can be an invalid value
> > > -		 * if the corresponding swap type is swapoff. We double check
> > > -		 * the flags here. It's even possible the swap type is swapoff
> > > -		 * and swapon again and its priority is changed. In such rare
> > > -		 * case, low prority swap type might be used, but eventually
> > > -		 * high priority swap will be used after several rounds of
> > > -		 * swap.
> > > -		 */
> > > -		if (hp_index != -1 && hp_index != type &&
> > > -		    swap_info[type]->prio < swap_info[hp_index]->prio &&
> > > -		    (swap_info[hp_index]->flags & SWP_WRITEOK)) {
> > > -			type = hp_index;
> > > -			swap_list.next = type;
> > > -		}
> > > -
> > > -		si = swap_info[type];
> > > -		next = si->next;
> > > -		if (next < 0 ||
> > > -		    (!wrapped && si->prio != swap_info[next]->prio)) {
> > > -			next = swap_list.head;
> > > -			wrapped++;
> > > -		}
> > > -
> > > +	list_for_each(tmp, &swap_list_head) {
> > > +		si = list_entry(tmp, typeof(*si), list);
> > >  		spin_lock(&si->lock);
> > > -		if (!si->highest_bit) {
> > > -			spin_unlock(&si->lock);
> > > -			continue;
> > > -		}
> > > -		if (!(si->flags & SWP_WRITEOK)) {
> > > +		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
> > >  			spin_unlock(&si->lock);
> > >  			continue;
> > >  		}
> > >  
> > > -		swap_list.next = next;
> > > +		/*
> > > +		 * rotate the current swap_info that we're going to use
> > > +		 * to after any other swap_info that have the same prio,
> > > +		 * so that all equal-priority swap_info get used equally
> > > +		 */
> > > +		next = si;
> > > +		list_for_each_entry_continue(next, &swap_list_head, list) {
> > > +			if (si->prio != next->prio)
> > > +				break;
> > > +			list_rotate_left(&si->list);
> > > +			next = si;
> > > +		}
> > >  
> > 
> > The list manipulations will be a lot of cache writes as the list is shuffled
> > around. On slow storage I do not think this will be noticable but it may
> > be noticable on faster swap devices that are SSD based. I've added Shaohua
> > Li to the cc as he has been concerned with the performance of swap in the
> > past. Shaohua, can you run this patchset through any of your test cases
> > with the addition that multiple swap files are used to see if the cache
> > writes are noticable? You'll need multiple swap files, some of which are
> > at equal priority so the list shuffling logic is triggered.
> 
> get_swap_page isn't hot so far (and we hold the swap_lock, which isn't
> contended), guess it's because other problems hide it, for example tlb flush
> overhead.
> 

The old method was not free either but I wanted to be sure you were
aware of the series just in case. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
