Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BE695F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 04:05:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3885Bsm011034
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Apr 2009 17:05:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 73D7345DD74
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:05:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A60345DD72
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:05:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17495E0800E
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:05:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D5A21DB8018
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 17:05:10 +0900 (JST)
Date: Wed, 8 Apr 2009 17:03:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090408170341.437c215b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090408074809.GF7082@balbir.in.ibm.com>
References: <20090407071825.GR7082@balbir.in.ibm.com>
	<20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407080355.GS7082@balbir.in.ibm.com>
	<20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052904.GY7082@balbir.in.ibm.com>
	<20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408070401.GC7082@balbir.in.ibm.com>
	<20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408071115.GD7082@balbir.in.ibm.com>
	<20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408074809.GF7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 13:18:09 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > > 3. Using the above, we can then try to (using an algorithm you
> > > proposed), try to do some work for figuring out the shared percentage.
> > > 
> > This is the point. At last. Why "# of shared pages" is important ?
> > 
> 
> I posted this in my motivation yesterday. # of shared pages can help
> plan the system better and the size of the cgroup. A cgroup might have
> small usage_in_bytes but large number of shared pages. We need a
> metric that can help figure out the fair usage of the cgroup.
> 
I don't fully understand but NR_FILE_MAPPED is an information in /proc/meminfo.
I personally think I want to support information in /proc/meminfo per memcg.

Hmm ? then, if you add a hook, it seems
== mm/rmap.c
 689 void page_add_file_rmap(struct page *page)
 690 {
 691         if (atomic_inc_and_test(&page->_mapcount))
 692                 __inc_zone_page_state(page, NR_FILE_MAPPED);
 693 }
==  page_remove_rmap(struct page *page)
 739                 __dec_zone_page_state(page,
 740                         PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
==

Is good place to go, maybe.

page->page_cgroup->mem_cgroup-> inc/dec counter ?

Maybe the patch itself will be simple, overhead is unknown..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
