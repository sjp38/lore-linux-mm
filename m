Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA25vEs9030561
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sun, 2 Nov 2008 14:57:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8FAF53C126
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:57:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BF3F524005B
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:57:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A37FD1DB803F
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:57:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FA6E1DB803C
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:57:13 +0900 (JST)
Date: Sun, 2 Nov 2008 14:56:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm] [PATCH 2/4] Memory cgroup resource counters for hierarchy
Message-Id: <20081102145641.a15f5bb3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <490D3F72.9040408@linux.vnet.ibm.com>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
	<20081101184837.2575.98059.sendpatchset@balbir-laptop>
	<20081102144237.59ab5f03.kamezawa.hiroyu@jp.fujitsu.com>
	<490D3F72.9040408@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 02 Nov 2008 11:19:38 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Sun, 02 Nov 2008 00:18:37 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> >> Add support for building hierarchies in resource counters. Cgroups allows us
> >> to build a deep hierarchy, but we currently don't link the resource counters
> >> belonging to the memory controller control groups, which are linked in
> >> cgroup hiearchy. This patch provides the infrastructure for resource counters
> >> that have the same hiearchy as their cgroup counter parts.
> >>
> >> These set of patches are based on the resource counter hiearchy patches posted
> >> by Pavel Emelianov.
> >>
> >> NOTE: Building hiearchies is expensive, deeper hierarchies imply charging
> >> the all the way up to the root. It is known that hiearchies are expensive,
> >> so the user needs to be careful and aware of the trade-offs before creating
> >> very deep ones.
> >>
> > ...isn't it better to add "root_lock" to res_counter rather than taking
> > all levels of lock one by one ?
> > 
> >  spin_lock(&res_counter->hierarchy_root->lock);
> >  do all charge/uncharge to hierarchy
> >  spin_unlock(&res_counter->hierarchy_root->lock);
> > 
> > Hmm ?
> > 
> 
> Good thought process, but that affects and adds code complexity for the case
> when hierarchy is enabled/disabled. It is also inefficient, since all charges
> will now contend on root lock, in the current process, it is step by step, the
> contention only occurs on common parts of the hierarchy (root being the best case).
> 

Above code's contention level is not different from "only root no children" case.
Just inside-lock is heavier.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
