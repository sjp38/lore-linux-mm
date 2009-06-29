Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2BA7F6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 03:46:46 -0400 (EDT)
Received: by gxk3 with SMTP id 3so6250233gxk.14
        for <linux-mm@kvack.org>; Mon, 29 Jun 2009 00:48:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360906280947o6f9358ddh20ab549e875282a9@mail.gmail.com>
References: <3901.1245848839@redhat.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
	 <2f11576a0906280749v25ab725dn8f98fbc1d2e5a5fd@mail.gmail.com>
	 <28c262360906280947o6f9358ddh20ab549e875282a9@mail.gmail.com>
Date: Mon, 29 Jun 2009 16:48:13 +0900
Message-ID: <2f11576a0906290048t29667ae0sd75c96d023b113e2@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2009/6/29 Minchan Kim <minchan.kim@gmail.com>:
> On Sun, Jun 28, 2009 at 11:49 PM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>>>> In David's OOM case, there are two symptoms:
>>>> 1) 70000 unaccounted/leaked pages as found by Andrew
>>>> =A0 (plus rather big number of PG_buddy and pagetable pages)
>>>> 2) almost zero active_file/inactive_file; small inactive_anon;
>>>> =A0 many slab and active_anon pages.
>>>>
>>>> In the situation of (2), the slab cache is _under_ scanned. So David
>>>> got OOM when vmscan should have squeezed some free pages from the slab
>>>> cache. Which is one important side effect of MinChan's patch?
>>>
>>> My patch's side effect is (2).
>>>
>>> My guessing is following as.
>>>
>>> 1. The number of page scanned in shrink_slab is increased in shrink_pag=
e_list.
>>> And it is doubled for mapped page or swapcache.
>>> 2. shrink_page_list is called by shrink_inactive_list
>>> 3. shrink_inactive_list is called by shrink_list
>>>
>>> Look at the shrink_list.
>>> If inactive lru list is low, it always call shrink_active_list not
>>> shrink_inactive_list in case of anon.
>>> It means it doesn't increased sc->nr_scanned.
>>> Then shrink_slab can't shrink enough slab pages.
>>> So, David OOM have a lot of slab pages and active anon pages.
>>>
>>> Does it make sense ?
>>> If it make sense, we have to change shrink_slab's pressure method.
>>> What do you think ?
>>
>> I'm confused.
>>
>> if system have no swap, get_scan_ratio() always return anon=3D0%.
>> Then, the numver of inactive_anon is not effect to sc.nr_scanned.
>>
>
> My patch isn't a concern since the number of anon lru list(active +
> anon) always same. =A0I mean shrink_slab's lru_pages is same whether my
> patch there is. =A0OOM or Pass depends on sc->nr_scanned, I think.
>
> Why I think it is my patch's side effect is follow as.
>
> Compared to old behavior, my patch can change balancing of anon lru
> list when "swap file" is full as Hannes already pointed me out.
>
> It can affect reclaimable anon pages while David is going on swap test on=
 LTP.
> When swap file test is end, pages on swap file is inserted anon lru list,=
 again.
>
> My patch can change physical location of anon pages on ram compared to ol=
d.

No.
shrink_active_list() doesn't change page physical address.


> From now on, we have no swap file so that we can reclaim only file pages.
> But we have missed one thing. lumpy reclaim!. (In fact, we should not
> reclaim anon pages in no swap space. A few days ago, I sended patch
> about this problem. http://patchwork.kernel.org/patch/32651/)
>
> It can reclaim anon pages although we have no swap file.
> But after all, shrink_page_list can't reclaim anon pages. =A0But it
> increases sc->nr_scanned.
>
> So I think whether Shrink_slab can reclaim enough or not depends on
> sc->nr_scanned.
>
> David's problem is very subtle.
>
> 1. If lumpy picks up the anon pages, it can pass LTP since
> sc->nr_scanned is increased.
> 2. If lumpy don't pick up the anon pages, it can meet OOM since
> sc->nr_scanned is almost zero or very small.
>
> Unfortunately, my patch seems to change physical location of pages on
> ram compared to old so that it selects 2.
>
> It's my imaginary novel.
>
> Okay. I believe Wu's patch will solve David's problem.
> David. Could you test with Wu's patch ?

However, lumpy reclaim is good viewpoint.
Recently KAMEZAWA-san fix one serious lumpy reclaim problem. since
2.6.28 lumpy reclaim can insert file mapped pages to anon lru list.
Then, the page become to be not able to reclaimable.

David, Can you please try to following patch? it was posted to LKML
about 1-2 week ago.

Subject "[BUGFIX][PATCH] fix lumpy reclaim lru handiling at
isolate_lru_pages v2"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
