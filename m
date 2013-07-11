Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 55BBF6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 10:31:25 -0400 (EDT)
Date: Thu, 11 Jul 2013 16:31:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 3/6] memcg: add per cgroup dirty pages accounting
Message-ID: <20130711143120.GI21667@dhcp22.suse.cz>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
 <1373045409-27617-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373045409-27617-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

Please also CC vfs people

On Sat 06-07-13 01:30:09, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> This patch adds memcg routines to count dirty pages, which allows memory controller
> to maintain an accurate view of the amount of its dirty memory.
> 
> After Kame's commit 89c06bd5(memcg: use new logic for page stat accounting), we can
> use 'struct page' flag to test page state instead of per page_cgroup flag. But memcg
> has a feature to move a page from a cgroup to another one and may have race between
> "move" and "page stat accounting". So in order to avoid the race we have designed a
> bigger lock:

Well, bigger lock is little bit an overstatement ;). It is full no-op for
!CONFIG_MEMCG, almost no-op if memcg is disabled (but compiled in), rcu
read lock in the most cases (no task is moving) and spin_lock_irqsave on
top in the slow path.

It would be good to mention this in the changelog for those who are not
familiar.

> 
>          mem_cgroup_begin_update_page_stat()
>          modify page information        -->(a)
>          mem_cgroup_update_page_stat()  -->(b)

Hmm, mem_cgroup_update_page_stat doesn't do any checking that we use a
proper locking. Which would be hard but we could at least test for
rcu_read_lock_held() because RCU is held if !mem_cgroup_disabled().
This would be a nice preparatory patch. What do you think?

>          mem_cgroup_end_update_page_stat()
> It requires both (a) and (b)(dirty pages accounting) to be pretected in
> mem_cgroup_{begin/end}_update_page_stat().
> 
> Server places should be added accounting:

Server?

>         incrementing (3):
>                 __set_page_dirty_buffers
>                 __set_page_dirty_nobuffers
> 		mark_buffer_dirty
>         decrementing (5):
>                 clear_page_dirty_for_io
>                 cancel_dirty_page
> 		delete_from_page_cache
> 		__delete_from_page_cache
> 		replace_page_cache_page
> 
> The lock order between memcg lock and mapping lock is:
> 	--> memcg->move_lock
> 	  --> mapping->private_lock
>             --> mapping->tree_lock
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> cc: Michal Hocko <mhocko@suse.cz>
> cc: Greg Thelen <gthelen@google.com>
> cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> cc: Andrew Morton <akpm@linux-foundation.org>
> cc: Fengguang Wu <fengguang.wu@intel.com>
> cc: Mel Gorman <mgorman@suse.de>
> ---
>  fs/buffer.c                |    9 +++++++++
>  include/linux/memcontrol.h |    1 +
>  mm/filemap.c               |   14 ++++++++++++++
>  mm/memcontrol.c            |   30 +++++++++++++++++++++++-------
>  mm/page-writeback.c        |   24 ++++++++++++++++++++++--
>  mm/truncate.c              |    6 ++++++
>  6 files changed, 75 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 695eb14..7c537f4 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -694,10 +694,13 @@ int __set_page_dirty_buffers(struct page *page)
>  {
>  	int newly_dirty;
>  	struct address_space *mapping = page_mapping(page);
> +	bool locked;
> +	unsigned long flags;
>  
>  	if (unlikely(!mapping))
>  		return !TestSetPageDirty(page);

I guess it would be worth mentioning why we do not care about pages
without mapping.

> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>  	spin_lock(&mapping->private_lock);
>  	if (page_has_buffers(page)) {
>  		struct buffer_head *head = page_buffers(page);
[...]
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 4b51ac1..5642de6 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
[...]
> @@ -144,6 +149,7 @@ void __delete_from_page_cache(struct page *page)

This needs a comment that it has to be called from within
mem_cgroup_{begin,end}_update_page_stat context. Btw. it seems that you
are missing invalidate_complete_page2 and __remove_mapping

>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>  		dec_zone_page_state(page, NR_FILE_DIRTY);
>  		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	}
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f9acf49..1d31851 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -91,6 +91,7 @@ static const char * const mem_cgroup_stat_names[] = {
>  	"rss_huge",
>  	"mapped_file",
>  	"swap",
> +	"dirty",

This doesn't match mem_cgroup_stat_index ordering.

>  };
>  
>  enum mem_cgroup_events_index {
[...]
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 4514ad7..3900e62 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1982,6 +1982,11 @@ int __set_page_dirty_no_writeback(struct page *page)
>  
>  /*
>   * Helper function for set_page_dirty family.
> + *
> + * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
> + * while modifying struct page state and accounting dirty pages.

I think "while calling this function" would be sufficient.

> + * See __set_page_dirty_{nobuffers,buffers} for example.
> + *
>   * NOTE: This relies on being atomic wrt interrupts.
>   */
>  void account_page_dirtied(struct page *page, struct address_space *mapping)
[...]

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
