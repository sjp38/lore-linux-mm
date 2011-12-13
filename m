Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 0D5FB6B0072
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:43:17 -0500 (EST)
Received: by qcsd17 with SMTP id d17so5707277qcs.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 10:43:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111213162126.GE30440@tiehlicka.suse.cz>
References: <1323742587-9084-1-git-send-email-yinghan@google.com>
	<20111213162126.GE30440@tiehlicka.suse.cz>
Date: Tue, 13 Dec 2011 10:43:16 -0800
Message-ID: <CALWz4iwHVMK_k5bxP_m1E8Ugq_FE5XTzHDNi7A8CRhkWHG_Z9A@mail.gmail.com>
Subject: Re: [PATCH 1/2] memcg: Use gfp_mask __GFP_NORETRY in try charge
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Tue, Dec 13, 2011 at 8:21 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 12-12-11 18:16:27, Ying Han wrote:
>> In __mem_cgroup_try_charge() function, the parameter "oom" is passed fro=
m the
>> caller indicating whether or not the charge should enter memcg oom kill.=
 In
>> fact, we should be able to eliminate that by using the existing gfp_mask=
 and
>> __GFP_NORETRY flag.
>>
>> This patch removed the "oom" parameter, and add the __GFP_NORETRY flag i=
nto
>> gfp_mask for those doesn't want to enter memcg oom. There is no function=
al
>> change for those setting false to "oom" like mem_cgroup_move_parent(), b=
ut
>> __GFP_NORETRY now is checked for those even setting true to "oom".
>>
>> The __GFP_NORETRY is used in page allocator to bypass retry and oom kill=
. I
>> believe there is a reason for callers to use that flag, and in memcg cha=
rge
>> we need to respect it as well.
>
> What is the reason for this change?
> To be honest it makes the oom condition more obscure. __GFP_NORETRY
> documentation doesn't say anything about OOM and one would have to know
> details about allocator internals to follow this.
> So I am not saying the patch is bad but I would need some strong reason
> to like it ;)

Thank you for looking into this :)

This patch was made as part of the effort solving the livelock issue.
Then it becomes a separate question by itself.

I don't quite understand the mismatch on gfp_mask =3D __GFP_NORETRY &&
oom_check =3D=3D true. In page allocator we bypass the retry as well as
the oom if the flag is set, but we ingore the flag totally when
getting into the memcg charge. Why is that, and is there any
implications to use "oom_check" instead?

Thanks

--Ying



