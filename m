Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 449B46B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 00:49:57 -0400 (EDT)
Date: Fri, 11 May 2012 00:49:49 -0400 (EDT)
Message-Id: <20120511.004949.655300373402132371.davem@davemloft.net>
Subject: Re: [PATCH 08/17] net: Introduce sk_allocation() to allow addition
 of GFP flags depending on the individual socket
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336657510-24378-9-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<1336657510-24378-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:45:01 +0100

> Introduce sk_allocation(), this function allows to inject sock specific
> flags to each sock related allocation. It is only used on allocation
> paths that may be required for writing pages back to network storage.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

This is still a little bit more than it needs to be.

You are trying to propagate a single bit from sk->sk_allocation into
all of the annotated socket memory allocation sites.

But many of them use sk->sk_allocation already.  In fact all of them
that use a variable rather than a constant GFP_* satisfy this
invariant.

All of those annotations are therefore spurious, and probably end up
generating unnecessary |'s in of that special bit in at least some
cases.

What you really, therefore, care about are the GFP_FOO cases.  And in
fact those are all GFP_ATOMIC.  So make something that says what it
is that you want, a GFP_ATOMIC with some socket specified bits |'d
in.

Something like this:

static inline gfp_t sk_gfp_atomic(struct sock *sk)
{
	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
}

You'll also have to make your networking patches conform to the
networking subsystem coding style.

For example:

> -	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
> +	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1,
> +					sk_allocation(sk, GFP_ATOMIC));

The sk_allocation() argument has to line up with the first column
after the openning parenthesis of the function call.  You can't just
use all TAB characters.  And this all TABs thing looks extremely ugly
to boot.

> -		newnp->pktoptions = skb_clone(treq->pktopts, GFP_ATOMIC);
> +		newnp->pktoptions = skb_clone(treq->pktopts,
> +						sk_allocation(sk, GFP_ATOMIC));

Same here.

What's really funny to me is that in several cases elsewhere in this
pach you get it right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
