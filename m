Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD1SWKr026714
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 10:28:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6333145DE55
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:28:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 33A9C45DE51
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:28:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 12C301DB8041
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:28:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B717F1DB803A
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:28:31 +0900 (JST)
Date: Thu, 13 Nov 2008 10:27:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
Message-Id: <20081113102755.11a11fa2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491B80E8.4090107@linux.vnet.ibm.com>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112160758.3dca0b22.akpm@linux-foundation.org>
	<20081113101344.6882c209.kamezawa.hiroyu@jp.fujitsu.com>
	<491B80E8.4090107@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Nov 2008 06:50:40 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 12 Nov 2008 16:07:58 -0800
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> >> On Wed, 12 Nov 2008 12:26:56 +0900
> >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >>> +5.1 on_rmdir
> >>> +set behavior of memcg at rmdir (Removing cgroup) default is "drop".
> >>> +
> >>> +5.1.1 drop
> >>> +       #echo on_rmdir drop > memory.attribute
> >>> +       This is default. All pages on the memcg will be freed.
> >>> +       If pages are locked or too busy, they will be moved up to the parent.
> >>> +       Useful when you want to drop (large) page caches used in this memcg.
> >>> +       But some of in-use page cache can be dropped by this.
> >>> +
> >>> +5.1.2 keep
> >>> +       #echo on_rmdir keep > memory.attribute
> >>> +       All pages on the memcg will be moved to its parent.
> >>> +       Useful when you don't want to drop page caches used in this memcg.
> >>> +       You can keep page caches from some library or DB accessed by this
> >>> +       memcg on memory.
> >> Would it not be more useful to implement a per-memcg version of
> >> /proc/sys/vm/drop_caches?  (One without drop_caches' locking bug,
> >> hopefully).
> >>
> >> If we do this then we can make the above "keep" behaviour non-optional,
> >> and the operator gets to choose whether or not to drop the caches
> >> before doing the rmdir.
> >>
> >> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
> >> interface, and it doesn't have the obvious races which on_rmdir has,
> >> etc.
> >>
> >> hm?
> >>
> > In my plan, I'll add
> > 
> > memory.shrink_usage interface to do and allows
> > 
> > #echo 0M > memory.shrink_memory_usage
> > (you may swap tasks out if there is task..)
> > 
> > to drop pages.
> > 
> 
> So, shrink_memory_usage is just for dropping caches? I don't understand the part
> about swap tasks out.
> 
No, just for shrinking usage. It can also drops ANON.


> > Balbir, how do you think ? I've already removed "force_empty".
> 
> Have you? Won't that go against API/ABI compatibility guidelines. I would
> recommend cc'ing linux-api as well. Sorry, I missed the patch that removes
> force_empty. Me culpa.
> 
account_move did that....

That was only for debug and is a hole for security of resource management.
So, removed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
