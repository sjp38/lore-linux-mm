Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 626098D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 23:31:25 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p224VIhP025778
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 20:31:18 -0800
Received: from yxe1 (yxe1.prod.google.com [10.190.2.1])
	by kpbe20.cbf.corp.google.com with ESMTP id p224VEDV026969
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 20:31:17 -0800
Received: by yxe1 with SMTP id 1so4838246yxe.25
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 20:31:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103010909320.6253@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com>
	<AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com>
	<alpine.DEB.2.00.1103010909320.6253@router.home>
Date: Tue, 1 Mar 2011 20:31:14 -0800
Message-ID: <AANLkTim0Zjc7c9-7LCnEaYpV5PVN=5fNQpjMYqtZe-fk@mail.gmail.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Tue, Mar 1, 2011 at 7:11 AM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 1 Mar 2011, Pekka Enberg wrote:
>
> > The SLAB and SLUB patches are fine by me if there are going to be real
> > users for this. Christoph, Paul?
>
> The solution is a bit overkill. It would be much simpler to add a union to
> struct page that has lru and the rcu in there similar things can be done
> for SLAB and the network layer. A similar issue already exists for the
> spinlock in struct page. Lets follow the existing way of handling this.
>
> Struct page may be larger for debugging purposes already because of the
> need for extended spinlock data.

That was so for a long time, but I stopped it just over a year ago
with commit a70caa8ba48f21f46d3b4e71b6b8d14080bbd57a, stop ptlock
enlarging struct page.

Partly out of shame at how large struct page was growing when lockdep
is on, but also a subtle KSM reason which might apply here too: KSM
relies on the content of page->mapping to be kernel pointer to a
relevant structure, NULLed when the page is freed.

If a union leads to "random junk" overwriting the page->mapping field
when the page is reused, and that junk could resemble the pointer in
question, then KSM would mistakenly think it still owned the page.
Very remote chance, and maybe it amounts to no more than a leak.  But
I'd still prefer we keep page->mapping for pointers (sometimes with
lower bits set as flags).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
