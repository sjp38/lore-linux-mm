Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BF8BA6B005A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 11:02:24 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so84196wib.2
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 08:02:23 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH V2 5/6] memcg: add per cgroup writeback pages accounting
References: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
	<1343384931-20202-1-git-send-email-handai.szj@taobao.com>
Date: Mon, 30 Jul 2012 08:02:21 -0700
In-Reply-To: <1343384931-20202-1-git-send-email-handai.szj@taobao.com> (Sha
	Zhengju's message of "Fri, 27 Jul 2012 18:28:51 +0800")
Message-ID: <xr93k3xl9ts2.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, fengguang.wu@intel.com, akpm@linux-foundation.org, yinghan@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, Sha Zhengju <handai.szj@taobao.com>

On Fri, Jul 27 2012, Sha Zhengju wrote:

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
> ---
>  include/linux/memcontrol.h |    1 +
>  mm/memcontrol.c            |    5 +++++
>  mm/page-writeback.c        |   17 +++++++++++++++++
>  3 files changed, 23 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8c6b8ca..0c8a699 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -42,6 +42,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
> +	MEM_CGROUP_STAT_WRITEBACK,  /* # of pages under writeback */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cdcd547..de91d3d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -86,6 +86,7 @@ static const char * const mem_cgroup_stat_names[] = {
>  	"mapped_file",
>  	"swap",
>  	"dirty",
> +	"writeback",
>  };
>  
>  enum mem_cgroup_events_index {
> @@ -2607,6 +2608,10 @@ static int mem_cgroup_move_account(struct page *page,
>  		mem_cgroup_move_account_page_stat(from, to,
>  				MEM_CGROUP_STAT_FILE_DIRTY);
>  
> +	if (PageWriteback(page))
> +		mem_cgroup_move_account_page_stat(from, to,
> +				MEM_CGROUP_STAT_WRITEBACK);
> +
>  	mem_cgroup_charge_statistics(from, anon, -nr_pages);
>  
>  	/* caller should have done css_get */
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 233e7ac..6b06d5e 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1956,11 +1956,17 @@ EXPORT_SYMBOL(account_page_dirtied);
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
> @@ -2192,7 +2198,10 @@ int test_clear_page_writeback(struct page *page)
>  {
>  	struct address_space *mapping = page_mapping(page);
>  	int ret;
> +	bool locked;
> +	unsigned long flags;
>  
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);

Reusing a variable name (flags) in the same function can cause
confusion.  Please use a different name.  Maybe memcg_flags.

>  	if (mapping) {
>  		struct backing_dev_info *bdi = mapping->backing_dev_info;
>  		unsigned long flags;
> @@ -2213,9 +2222,12 @@ int test_clear_page_writeback(struct page *page)
>  		ret = TestClearPageWriteback(page);
>  	}
>  	if (ret) {
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
>  		dec_zone_page_state(page, NR_WRITEBACK);
>  		inc_zone_page_state(page, NR_WRITTEN);
>  	}
> +
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  	return ret;
>  }
>  
> @@ -2223,7 +2235,10 @@ int test_set_page_writeback(struct page *page)
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
> @@ -2250,6 +2265,8 @@ int test_set_page_writeback(struct page *page)
>  	}
>  	if (!ret)
>  		account_page_writeback(page);
> +
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  	return ret;
>  
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
