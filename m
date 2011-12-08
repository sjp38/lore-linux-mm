Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 06F356B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 05:34:51 -0500 (EST)
Received: by qan41 with SMTP id 41so350492qan.14
        for <linux-mm@kvack.org>; Thu, 08 Dec 2011 02:34:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111208104213.90243b69.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323253846-21245-1-git-send-email-lliubbo@gmail.com>
	<20111207200315.0bb99400.kamezawa.hiroyu@jp.fujitsu.com>
	<CAA_GA1d_PTnGQ9Sh+3wuX8uW8VEYrXwn1g-ui7hbzMLC1-HG=A@mail.gmail.com>
	<20111208104213.90243b69.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 8 Dec 2011 18:34:50 +0800
Message-ID: <CAA_GA1cyRc0RFh7o85PSsNzFYOSwfbniJQUd6JOt=zjkxJ=Y4w@mail.gmail.com>
Subject: Re: [PATCH] memcg: drop type MEM_CGROUP_CHARGE_TYPE_DROP
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, jweiner@redhat.com, mhocko@suse.cz

On Thu, Dec 8, 2011 at 9:42 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 7 Dec 2011 20:29:24 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
>
>> On Wed, Dec 7, 2011 at 7:03 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Wed, 7 Dec 2011 18:30:46 +0800
>> > Bob Liu <lliubbo@gmail.com> wrote:
>> >
>> >> uncharge will happen only when !page_mapped(page) no matter MEM_CGROU=
P_CHARGE_TYPE_DROP
>> >> or MEM_CGROUP_CHARGE_TYPE_SWAPOUT when called from mem_cgroup_uncharg=
e_swapcache().
>> >> i think it's no difference, so drop it.
>> >>
>> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> >
>> > I think you didn't test at all.
>> >
>> >> ---
>> >> =C2=A0mm/memcontrol.c | =C2=A0 =C2=A05 -----
>> >> =C2=A01 files changed, 0 insertions(+), 5 deletions(-)
>> >>
>> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> >> index 6aff93c..02a2988 100644
>> >> --- a/mm/memcontrol.c
>> >> +++ b/mm/memcontrol.c
>> >> @@ -339,7 +339,6 @@ enum charge_type {
>> >> =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_CHARGE_TYPE_SHMEM, =C2=A0 /* used by =
page migration of shmem */
>> >> =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_CHARGE_TYPE_FORCE, =C2=A0 /* used by =
force_empty */
>> >> =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_CHARGE_TYPE_SWAPOUT, /* for accountin=
g swapcache */
>> >> - =C2=A0 =C2=A0 MEM_CGROUP_CHARGE_TYPE_DROP, =C2=A0 =C2=A0/* a page w=
as unused swap cache */
>> >> =C2=A0 =C2=A0 =C2=A0 NR_CHARGE_TYPE,
>> >> =C2=A0};
>> >>
>> >> @@ -3000,7 +2999,6 @@ __mem_cgroup_uncharge_common(struct page *page,=
 enum charge_type ctype)
>> >>
>> >> =C2=A0 =C2=A0 =C2=A0 switch (ctype) {
>> >> =C2=A0 =C2=A0 =C2=A0 case MEM_CGROUP_CHARGE_TYPE_MAPPED:
>> >> - =C2=A0 =C2=A0 case MEM_CGROUP_CHARGE_TYPE_DROP:
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* See mem_cgroup_pr=
epare_migration() */
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_mapped(page=
) || PageCgroupMigration(pc))
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 goto unlock_out;
>> >> @@ -3121,9 +3119,6 @@ mem_cgroup_uncharge_swapcache(struct page *page=
, swp_entry_t ent, bool swapout)
>> >> =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;
>> >> =C2=A0 =C2=A0 =C2=A0 int ctype =3D MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
>> >>
>> >> - =C2=A0 =C2=A0 if (!swapout) /* this was a swap cache but the swap i=
s unused ! */
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ctype =3D MEM_CGROUP_CHAR=
GE_TYPE_DROP;
>> >> -
>> >
>> > Then, here , what ctype must be if !swapout ?
>> >
>>
>> I think MEM_CGROUP_CHARGE_TYPE_SWAPOUT is okay, i didn't get the point
>> that the benefit of using MEM_CGROUP_CHARGE_TYPE_DROP.
>>
>> If use =C2=A0MEM_CGROUP_CHARGE_TYPE_SWAPOUT, page_mapped(page) also chec=
ked in
>> __mem_cgroup_uncharge_common().
>>
>> Maybe i missed something. Thanks.
>>
> why you don't see 10 more lines.
>
> If SWAPOUT,
> =C2=A0- record swap out information to swap_cgroup
> =C2=A0- don't decrease memcg->memsw counter
> If DROP
> =C2=A0- same as usual MAPPED anon pages.
>
> DROP may be equal to MAPPED. But this swap realted codes are most fragile
> part of memcg and we used another name than MAPPED for taking care.
>

Get it.
Sorry for my noise, i didn't deep into following function.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
