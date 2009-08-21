Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E54776B009A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:37:29 -0400 (EDT)
Received: by gxk12 with SMTP id 12so1148926gxk.4
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 08:37:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090821072743.GA1808@localhost>
References: <20090820024929.GA19793@localhost>
	 <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090820040533.GA27540@localhost>
	 <28c262360908202055u2744879cic989e007867d0599@mail.gmail.com>
	 <20090821072743.GA1808@localhost>
Date: Fri, 21 Aug 2009 19:57:24 +0900
Message-ID: <2f11576a0908210357j72a0c5b4v16997dff137bd738@mail.gmail.com>
Subject: Re: [PATCH -v2 changelog updated] mm: do batched scans for mem_cgroup
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

2009/8/21 Wu Fengguang <fengguang.wu@intel.com>:
> For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=3D1,
> in which case shrink_list() _still_ calls isolate_pages() with the much
> larger SWAP_CLUSTER_MAX. =A0It effectively scales up the inactive list
> scan rate by up to 32 times.
>
> For example, with 16k inactive pages and DEF_PRIORITY=3D12, (16k >> 12)=
=3D4.
> So when shrink_zone() expects to scan 4 pages in the active/inactive
> list, the active list will be scanned 4 pages, while the inactive list
> will be (over) scanned SWAP_CLUSTER_MAX=3D32 pages in effect. And that
> could break the balance between the two lists.
>
> It can further impact the scan of anon active list, due to the anon
> active/inactive ratio rebalance logic in balance_pgdat()/shrink_zone():
>
> inactive anon list over scanned =3D> inactive_anon_is_low() =3D=3D TRUE
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D> shrin=
k_active_list()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D> activ=
e anon list over scanned
>
> So the end result may be
>
> - anon inactive =A0=3D> over scanned
> - anon active =A0 =A0=3D> over scanned (maybe not as much)
> - file inactive =A0=3D> over scanned
> - file active =A0 =A0=3D> under scanned (relatively)
>
> The accesses to nr_saved_scan are not lock protected and so not 100%
> accurate, however we can tolerate small errors and the resulted small
> imbalanced scan rates between zones.
>

Looks good to me.
  Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
