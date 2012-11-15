Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 28A896B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:28:24 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BDA493EE0BC
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:28:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B4C45DE5A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:28:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5AD845DE5C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:28:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4395E08007
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:28:21 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 882F41DB804C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:28:21 +0900 (JST)
Message-ID: <50A4B5A0.8040102@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:28:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] memcg: remove test for current->mm in memcg_stop/resume_kmem_account
References: <1352948093-2315-1-git-send-email-glommer@parallels.com> <1352948093-2315-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1352948093-2315-4-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

(2012/11/15 11:54), Glauber Costa wrote:
> The original reason for the existence of this test, was that
> memcg_kmem_cache_create could be called from either softirq context
> (where memcg_stop/resume_account is not needed), or process context,
> (where memcg_stop/resume_account is needed). Just skipping it
> in-function was the cleanest way to merge both behaviors. The reason for
> that is that we would try to create caches right away through
> memcg_kmem_cache_create if the context would allow us to.
> 
> However, the final version of the code that merged did not have this
> behavior and we always queue up new cache creation. Thus, instead of a
> comment explaining why current->mm test is needed, my proposal in this
> patch is to remove memcg_stop/resume_account from the worker thread and
> make sure all callers have a valid mm context.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Andrew Morton <akpm@linux-foundation.org>

seems ok to me. But do we need VM_BUG_ON() ?
It seems functions called under memcg_stop_kmem_account() doesn't access
current->mm...

Anyway.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
