Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9DCD26B0099
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 18:57:20 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0QNvHX8010850
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 Jan 2010 08:57:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70C6645DE50
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:57:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45BE045DE4F
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:57:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F21D11DB8040
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:57:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81F921DB8037
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:57:16 +0900 (JST)
Date: Wed, 27 Jan 2010 08:53:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100126151202.75bd9347.akpm@linux-foundation.org>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010 15:12:02 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 25 Jan 2010 15:15:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > This patch does
> >   - add sysctl for new bahavior.
> >   - add CONSTRAINT_LOWMEM to oom's constraint type.
> >   - pass constraint to __badness()
> >   - change calculation based on constraint. If CONSTRAINT_LOWMEM,
> >     use low_rss instead of vmsize.
> > 
> > Changelog 2010/01/25
> >  - showing extension_mask value in OOM kill main log header.
> > Changelog 2010/01/22:
> >  - added sysctl
> >  - fixed !CONFIG_MMU
> >  - fixed fs/proc/base.c breakacge.
> 
> It'd be nice to see some testing results for this.  Perhaps "here's a
> test case and here's the before-and-after behaviour".
> 
Hm. posting test case module is O.K ?
At leaset, I'll add what test was done and /var/log/message output to the log.


> I don't like the sysctl knob much. 
me, too.

> Hardly anyone will know to enable
> it so the feature won't get much testing and this binary decision
> fractures the testing effort.  It would be much better if we can get
> everyone running the same code.  I mean, if there are certain workloads
> on certain machines with which the oom-killer doesn't behave correctly
> then fix it!
Yes, I think you're right. But "breaking current behaviro of our servers!"
arguments kills all proposal to this area and this oom-killer or vmscan is
a feature should be tested by real users. (I'll write fork-bomb detector
and RSS based OOM again.)

Then, I'd like to use sysctl. Distro/users can select default value of this
by /etc/sysctl.conf file, at least.


> 
> Why was the '#include <linux/sysctl.h>" removed from sysctl.c?
> 
> The patch adds a random newline to sysctl.c.
> 
Sorry. my bad.


> It was never a good idea to add extern declarations to sysctl.c.  It's
> better to add them to a subsystem-specific header file (ie:
> mm-sysctl.h) and then include that file from the mm files that define
> or use sysctl_foo, and include it into sysctl.c.  Oh well.
> 
Hmm. Okay. I'll consider about that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
