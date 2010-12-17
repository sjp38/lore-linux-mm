Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CAB636B00A2
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 19:06:49 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBH06lm6029066
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Dec 2010 09:06:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB81B45DE5C
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:06:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C67F745DE58
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:06:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7B611DB8048
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:06:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 839211DB804A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:06:46 +0900 (JST)
Date: Fri, 17 Dec 2010 09:01:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
Message-Id: <20101217090103.2a9ca19a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <E1PTCae-0007tw-Un@pomaz-ex.szeredi.hu>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
	<20101216100744.e3a417cf.kamezawa.hiroyu@jp.fujitsu.com>
	<E1PTCae-0007tw-Un@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Dec 2010 13:05:44 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Thu, 16 Dec 2010, KAMEZAWA Hiroyuki wrote:

> > Hmm, then, the page will be recharged to "current" instead of the memcg
> > where "old" was under control. Is this design ? If so, why ?
> 
> No, I just haven't thought about it.
> 
> Porbably charging "new" to where "old" was charged is the logical
> thing to do here.
> 
> > 
> > In mm/migrate.c, following is called.
> > 
> > 	 charge = mem_cgroup_prepare_migration(page, newpage, &mem);
> > 	....do migration....
> >         if (!charge)
> >                 mem_cgroup_end_migration(mem, page, newpage);
> > 
> > BTW, off topic, in fuse/dev.c
> > 
> > add_to_page_cache_locked(page)
> 
> This is the call which the above patch replaces with
> replace_page_cache_page().  So if I fix replace_page_cache_page() to
> charge "newpage" to the correct memory cgroup, that should solve all
> problems, no?
> 
No. memory cgroup expects all pages should be found on LRU. But, IIUC,
pages on this radix-tree will not be on LRU. So, memory cgroup can't find
it at destroying cgroup and can't reduce "usage" of resource to be 0.
This makes rmdir() returns -EBUSY.

I'm sorry if this page will be on LRU, somewhere.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
