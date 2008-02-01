Date: Thu, 31 Jan 2008 21:01:05 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
Message-ID: <20080201030104.GA29417@sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com> <20080201023113.GB26420@sgi.com> <Pine.LNX.4.64.0801311838070.26594@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311838070.26594@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 06:39:19PM -0800, Christoph Lameter wrote:
> On Thu, 31 Jan 2008, Robin Holt wrote:
> 
> > Jack has repeatedly pointed out needing an unregister outside the
> > mmap_sem.  I still don't see the benefit to not having the lock in the mm.
> 
> I never understood why this would be needed. ->release removes the 
> mmu_notifier right now.

Christoph -

We discussed this earlier this week. Here is part of the mail:

------------

> > There currently is no __mmu_notifier_unregister(). Oversite???
>
> No need. mmu_notifier_release implies an unregister and I think that is
> the most favored way to release resources since it deals with the RCU
> quiescent period.


I currently unlink the mmu_notifier when the last GRU mapping is closed. For
example, if a user does a:

        gru_create_context();
        ...
        gru_destroy_context();

the mmu_notifier is unlinked and all task tables allocated
by the driver are freed. Are you suggesting that I leave tables
allocated until the task terminates??

Why is that better? What problem do I cause by trying
to free tables as soon as they are not needed?


-----------------------------------------------

> Christoph responded:
> > the mmu_notifier is unlinked and all task tables allocated
> > by the driver are freed. Are you suggesting that I leave tables
> > allocated until the task terminates??
>
> You need to leave the mmu_notifier structure allocated until the next
> quiescent rcu period unless you use the release notifier.

I assumed that I would need to use call_rcu() or synchronize_rcu()
before the table is actually freed. That's still on my TODO list.



--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
