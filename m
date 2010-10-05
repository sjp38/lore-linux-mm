Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9D16B0047
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:35:27 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 05/10] memcg: add dirty page accounting infrastructure
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-6-git-send-email-gthelen@google.com>
	<20101005162205.3908952a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 05 Oct 2010 00:35:07 -0700
In-Reply-To: <20101005162205.3908952a.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Tue, 5 Oct 2010 16:22:05 +0900")
Message-ID: <xr93lj6dw0r8.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Sun,  3 Oct 2010 23:58:00 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Add memcg routines to track dirty, writeback, and unstable_NFS pages.
>> These routines are not yet used by the kernel to count such pages.
>> A later change adds kernel calls to these new routines.
>> 
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>
> a small request. see below.
>
>> ---
>>  include/linux/memcontrol.h |    3 +
>>  mm/memcontrol.c            |   89 ++++++++++++++++++++++++++++++++++++++++----
>>  2 files changed, 84 insertions(+), 8 deletions(-)
>> 
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 7c7bec4..6303da1 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -28,6 +28,9 @@ struct mm_struct;
>>  /* Stats that can be updated by kernel. */
>>  enum mem_cgroup_write_page_stat_item {
>>  	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>> +	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
>> +	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
>> +	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
>>  };
>>  
>>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 267d774..f40839f 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -85,10 +85,13 @@ enum mem_cgroup_stat_index {
>>  	 */
>>  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
>>  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
>> -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>> +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>> +	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
>> +	MEM_CGROUP_STAT_FILE_WRITEBACK,		/* # of pages under writeback */
>> +	MEM_CGROUP_STAT_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
>>  	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
>>  	/* incremented at every  pagein/pageout */
>>  	MEM_CGROUP_EVENTS = MEM_CGROUP_STAT_DATA,
>> @@ -1626,6 +1629,48 @@ void mem_cgroup_update_page_stat(struct page *page,
>>  			ClearPageCgroupFileMapped(pc);
>>  		idx = MEM_CGROUP_STAT_FILE_MAPPED;
>>  		break;
>> +
>> +	case MEMCG_NR_FILE_DIRTY:
>> +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
>> +		if (val > 0) {
>> +			if (TestSetPageCgroupFileDirty(pc))
>> +				/* already set */
>> +				val = 0;
>> +		} else {
>> +			if (!TestClearPageCgroupFileDirty(pc))
>> +				/* already cleared */
>> +				val = 0;
>> +		}
>> +		idx = MEM_CGROUP_STAT_FILE_DIRTY;
>> +		break;
>> +
>> +	case MEMCG_NR_FILE_WRITEBACK:
>> +		/*
>> +		 * This counter is adjusted while holding the mapping's
>> +		 * tree_lock.  Therefore there is no race between settings and
>> +		 * clearing of this flag.
>> +		 */
>
> nice description.
>
>> +		if (val > 0)
>> +			SetPageCgroupFileWriteback(pc);
>> +		else
>> +			ClearPageCgroupFileWriteback(pc);
>> +		idx = MEM_CGROUP_STAT_FILE_WRITEBACK;
>> +		break;
>> +
>> +	case MEMCG_NR_FILE_UNSTABLE_NFS:
>> +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
>> +		if (val > 0) {
>> +			if (TestSetPageCgroupFileUnstableNFS(pc))
>> +				/* already set */
>> +				val = 0;
>> +		} else {
>> +			if (!TestClearPageCgroupFileUnstableNFS(pc))
>> +				/* already cleared */
>> +				val = 0;
>> +		}
>> +		idx = MEM_CGROUP_STAT_FILE_UNSTABLE_NFS;
>> +		break;
>> +
>>  	default:
>>  		BUG();
>>  	}
>> @@ -2133,6 +2178,16 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>>  	memcg_check_events(mem, pc->page);
>>  }
>>  
>> +static void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
>> +					      struct mem_cgroup *to,
>> +					      enum mem_cgroup_stat_index idx)
>> +{
>> +	preempt_disable();
>> +	__this_cpu_dec(from->stat->count[idx]);
>> +	__this_cpu_inc(to->stat->count[idx]);
>> +	preempt_enable();
>> +}
>> +
>>  /**
>>   * __mem_cgroup_move_account - move account of the page
>>   * @pc:	page_cgroup of the page.
>> @@ -2159,13 +2214,18 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
>>  	VM_BUG_ON(!PageCgroupUsed(pc));
>>  	VM_BUG_ON(pc->mem_cgroup != from);
>>  
>> -	if (PageCgroupFileMapped(pc)) {
>> -		/* Update mapped_file data for mem_cgroup */
>> -		preempt_disable();
>> -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>> -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>> -		preempt_enable();
>> -	}
>> +	if (PageCgroupFileMapped(pc))
>> +		mem_cgroup_move_account_page_stat(from, to,
>> +					MEM_CGROUP_STAT_FILE_MAPPED);
>> +	if (PageCgroupFileDirty(pc))
>> +		mem_cgroup_move_account_page_stat(from, to,
>> +					MEM_CGROUP_STAT_FILE_DIRTY);
>> +	if (PageCgroupFileWriteback(pc))
>> +		mem_cgroup_move_account_page_stat(from, to,
>> +					MEM_CGROUP_STAT_FILE_WRITEBACK);
>> +	if (PageCgroupFileUnstableNFS(pc))
>> +		mem_cgroup_move_account_page_stat(from, to,
>> +					MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
>>  	mem_cgroup_charge_statistics(from, pc, false);
>>  	if (uncharge)
>>  		/* This is not "cancel", but cancel_charge does all we need. */
>> @@ -3545,6 +3605,9 @@ enum {
>>  	MCS_PGPGIN,
>>  	MCS_PGPGOUT,
>>  	MCS_SWAP,
>> +	MCS_FILE_DIRTY,
>> +	MCS_WRITEBACK,
>> +	MCS_UNSTABLE_NFS,
>>  	MCS_INACTIVE_ANON,
>>  	MCS_ACTIVE_ANON,
>>  	MCS_INACTIVE_FILE,
>> @@ -3567,6 +3630,9 @@ struct {
>>  	{"pgpgin", "total_pgpgin"},
>>  	{"pgpgout", "total_pgpgout"},
>>  	{"swap", "total_swap"},
>> +	{"dirty", "total_dirty"},
>> +	{"writeback", "total_writeback"},
>> +	{"nfs", "total_nfs"},
>
> Could you make this as nfs_unstable as meminfo shows ?
> If I am a user, I think this is the number of NFS pages not NFS_UNSTABLE pages.

Good catch!  In the next revision I will change this from
"nfs"/"total_nfs" to "NFS_Unstable"/"total_NFS_Unstable" to match
/proc/meminfo.

> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
