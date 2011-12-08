Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id DDFC56B004F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:43:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D67253EE0BC
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:43:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B961D45DEBC
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:43:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6319845DEB4
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:43:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 53D111DB803E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:43:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E56631DB8042
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:43:28 +0900 (JST)
Date: Thu, 8 Dec 2011 10:42:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: drop type MEM_CGROUP_CHARGE_TYPE_DROP
Message-Id: <20111208104213.90243b69.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAA_GA1d_PTnGQ9Sh+3wuX8uW8VEYrXwn1g-ui7hbzMLC1-HG=A@mail.gmail.com>
References: <1323253846-21245-1-git-send-email-lliubbo@gmail.com>
	<20111207200315.0bb99400.kamezawa.hiroyu@jp.fujitsu.com>
	<CAA_GA1d_PTnGQ9Sh+3wuX8uW8VEYrXwn1g-ui7hbzMLC1-HG=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, jweiner@redhat.com, mhocko@suse.cz

On Wed, 7 Dec 2011 20:29:24 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> On Wed, Dec 7, 2011 at 7:03 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 7 Dec 2011 18:30:46 +0800
> > Bob Liu <lliubbo@gmail.com> wrote:
> >
> >> uncharge will happen only when !page_mapped(page) no matter MEM_CGROUP_CHARGE_TYPE_DROP
> >> or MEM_CGROUP_CHARGE_TYPE_SWAPOUT when called from mem_cgroup_uncharge_swapcache().
> >> i think it's no difference, so drop it.
> >>
> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >
> > I think you didn't test at all.
> >
> >> ---
> >> A mm/memcontrol.c | A  A 5 -----
> >> A 1 files changed, 0 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 6aff93c..02a2988 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -339,7 +339,6 @@ enum charge_type {
> >> A  A  A  MEM_CGROUP_CHARGE_TYPE_SHMEM, A  /* used by page migration of shmem */
> >> A  A  A  MEM_CGROUP_CHARGE_TYPE_FORCE, A  /* used by force_empty */
> >> A  A  A  MEM_CGROUP_CHARGE_TYPE_SWAPOUT, /* for accounting swapcache */
> >> - A  A  MEM_CGROUP_CHARGE_TYPE_DROP, A  A /* a page was unused swap cache */
> >> A  A  A  NR_CHARGE_TYPE,
> >> A };
> >>
> >> @@ -3000,7 +2999,6 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >>
> >> A  A  A  switch (ctype) {
> >> A  A  A  case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> >> - A  A  case MEM_CGROUP_CHARGE_TYPE_DROP:
> >> A  A  A  A  A  A  A  /* See mem_cgroup_prepare_migration() */
> >> A  A  A  A  A  A  A  if (page_mapped(page) || PageCgroupMigration(pc))
> >> A  A  A  A  A  A  A  A  A  A  A  goto unlock_out;
> >> @@ -3121,9 +3119,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
> >> A  A  A  struct mem_cgroup *memcg;
> >> A  A  A  int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
> >>
> >> - A  A  if (!swapout) /* this was a swap cache but the swap is unused ! */
> >> - A  A  A  A  A  A  ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
> >> -
> >
> > Then, here , what ctype must be if !swapout ?
> >
> 
> I think MEM_CGROUP_CHARGE_TYPE_SWAPOUT is okay, i didn't get the point
> that the benefit of using MEM_CGROUP_CHARGE_TYPE_DROP.
> 
> If use  MEM_CGROUP_CHARGE_TYPE_SWAPOUT, page_mapped(page) also checked in
> __mem_cgroup_uncharge_common().
> 
> Maybe i missed something. Thanks.
> 
why you don't see 10 more lines.

If SWAPOUT, 
  - record swap out information to swap_cgroup
  - don't decrease memcg->memsw counter
If DROP
  - same as usual MAPPED anon pages.

DROP may be equal to MAPPED. But this swap realted codes are most fragile
part of memcg and we used another name than MAPPED for taking care.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
