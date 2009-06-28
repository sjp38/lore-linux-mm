Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0425D6B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 10:48:21 -0400 (EDT)
Received: by yxe38 with SMTP id 38so3118512yxe.12
        for <linux-mm@kvack.org>; Sun, 28 Jun 2009 07:49:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
References: <3901.1245848839@redhat.com> <32411.1245336412@redhat.com>
	 <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
Date: Sun, 28 Jun 2009 23:49:52 +0900
Message-ID: <2f11576a0906280749v25ab725dn8f98fbc1d2e5a5fd@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

>> In David's OOM case, there are two symptoms:
>> 1) 70000 unaccounted/leaked pages as found by Andrew
>> =A0 (plus rather big number of PG_buddy and pagetable pages)
>> 2) almost zero active_file/inactive_file; small inactive_anon;
>> =A0 many slab and active_anon pages.
>>
>> In the situation of (2), the slab cache is _under_ scanned. So David
>> got OOM when vmscan should have squeezed some free pages from the slab
>> cache. Which is one important side effect of MinChan's patch?
>
> My patch's side effect is (2).
>
> My guessing is following as.
>
> 1. The number of page scanned in shrink_slab is increased in shrink_page_=
list.
> And it is doubled for mapped page or swapcache.
> 2. shrink_page_list is called by shrink_inactive_list
> 3. shrink_inactive_list is called by shrink_list
>
> Look at the shrink_list.
> If inactive lru list is low, it always call shrink_active_list not
> shrink_inactive_list in case of anon.
> It means it doesn't increased sc->nr_scanned.
> Then shrink_slab can't shrink enough slab pages.
> So, David OOM have a lot of slab pages and active anon pages.
>
> Does it make sense ?
> If it make sense, we have to change shrink_slab's pressure method.
> What do you think ?

I'm confused.

if system have no swap, get_scan_ratio() always return anon=3D0%.
Then, the numver of inactive_anon is not effect to sc.nr_scanned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
