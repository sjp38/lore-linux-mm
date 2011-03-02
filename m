Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 31ECB8D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 07:32:09 -0500 (EST)
Date: Wed, 2 Mar 2011 06:32:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
In-Reply-To: <AANLkTim0Zjc7c9-7LCnEaYpV5PVN=5fNQpjMYqtZe-fk@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103020625290.10180@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com> <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com> <alpine.DEB.2.00.1103010909320.6253@router.home> <AANLkTim0Zjc7c9-7LCnEaYpV5PVN=5fNQpjMYqtZe-fk@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Tue, 1 Mar 2011, Hugh Dickins wrote:

> > Struct page may be larger for debugging purposes already because of the
> > need for extended spinlock data.
>
> That was so for a long time, but I stopped it just over a year ago
> with commit a70caa8ba48f21f46d3b4e71b6b8d14080bbd57a, stop ptlock
> enlarging struct page.

Strange. I just played around with in in January and the page struct size
changes when I build kernels with full debugging. I have some
cmpxchg_double patches here that depend on certain alignment in the page
struct. Debugging causes all that stuff to get out of whack so that I had
to do some special patches to make sure fields following the spinlock are
properly aligned when the sizes change.

> If a union leads to "random junk" overwriting the page->mapping field
> when the page is reused, and that junk could resemble the pointer in
> question, then KSM would mistakenly think it still owned the page.
> Very remote chance, and maybe it amounts to no more than a leak.  But
> I'd still prefer we keep page->mapping for pointers (sometimes with
> lower bits set as flags).

DESTROY BY RCU uses the lru field which follows the mapping field in page
struct. Why would random junk overwrite the mapping field?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
