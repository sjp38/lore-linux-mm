Date: Fri, 7 Mar 2008 12:10:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
 methods to sleep (#v9 was 1/4)
In-Reply-To: <20080307175019.GK24114@v2.random>
Message-ID: <Pine.LNX.4.64.0803071207540.6815@schroedinger.engr.sgi.com>
References: <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com>
 <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
 <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
 <1204908762.8514.114.camel@twins> <20080307175019.GK24114@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andrea Arcangeli wrote:

> In the meantime I've also been thinking that we could need the
> write_seqlock in mmu_notifier_register, to know when to restart the
> loop if somebody does a mmu_notifier_register;
> synchronize_rcu(). Otherwise there's no way to be sure the mmu
> notifier will start firing immediately after synchronize_rcu. I'm
> unsure if it's acceptable that in-progress mmu notifier invocations,
> don't need to notice the fact that somebody did mmu_notifier_register;
> synchronize_rcu. If they don't need to notice, then we can just drop
> unregister and all rcu_read_lock()s instead of adding write_seqlock to
> the register operation.

This is all getting into some very complicated issues.....

> Overall my effort is to try to avoid expand the list walk with
> explicit memory barriers like in EMM while trying to be equally
> efficient.

The smp_rmb is such a big problem? You have seqlock, rcu etc all in there 
as well. I doubt that this is more efficient.

> Another issue is that the _begin/_end logic doesn't provide any
> guarantee that the _begin will start firing before _end, if a kernel
> module is loaded while another cpu is already running inside some
> munmap operation etc.. The KVM usage of mmu notifier has no problem
> with that detail, but KVM doesn't use _begin at all, I wonder if
> others would have problems. This is a kind of a separate problem, but
> quite related to the question if the notifiers must be guaranteed to
> start firing immediately after mmu_notifier_unregister;synchronize_rcu
> or not, that's why I mentioned it here.

Ahh. Yes that is an interesting issue. If a device driver cannot handle 
this then _begin must prohibit module loading. That means not allowing 
stop_machine_run I guess which should not be that difficult.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
