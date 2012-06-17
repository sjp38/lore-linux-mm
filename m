Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id EF2976B0068
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 02:53:23 -0400 (EDT)
Received: by obbtb8 with SMTP id tb8so151938obb.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 23:53:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <xr937gv8vc1y.fsf@gthelen.mtv.corp.google.com>
References: <1339761611-29033-1-git-send-email-handai.szj@taobao.com>
	<xr937gv8vc1y.fsf@gthelen.mtv.corp.google.com>
Date: Sun, 17 Jun 2012 14:53:22 +0800
Message-ID: <CAFj3OHUcat5TwAn2FQbJo02sGULmq6r=k3DOkhK6GBXPwOroPw@mail.gmail.com>
Subject: Re: [PATCH 1/2] memcg: remove MEMCG_NR_FILE_MAPPED
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Fri, Jun 15, 2012 at 11:18 PM, Greg Thelen <gthelen@google.com> wrote:
> On Fri, Jun 15 2012, Sha Zhengju wrote:
>
>> While doing memcg page stat accounting, there's no need to use MEMCG_NR_=
FILE_MAPPED
>> as an intermediate, we can use MEM_CGROUP_STAT_FILE_MAPPED directly.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 22 ++++++++++++++++------
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 25 +--------------------=
----
>> =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
>> =A03 files changed, 19 insertions(+), 32 deletions(-)
>
> I assume this patch is relative to v3.4.
>


Yeah, I cook it based on linux-stable v3.4.


>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index f94efd2..a337c2e 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -27,9 +27,19 @@ struct page_cgroup;
>> =A0struct page;
>> =A0struct mm_struct;
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
>> =A0};
>
> This has unfortunate side effect of letting code outside of memcontrol.c
> manipulate memcg internally managed statistics
> (e.g. MEM_CGROUP_STAT_CACHE) with mem_cgroup_{dec,inc}_page_stat. =A0I
> think that your change is fine. =A0The complexity and presumed performanc=
e
> overhead of the extra layer of indirection was not worth it.
>
>> =A0struct mem_cgroup_reclaim_cookie {
>> @@ -170,17 +180,17 @@ static inline void mem_cgroup_end_update_page_stat=
(struct page *page,
>> =A0}
>>
>> =A0void mem_cgroup_update_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cg=
roup_page_stat_item idx,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cg=
roup_stat_index idx,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int val);
>>
>> =A0static inline void mem_cgroup_inc_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_page_stat_item idx)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_stat_index idx)
>> =A0{
>> =A0 =A0 =A0 mem_cgroup_update_page_stat(page, idx, 1);
>> =A0}
>>
>> =A0static inline void mem_cgroup_dec_page_stat(struct page *page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_page_stat_item idx)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_stat_index idx)
>> =A0{
>> =A0 =A0 =A0 mem_cgroup_update_page_stat(page, idx, -1);
>> =A0}
>
> You missed two more uses of enum mem_cgroup_page_stat_item in
> memcontrol.h.
>

Ah, I find them, thanks for reviewing!


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
