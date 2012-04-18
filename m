Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 73D5A6B0092
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 13:03:43 -0400 (EDT)
Received: by dakh32 with SMTP id h32so10839624dak.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 10:03:42 -0700 (PDT)
Date: Wed, 18 Apr 2012 10:03:37 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/7] res_counter: add a function
 res_counter_move_parent().
Message-ID: <20120418170337.GH19975@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
 <4F86BA66.2010503@jp.fujitsu.com>
 <20120416223157.GE12421@google.com>
 <4F8E678A.8000805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F8E678A.8000805@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Apr 18, 2012 at 04:04:42PM +0900, KAMEZAWA Hiroyuki wrote:
> (2012/04/17 7:31), Tejun Heo wrote:
> 
> > On Thu, Apr 12, 2012 at 08:20:06PM +0900, KAMEZAWA Hiroyuki wrote:
> >> +/*
> >> + * In hierarchical accounting, child's usage is accounted into ancestors.
> >> + * To move local usage to its parent, just forget current level usage.
> >> + */
> >> +void res_counter_move_parent(struct res_counter *counter, unsigned long val)
> >> +{
> >> +	unsigned long flags;
> >> +
> >> +	BUG_ON(!counter->parent);
> >> +	spin_lock_irqsave(&counter->lock, flags);
> >> +	res_counter_uncharge_locked(counter, val);
> >> +	spin_unlock_irqrestore(&counter->lock, flags);
> >> +}
> > 
> > On the second thought, do we need this at all?  It's as good as doing
> > nothing after all, no?
> > 
> 
> 
> I considered that, but I think it may make it hard to debug memcg leakage.
> I'd like to confirm res->usage == 0 at removal of memcg.

Hmmm... then let's name it res_counter_reset() or something.  I feel
very confused about the function name.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
