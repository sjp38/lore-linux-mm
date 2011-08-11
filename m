Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 46213900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:09:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8D4E83EE0B6
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:09:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 74D3245DF42
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:09:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 56D4B45DF4B
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:09:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 38FF01DB803B
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:09:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0518E1DB8037
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:09:30 +0900 (JST)
Date: Thu, 11 Aug 2011 09:02:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: replace ss->id_lock with a rwlock
Message-Id: <20110811090211.77d380fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313000433-11537-1-git-send-email-abrestic@google.com>
References: <1313000433-11537-1-git-send-email-abrestic@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Bresticker <abrestic@google.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org

On Wed, 10 Aug 2011 11:20:33 -0700
Andrew Bresticker <abrestic@google.com> wrote:

> While back-porting Johannes Weiner's patch "mm: memcg-aware global reclaim"
> for an internal effort, we noticed a significant performance regression
> during page-reclaim heavy workloads due to high contention of the ss->id_lock.
> This lock protects idr map, and serializes calls to idr_get_next() in
> css_get_next() (which is used during the memcg hierarchy walk).  Since
> idr_get_next() is just doing a look up, we need only serialize it with
> respect to idr_remove()/idr_get_new().  By making the ss->id_lock a
> rwlock, contention is greatly reduced and performance improves.
> 
> Tested: cat a 256m file from a ramdisk in a 128m container 50 times
> on each core (one file + container per core) in parallel on a NUMA
> machine.  Result is the time for the test to complete in 1 of the
> containers.  Both kernels included Johannes' memcg-aware global
> reclaim patches.
> Before rwlock patch: 1710.778s
> After rwlock patch: 152.227s
> 
> Signed-off-by: Andrew Bresticker <abrestic@google.com>

Hopefully, the changelog should be based on the latest Linus's git tree
or mmotm. Even now, if a system has multiple hierarchies of memcg, I think
the contention will happen.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
