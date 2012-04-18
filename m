Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 56BDE6B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:06:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EC9C43EE0C0
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:06:31 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D344345DE50
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:06:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBA8645DE4D
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:06:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA3F7E08007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:06:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AB69E08003
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:06:31 +0900 (JST)
Message-ID: <4F8E678A.8000805@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:04:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] res_counter: add a function res_counter_move_parent().
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BA66.2010503@jp.fujitsu.com> <20120416223157.GE12421@google.com>
In-Reply-To: <20120416223157.GE12421@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/17 7:31), Tejun Heo wrote:

> On Thu, Apr 12, 2012 at 08:20:06PM +0900, KAMEZAWA Hiroyuki wrote:
>> +/*
>> + * In hierarchical accounting, child's usage is accounted into ancestors.
>> + * To move local usage to its parent, just forget current level usage.
>> + */
>> +void res_counter_move_parent(struct res_counter *counter, unsigned long val)
>> +{
>> +	unsigned long flags;
>> +
>> +	BUG_ON(!counter->parent);
>> +	spin_lock_irqsave(&counter->lock, flags);
>> +	res_counter_uncharge_locked(counter, val);
>> +	spin_unlock_irqrestore(&counter->lock, flags);
>> +}
> 
> On the second thought, do we need this at all?  It's as good as doing
> nothing after all, no?
> 


I considered that, but I think it may make it hard to debug memcg leakage.
I'd like to confirm res->usage == 0 at removal of memcg.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
