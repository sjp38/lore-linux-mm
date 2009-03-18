Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3A5C26B004D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 20:09:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2I09Cdb022395
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Mar 2009 09:09:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6512E45DE51
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 09:09:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46D7C45DD79
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 09:09:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C6871DB803A
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 09:09:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D8C261DB803E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 09:09:11 +0900 (JST)
Date: Wed, 18 Mar 2009 09:07:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090318090747.61f09554.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090316083512.GV16897@balbir.in.ibm.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
	<20090314173111.16591.68465.sendpatchset@localhost.localdomain>
	<20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316083512.GV16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 14:05:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > +				next_mem =
> > > +					__mem_cgroup_largest_soft_limit_node();
> > > +			} while (next_mem == mem);
> > > +		}
> > > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > > +		__mem_cgroup_remove_exceeded(mem);
> > > +		if (mem->usage_in_excess)
> > > +			__mem_cgroup_insert_exceeded(mem);
> > 
> > If next_mem == NULL here, (means "mem" is an only mem_cgroup which excess softlimit.)
> > mem will be found again even if !reclaimed.
> > plz check.
> 
> Yes, We need to add a if (!next_mem) break; Thanks!
> 
Plz be sure that there can be following case.

  1. several memcg is over softlimit.
  2. almost all memory usage comes from ANON or tmpfile/shmem.
  3. Swapless system
     or
     Most of memory are mlocked.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
