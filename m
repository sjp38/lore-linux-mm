Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7205F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 04:49:42 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n38JnXf4003808
	for <linux-mm@kvack.org>; Thu, 9 Apr 2009 05:49:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n388oMHS299442
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 18:50:22 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n388oMGd032595
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 18:50:22 +1000
Date: Wed, 8 Apr 2009 14:19:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090408084952.GG7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090407080355.GS7082@balbir.in.ibm.com> <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com> <20090408052904.GY7082@balbir.in.ibm.com> <20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com> <20090408070401.GC7082@balbir.in.ibm.com> <20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com> <20090408071115.GD7082@balbir.in.ibm.com> <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com> <20090408074809.GF7082@balbir.in.ibm.com> <20090408170341.437c215b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090408170341.437c215b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 17:03:41]:

> On Wed, 8 Apr 2009 13:18:09 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > > > 3. Using the above, we can then try to (using an algorithm you
> > > > proposed), try to do some work for figuring out the shared percentage.
> > > > 
> > > This is the point. At last. Why "# of shared pages" is important ?
> > > 
> > 
> > I posted this in my motivation yesterday. # of shared pages can help
> > plan the system better and the size of the cgroup. A cgroup might have
> > small usage_in_bytes but large number of shared pages. We need a
> > metric that can help figure out the fair usage of the cgroup.
> > 
> I don't fully understand but NR_FILE_MAPPED is an information in /proc/meminfo.
> I personally think I want to support information in /proc/meminfo per memcg.
> 
> Hmm ? then, if you add a hook, it seems
> == mm/rmap.c
>  689 void page_add_file_rmap(struct page *page)
>  690 {
>  691         if (atomic_inc_and_test(&page->_mapcount))
>  692                 __inc_zone_page_state(page, NR_FILE_MAPPED);
>  693 }
> ==  page_remove_rmap(struct page *page)
>  739                 __dec_zone_page_state(page,
>  740                         PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
> ==
> 
> Is good place to go, maybe.
> 
> page->page_cgroup->mem_cgroup-> inc/dec counter ?
> 
> Maybe the patch itself will be simple, overhead is unknown..

I thought of the same thing, but then moved to the following

... mem_cgroup_charge_statistics(..) {
 if (page_mapcount(page) == 0 && page_is_file_cache(page))
    __mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_RSS, val);

But I've not yet tested the end result


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
