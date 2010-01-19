Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 17B226B009D
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 20:19:34 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0J1JVHl014633
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Jan 2010 10:19:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E4AB45DE54
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 10:19:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7285845DE55
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 10:19:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 487AB1DB803C
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 10:19:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CEA97E18004
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 10:19:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
In-Reply-To: <201001182155.09727.rjw@sisk.pl>
References: <20100118110324.AE30.A69D9226@jp.fujitsu.com> <201001182155.09727.rjw@sisk.pl>
Message-Id: <20100119101101.5F2E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Jan 2010 10:19:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi 

> > If suspend need lots memory, we need to make free memory before starting IO
> > suspending, I think.
> 
> Suspend as such doesn't need a lot of memory, except for some drivers doing
> things they shouldn't do.
> 
> However, there are a few problems that need to be addressed in general.
> 
> First, we can't really guarantee that there's a lot of free memory available
> during suspend and some memory allocations are done indirectly, using
> GFP_KERNEL (for example, when new kernel threads are started).  If one of
> these is done during suspend and it happens to cause the mm subsystem to
> start I/O on a suspended devices, the kernel will lock up.
> 
> Second, there may be a memory allocation in progress when suspend is started
> that causes I/O to happen and races with the suspend process.  If the latter
> wins the race, the I/O may be attempted on a suspended device and the kernel
> will lock up.

I think the race happen itself is bad. memory and I/O subsystem can't solve such race
elegantly. These doesn't know enough suspend state knowlege. I think the practical 
solution is that higher level design prevent the race happen.


> My patch attempts to avoid these two problems as well as the problem with
> drivers using GFP_KERNEL allocations during suspend which I admit might be
> solved by reworking the drivers.

Agreed. In this case, only drivers change can solve the issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
