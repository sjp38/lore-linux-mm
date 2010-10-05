Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5E66B0071
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 16:00:21 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 03/10] memcg: create extensible page stat update routines
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-4-git-send-email-gthelen@google.com>
	<20101005154250.GA9515@barrios-desktop>
Date: Tue, 05 Oct 2010 12:59:37 -0700
In-Reply-To: <20101005154250.GA9515@barrios-desktop> (Minchan Kim's message of
	"Wed, 6 Oct 2010 00:42:50 +0900")
Message-ID: <xr93aamstnpy.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Minchan Kim <minchan.kim@gmail.com> writes:

> On Sun, Oct 03, 2010 at 11:57:58PM -0700, Greg Thelen wrote:
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
>> ---
>>  include/linux/memcontrol.h |   31 ++++++++++++++++++++++++++++---
>>  mm/memcontrol.c            |   17 ++++++++---------
>>  mm/rmap.c                  |    4 ++--
>>  3 files changed, 38 insertions(+), 14 deletions(-)
>> 
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 159a076..7c7bec4 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -25,6 +25,11 @@ struct page_cgroup;
>>  struct page;
>>  struct mm_struct;
>>  
>> +/* Stats that can be updated by kernel. */
>> +enum mem_cgroup_write_page_stat_item {
>> +	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>> +};
>> +
>
> mem_cgrou_"write"_page_stat_item?
> Does "write" make sense to abstract page_state generally?

First I will summarize the portion of the design relevant to this
comment:

This patch series introduces two sets of memcg statistics.
a) the writable set of statistics the kernel updates when pages change
   state (example: when a page becomes dirty) using:
     mem_cgroup_inc_page_stat(struct page *page,
     				enum mem_cgroup_write_page_stat_item idx)
     mem_cgroup_dec_page_stat(struct page *page,
     				enum mem_cgroup_write_page_stat_item idx)

b) the read-only set of statistics the kernel queries to measure the
   amount of dirty memory used by the current cgroup using:
     s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)

   This read-only set of statistics is set of a higher level conceptual
   counters.  For example, MEMCG_NR_DIRTYABLE_PAGES is the sum of the
   counts of pages in various states (active + inactive).  mem_cgroup
   exports this value as a higher level counter rather than individual
   counters (active & inactive) to minimize the number of calls into
   mem_cgroup_page_stat().  This avoids extra calls to cgroup tree
   iteration with for_each_mem_cgroup_tree().

Notice that each of the two sets of statistics are addressed by a
different type, mem_cgroup_{read vs write}_page_stat_item.

This particular patch (memcg: create extensible page stat update
routines) introduces part of this design.  A later patch I emailed
(memcg: add dirty limits to mem_cgroup) added
mem_cgroup_read_page_stat_item.


I think the code would read better if I renamed 
enum mem_cgroup_write_page_stat_item to 
enum mem_cgroup_update_page_stat_item.

Would this address your concern?

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
