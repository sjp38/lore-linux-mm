Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 13B206B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 11:04:22 -0400 (EDT)
Date: Sun, 28 Jun 2009 23:04:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090628150407.GA25076@localhost>
References: <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost> <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <2f11576a0906280749v25ab725dn8f98fbc1d2e5a5fd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0906280749v25ab725dn8f98fbc1d2e5a5fd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 28, 2009 at 10:49:52PM +0800, KOSAKI Motohiro wrote:
> >> In David's OOM case, there are two symptoms:
> >> 1) 70000 unaccounted/leaked pages as found by Andrew
> >> A  (plus rather big number of PG_buddy and pagetable pages)
> >> 2) almost zero active_file/inactive_file; small inactive_anon;
> >> A  many slab and active_anon pages.
> >>
> >> In the situation of (2), the slab cache is _under_ scanned. So David
> >> got OOM when vmscan should have squeezed some free pages from the slab
> >> cache. Which is one important side effect of MinChan's patch?
> >
> > My patch's side effect is (2).
> >
> > My guessing is following as.
> >
> > 1. The number of page scanned in shrink_slab is increased in shrink_page_list.
> > And it is doubled for mapped page or swapcache.
> > 2. shrink_page_list is called by shrink_inactive_list
> > 3. shrink_inactive_list is called by shrink_list
> >
> > Look at the shrink_list.
> > If inactive lru list is low, it always call shrink_active_list not
> > shrink_inactive_list in case of anon.
> > It means it doesn't increased sc->nr_scanned.
> > Then shrink_slab can't shrink enough slab pages.
> > So, David OOM have a lot of slab pages and active anon pages.
> >
> > Does it make sense ?
> > If it make sense, we have to change shrink_slab's pressure method.
> > What do you think ?
> 
> I'm confused.
> 
> if system have no swap, get_scan_ratio() always return anon=0%.
> Then, the numver of inactive_anon is not effect to sc.nr_scanned.

You are right. Hehe, so that's not a real side effect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
