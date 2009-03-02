Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9AC006B00B3
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 19:25:25 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n220PMBD012433
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Mar 2009 09:25:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE8845DE53
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 09:25:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1912C45DE51
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 09:25:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFAA71DB805D
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 09:25:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 920A31DB803C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 09:25:21 +0900 (JST)
Date: Mon, 2 Mar 2009 09:24:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 01 Mar 2009 11:59:59 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v3...v2
> 1. Implemented several review comments from Kosaki-San and Kamezawa-San
>    Please see individual changelogs for changes
> 
> Changelog v2...v1
> 1. Soft limits now support hierarchies
> 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> 
> Here is v3 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. The CPU controllers interpretation
> of shares is very different though. 
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> If there are no major objections to the patches, I would like to get them
> included in -mm.
> 
> TODOs
> 
> 1. The current implementation maintains the delta from the soft limit
>    and pushes back groups to their soft limits, a ratio of delta/soft_limit
>    might be more useful
> 2. It would be nice to have more targetted reclaim (in terms of pages to
>    recalim) interface. So that groups are pushed back, close to their soft
>    limits.
> 
> Tests
> -----
> 
> I've run two memory intensive workloads with differing soft limits and
> seen that they are pushed back to their soft limit on contention. Their usage
> was their soft limit plus additional memory that they were able to grab
> on the system. Soft limit can take a while before we see the expected
> results.
> 
> Please review, comment.
> 
Please forgive me to say....that the code itself is getting better but far from
what I want. Maybe I have to show my own implementation to show my idea
and the answer is between yours and mine. If now was the last year, I have enough
time until distro's target kernel and may welcome any innovative patches even if
it seems to give me concerns, but I have to be conservative now.

At first, it's said "When cgroup people adds something, the kernel gets slow".
This is my start point of reviewing. Below is comments to this version of patch.

 1. I think it's bad to add more hooks to res_counter. It's enough slow to give up
    adding more fancy things..

 2. please avoid to add hooks to hot-path. In your patch, especially a hook to
    mem_cgroup_uncharge_common() is annoying me.

 3. please avoid to use global spinlock more. 
    no lock is best. mutex is better, maybe.

 4. RB-tree seems broken. Following is example. (please note you do all ops
    in lazy manner (once in HZ/4.)

   i). while running, the tree is constructed as following
 
             R           R=exceed=300M
            / \ 
           A   B      A=exceed=200M  B=exceed=400M
   ii) A process B exits, but and usage goes down.

   iii)      R          R=exceed=300M
            / \
           A   B      A=exceed=200M  B=exceed=10M

   vi) A new node inserted
             R         R=exceed=300M
            / \       
           A   B       A=exceed=200M B=exceed=10M
              / \
             nil C     C=exceed=310M

   v) Time expires and remove "R" and do rotate.

   Hmm ? Is above status is allowed ? I'm sorry if I misunderstand RBtree.

I'll post my own version in this week (more conservative version, maybe).
please discuss and compare trafe-offs.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
