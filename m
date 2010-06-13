Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 100686B01B6
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOtRg021755
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AAB6845DE52
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8787745DE4D
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 656911DB8051
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13EA01DB8045
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100608170630.80753ed1.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1006081654020.19582@chino.kir.corp.google.com> <20100608170630.80753ed1.akpm@linux-foundation.org>
Message-Id: <20100613184604.6184.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 8 Jun 2010 16:54:31 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Tue, 8 Jun 2010, Andrew Morton wrote:
> > 
> > > And I wonder if David has observed some problem which the 2010 change
> > > fixes!
> > > 
> > 
> > Yes, as explained in my changelog.  I'll paste it:
> > 
> > Tasks that do not share the same set of allowed nodes with the task that
> > triggered the oom should not be considered as candidates for oom kill.
> > 
> > Tasks in other cpusets with a disjoint set of mems would be unfairly
> > penalized otherwise because of oom conditions elsewhere; an extreme
> > example could unfairly kill all other applications on the system if a
> > single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> > more memory than allowed.
> 
> OK, so Nick's change didn't anticipate things being set to OOM_DISABLE?
> 
> OOM_DISABLE seems pretty dangerous really - allows malicious
> unprivileged users to go homicidal?

Just clarify. 

David's patch have following Pros/Cons.

Pros
	- 1/8 badness was inaccurate and a bit unclear why 1/8.
	- Usually, almost processes don't change their cpuset mask
	  in their life time. then, cpuset_mems_allowed_intersects()
	  is so so good heuristic.

Cons
	- But, they can change CPUSET mask. we can't assume 
	  cpuset_mems_allowed_intersects() return always correct 
	  memory usage.
	- The task may have mlocked page cache out of CPUSET mask.
	  (probably they are using cpuset.memory_spread_page, perhaps)


I don't think this is OOM_DISABLE related issue. I think just heuristic choice
matter. Both approaches have corner case obviously. Then, I asked most 
typical workload concern and test result. 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
