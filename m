Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD2VCcD011373
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 11:31:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5486545DD7E
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:31:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B3F745DD7B
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:31:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0163D1DB803B
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:31:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 991F41DB8041
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:31:11 +0900 (JST)
Date: Thu, 13 Nov 2008 11:30:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
Message-Id: <20081113113035.844e8756.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491B802B.2060401@linux.vnet.ibm.com>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112160758.3dca0b22.akpm@linux-foundation.org>
	<491B7395.8040606@linux.vnet.ibm.com>
	<20081112164637.b6f3cb78.akpm@linux-foundation.org>
	<491B7978.7010300@linux.vnet.ibm.com>
	<20081112170400.bfb7211c.akpm@linux-foundation.org>
	<491B802B.2060401@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Nov 2008 06:47:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > btw, mem_cgroup_force_empty_list() uses PageLRU() outside ->lru_lock. 
> > That's racy, although afaict this race will only cause an accounting
> > error.
> > 
> > Or maybe not.  What happens if
> > __mem_cgroup_uncharge_common()->__mem_cgroup_remove_list() is passed a
> > page which isn't on an LRU any more?  boom?
> > 
> 
> IIRC, Kamezawa has been working on redoing force_empty interface. We are
> reworking its internals as well.
> 

PageLRU() is not used in account_move() version (in mmotm queue)
patches/memcg-move-all-acccounts-to-parent-at-rmdir.patch removes that.

We're now testing patch [6/6] which does

 1. remove per-memcg-lru-lock
 2. use zone->lru_lock instead of that.

Then, maintenance of this memcontrol.c will be much easier.

After patch [6/6]. account_move does

  isolate_page(page);
	move to other cgroup
  putback_lru_page(page);

as other usual routine does.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
