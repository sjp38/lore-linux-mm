Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EC75E6B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 22:34:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n812YFpY017288
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 11:34:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A434B45DE64
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 11:34:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49A5945DE55
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 11:34:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C5B41DB8042
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 11:34:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 95A761DB8047
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 11:34:14 +0900 (JST)
Date: Tue, 1 Sep 2009 11:32:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-Id: <20090901113214.60e7ae32.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090901022514.GA11974@localhost>
References: <20090831102640.092092954@intel.com>
	<20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com>
	<20090901022514.GA11974@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009 10:25:14 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 4. I can't understand why you need this. I wonder you can get pfn via
> >    /proc/<pid>/????. And this may insert HWPOISON to page-cache of shared
> >    library and "unexpected" process will be poisoned.
> 
> Sorry I should have explained this. It's mainly for correctness.
> When a user space tool queries the task PFNs in /proc/pid/pagemap and
> then send to /debug/hwpoison/corrupt-pfn, there is a racy window that
> the page could be reclaimed and allocated by some one else. It would
> be awkward to try to pin the pages in user space. So we need the
> guarantees provided by /debug/hwpoison/corrupt-filter-memcg, which
> will be checked inside the page lock with elevated reference count.
> 

memcg never holds refcnt for a page and the kernel::vmscan.c can reclaim
any pages under memcg whithout checking anything related to memcg.
*And*, your code has no "pin" code.
This patch sed does no jobs for your concern.

I recommend you to add
  /debug/hwpoizon/pin-pfn

Then,
	echo pfn > /debug/hwpoizon/pin-pfn
        # add pfn for hwpoison debug's watch list. and elevate refcnt
	check 'pfn' is still used.
 	echo pfn > /debug/hwpoison/corrupt-pfn
	# check 'watch list' and make it corrupt and release refcnt.
or some.

memcg is not for pinning a page and never do such.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
