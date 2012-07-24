Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E5AF16B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 21:46:16 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so14325215pbb.14
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 18:46:16 -0700 (PDT)
Date: Mon, 23 Jul 2012 18:46:11 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [RFC PATCH 0/6] augmented rbtree changes
Message-ID: <20120724014611.GA6974@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342787467-5493-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 20, 2012 at 05:31:01AM -0700, Michel Lespinasse wrote:
> Patch 5 speeds up the augmented rbtree erase. Here again we use a tree
> rotation callback during rebalancing; however we also have to propagate
> the augmented node information above nodes being erased and/or stitched,
> and I haven't found a nice enough way to do that. So for now I am proposing
> the simple-stupid way of propagating all the way to the root. More on
> this later.

So, I looked at it again and finally figured out a decent way to avoid
unnecessary propagation here. Going to resend patches 5/6 as replies to
their original postings.

> - The prio tree of all VMAs mapping a given file (struct address_space)
> could be switched to an augmented rbtree based interval tree (thus removing
> the prio tree library in favor of augmented rbtrees)

I actually have a prototype for that already. The augmented rbtree based
implementation is slightly faster than prio tree on insert/erase, and
considerably faster on lookups. However, this is with a synthetic test
exercising prio and rbtrees directly, not with a realistic workload going
through the MM layers. Do we know of situations where prio tree performance
is currently a concern ?

> As they stand, patches 3-6 don't seem to make a difference for basic rbtree
> support, and they improve my augmented rbtree insertion/erase benchmark
> by a factor of ~2.1 to ~2.3 depending on test machines.

After rewriting patches 5-6 as discussed above, augmented rbtrees are now
~2.5 - ~2.7 times faster than before this patch series.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
