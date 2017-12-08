Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE5CB6B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:26:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so8161923pfe.22
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:26:48 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k195si5109039pgc.575.2017.12.08.00.26.46
        for <linux-mm@kvack.org>;
        Fri, 08 Dec 2017 00:26:47 -0800 (PST)
Date: Fri, 8 Dec 2017 17:26:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20171208082644.GA14361@bbox>
References: <20171207011426.1633-1-ying.huang@intel.com>
 <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
 <20171208014346.GA8915@bbox>
 <87po7pg4jt.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87po7pg4jt.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Fri, Dec 08, 2017 at 01:41:10PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Thu, Dec 07, 2017 at 04:29:37PM -0800, Andrew Morton wrote:
> >> On Thu,  7 Dec 2017 09:14:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> >> 
> >> > When the swapin is performed, after getting the swap entry information
> >> > from the page table, the PTL (page table lock) will be released, then
> >> > system will go to swap in the swap entry, without any lock held to
> >> > prevent the swap device from being swapoff.  This may cause the race
> >> > like below,
> >> > 
> >> > CPU 1				CPU 2
> >> > -----				-----
> >> > 				do_swap_page
> >> > 				  swapin_readahead
> >> > 				    __read_swap_cache_async
> >> > swapoff				      swapcache_prepare
> >> >   p->swap_map = NULL		        __swap_duplicate
> >> > 					  p->swap_map[?] /* !!! NULL pointer access */
> >> > 
> >> > Because swap off is usually done when system shutdown only, the race
> >> > may not hit many people in practice.  But it is still a race need to
> >> > be fixed.
> >> 
> >> swapoff is so rare that it's hard to get motivated about any fix which
> >> adds overhead to the regular codepaths.
> >
> > That was my concern, too when I see this patch.
> >
> >> 
> >> Is there something we can do to ensure that all the overhead of this
> >> fix is placed into the swapoff side?  stop_machine() may be a bit
> >> brutal, but a surprising amount of code uses it.  Any other ideas?
> >
> > How about this?
> >
> > I think It's same approach with old where we uses si->lock everywhere
> > instead of more fine-grained cluster lock.
> >
> > The reason I repeated to reset p->max to zero in the loop is to avoid
> > using lockdep annotation(maybe, spin_lock_nested(something) to prevent
> > false positive.
> >
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 42fe5653814a..9ce007a42bbc 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -2644,6 +2644,19 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	swap_file = p->swap_file;
> >  	old_block_size = p->old_block_size;
> >  	p->swap_file = NULL;
> > +
> > +	if (p->flags & SWP_SOLIDSTATE) {
> > +		unsigned long ci, nr_cluster;
> > +
> > +		nr_cluster = DIV_ROUND_UP(p->max, SWAPFILE_CLUSTER);
> > +		for (ci = 0; ci < nr_cluster; ci++) {
> > +			struct swap_cluster_info *sci;
> > +
> > +			sci = lock_cluster(p, ci * SWAPFILE_CLUSTER);
> > +			p->max = 0;
> > +			unlock_cluster(sci);
> > +		}
> > +	}
> >  	p->max = 0;
> >  	swap_map = p->swap_map;
> >  	p->swap_map = NULL;
> > @@ -3369,10 +3382,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
> >  		goto bad_file;
> >  	p = swap_info[type];
> >  	offset = swp_offset(entry);
> > -	if (unlikely(offset >= p->max))
> > -		goto out;
> >  
> >  	ci = lock_cluster_or_swap_info(p, offset);
> > +	if (unlikely(offset >= p->max))
> > +		goto unlock_out;
> >  
> >  	count = p->swap_map[offset];
> >  
> 
> Sorry, this doesn't work, because
> 
> lock_cluster_or_swap_info()
> 
> Need to read p->cluster_info, which may be freed during swapoff too.
> 
> 
> To reduce the added overhead in regular code path, Maybe we can use SRCU
> to implement get_swap_device() and put_swap_device()?  There is only
> increment/decrement on CPU local variable in srcu_read_lock/unlock().
> Should be acceptable in not so hot swap path?
> 
> This needs to select CONFIG_SRCU if CONFIG_SWAP is enabled.  But I guess
> that should be acceptable too?
> 

Why do we need srcu here? Is it enough with rcu like below?

It might have a bug/room to be optimized about performance/naming.
I just wanted to show my intention.

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2417d288e016..bfe493f3bcb8 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -273,6 +273,7 @@ struct swap_info_struct {
 					 */
 	struct work_struct discard_work; /* discard worker */
 	struct swap_cluster_list discard_clusters; /* discard clusters list */
+	struct rcu_head	rcu;
 };
 
 #ifdef CONFIG_64BIT
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 42fe5653814a..ecec064f9b20 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -302,6 +302,7 @@ static inline struct swap_cluster_info *lock_cluster_or_swap_info(
 {
 	struct swap_cluster_info *ci;
 
+	rcu_read_lock();
 	ci = lock_cluster(si, offset);
 	if (!ci)
 		spin_lock(&si->lock);
@@ -316,6 +317,7 @@ static inline void unlock_cluster_or_swap_info(struct swap_info_struct *si,
 		unlock_cluster(ci);
 	else
 		spin_unlock(&si->lock);
+	rcu_read_unlock();
 }
 
 static inline bool cluster_list_empty(struct swap_cluster_list *list)
@@ -2530,11 +2532,17 @@ bool has_usable_swap(void)
 	return ret;
 }
 
+static void swap_cluster_info_free(struct rcu_head *rcu)
+{
+	struct swap_info_struct *si = container_of(rcu, struct swap_info_struct, rcu);
+	kvfree(si->cluster_info);
+	si->cluster_info = NULL;
+}
+
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct *p = NULL;
 	unsigned char *swap_map;
-	struct swap_cluster_info *cluster_info;
 	unsigned long *frontswap_map;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
@@ -2542,6 +2550,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	struct filename *pathname;
 	int err, found = 0;
 	unsigned int old_block_size;
+	unsigned long ci, nr_cluster;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -2631,6 +2640,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_lock(&p->lock);
 	drain_mmlist();
 
+	nr_cluster = DIV_ROUND_UP(p->max, SWAPFILE_CLUSTER);
 	/* wait for anyone still in scan_swap_map */
 	p->highest_bit = 0;		/* cuts scans short */
 	while (p->flags >= SWP_SCANNING) {
@@ -2641,14 +2651,33 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_lock(&p->lock);
 	}
 
+	if (p->flags & SWP_SOLIDSTATE) {
+		struct swap_cluster_info *sci, *head_cluster;
+
+		head_cluster = p->cluster_info;
+		spin_lock(&head_cluster->lock);
+		sci = head_cluster + 1;
+		for (ci = 1; ci < nr_cluster; ci++, sci++)
+			spin_lock_nest_lock(&sci->lock, &head_cluster->lock);
+	}
+
 	swap_file = p->swap_file;
 	old_block_size = p->old_block_size;
 	p->swap_file = NULL;
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
-	cluster_info = p->cluster_info;
-	p->cluster_info = NULL;
+
+	if (p->flags & SWP_SOLIDSTATE) {
+		struct swap_cluster_info *sci, *head_cluster;
+
+		head_cluster = p->cluster_info;
+		sci = head_cluster + 1;
+		for (ci = 1; ci < nr_cluster; ci++, sci++)
+			spin_unlock(&sci->lock);
+		spin_unlock(&head_cluster->lock);
+	}
+
 	frontswap_map = frontswap_map_get(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
@@ -2658,7 +2687,8 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	free_percpu(p->percpu_cluster);
 	p->percpu_cluster = NULL;
 	vfree(swap_map);
-	kvfree(cluster_info);
+	call_rcu(&p->rcu, swap_cluster_info_free);
+	synchronize_rcu();
 	kvfree(frontswap_map);
 	/* Destroy swap account information */
 	swap_cgroup_swapoff(p->type);
@@ -3369,10 +3399,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 		goto bad_file;
 	p = swap_info[type];
 	offset = swp_offset(entry);
-	if (unlikely(offset >= p->max))
-		goto out;
 
 	ci = lock_cluster_or_swap_info(p, offset);
+	if (unlikely(offset >= p->max))
+		goto unlock_out;
 
 	count = p->swap_map[offset];
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
