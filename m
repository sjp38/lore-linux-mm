Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 233D78D005B
	for <linux-mm@kvack.org>; Sun, 31 Oct 2010 16:12:10 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v4 03/11] memcg: create extensible page stat update routines
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-4-git-send-email-gthelen@google.com>
	<4CCD81CB.9030503@linux.vnet.ibm.com>
Date: Sun, 31 Oct 2010 13:11:46 -0700
In-Reply-To: <4CCD81CB.9030503@linux.vnet.ibm.com> (Ciju Rajan K.'s message of
	"Sun, 31 Oct 2010 20:18:43 +0530")
Message-ID: <xr93sjzmcebh.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Ciju Rajan K <ciju@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Ciju Rajan K <ciju@linux.vnet.ibm.com> writes:

> Greg Thelen wrote:
>> Replace usage of the mem_cgroup_update_file_mapped() memcg
>> statistic update routine with two new routines:
>> * mem_cgroup_inc_page_stat()
>> * mem_cgroup_dec_page_stat()
>>
>> As before, only the file_mapped statistic is managed.  However,
>> these more general interfaces allow for new statistics to be
>> more easily added.  New statistics are added with memcg dirty
>> page accounting.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> ---
>> Changelog since v1:
>> - Rename (for clarity):
>>   - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
>>   - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
>>
>>  include/linux/memcontrol.h |   31 ++++++++++++++++++++++++++++---
>>  mm/memcontrol.c            |   16 +++++++---------
>>  mm/rmap.c                  |    4 ++--
>>  3 files changed, 37 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 159a076..067115c 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -25,6 +25,11 @@ struct page_cgroup;
>>  struct page;
>>  struct mm_struct;
>>
>> +/* Stats that can be updated by kernel. */
>> +enum mem_cgroup_page_stat_item {
>> +	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>> +};
>> +
>>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>>  					struct list_head *dst,
>>  					unsigned long *scanned, int order,
>> @@ -121,7 +126,22 @@ static inline bool mem_cgroup_disabled(void)
>>  	return false;
>>  }
>>
>> -void mem_cgroup_update_file_mapped(struct page *page, int val);
>> +void mem_cgroup_update_page_stat(struct page *page,
>> +				 enum mem_cgroup_page_stat_item idx,
>> +				 int val);
>> +
>> +static inline void mem_cgroup_inc_page_stat(struct page *page,
>> +					    enum mem_cgroup_page_stat_item idx)
>> +{
>> +	mem_cgroup_update_page_stat(page, idx, 1);
>> +}
>> +
>> +static inline void mem_cgroup_dec_page_stat(struct page *page,
>> +					    enum mem_cgroup_page_stat_item idx)
>> +{
>> +	mem_cgroup_update_page_stat(page, idx, -1);
>> +}
>> +
>>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>>  						gfp_t gfp_mask);
>>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>> @@ -293,8 +313,13 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>>  {
>>  }
>>
>> -static inline void mem_cgroup_update_file_mapped(struct page *page,
>> -							int val)
>> +static inline void mem_cgroup_inc_page_stat(struct page *page,
>> +					    enum mem_cgroup_page_stat_item idx)
>> +{
>> +}
>> +
>> +static inline void mem_cgroup_dec_page_stat(struct page *page,
>> +					    enum mem_cgroup_page_stat_item idx)
>>  {
>>  }
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 9a99cfa..4fd00c4 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1592,7 +1592,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>>   * possibility of race condition. If there is, we take a lock.
>>   */
>>
>>   
> Greg,
>
> I am not seeing the function mem_cgroup_update_file_stat() in the latest mmotm
> 2010-10-22-16-36.
> So not able to apply this patch. Tried couple of times cloning the entire mmotm
> git repository. But no luck.
> Tried in the web interface http://git.zen-kernel.org/mmotm/tree/mm/memcontrol.c
> also. It is not there.
> Surprisingly git log doesn't show any recent changes to mm/memcontrol.c. Am I
> missing something?
> I could see this function in the mainline linux 2.6 git tree.
>
> -Ciju

mem_cgroup_update_file_mapped() was renamed to
mem_cgroup_update_file_stat() in
http://userweb.kernel.org/~akpm/mmotm/broken-out/memcg-generic-filestat-update-interface.patch

I also do not see this in the mmotm git repo.  However, if I manually
apply the mmotm patches to v2.6.36 using quilt then I see the expected
patched memcontrol.c.  I am not sure why the zen-kernel.org git mmotm
repo differs from a mmotm patched mainline 2.6.36.

Here is my procedure using quilt to patch mainline:

# Checkout 2.6.36 mainline
$ git checkout v2.6.36

# Confirm mainline 2.6.36 does not have mem_cgroup_update_file_stat()
$ grep mem_cgroup_update_file_stat -r mm

# Apply patches
$ curl http://userweb.kernel.org/~akpm/mmotm/broken-out.tar.gz | tar -xzf -
$ export QUILT_PATCHES=broken-out
$ quilt push -aq
...
Now at patch memblock-add-input-size-checking-to-memblock_find_region-fix.patch

# Now the memcontrol contains mem_cgroup_update_file_stat()
$ grep mem_cgroup_update_file_stat -r mm
mm/memcontrol.c:static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
mm/memcontrol.c:        mem_cgroup_update_file_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, val);

>> -static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
>> +void mem_cgroup_update_page_stat(struct page *page,
>> +				 enum mem_cgroup_page_stat_item idx, int val)
>>  {
>>  	struct mem_cgroup *mem;
>>  	struct page_cgroup *pc = lookup_page_cgroup(page);
>> @@ -1615,30 +1616,27 @@ static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
>>  			goto out;
>>  	}
>>
>> -	this_cpu_add(mem->stat->count[idx], val);
>> -
>>  	switch (idx) {
>> -	case MEM_CGROUP_STAT_FILE_MAPPED:
>> +	case MEMCG_NR_FILE_MAPPED:
>>  		if (val > 0)
>>  			SetPageCgroupFileMapped(pc);
>>  		else if (!page_mapped(page))
>>  			ClearPageCgroupFileMapped(pc);
>> +		idx = MEM_CGROUP_STAT_FILE_MAPPED;
>>  		break;
>>  	default:
>>  		BUG();
>>  	}
>>
>> +	this_cpu_add(mem->stat->count[idx], val);
>> +
>>  out:
>>  	if (unlikely(need_unlock))
>>  		unlock_page_cgroup(pc);
>>  	rcu_read_unlock();
>>  	return;
>>  }
>> -
>> -void mem_cgroup_update_file_mapped(struct page *page, int val)
>> -{
>> -	mem_cgroup_update_file_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, val);
>> -}
>> +EXPORT_SYMBOL(mem_cgroup_update_page_stat);
>>
>>  /*
>>   * size of first charge trial. "32" comes from vmscan.c's magic value.
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 1a8bf76..a66ab76 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -911,7 +911,7 @@ void page_add_file_rmap(struct page *page)
>>  {
>>  	if (atomic_inc_and_test(&page->_mapcount)) {
>>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
>> -		mem_cgroup_update_file_mapped(page, 1);
>> +		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
>>  	}
>>  }
>>
>> @@ -949,7 +949,7 @@ void page_remove_rmap(struct page *page)
>>  		__dec_zone_page_state(page, NR_ANON_PAGES);
>>  	} else {
>>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
>> -		mem_cgroup_update_file_mapped(page, -1);
>> +		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
>>  	}
>>  	/*
>>  	 * It would be tidy to reset the PageAnon mapping here,
>>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
