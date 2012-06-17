Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1C14E6B0068
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 02:56:16 -0400 (EDT)
Received: by obbtb8 with SMTP id tb8so154757obb.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 23:56:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FDC2834.7010705@jp.fujitsu.com>
References: <1339761611-29033-1-git-send-email-handai.szj@taobao.com>
	<4FDC2834.7010705@jp.fujitsu.com>
Date: Sun, 17 Jun 2012 14:56:15 +0800
Message-ID: <CAFj3OHVs4dLAZUPVFaadp3PPH15fU8RpOeciU5rZs9-xutDgsg@mail.gmail.com>
Subject: Re: [PATCH 1/2] memcg: remove MEMCG_NR_FILE_MAPPED
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Sat, Jun 16, 2012 at 2:31 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/06/15 21:00), Sha Zhengju wrote:
>> While doing memcg page stat accounting, there's no need to use MEMCG_NR_=
FILE_MAPPED
>> as an intermediate, we can use MEM_CGROUP_STAT_FILE_MAPPED directly.
>>
>> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
>
> I'm sorry but my recent patch modified mem_cgroup_stat_index and this wil=
l hunk with
> mm tree. (not visible in linux-next yet.)
>
> I have no objection to the patch. I'm grad if you'll update this and repo=
st, later.
>


Okay, I'll repost one based on mm tree.

Thanks,
Sha


> Thanks,
> -Kame
>
>
>> ---
>> =A0 include/linux/memcontrol.h | =A0 22 ++++++++++++++++------
>> =A0 mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 25 +-------------------=
-----
>> =A0 mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
>> =A0 3 files changed, 19 insertions(+), 32 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index f94efd2..a337c2e 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -27,9 +27,19 @@ struct page_cgroup;
>> =A0 struct page;
>> =A0 struct mm_struct;
>>
>> -/* Stats that can be updated by kernel. */
>> -enum mem_cgroup_page_stat_item {
>> - =A0 =A0 MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>> +/*
>> + * Statistics for memory cgroup.
>> + */
>> +enum mem_cgroup_stat_index {
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* For MEM_CONTAINER_TYPE_ALL, usage =3D pagecache + rss.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 MEM_CGROUP_STAT_CACHE, =A0 =A0 /* # of pages charged as cache =
*/
>> + =A0 =A0 MEM_CGROUP_STAT_RSS, =A0 =A0 =A0 /* # of pages charged as anon=
 rss */
>> + =A0 =A0 MEM_CGROUP_STAT_FILE_MAPPED, =A0/* # of pages charged as file =
rss */
>> + =A0 =A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>> + =A0 =A0 MEM_CGROUP_STAT_DATA, /* end of data requires synchronization =
*/
>> + =A0 =A0 MEM_CGROUP_STAT_NSTATS,
>> =A0 };
>>
>> =A0 struct mem_cgroup_reclaim_cookie {
>> @@ -170,17 +180,17 @@ static inline void mem_cgroup_end_update_page_stat=
(struct page *page,
>> =A0 }
>>
>> =A0 void mem_cgroup_update_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cg=
roup_page_stat_item idx,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cg=
roup_stat_index idx,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int val);
>>
>> =A0 static inline void mem_cgroup_inc_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_page_stat_item idx)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_stat_index idx)
>> =A0 {
>> =A0 =A0 =A0 mem_cgroup_update_page_stat(page, idx, 1);
>> =A0 }
>>
>> =A0 static inline void mem_cgroup_dec_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_page_stat_item idx)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_stat_index idx)
>> =A0 {
>> =A0 =A0 =A0 mem_cgroup_update_page_stat(page, idx, -1);
>> =A0 }
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 7685d4a..9102b8c 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -77,21 +77,6 @@ static int really_do_swap_account __initdata =3D 0;
>> =A0 #endif
>>
>>
>> -/*
>> - * Statistics for memory cgroup.
>> - */
>> -enum mem_cgroup_stat_index {
>> - =A0 =A0 /*
>> - =A0 =A0 =A0* For MEM_CONTAINER_TYPE_ALL, usage =3D pagecache + rss.
>> - =A0 =A0 =A0*/
>> - =A0 =A0 MEM_CGROUP_STAT_CACHE, =A0 =A0 /* # of pages charged as cache =
*/
>> - =A0 =A0 MEM_CGROUP_STAT_RSS, =A0 =A0 =A0 /* # of pages charged as anon=
 rss */
>> - =A0 =A0 MEM_CGROUP_STAT_FILE_MAPPED, =A0/* # of pages charged as file =
rss */
>> - =A0 =A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>> - =A0 =A0 MEM_CGROUP_STAT_DATA, /* end of data requires synchronization =
*/
>> - =A0 =A0 MEM_CGROUP_STAT_NSTATS,
>> -};
>> -
>> =A0 enum mem_cgroup_events_index {
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGPGIN, =A0 =A0 =A0 /* # of pages paged in=
 */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGPGOUT, =A0 =A0 =A0/* # of pages paged ou=
t */
>> @@ -1958,7 +1943,7 @@ void __mem_cgroup_end_update_page_stat(struct page=
 *page, unsigned long *flags)
>> =A0 }
>>
>> =A0 void mem_cgroup_update_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cg=
roup_page_stat_item idx, int val)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cg=
roup_stat_index idx, int val)
>> =A0 {
>> =A0 =A0 =A0 struct mem_cgroup *memcg;
>> =A0 =A0 =A0 struct page_cgroup *pc =3D lookup_page_cgroup(page);
>> @@ -1971,14 +1956,6 @@ void mem_cgroup_update_page_stat(struct page *pag=
e,
>> =A0 =A0 =A0 if (unlikely(!memcg || !PageCgroupUsed(pc)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> - =A0 =A0 switch (idx) {
>> - =A0 =A0 case MEMCG_NR_FILE_MAPPED:
>> - =A0 =A0 =A0 =A0 =A0 =A0 idx =3D MEM_CGROUP_STAT_FILE_MAPPED;
>> - =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 default:
>> - =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> - =A0 =A0 }
>> -
>> =A0 =A0 =A0 this_cpu_add(memcg->stat->count[idx], val);
>> =A0 }
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 5b5ad58..7e4e481 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1154,7 +1154,7 @@ void page_add_file_rmap(struct page *page)
>> =A0 =A0 =A0 mem_cgroup_begin_update_page_stat(page,&locked,&flags);
>> =A0 =A0 =A0 if (atomic_inc_and_test(&page->_mapcount)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(page, NR_FILE_MAPPED);
>> - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_M=
APPED);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT=
_FILE_MAPPED);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 mem_cgroup_end_update_page_stat(page,&locked,&flags);
>> =A0 }
>> @@ -1208,7 +1208,7 @@ void page_remove_rmap(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 NR_ANON_TRANSPARENT_HUGEPAGES);
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dec_zone_page_state(page, NR_FILE_MAPPED);
>> - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_M=
APPED);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT=
_FILE_MAPPED);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* It would be tidy to reset the PageAnon mapping here,
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