>
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0mm/memcontrol.c | =A0 26 +++++++++++++-------------
>> =A01 files changed, 13 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 894e0d2..4c49ca0 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2065,8 +2065,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup =
*memcg, gfp_t gfp_mask,
>> =A0static int __mem_cgroup_try_charge(struct mm_struct *mm,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t=
 gfp_mask,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsig=
ned int nr_pages,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =
mem_cgroup **ptr,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool oo=
m)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =
mem_cgroup **ptr)
>> =A0{
>> =A0 =A0 =A0 unsigned int batch =3D max(CHARGE_BATCH, nr_pages);
>> =A0 =A0 =A0 int nr_oom_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
>> @@ -2149,7 +2148,7 @@ again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 oom_check =3D false;
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (oom && !nr_oom_retries) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!(gfp_mask & __GFP_NORETRY) && !nr_oom_ret=
ries) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 oom_check =3D true;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_oom_retries =3D MEM_CGROU=
P_RECLAIM_RETRIES;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -2167,7 +2166,7 @@ again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&memcg->css);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nomem;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case CHARGE_NOMEM: /* OOM routine works */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!oom) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (gfp_mask & __GFP_NORETRY) =
{
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&mem=
cg->css);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nomem;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -2456,10 +2455,11 @@ static int mem_cgroup_move_parent(struct page *p=
age,
>> =A0 =A0 =A0 if (isolate_lru_page(page))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto put;
>>
>> + =A0 =A0 gfp_mask |=3D __GFP_NORETRY;
>> =A0 =A0 =A0 nr_pages =3D hpage_nr_pages(page);
>>
>> =A0 =A0 =A0 parent =3D mem_cgroup_from_cont(pcg);
>> - =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &par=
ent, false);
>> + =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &par=
ent);
>> =A0 =A0 =A0 if (ret || !parent)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto put_back;
>>
>> @@ -2492,7 +2492,6 @@ static int mem_cgroup_charge_common(struct page *p=
age, struct mm_struct *mm,
>> =A0 =A0 =A0 struct mem_cgroup *memcg =3D NULL;
>> =A0 =A0 =A0 unsigned int nr_pages =3D 1;
>> =A0 =A0 =A0 struct page_cgroup *pc;
>> - =A0 =A0 bool oom =3D true;
>> =A0 =A0 =A0 int ret;
>>
>> =A0 =A0 =A0 if (PageTransHuge(page)) {
>> @@ -2502,13 +2501,13 @@ static int mem_cgroup_charge_common(struct page =
*page, struct mm_struct *mm,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Never OOM-kill a process for a huge pag=
e. =A0The
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* fault handler will fall back to regular=
 pages.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 oom =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 gfp_mask |=3D __GFP_NORETRY;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
>> =A0 =A0 =A0 BUG_ON(!pc); /* XXX: remove this and move pc lookup into com=
mit */
>>
>> - =A0 =A0 ret =3D __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg=
, oom);
>> + =A0 =A0 ret =3D __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg=
);
>> =A0 =A0 =A0 if (ret || !memcg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>>
>> @@ -2571,7 +2570,7 @@ int mem_cgroup_cache_charge(struct page *page, str=
uct mm_struct *mm,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mm =3D &init_mm;
>>
>> =A0 =A0 =A0 if (page_is_file_cache(page)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __mem_cgroup_try_charge(mm, gfp_mask, =
1, &memcg, true);
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __mem_cgroup_try_charge(mm, gfp_mask, =
1, &memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret || !memcg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>>
>> @@ -2629,13 +2628,13 @@ int mem_cgroup_try_charge_swapin(struct mm_struc=
t *mm,
>> =A0 =A0 =A0 if (!memcg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto charge_cur_mm;
>> =A0 =A0 =A0 *ptr =3D memcg;
>> - =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, mask, 1, ptr, true);
>> + =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, mask, 1, ptr);
>> =A0 =A0 =A0 css_put(&memcg->css);
>> =A0 =A0 =A0 return ret;
>> =A0charge_cur_mm:
>> =A0 =A0 =A0 if (unlikely(!mm))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mm =3D &init_mm;
>> - =A0 =A0 return __mem_cgroup_try_charge(mm, mask, 1, ptr, true);
>> + =A0 =A0 return __mem_cgroup_try_charge(mm, mask, 1, ptr);
>> =A0}
>>
>> =A0static void
>> @@ -3024,6 +3023,7 @@ int mem_cgroup_prepare_migration(struct page *page=
,
>> =A0 =A0 =A0 int ret =3D 0;
>>
>> =A0 =A0 =A0 *ptr =3D NULL;
>> + =A0 =A0 gfp_mask |=3D __GFP_NORETRY;
>>
>> =A0 =A0 =A0 VM_BUG_ON(PageTransHuge(page));
>> =A0 =A0 =A0 if (mem_cgroup_disabled())
>> @@ -3075,7 +3075,7 @@ int mem_cgroup_prepare_migration(struct page *page=
,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> =A0 =A0 =A0 *ptr =3D memcg;
>> - =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, gfp_mask, 1, ptr, false)=
;
>> + =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, gfp_mask, 1, ptr);
>> =A0 =A0 =A0 css_put(&memcg->css);/* drop extra refcnt */
>> =A0 =A0 =A0 if (ret || *ptr =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageAnon(page)) {
>> @@ -4765,7 +4765,7 @@ one_by_one:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 GFP_KERNEL, 1, &memcg, false);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 GFP_KERNEL | __GFP_NORETRY, 1, &memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret || !memcg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* mem_cgroup_clear_mc() wil=
l do uncharge later */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> --
>> 1.7.3.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
