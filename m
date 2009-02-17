Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4D6656B00D6
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 19:06:40 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1H06bV8018500
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Feb 2009 09:06:37 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66F3E45DE53
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:06:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F12C45DE4F
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:06:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F0D91DB8042
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:06:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CD591DB803C
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:06:36 +0900 (JST)
Date: Tue, 17 Feb 2009 09:05:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches (v2)
Message-Id: <20090217090523.975bbec2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2009 16:38:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v2...v1
> 1. Soft limits now support hierarchies
> 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> 
> Here is v2 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. The CPU controllers interpretation
> of shares is very different though. We'll compare shares and soft limits
> below.
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> This is an RFC implementation and is not meant for inclusion
> 

some thoughts after reading patch.

1. As I pointed out, cpuset/mempolicy case is not handled yet.
2. I don't like to change usual direct-memory-reclaim path. It will be obstacles
   for VM-maintaners to improve memory reclaim. memcg's LRU is designed for
   shrinking memory usage and not for avoiding memory shortage. IOW, it's slow routine
   for reclaiming memory for memory shortage.
3. After this patch, res_counter is no longer for general purpose res_counter...
   It seems to have too many unnecessary accessories for general purpose.  
4. please use css_tryget() rather than mem_cgroup_get().
5. please remove mem_cgroup from tree at force_empty or rmdir.
   Just making  memcg->on_tree=false is enough ? I'm in doubt.
6. What happens when the-largest-soft-limit-memcg has tons on Anon on swapless
   system and memory reclaim cannot make enough progress ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
