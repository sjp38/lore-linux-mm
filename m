Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2DB9D6B00BD
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 15:17:17 -0400 (EDT)
Received: by qyk29 with SMTP id 29so235222qyk.12
        for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:17:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090427203535.4e3f970b.d-nishimura@mtf.biglobe.ne.jp>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090427101323.GK4454@balbir.in.ibm.com>
	 <20090427203535.4e3f970b.d-nishimura@mtf.biglobe.ne.jp>
Date: Tue, 28 Apr 2009 00:47:31 +0530
Message-ID: <661de9470904271217t7ef9e300x1e40bbf0362ca14f@mail.gmail.com>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
	memcg
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 27, 2009 at 5:05 PM, Daisuke Nishimura
<d-nishimura@mtf.biglobe.ne.jp> wrote:
> On Mon, 27 Apr 2009 15:43:23 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-27 18:12:5=
9]:
>>
>> > Works very well under my test as following.
>> > =A0 prepare a program which does malloc, touch pages repeatedly.
>> >
>> > =A0 # echo 2M > /cgroup/A/memory.limit_in_bytes =A0# set limit to 2M.
>> > =A0 # echo 0 > /cgroup/A/tasks. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# a=
dd shell to the group.
>> >
>> > =A0 while true; do
>> > =A0 =A0 malloc_and_touch 1M & =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 # run malloc and touch program.
>> > =A0 =A0 malloc_and_touch 1M &
>> > =A0 =A0 malloc_and_touch 1M &
>> > =A0 =A0 sleep 3
>> > =A0 =A0 pkill malloc_and_touch =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0# kill them
>> > =A0 done
>> >
>> > Then, you can see memory.memsw.usage_in_bytes increase gradually and e=
xceeds 3M bytes.
>> > This means account for swp_entry is not reclaimed at kill -> exit-> za=
p_pte()
>> > because of race with swap-ops and zap_pte() under memcg.
>> >
>> > =3D=3D
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > Because free_swap_and_cache() function is called under spinlocks,
>> > it can't sleep and use trylock_page() instead of lock_page().
>> > By this, swp_entry which is not used after zap_xx can exists as
>> > SwapCache, which will be never used.
>> > This kind of SwapCache is reclaimed by global LRU when it's found
>> > at LRU rotation. Typical case is following.
>> >
>>
>> The changelog is not clear, this is the typical case for?
>>
> Okey, let me summarise the problem.
>
> First of all, what I think is problematic is "!PageCgroupUsed
> swap cache without the owner process".
> Those swap caches cannot be reclaimed by memcg's reclaim
> because they are not on memcg's LRU(!PageCgroupUsed pages are not
> linked to memcg's LRU).
> Moreover, the owner prcess has already gone, only global LRU scanning
> can free those swap caches.
>
> Those swap caches causes some problems like:
> (1) pressure the memsw.usage(only when MEM_RES_CTLR_SWAP).
> (2) make struct mem_cgroup unfreeable even after rmdir, because
> =A0 =A0we call mem_cgroup_get() when a page is swaped out(only when MEM_R=
ES_CTLR_SWAP).
> (3) pressure the usage of swap entry.
>
> Those swap caches can be created in paths like:
>
> Type-1) race between exit and swap-in path
> =A0Assume processA is exiting and pte has swap entry of swaped out page.
> =A0And processB is trying to swap in the entry by readahead.
> =A0This entry holds memsw.usage and refcnt to struct mem_cgroup.
>
> Type-1.1)
> =A0 =A0 =A0 =A0 =A0 =A0processA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A0 =A0 =A0 =A0 processB
> =A0-------------------------------------+--------------------------------=
-----
> =A0 =A0(free_swap_and_cache()) =A0 =A0 =A0 =A0 =A0 =A0| =A0(read_swap_cac=
he_async())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0swap_duplicate()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0__set_page_locked()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0add_to_swap_cache()
> =A0 =A0 =A0swap_entry_free() =3D=3D 1 =A0 =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0find_get_page() -> found =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0try_lock_page() -> fail & return |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0lru_cache_add_anon()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0 =A0doesn't link this page to memcg's
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0 =A0LRU, because of !PageCgroupUsed.
>
> Type-1.2)
> =A0 =A0 =A0 =A0 =A0 =A0processA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A0 =A0 =A0 =A0 processB
> =A0-------------------------------------+--------------------------------=
-----
> =A0 =A0(free_swap_and_cache()) =A0 =A0 =A0 =A0 =A0 =A0| =A0(read_swap_cac=
he_async())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0swap_duplicate()
> =A0 =A0 =A0swap_entry_free() =3D=3D 1 =A0 =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0find_get_page() -> not found =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 & return =A0 =A0 =A0| =A0=
 =A0__set_page_locked()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0add_to_swap_cache()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0lru_cache_add_anon()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0 =A0doesn't link this page to memcg's
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0 =A0LRU, because of !PageCgroupUsed.
>
> Type-2) race between exit and swap-out path
> =A0Assume processA is exiting and pte points to a page(!PageSwapCache).
> =A0And processB is trying reclaim the page.
>
> =A0 =A0 =A0 =A0 =A0 =A0processA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A0 =A0 =A0 =A0 processB
> =A0-------------------------------------+--------------------------------=
-----
> =A0 =A0(page_remove_rmap()) =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0(shrink_page=
_list())
> =A0 =A0 =A0 mem_cgroup_uncharge_page() =A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0->uncharged because it's not |
> =A0 =A0 =A0 =A0 =A0 =A0PageSwapCache yet. =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0So, both mem/memsw.usage =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0are decremented. =A0 =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A0add_to_swap() -> added to swap cache.
>
> =A0If this page goes thorough without being freed for some reason, this p=
age
> =A0doesn't goes back to memcg's LRU because of !PageCgroupUsed.

Thanks for the detailed explanation of the possible race conditions. I
am beginning to wonder why we don't have any hooks in add_to_swap.*.
for charging a page. If the page is already charged and if it is a
context issue (charging it to the right cgroup) that is already
handled from what I see. Won't that help us solve the !PageCgroupUsed
issue?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
