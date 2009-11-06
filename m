Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C38236B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 19:58:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA60wdKe004765
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 09:58:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09BB845DE52
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:58:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB10445DE4E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:58:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B06D91DB803C
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:58:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 692E91DB8037
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 09:58:38 +0900 (JST)
Date: Fri, 6 Nov 2009 09:56:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lib: generic percpu counter array
Message-Id: <20091106095605.0cc96ab5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911051017310.25718@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
	<20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com>
	<20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911051017310.25718@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 10:20:18 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 5 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Anothter major percpu coutner is vm_stat[]. This patch implements
> > vm_stat[] style counter array in lib/percpu_counter.c
> > This is designed for introducing vm_stat[] style counter to memcg,
> > but maybe useful for other people. By using this, counter array
> > using percpu can be implemented easily in compact structure.
> 
> 
> Note that vm_stat support was written that way because we have extreme
> space constraints due to the need to keep statistics per zone and per cpu
> and avoid cache line pressure that would result through the use of big
> integer arrays per zone and per cpu. For a large number of zones and cpus
> this is desastrous.
> 
> If you only need to keep statistics per cpu for an entity then the vmstat
> approach is overkill. A per cpu allocation of a counter is enough.
> 
counter per memcg is required.
Memcg uses its own one but I want to remove it. (it doesn't consider memory
placement.)
What I can use under /lib is percpu_counter, but it's really overkill.

My concern on pure percpu counter is "read" side.
Now, we read counters only via status file and sometimes vmscan will read it.
For supporting dirty_ratio, we need to read them more.
I'll check I can move it to pure percpu counter as you do in mm_counters and
see how read side is affected by for_each_possible_cpu(). Anyway, it's
better than current one.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
