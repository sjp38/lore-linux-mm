Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8EFA66B0140
	for <linux-mm@kvack.org>; Wed, 13 May 2009 19:44:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4DNjYEG028346
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 14 May 2009 08:45:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6504B45DD74
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:45:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4286945DD70
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:45:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48B5A1DB8012
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:45:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01F651DB8015
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:45:34 +0900 (JST)
Date: Thu, 14 May 2009 08:44:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix deadlock between lock_page_cgroup
 and mapping tree_lock
Message-Id: <20090514084401.0ec3432f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090513115626.57844f28.akpm@linux-foundation.org>
References: <20090513133031.f4be15a8.nishimura@mxp.nes.nec.co.jp>
	<20090513115626.57844f28.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, balbir@in.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 11:56:26 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 13 May 2009 13:30:31 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > mapping->tree_lock can be aquired from interrupt context.
> > Then, following dead lock can occur.
> > 
> > Assume "A" as a page.
> > 
> >  CPU0:
> >        lock_page_cgroup(A)
> > 		interrupted
> > 			-> take mapping->tree_lock.
> >  CPU1:
> >        take mapping->tree_lock
> > 		-> lock_page_cgroup(A)
> 
> And we didn't find out about this because lock_page_cgroup() uses
> bit_spin_lock(), and lockdep doesn't handle bit_spin_lock().
> 
> It would perhaps be useful if one of you guys were to add a spinlock to
> struct page, convert lock_page_cgroup() to use that spinlock then run a
> full set of tests under lockdep, see if it can shake out any other bugs.
> 
Ah, yes. Special debug option to this can be allowed ?
CONFIG_DEBUG_MEM_CGROUP_SPINLOCK or some.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
