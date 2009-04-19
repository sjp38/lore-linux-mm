Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0761F5F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 04:58:58 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 4so977955ywq.26
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 01:59:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090418184337.GA5556@cmpxchg.org>
References: <20090418152100.125A.A69D9226@jp.fujitsu.com>
	 <20090418184337.GA5556@cmpxchg.org>
Date: Sun, 19 Apr 2009 17:59:54 +0900
Message-ID: <2f11576a0904190159t2898edfal858ba12d3460c4e5@mail.gmail.com>
Subject: Re: [PATCH for mmotm 0414] vmscan,memcg: reintroduce sc->may_swap
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

Hi

>> @@ -1724,6 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pag
>> =A0 =A0 =A0 struct scan_control sc =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !laptop_mode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swap_cluster_max =3D SWAP_CLUSTER_MAX,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D swappiness,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,
>> @@ -1734,7 +1739,7 @@ unsigned long try_to_free_mem_cgroup_pag
>> =A0 =A0 =A0 struct zonelist *zonelist;
>>
>> =A0 =A0 =A0 if (noswap)
>> - =A0 =A0 =A0 =A0 =A0 =A0 sc.may_unmap =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.may_swap =3D 0;
>
> Can this be directly initialized?
>
> struct scan_control sc =3D {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0.may_swap =3D !noswap,
> =A0 =A0 =A0 =A0...
> };

your proposal is better coding style. but I also prefer condig style
consistency.
I think we should change may_unmap and may_swap at the same time.
Thus, I'd like to does it by another patch.



>> @@ -2120,6 +2126,7 @@ unsigned long shrink_all_memory(unsigned
>> =A0 =A0 =A0 struct scan_control sc =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
>
> shrink_all_memory() is not a user of shrink_zone() -> get_scan_ratio()
> and therefor not affected by this flag. =A0I think it's better not to
> set it here (just like sc->swappiness).

Will fix. thanks.



>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D 1,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .isolate_pages =3D isolate_pages_global,
>> =A0 =A0 =A0 };
>> @@ -2304,6 +2311,7 @@ static int __zone_reclaim(struct zone *z
>> =A0 =A0 =A0 struct scan_control sc =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !!(zone_reclaim_mode & RE=
CLAIM_WRITE),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D !!(zone_reclaim_mode & RECLAI=
M_SWAP),
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
>
> Shouldn't this be set to !!(zone_reclaim_mode & RECLAIM_SWAP) as well?
>
> With set to 1, zone_reclaim() will also reclaim unmapped swap cache
> pages (without swapping) and it might be desirable to do that.

In general, you are right.
but another patch is better. this patch should only change memcg behavior.

I plan to change this. I'm making some zone reclaim test case, after it,
I can post the patch.


> But
> then may_swap is a confusing name. =A0may_anon? =A0may_scan_anon?
> scan_anon?

Why?
may_swap =3D 0 mean no swap-out directly. not anon only.
it's because shmem page stay in LRU_ANON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
