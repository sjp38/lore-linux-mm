Date: Fri, 7 Mar 2008 18:50:19 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
	methods to sleep (#v9 was 1/4)
Message-ID: <20080307175019.GK24114@v2.random>
References: <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com> <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com> <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com> <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random> <1204908762.8514.114.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1204908762.8514.114.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 05:52:42PM +0100, Peter Zijlstra wrote:
> hlist_del_rcu(&mn->hlist)
> 
> > +			rcu_read_unlock();
> 
> kfree(mn);
> 
> >  			young |= mn->ops->clear_flush_young(mn, mm, address);
> 
> *BANG*

My objective was to allow mmu_notifier_register/unregister to be
called with the same mmu notifier object, I didn't mean the object
could have been freed until ->release is called. However you reminded
me that after unregistering ->release won't be called so unregister
isn't very useful and I doubt we can keep it ;).

In the meantime I've also been thinking that we could need the
write_seqlock in mmu_notifier_register, to know when to restart the
loop if somebody does a mmu_notifier_register;
synchronize_rcu(). Otherwise there's no way to be sure the mmu
notifier will start firing immediately after synchronize_rcu. I'm
unsure if it's acceptable that in-progress mmu notifier invocations,
don't need to notice the fact that somebody did mmu_notifier_register;
synchronize_rcu. If they don't need to notice, then we can just drop
unregister and all rcu_read_lock()s instead of adding write_seqlock to
the register operation.

Overall my effort is to try to avoid expand the list walk with
explicit memory barriers like in EMM while trying to be equally
efficient.

Another issue is that the _begin/_end logic doesn't provide any
guarantee that the _begin will start firing before _end, if a kernel
module is loaded while another cpu is already running inside some
munmap operation etc.. The KVM usage of mmu notifier has no problem
with that detail, but KVM doesn't use _begin at all, I wonder if
others would have problems. This is a kind of a separate problem, but
quite related to the question if the notifiers must be guaranteed to
start firing immediately after mmu_notifier_unregister;synchronize_rcu
or not, that's why I mentioned it here.

Once I get comments on the suggested direction for these details, I'll
quickly repost a replacement patch for 3/4.

Thanks Peter!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
