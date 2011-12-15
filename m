Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id AC81E6B00DB
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 05:24:45 -0500 (EST)
Date: Thu, 15 Dec 2011 11:24:42 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 4/5] memcg: remove PCG_CACHE bit
Message-ID: <20111215102442.GI3047@cmpxchg.org>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
 <20111215150822.7b609f89.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111215150822.7b609f89.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, Dec 15, 2011 at 03:08:22PM +0900, KAMEZAWA Hiroyuki wrote:
> >From 577b441ae259728d83a99baba11bf4925b4542d4 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 15 Dec 2011 12:09:03 +0900
> Subject: [PATCH 4/5] memcg: remove PCG_CACHE bit.
> 
> This bit can be replaced by PageAnon(page) check.

You need to make sure that only fully rmapped pages are
charged/uncharged, which is not the case yet.  E.g. look at the
newpage_charge() in mm/memory.c::do_anonymous_page() - if the page
table is updated by someone else, that uncharge_page() in the error
path will see !PageAnon() because page->mapping is not set yet and
uncharge it as cache.

What I think is required is to break up the charging and committing
like we do for swap cache already:

	if (!mem_cgroup_try_charge())
		goto error;
	page_add_new_anon_rmap()
	mem_cgroup_commit()

This will also allow us to even get rid of passing around the charge
type everywhere...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
