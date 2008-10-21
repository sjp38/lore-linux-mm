Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L1Ew52022316
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 10:14:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 356DE2AC025
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:14:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C5D612C049
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:14:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E38211DB803A
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:14:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A51F01DB803B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:14:57 +0900 (JST)
Date: Tue, 21 Oct 2008 10:14:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
Message-Id: <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008 12:53:58 -0700
"Paul Menage" <menage@google.com> wrote:

> Can't we do this in a more generic way, rather than duplicating a lot
> of functionality from res_counter?
> 
> You're trying to track:
> 
> - mem usage
> - mem limit
> - swap usage
> - swap+mem usage
> - swap+mem limit
> 
> And ensuring that:
> 
> - mem usage < mem limit
> - swap+mem usage < swap+mem limit
> 
> Could we somehow represent this as a pair of resource counters, one
> for mem and one for swap+mem that are linked together?
> 

1. It's harmful to increase size of *generic* res_counter. So, modifing
   res_counter only for us is not a choice.
2. Operation should be done under a lock. We have to do 
   -page + swap in atomic, at least.
3. We want to pack all member into a cache-line, multiple res_counter
   is no good.
4. I hate res_counter ;)

> Maybe have an "aggregate" pointer in a res_counter that points to
> another res_counter that sums some number of counters; both the mem
> and the swap res_counter objects for a cgroup would point to the
> mem+swap res_counter for their aggregate. Adjusting the usage of a
> counter would also adjust its aggregate (or fail if adjusting the
> aggregate failed).
> 
It's complicated. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
