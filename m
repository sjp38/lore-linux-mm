Date: Thu, 31 Jan 2008 19:03:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
In-Reply-To: <20080201030104.GA29417@sgi.com>
Message-ID: <Pine.LNX.4.64.0801311901580.6272@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com>
 <20080201023113.GB26420@sgi.com> <Pine.LNX.4.64.0801311838070.26594@schroedinger.engr.sgi.com>
 <20080201030104.GA29417@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Jack Steiner wrote:

> I currently unlink the mmu_notifier when the last GRU mapping is closed. For
> example, if a user does a:
> 
>         gru_create_context();
>         ...
>         gru_destroy_context();
> 
> the mmu_notifier is unlinked and all task tables allocated
> by the driver are freed. Are you suggesting that I leave tables
> allocated until the task terminates??

You are in user space and calling into the kernel somehow. The 
mmap_sem is not held at that point so its no trouble to use the unregister 
function. After that wait for rcu and then free your tables.

> I assumed that I would need to use call_rcu() or synchronize_rcu()
> before the table is actually freed. That's still on my TODO list.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
