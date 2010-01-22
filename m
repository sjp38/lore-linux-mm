Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F21466B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 20:31:39 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M1Va1u011208
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 22 Jan 2010 10:31:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 85B1F45DE5B
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:31:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AC6645DE5A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:31:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 18BE7E18004
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:31:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C6AED1DB803F
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:31:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
In-Reply-To: <201001212121.50272.rjw@sisk.pl>
References: <20100121091023.3775.A69D9226@jp.fujitsu.com> <201001212121.50272.rjw@sisk.pl>
Message-Id: <20100122100155.6C03.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 22 Jan 2010 10:31:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Probably we have multiple option. but I don't think GFP_NOIO is good
> > option. It assume the system have lots non-dirty cache memory and it isn't
> > guranteed.
> 
> Basically nothing is guaranteed in this case.  However, does it actually make
> things _worse_?  

Hmm..
Do you mean we don't need to prevent accidental suspend failure?
Perhaps, I did misunderstand your intention. If you think your patch solve
this this issue, I still disagree. but If you think your patch mitigate
the pain of this issue, I agree it. I don't have any reason to oppose your
first patch.

> What _exactly_ does happen without the $subject patch if the
> system doesn't have non-dirty cache memory and someone makes a GFP_KERNEL
> allocation during suspend?

Page allocator prefer to spent lots time for reclaimable memory searching than
returning NULL. IOW, it can spent time few second if it doesn't have
reclaimable memory.
In typical case, OOM killer forcely make enough free memory if the system
don't have any memory. But under suspending time, oom killer is disabled.
So, if the caller (probably drivers) call alloc >1000times, the system
spent lots seconds.

In this case, GFP_NOIO doesn't help. slowness behavior is caused by
freeable memory search, not slow i/o.

However, if strange i/o device makes any i/o slowness, GFP_NOIO might help.
In this case, please don't ask me about i/o thing. I don't know ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
