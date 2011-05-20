Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 458256B0022
	for <linux-mm@kvack.org>; Fri, 20 May 2011 01:36:16 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2443222qyk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 22:36:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
	<BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
	<BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
	<BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
	<20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 20 May 2011 14:36:13 +0900
Message-ID: <BANLkTinJbYrQoye7qjPzPxP8_deCSK0g7w@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Lutomirski <luto@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, May 20, 2011 at 2:08 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 20 May 2011 13:20:15 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> So I want to resolve your problem asap.
>> We don't have see report about that. Could you do git-bisect?
>> FYI, Recently, big change of mm is compaction,transparent huge pages.
>> Kame, could you point out thing related to memcg if you have a mind?
>>
>
> I don't doubt memcg at this stage because it never modify page->flags.
> Consdering the case, PageActive() is set against off-LRU pages after
> clear_active_flags() clears it.
>
> Hmm, I think I don't understand the lock system fully but...how do you
> think this ?
>
> =3D=3D
>
> At splitting a hugepage, the routine marks all pmd as "splitting".
>
> But assume a racy case where 2 threads run into spit at the
> same time, one thread wins compound_lock() and do split, another
> thread should not touch splitted pages.

Sorry. Now I don't have a time to review in detail.
When I look it roughly,  page_lock_anon_vma have to prevent it.
But Andrea needs current this problem and he will catch something we lost. =
:)


>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Index: mmotm-May11/mm/huge_memory.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-May11.orig/mm/huge_memory.c
> +++ mmotm-May11/mm/huge_memory.c
> @@ -1150,7 +1150,7 @@ static int __split_huge_page_splitting(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> -static void __split_huge_page_refcount(struct page *page)
> +static bool __split_huge_page_refcount(struct page *page)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long head_index =3D page->index;
> @@ -1161,6 +1161,11 @@ static void __split_huge_page_refcount(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&zone->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0compound_lock(page);
>
> + =C2=A0 =C2=A0 =C2=A0 if (!PageCompound(page)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 compound_unlock(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone-=
>lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 1; i < HPAGE_PMD_NR; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page_=
tail =3D page + i;
>
> @@ -1258,6 +1263,7 @@ static void __split_huge_page_refcount(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * to be pinned by the caller.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(page_count(page) <=3D 0);
> + =C2=A0 =C2=A0 =C2=A0 return true;
> =C2=A0}
>
> =C2=A0static int __split_huge_page_map(struct page *page,
> @@ -1367,7 +1373,8 @@ static void __split_huge_page(struct pag
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 mapcount, page_mapcount(page));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(mapcount !=3D page_mapcount(page));
>
> - =C2=A0 =C2=A0 =C2=A0 __split_huge_page_refcount(page);
> + =C2=A0 =C2=A0 =C2=A0 if (!__split_huge_page_refcount(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mapcount2 =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(avc, &anon_vma->head, same=
_anon_vma) {
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
