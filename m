Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFF88D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 21:02:45 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p2G12gMo015292
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:02:42 -0700
Received: from qyk27 (qyk27.prod.google.com [10.241.83.155])
	by wpaz13.hot.corp.google.com with ESMTP id p2G12Y0m012797
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:02:41 -0700
Received: by qyk27 with SMTP id 27so1035429qyk.13
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:02:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110315225409.GD5740@redhat.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-10-git-send-email-gthelen@google.com> <20110315225409.GD5740@redhat.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 15 Mar 2011 18:00:16 -0700
Message-ID: <AANLkTin=N8PDK7Z4xke3M01FY0scEBx_NMGx0GC2S+ro@mail.gmail.com>
Subject: Re: [PATCH v6 9/9] memcg: make background writeback memcg aware
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Tue, Mar 15, 2011 at 3:54 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Fri, Mar 11, 2011 at 10:43:31AM -0800, Greg Thelen wrote:
>> Add an memcg parameter to bdi_start_background_writeback(). =A0If a memc=
g
>> is specified then the resulting background writeback call to
>> wb_writeback() will run until the memcg dirty memory usage drops below
>> the memcg background limit. =A0This is used when balancing memcg dirty
>> memory with mem_cgroup_balance_dirty_pages().
>>
>> If the memcg parameter is not specified, then background writeback runs
>> globally system dirty memory usage falls below the system background
>> limit.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>
> [..]
>> -static inline bool over_bground_thresh(void)
>> +static inline bool over_bground_thresh(struct mem_cgroup *mem_cgroup)
>> =A0{
>> =A0 =A0 =A0 unsigned long background_thresh, dirty_thresh;
>>
>> + =A0 =A0 if (mem_cgroup) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct dirty_info info;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_hierarchical_dirty_info(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 determine_dirtyable_me=
mory(), false,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup, &info))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 return info.nr_file_dirty +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 info.nr_unstable_nfs > info.ba=
ckground_thresh;
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 global_dirty_limits(&background_thresh, &dirty_thresh);
>>
>> =A0 =A0 =A0 return (global_page_state(NR_FILE_DIRTY) +
>> @@ -683,7 +694,8 @@ static long wb_writeback(struct bdi_writeback *wb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For background writeout, stop when we a=
re below the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* background dirty threshold
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (work->for_background && !over_bground_thre=
sh())
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (work->for_background &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !over_bground_thresh(work->mem_cgroup)=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wbc.more_io =3D 0;
>> @@ -761,23 +773,6 @@ static unsigned long get_nr_dirty_pages(void)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_nr_dirty_inodes();
>> =A0}
>>
>> -static long wb_check_background_flush(struct bdi_writeback *wb)
>> -{
>> - =A0 =A0 if (over_bground_thresh()) {
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 struct wb_writeback_work work =3D {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_pages =A0 =A0 =A0 =3D LONG=
_MAX,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .sync_mode =A0 =A0 =A0=3D WB_S=
YNC_NONE,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .for_background =3D 1,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .range_cyclic =A0 =3D 1,
>> - =A0 =A0 =A0 =A0 =A0 =A0 };
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 return wb_writeback(wb, &work);
>> - =A0 =A0 }
>> -
>> - =A0 =A0 return 0;
>> -}
>> -
>> =A0static long wb_check_old_data_flush(struct bdi_writeback *wb)
>> =A0{
>> =A0 =A0 =A0 unsigned long expired;
>> @@ -839,15 +834,17 @@ long wb_do_writeback(struct bdi_writeback *wb, int=
 force_wait)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (work->done)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete(work->done);
>> - =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (work->mem_cgroup)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_bg_=
writeback_done(work->mem_cgroup);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(work);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Check for periodic writeback, kupdated() style
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 wrote +=3D wb_check_old_data_flush(wb);
>> - =A0 =A0 wrote +=3D wb_check_background_flush(wb);
>
> Hi Greg,
>
> So in the past we will leave the background work unfinished and try
> to finish queued work first.
>
> I see following line in wb_writeback().
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Background writeout and kupdate-style w=
riteback may
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * run forever. Stop them if there is othe=
r work to do
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * so that e.g. sync can proceed. They'll =
be restarted
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * after the other works are all done.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((work->for_background || work->for_kup=
date) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!list_empty(&wb->bdi->work_list))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> Now you seem to have converted background writeout also as queued
> work item. So it sounds wb_writebac() will finish that background
> work early and never take it up and finish other queued items. So
> we might finish queued items still flusher thread might exit
> without bringing down the background ratio of either root or memcg
> depending on the ->mem_cgroup pointer.
>
> May be requeuing the background work at the end of list might help.

Good catch!  I agree that an interrupted queued bg writeback work item
should be requeued to the tail.

> Thanks
> Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
