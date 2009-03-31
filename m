Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 69CEB6B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 21:25:54 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so2360388rvb.26
        for <linux-mm@kvack.org>; Mon, 30 Mar 2009 18:26:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090328214636.68FF.A69D9226@jp.fujitsu.com>
References: <20090327151926.f252fba7.nishimura@mxp.nes.nec.co.jp>
	 <20090327153035.35498303.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090328214636.68FF.A69D9226@jp.fujitsu.com>
Date: Tue, 31 Mar 2009 10:26:17 +0900
Message-ID: <28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename
	sc.may_swap to may_unmap)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,




On Mon, Mar 30, 2009 at 8:45 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Fri, 27 Mar 2009 15:19:26 +0900
>> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>>
>> > Added
>> > =C2=A0Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > =C2=A0Cc: Balbir Singh <balbir@in.ibm.com>
>> >
>> > I'm sorry for replying to a very old mail.
>> >
>> > > @@ -1713,7 +1713,7 @@ unsigned long try_to_free_mem_cgroup_pag
>> > > =C2=A0{
>> > > =C2=A0 struct scan_control sc =3D {
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_writepage =3D !laptop_mode,
>> > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_unmap =3D 1,
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .swap_cluster_max =3D SWAP_CLUSTE=
R_MAX,
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .swappiness =3D swappiness,
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .order =3D 0,
>> > > @@ -1723,7 +1723,7 @@ unsigned long try_to_free_mem_cgroup_pag
>> > > =C2=A0 struct zonelist *zonelist;
>> > >
>> > > =C2=A0 if (noswap)
>> > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc.may_swap =3D 0;
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc.may_unmap =3D 0;
>> > >
>> > > =C2=A0 sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (GFP_=
HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>> > IIUC, memcg had used may_swap as a flag for "we need to use swap?" as =
the name indicate.
>> >
>> > Because, when mem+swap hits the limit, trying to swapout pages is mean=
ingless
>> > as it doesn't change mem+swap usage.
>> >
>> Good catch...sigh, I missed this disussion.
>>
>>
>>
>> > What do you think of this patch?
>> > =3D=3D=3D
>> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> >
>> > vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
>> > but memcg had used it as a flag for "we need to use swap?", as the
>> > name indicate.
>> >
>> > And in current implementation, memcg cannot reclaim mapped file caches
>> > when mem+swap hits the limit.
>> >
>> When mem+swap hits the limit, swap-out anonymous page doesn't reduce the
>> amount of usage of mem+swap, so, swap-out should be avoided.
>>
>> > re-introduce may_swap flag and handle it at shrink_page_list.
>> >
>> > This patch doesn't influence any scan_control users other than memcg.
>> >
>>
>>
>> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>>
>> Seems good,
>> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> But hum....Maybe this lru scan work in the same way as the case
>> of !total_swap_pages. (means don't scan anon LRU.)
>> revisit this later.
>
> Well, How about following patch?
>
> So, I have to agree my judgement of may_unmap was wrong.
> You explain memcg can use may_swap instead may_unmap. and I think
> other may_unmap user (zone_reclaim and shrink_all_list) can convert
> may_unmap code to may_swap.
>
> IOW, Nishimura-san, you explain we can remove the branch of the may_unmap
> from shrink_page_list().
> it's really good job. thanks!
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D
> Subject: vmswan: reintroduce sc->may_swap
>
> vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
> but memcg had used it as a flag for "we need to use swap?", as the
> name indicate.
>
> And in current implementation, memcg cannot reclaim mapped file caches
> when mem+swap hits the limit.
>
> re-introduce may_swap flag and handle it at get_scan_ratio().
> This patch doesn't influence any scan_control users other than memcg.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> --
> =C2=A0mm/vmscan.c | =C2=A0 12 ++++++++++--
> =C2=A01 files changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3be6157..00ea4a1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -63,6 +63,9 @@ struct scan_control {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Can mapped pages be reclaimed? */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int may_unmap;
>
> + =C2=A0 =C2=A0 =C2=A0 /* Can pages be swapped as part of reclaim? */
> + =C2=A0 =C2=A0 =C2=A0 int may_swap;
> +

Sorry for too late response.
I don't know memcg well.

The memcg managed to use may_swap well with global page reclaim until now.
I think that was because may_swap can represent both meaning.
Do we need each variables really ?

How about using union variable ?
---

struct scan_control {
  /* Incremented by the number of inactive pages that were scanned */
  unsigned long nr_scanned;
...
   union {
    int may_swap; /* memcg: Cap pages be swapped as part of reclaim? */
    int may_unmap /* global: Can mapped pages be reclaimed? */
  };



> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* This context's SWAP_CLUSTER_MAX. If freeing=
 memory for
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * suspend, we effectively ignore SWAP_CLUSTER=
_MAX.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * In this context, it doesn't matter that we =
scan the
> @@ -1379,7 +1382,7 @@ static void get_scan_ratio(struct zone *zone, struc=
t scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone_reclaim_stat *reclaim_stat =3D get=
_reclaim_stat(zone, sc);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If we have no swap space, do not bother sca=
nning anon pages. */
> - =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages <=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[0] =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[1] =3D 100=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> @@ -1695,6 +1698,7 @@ unsigned long try_to_free_pages(struct zonelist *zo=
nelist, int order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_writepage =3D=
 !laptop_mode,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swap_cluster_max =
=3D SWAP_CLUSTER_MAX,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_unmap =3D 1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swappiness =3D vm=
_swappiness,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.order =3D order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.mem_cgroup =3D NU=
LL,
> @@ -1714,6 +1718,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct m=
em_cgroup *mem_cont,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_control sc =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_writepage =3D=
 !laptop_mode,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_unmap =3D 1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swap_cluster_max =
=3D SWAP_CLUSTER_MAX,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swappiness =3D sw=
appiness,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.order =3D 0,
> @@ -1723,7 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct m=
em_cgroup *mem_cont,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zonelist *zonelist;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (noswap)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc.may_unmap =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc.may_swap =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) =
|
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> @@ -1763,6 +1768,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat=
, int order)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_control sc =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.gfp_mask =3D GFP_=
KERNEL,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_unmap =3D 1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swap_cluster_max =
=3D SWAP_CLUSTER_MAX,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swappiness =3D vm=
_swappiness,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.order =3D order,
> @@ -2109,6 +2115,7 @@ unsigned long shrink_all_memory(unsigned long nr_pa=
ges)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_control sc =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.gfp_mask =3D GFP_=
KERNEL,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_unmap =3D 0,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swap_cluster_max =
=3D nr_pages,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_writepage =3D=
 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.isolate_pages =3D=
 isolate_pages_global,
> @@ -2289,6 +2296,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_control sc =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_writepage =3D=
 !!(zone_reclaim_mode & RECLAIM_WRITE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.may_unmap =3D !!(=
zone_reclaim_mode & RECLAIM_SWAP),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .may_swap =3D 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.swap_cluster_max =
=3D max_t(unsigned long, nr_pages,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SWAP_CLUS=
TER_MAX),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.gfp_mask =3D gfp_=
mask,
>
>
>
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
