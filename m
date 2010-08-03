Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5AE046008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:22:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o733QpRg011428
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 12:26:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC4B145DE4D
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:26:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B95FA45DE6F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:26:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BD4A1DB8040
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:26:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F721DB8037
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:26:47 +0900 (JST)
Date: Tue, 3 Aug 2010 12:21:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] quick lookup memcg by ID
Message-Id: <20100803122158.c01b9921.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803032216.GC3863@balbir.in.ibm.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191304.8e520808.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803032216.GC3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 08:52:16 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:13:04]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, memory cgroup has an ID per cgroup and make use of it at
> >  - hierarchy walk,
> >  - swap recording.
> > 
> > This patch is for making more use of it. The final purpose is
> > to replace page_cgroup->mem_cgroup's pointer to an unsigned short.
> > 
> > This patch caches a pointer of memcg in an array. By this, we
> > don't have to call css_lookup() which requires radix-hash walk.
> > This saves some amount of memory footprint at lookup memcg via id.
> >
> 
> It is a memory versus speed tradeoff, but if the number of created
> cgroups is low, it might not be all that slow, besides we do that for
> swap_cgroup anyway - no?
>  

In following patch, pc->page_cgroup is changed from pointer to ID.
Then, this lookup happens in lru_add/del, for example.
And, by this, we can place all lookup related things to __read_mostly.
With css_lookup(), we can't do it and have to be afraid of cache
behavior.

I hear there are a users who create 2000+ cgroups and considering
about "low number" user here is not important.
This patch is a help for getting _stable_ performance even when there are
many cgroups.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
