Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD63A6B006E
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 16:15:46 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id k14so6954425wgh.22
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:15:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r4si19805305wjz.63.2014.03.10.13.15.44
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 13:15:45 -0700 (PDT)
Date: Mon, 10 Mar 2014 16:15:08 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: deadlock in lru_add_drain ? (3.14rc5)
Message-ID: <20140310201508.GA16200@redhat.com>
References: <20140308220024.GA814@redhat.com>
 <CA+55aFzLxY8Xsn90v1OAsmVBWYPZTiJ74YE=HaCPYR2hvRfk+g@mail.gmail.com>
 <20140310150106.GD25290@htj.dyndns.org>
 <20140310155053.GA26188@redhat.com>
 <20140310200957.GF25290@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140310200957.GF25290@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Chris Metcalf <cmetcalf@tilera.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lai Jiangshan <laijs@cn.fujitsu.com>

On Mon, Mar 10, 2014 at 04:09:57PM -0400, Tejun Heo wrote:

 > Hmmm... this is puzzling.  At least according to the slightly
 > truncated (pids < 13) sysrq-t output, there's no kworker running
 > lru_add_drain_per_cpu() and nothing blocked on lru_add_drain_all::lock
 > can introduce any complex dependency.  Also, at least from glancing
 > over, I don't see anything behind lru_add_rain_per_cpu() which can get
 > involved in a complex dependency chain.
 > 
 > Assuming that the handful lost traces didn't reveal serious ah-has, it
 > almost looks like workqueue either failed to initiate execution of a
 > queued work item or flush_work() somehow got confused on a work item
 > which already finished, both of which are quite unlikely given that we
 > haven't had any simliar report on any other work items.
 > 
 > I think it'd be wise to extend sysrq-t output to include the states of
 > workqueue if for nothing else to easily rule out doubts about basic wq
 > functions.  Dave, is this as much information we're gonna get from the
 > trinity instance?  I assume trying to reproduce the case isn't likely
 > to work?
 
I tried enabling the function tracer, and ended up locking up the box entirely,
so had to reboot.  Rerunning it now on rc6, will let you know if it reproduces
(though it took like a day or so last time).

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
