Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 3074F6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 06:15:20 -0500 (EST)
Date: Wed, 2 Jan 2013 12:15:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 5/8] memcg: add per cgroup writeback pages accounting
Message-ID: <20130102111514.GD22160@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
 <1356456409-14701-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356456409-14701-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

On Wed 26-12-12 01:26:48, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Similar to dirty page, we add per cgroup writeback pages accounting. The lock
> rule still is:
>         mem_cgroup_begin_update_page_stat()
>         modify page WRITEBACK stat
>         mem_cgroup_update_page_stat()
>         mem_cgroup_end_update_page_stat()
> 
> There're two writeback interface to modify: test_clear/set_page_writeback.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Looks good to me
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!
> ---
>  include/linux/memcontrol.h |    1 +
>  mm/memcontrol.c            |    5 +++++
>  mm/page-writeback.c        |   17 +++++++++++++++++
>  3 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 358019e..1d22b81 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -45,6 +45,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
> +	MEM_CGROUP_STAT_WRITEBACK,  /* # of pages under writeback */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 21df36d..13cd14a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -96,6 +96,7 @@ static const char * const mem_cgroup_stat_names[] = {
>  	"mapped_file",
>  	"swap",
>  	"dirty",
> +	"writeback",
>  };
>  
>  enum mem_cgroup_events_index {
> @@ -3676,6 +3677,10 @@ static int mem_cgroup_move_account(struct page *page,
>  		mem_cgroup_move_account_page_stat(from, to, nr_pages,
>  			MEM_CGROUP_STAT_FILE_DIRTY);
>  
> +	if (PageWriteback(page))
> +		mem_cgroup_move_account_page_stat(from, to, nr_pages,
> +			MEM_CGROUP_STAT_WRITEBACK);
> +
>  	mem_cgroup_charge_statistics(from, anon, -nr_pages);
>  
>  	/* caller should have done css_get */
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 526ddd7..ae6498a 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2002,11 +2002,17 @@ EXPORT_SYMBOL(account_page_dirtied);
>  
>  /*
>   * Helper function for set_page_writeback family.
> + *
> + * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
> + * while modifying struct page state and accounting writeback pages.
> + * See test_set_page_writeback for example.
> + *
>   * NOTE: Unlike account_page_dirtied this does not rely on being atomic
>   * wrt interrupts.
>   */
>  void account_page_writeback(struct page *page)
>  {
> +	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
>  	inc_zone_page_state(page, NR_WRITEBACK);
>  }
>  EXPORT_SYMBOL(account_page_writeback);
> @@ -2242,7 +2248,10 @@ int test_clear_page_writeback(struct page *page)
>  {
>  	struct address_space *mapping = page_mapping(page);
>  	int ret;
> +	bool locked;
> +	unsigned long memcg_flags;
>  
> +	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
>  	if (mapping) {
>  		struct backing_dev_info *bdi = mapping->backing_dev_info;
>  		unsigned long flags;
> @@ -2263,9 +2272,12 @@ int test_clear_page_writeback(struct page *page)
>  		ret = TestClearPageWriteback(page);
>  	}
>  	if (ret) {
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
>  		dec_zone_page_state(page, NR_WRITEBACK);
>  		inc_zone_page_state(page, NR_WRITTEN);
>  	}
> +
> +	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
>  	return ret;
>  }
>  
> @@ -2273,7 +2285,10 @@ int test_set_page_writeback(struct page *page)
>  {
>  	struct address_space *mapping = page_mapping(page);
>  	int ret;
> +	bool locked;
> +	unsigned long flags;
>  
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>  	if (mapping) {
>  		struct backing_dev_info *bdi = mapping->backing_dev_info;
>  		unsigned long flags;
> @@ -2300,6 +2315,8 @@ int test_set_page_writeback(struct page *page)
>  	}
>  	if (!ret)
>  		account_page_writeback(page);
> +
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  	return ret;
>  
>  }
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
