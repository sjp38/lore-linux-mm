Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 717E66B01F9
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:40:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U6eEwk008566
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Mar 2010 15:40:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 278E545DE60
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:40:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C1D445DE70
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:40:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E76C81DB804C
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:40:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4770CE18003
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:40:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <1269930756.17240.4.camel@sli10-desk.sh.intel.com>
References: <20100330150453.8E9F.A69D9226@jp.fujitsu.com> <1269930756.17240.4.camel@sli10-desk.sh.intel.com>
Message-Id: <20100330153750.8EA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 30 Mar 2010 15:40:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 2010-03-30 at 14:08 +0800, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > value, but our calculation round it to zero. The commit makes vmscan
> > > completely skip anon pages and cause oops.
> > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > to 1. See below patch.
> > > But the offending commit still changes behavior. Without the commit, we scan
> > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > It's required to fix this too.
> > 
> > Can you please post your /proc/meminfo 
> attached.
> > and reproduce program? I'll digg it.
> our test is quite sample. mount tmpfs with double memory size and store several
> copies (memory size * 2/G) of kernel in tmpfs, and then do kernel build.
> for example, there is 3G memory and then tmpfs size is 6G and there is 6
> kernel copy.

Wow, tmpfs size > memsize!


> > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > had similar logic, but 1% swap-out made lots bug reports. 
> can you elaborate this?
> Completely restore previous behavior (do full scan with priority 0) is
> ok too.

This is a option. but we need to know the root cause anyway. if not,
we might reintroduce this issue again in the future.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
