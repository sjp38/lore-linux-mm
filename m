Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C886F6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 19:47:22 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L0lK9p002100
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 21 Jan 2010 09:47:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D0E45DE4E
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 09:47:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C491A45DD6D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 09:47:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA689E08002
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 09:47:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 872F51DB8040
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 09:47:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
In-Reply-To: <201001202221.34804.rjw@sisk.pl>
References: <20100120085053.405A.A69D9226@jp.fujitsu.com> <201001202221.34804.rjw@sisk.pl>
Message-Id: <20100121091023.3775.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 21 Jan 2010 09:47:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Hi Rafael,
> > 
> > Do you mean this is the unrelated issue of nVidia bug?
> 
> The nvidia driver _is_ buggy, but Maxim said he couldn't reproduce the
> problem if all the allocations made by the nvidia driver during suspend
> were changed to GFP_ATOMIC.
> 
> > Probably I haven't catch your point. I don't find Maxim's original bug
> > report. Can we share the test-case and your analysis detail?
> 
> The Maxim's original report is here:
> https://lists.linux-foundation.org/pipermail/linux-pm/2010-January/023982.html
> 
> and the message I'm referring to is at:
> https://lists.linux-foundation.org/pipermail/linux-pm/2010-January/023990.html

Hmmm...

Usually, Increasing I/O isn't caused MM change. either subsystem change
memory alloc/free pattern and another subsystem receive such effect ;)
I don't think this message indicate MM fault.

And, 2.6.33 MM change is not much. if the fault is in MM change
(note: my guess is no), The most doubtful patch is my "killing shrink_all_zones"
patch. If old shrink_all_zones reclaimed memory much rather than required. 
The patch fixed it. IOW, the patch can reduce available free memory to be used
buggy .suspend of the driver. but I don't think it is MM fault.

As I said, drivers can't use memory freely as their demand in suspend method.
It's obvious. They should stop such unrealistic assumption. but How should we fix
this?
 - Gurantee suspend I/O device at last?
 - Make much much free memory before calling .suspend method? even though
   typical drivers don't need.
 - Ask all drivers how much they require memory before starting suspend and
   Make enough free memory at first?
 - Or, do we have an alternative way?


Probably we have multiple option. but I don't think GFP_NOIO is good
option. It assume the system have lots non-dirty cache memory and it isn't
guranteed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
