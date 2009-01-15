Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 481586B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:32:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F6WdWX003067
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 15:32:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3728D45DD78
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:32:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 057A545DD7D
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:32:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C845D1DB8043
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:32:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F78E1DB803C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:32:38 +0900 (JST)
Date: Thu, 15 Jan 2009 15:31:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
Message-Id: <20090115153134.632ebc85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115061557.GD30358@balbir.in.ibm.com>
References: <496ED2B7.5050902@cn.fujitsu.com>
	<20090115061557.GD30358@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 11:45:57 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Li Zefan <lizf@cn.fujitsu.com> [2009-01-15 14:07:51]:
> 
> > 1. task p1 is in /memcg/0
> > 2. p1 does mmap(4096*2, MAP_LOCKED)
> > 3. echo 4096 > /memcg/0/memory.limit_in_bytes
> > 
> > The above 'echo' will never return, unless p1 exited or freed the memory.
> > The cause is we can't reclaim memory from p1, so the while loop in
> > mem_cgroup_resize_limit() won't break.
> > 
> > This patch fixes it by decrementing retry_count regardless the return value
> > of mem_cgroup_hierarchical_reclaim().
> >
> 
> The problem definitely seems to exist, shouldn't we fix reclaim to
> return 0, so that we know progress is not made and retry count
> decrements? 
> 

The behavior is correct. And we already check signal_pending() in the loop.
Ctrl-C or SIGALARM will works better than checking retry count.
 But adding a new control file, memory.resize_timeout to check timeout is a choice.

Second thought is.
thanks to Kosaki at el, LRU for locked pages is now visible in memory.stat
file. So, we may able to have clever way.

== 
 unevictable = mem_cgroup_get_all_zonestat(mem, LRU_UNEVICLABLE);
 if (newlimit < unevictable)
	break;
==
But considering hierarchy, this can be complex.
please don't modify current behavior for a while, I'll try to write "hierarchical stat"
with CSS_ID patch set's easy hierarchy walk.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
