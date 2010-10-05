Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 23BDC6B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 19:57:19 -0400 (EDT)
Received: by iwn41 with SMTP id 41so1500527iwn.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 16:57:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <xr93aamstnpy.fsf@ninji.mtv.corp.google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-4-git-send-email-gthelen@google.com>
	<20101005154250.GA9515@barrios-desktop>
	<xr93aamstnpy.fsf@ninji.mtv.corp.google.com>
Date: Wed, 6 Oct 2010 08:57:15 +0900
Message-ID: <AANLkTi=LsoJ+_rGGjXgPTESW4Hpi03XzUL_K2ULPLGxf@mail.gmail.com>
Subject: Re: [PATCH 03/10] memcg: create extensible page stat update routines
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 6, 2010 at 4:59 AM, Greg Thelen <gthelen@google.com> wrote:
> Minchan Kim <minchan.kim@gmail.com> writes:
>
>> On Sun, Oct 03, 2010 at 11:57:58PM -0700, Greg Thelen wrote:
>>> Replace usage of the mem_cgroup_update_file_mapped() memcg
>>> statistic update routine with two new routines:
>>> * mem_cgroup_inc_page_stat()
>>> * mem_cgroup_dec_page_stat()
>>>
>>> As before, only the file_mapped statistic is managed. =A0However,
>>> these more general interfaces allow for new statistics to be
>>> more easily added. =A0New statistics are added with memcg dirty
>>> page accounting.
>>>
>>> Signed-off-by: Greg Thelen <gthelen@google.com>
>>> Signed-off-by: Andrea Righi <arighi@develer.com>
>>> ---
>>> =A0include/linux/memcontrol.h | =A0 31 ++++++++++++++++++++++++++++---
>>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 17 ++++++++---------
>>> =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
>>> =A03 files changed, 38 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>> index 159a076..7c7bec4 100644
>>> --- a/include/linux/memcontrol.h
>>> +++ b/include/linux/memcontrol.h
>>> @@ -25,6 +25,11 @@ struct page_cgroup;
>>> =A0struct page;
>>> =A0struct mm_struct;
>>>
>>> +/* Stats that can be updated by kernel. */
>>> +enum mem_cgroup_write_page_stat_item {
>>> + =A0 =A0MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>>> +};
>>> +
>>
>> mem_cgrou_"write"_page_stat_item?
>> Does "write" make sense to abstract page_state generally?
>
> First I will summarize the portion of the design relevant to this
> comment:
>
> This patch series introduces two sets of memcg statistics.
> a) the writable set of statistics the kernel updates when pages change
> =A0 state (example: when a page becomes dirty) using:
> =A0 =A0 mem_cgroup_inc_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_c=
group_write_page_stat_item idx)
> =A0 =A0 mem_cgroup_dec_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_c=
group_write_page_stat_item idx)
>
> b) the read-only set of statistics the kernel queries to measure the
> =A0 amount of dirty memory used by the current cgroup using:
> =A0 =A0 s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item=
)
>
> =A0 This read-only set of statistics is set of a higher level conceptual
> =A0 counters. =A0For example, MEMCG_NR_DIRTYABLE_PAGES is the sum of the
> =A0 counts of pages in various states (active + inactive). =A0mem_cgroup
> =A0 exports this value as a higher level counter rather than individual
> =A0 counters (active & inactive) to minimize the number of calls into
> =A0 mem_cgroup_page_stat(). =A0This avoids extra calls to cgroup tree
> =A0 iteration with for_each_mem_cgroup_tree().
>
> Notice that each of the two sets of statistics are addressed by a
> different type, mem_cgroup_{read vs write}_page_stat_item.
>
> This particular patch (memcg: create extensible page stat update
> routines) introduces part of this design. =A0A later patch I emailed
> (memcg: add dirty limits to mem_cgroup) added
> mem_cgroup_read_page_stat_item.
>
>
> I think the code would read better if I renamed
> enum mem_cgroup_write_page_stat_item to
> enum mem_cgroup_update_page_stat_item.
>
> Would this address your concern

Thanks for the kind explanation.
I understand your concept.

I think you makes update and query as completely different level
abstraction but you could use similar terms.
Even the terms(write VS read) make me more confusing.

How about renaming following as?

1. mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
2. mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item

At least it looks to be easy for me to understand the code.
But it's just my preference. If others think your semantic is more
desirable, I am not against it strongly.

Thanks, Greg.

>
> --
> Greg
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
