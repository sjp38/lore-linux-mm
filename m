Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EACD25F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 04:54:48 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n388tcUn002513
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Apr 2009 17:55:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 421D145DE50
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:55:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1872045DE4F
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:55:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 101F71DB8037
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:55:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A66C01DB8045
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:55:37 +0900 (JST)
Date: Wed, 8 Apr 2009 17:54:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090408175409.eb0818db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090408084952.GG7082@balbir.in.ibm.com>
References: <20090407080355.GS7082@balbir.in.ibm.com>
	<20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052904.GY7082@balbir.in.ibm.com>
	<20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408070401.GC7082@balbir.in.ibm.com>
	<20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408071115.GD7082@balbir.in.ibm.com>
	<20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408074809.GF7082@balbir.in.ibm.com>
	<20090408170341.437c215b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408084952.GG7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 14:19:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 17:03:41]:
> 
> > On Wed, 8 Apr 2009 13:18:09 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > > > 3. Using the above, we can then try to (using an algorithm you
> > > > > proposed), try to do some work for figuring out the shared percentage.
> > > > > 
> > > > This is the point. At last. Why "# of shared pages" is important ?
> > > > 
> > > 
> > > I posted this in my motivation yesterday. # of shared pages can help
> > > plan the system better and the size of the cgroup. A cgroup might have
> > > small usage_in_bytes but large number of shared pages. We need a
> > > metric that can help figure out the fair usage of the cgroup.
> > > 
> > I don't fully understand but NR_FILE_MAPPED is an information in /proc/meminfo.
> > I personally think I want to support information in /proc/meminfo per memcg.
> > 
> > Hmm ? then, if you add a hook, it seems
> > == mm/rmap.c
> >  689 void page_add_file_rmap(struct page *page)
> >  690 {
> >  691         if (atomic_inc_and_test(&page->_mapcount))
> >  692                 __inc_zone_page_state(page, NR_FILE_MAPPED);
> >  693 }
> > ==  page_remove_rmap(struct page *page)
> >  739                 __dec_zone_page_state(page,
> >  740                         PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
> > ==
> > 
> > Is good place to go, maybe.
> > 
> > page->page_cgroup->mem_cgroup-> inc/dec counter ?
> > 
> > Maybe the patch itself will be simple, overhead is unknown..
> 
> I thought of the same thing, but then moved to the following
> 
> ... mem_cgroup_charge_statistics(..) {
>  if (page_mapcount(page) == 0 && page_is_file_cache(page))
>     __mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_RSS, val);
> 
> But I've not yet tested the end result
> 
I think 
 - at uncharge:
   charge_statistics is only called when FILE CACHE is removed from radix-tree.
   mem_cgroup_uncharge() is called only when PageAnon(page).
 - at charge:
   charge_statistics is only called when FILE CACHE is added to radix-tree.

This "checking only radix-tree insert/delete" help us to remove most of overheads
on FILE CACHE.

So, adding new hooks to page_add_file_rmap() and page_remove_rmap()
is a way to go. (and easy to understand because we account it at the same time
NR_FILE_MAPPED is modified.)


Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
