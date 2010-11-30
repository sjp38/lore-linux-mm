Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4649E6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 03:15:39 -0500 (EST)
Received: by iwn42 with SMTP id 42so1029343iwn.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 00:15:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 17:15:37 +0900
Message-ID: <AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 4:08 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 29 Nov 2010 22:49:42 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> There is a kswapd kernel thread for each memory node. We add a different=
 kswapd
>> for each cgroup. The kswapd is sleeping in the wait queue headed at kswa=
pd_wait
>> field of a kswapd descriptor. The kswapd descriptor stores information o=
f node
>> or cgroup and it allows the global and per cgroup background reclaim to =
share
>> common reclaim algorithms.
>>
>> This patch addes the kswapd descriptor and changes per zone kswapd_wait =
to the
>> common data structure.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/mmzone.h | =A0 =A03 +-
>> =A0include/linux/swap.h =A0 | =A0 10 +++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0mm/mmzone.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A09 +++-
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 98 +++++++++++++++++++++++++=
++++++++--------------
>> =A06 files changed, 90 insertions(+), 34 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 39c24eb..c77dfa2 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -642,8 +642,7 @@ typedef struct pglist_data {
>> =A0 =A0 =A0 unsigned long node_spanned_pages; /* total size of physical =
page
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0range, including holes */
>> =A0 =A0 =A0 int node_id;
>> - =A0 =A0 wait_queue_head_t kswapd_wait;
>> - =A0 =A0 struct task_struct *kswapd;
>> + =A0 =A0 wait_queue_head_t *kswapd_wait;
>> =A0 =A0 =A0 int kswapd_max_order;
>> =A0} pg_data_t;
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index eba53e7..2e6cb58 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -26,6 +26,16 @@ static inline int current_is_kswapd(void)
>> =A0 =A0 =A0 return current->flags & PF_KSWAPD;
>> =A0}
>>
>> +struct kswapd {
>> + =A0 =A0 struct task_struct *kswapd_task;
>> + =A0 =A0 wait_queue_head_t kswapd_wait;
>> + =A0 =A0 struct mem_cgroup *kswapd_mem;
>> + =A0 =A0 pg_data_t *kswapd_pgdat;
>> +};
>> +
>> +#define MAX_KSWAPDS MAX_NUMNODES
>> +extern struct kswapd kswapds[MAX_KSWAPDS];
>> +int kswapd(void *p);
>
> Why this is required ? Can't we allocate this at boot (if necessary) ?
> Why exsiting kswapd is also controlled under this structure ?
> At the 1st look, this just seem to increase the size of changes....
>
> IMHO, implementing background-reclaim-for-memcg is cleaner than reusing k=
swapd..
> kswapd has tons of unnecessary checks.

Ideally, I hope we unify global and memcg of kswapd for easy
maintainance if it's not a big problem.
When we make patches about lru pages, we always have to consider what
I should do for memcg.
And when we review patches, we also should consider what the patch is
missing for memcg.
It makes maintainance cost big. Of course, if memcg maintainers is
involved with all patches, it's no problem as it is.

If it is impossible due to current kswapd's spaghetti, we can clean up
it first. I am not sure whether my suggestion make sense or not.
Kame can know it much rather than me. But please consider such the voice.

>
> Regards,
> -Kame
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
