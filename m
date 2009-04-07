Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 011775F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:01:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3771g7E018756
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Apr 2009 16:01:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7729545DE5D
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:01:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46E1E45DE57
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:01:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 337301DB8040
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:01:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA9421DB803E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:01:41 +0900 (JST)
Date: Tue, 7 Apr 2009 16:00:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090407063722.GQ7082@balbir.in.ibm.com>
References: <20090407063722.GQ7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Apr 2009 12:07:22 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Hi, All,
> 
> This is a request for input for the design of shared page accounting for
> the memory resource controller, here is what I have so far
> 

In my first impression, I think simple counting is impossible.
IOW, "usage count" and "shared or not" is very different problem.

Assume a page and its page_cgroup.

Case 1)
  1. a page is mapped by process-X under group-A
  2. its mapped by process-Y in group-B (now, shared and charged under group-A)
  3. move process-X to group-B
  4. now the page is not shared.

Case 2)
  swap is an object which can be shared.

Case 3)
  1. a page known as "A" is mapped by process-X under group-A.
  2. its mapped by process-Y under group-B(now, shared and charged under group-A)
  3. Do copy-on-write by process-X.
     Now, "A" is mapped only by B but accoutned under group-A.
     This case is ignored intentionally, now.
     Do you want to call try_charge() both against group-A and group-B
     under process-X's page fault ?

There will be many many corner case.


> Motivation for shared page accounting
> -------------------------------------
> 1. Memory cgroup administrators will benefit from the knowledge of how
>    much of the data is shared, it helps size the groups correctly.
> 2. We currently report only the pages brought in by the cgroup, knowledge
>    of shared data will give a complete picture of the actual usage.
> 

Motivation sounds good. But counting this in generic rmap will have tons of
troubles and slow-down.

I bet we should prepare a file as
  /proc/<pid>/cgroup_maps

And show RSS/RSS-owned-by-us per process. Maybe this feature will be able to be
implemented in 3 days.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
