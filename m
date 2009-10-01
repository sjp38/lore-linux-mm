Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94E456B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 21:06:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n911VQEv029223
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 1 Oct 2009 10:31:26 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0680945DE53
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:31:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C5845DE51
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:31:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AC93F1DB8040
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:31:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 53374E18009
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:31:25 +0900 (JST)
Date: Thu, 1 Oct 2009 10:29:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] memcg: replace memcg's per cpu status counter
 with array counter like vmstat
Message-Id: <20091001102912.7276a8b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091001094514.c9d2b3d9.nishimura@mxp.nes.nec.co.jp>
References: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
	<20091001094514.c9d2b3d9.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009 09:45:14 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 30 Sep 2009 19:04:17 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Hi,
> > 
> > In current implementation, memcg uses its own percpu counters for counting
> > evetns and # of RSS, CACHES. Now, counter is maintainer per cpu without
> > any synchronization as vm_stat[] or percpu_counter. So, this is
> >  update-is-fast-but-read-is-slow conter.
> > 
> > Because "read" for these counter was only done by memory.stat file, I thought
> > read-side-slowness was acceptable. Amount of memory usage, which affects
> > memory limit check, can be read by memory.usage_in_bytes. It's maintained
> > by res_counter.
> > 
> > But in current -rc, root memcg's memory usage is calcualted by this per cpu
> > counter and read side slowness may be trouble if it's frequently read.
> > 
> > And, in recent discusstion, I wonder we should maintain NR_DIRTY etc...
> > in memcg. So, slow-read-counter will not match our requirements, I guess.
> > I want some counter like vm_stat[] in memcg.
> > 
> I see your concern.
> 
> But IMHO, it would be better to explain why we need a new percpu array counter
> instead of using array of percpu_counter(size or consolidation of related counters ?),
> IOW, what the benefit of percpu array counter is.
> 
Ok.
  array of 4 percpu counter means a struct like following.

     lock                4bytes (int)
     count               8bytes
     list_head           16bytes
     pointer to percpu   8bytes
     lock                ,,,
     count
     list_head
     pointer to percpu
     lock
     count
     list_head
     pointer to percpu
     lock
     count
     list_head
     pointer to percpu

    36x4= 144 bytes and this has 4 spinlocks.2 cache lines.
    4 spinlock means if one of "batch" expires in a cpu, all cache above will
    be invalidated. Most of read-only data will lost.

    Making alignments of each percpu counter to cacheline for avoiding
    false sharing means this will use 4 cachelines + percpu area.
    That's bad.

  array counter of 4 entry is:
     s8 batch            4bytes (will be aligned)
     pointer to percpu   8bytes
     elements            4bytes.
     list head           16bytes
     ==== cacheline aligned here== 128bytes.
     atomic_long_t       4x8==32bytes
     ==== should be aligned to cache ? maybe yes===

  Then, this will occupy 2 cachelines + percpu area.
  No false sharing in read-only area.
  All writes are done in one (locked) access.

Hmm..I may have to consider more about archs which has not atomic_xxx ops.

Considerng sets of counters can be updated at once, array of percpu counter
is not good choice. I think.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
