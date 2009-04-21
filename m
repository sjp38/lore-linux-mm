Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D2A7D6B003D
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 21:40:46 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L1fN8F029050
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 10:41:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB43945DE62
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:41:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC16345DD79
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:41:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89DCCE38008
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:41:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9A67E18001
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:41:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V3] Fix Committed_AS underflow
In-Reply-To: <1240256999.32604.330.camel@nimitz>
References: <1240244120.32604.278.camel@nimitz> <1240256999.32604.330.camel@nimitz>
Message-Id: <20090421102317.F113.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 10:41:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Eric B Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@linux.vnet.ibm.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> void vm_acct_memory(long pages)
> {
>         long *local;
> 	long local_min = -ACCT_THRESHOLD;
> 	long local_max = ACCT_THRESHOLD;
> 	long local_goal = 0;
> 
>         preempt_disable();
>         local = &__get_cpu_var(committed_space);
>         *local += pages;
>         if (*local > local_max || *local < local_min) {
>                 atomic_long_add(*local - local_goal, &vm_committed_space);
>                 *local = local_goal;
>         }
>         preempt_enable();
> }
> 
> But now consider if we changed the local_* variables a bit:
> 
> 	long local_min = -(ACCT_THRESHOLD*2);
> 	long local_max = 0
> 	long local_goal = -ACCT_THRESHOLD;
> 
> We'll get some possibly *large* numbers in meminfo, but it will at least
> never underflow.

if *local == -(ACCT_THRESHOLD*2), 
  *local - local_goal = -(ACCT_THRESHOLD*2) + ACCT_THRESHOLD = -ACCT_THRESHOLD

Then, we still pass negative value to atomic_long_add().
IOW, vm_committed_space still can be negative value.

Am I missing anything?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
