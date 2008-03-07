Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
	methods to sleep (#v9 was 1/4)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080307175019.GK24114@v2.random>
References: <20080303220502.GA5301@v2.random>
	 <47CC9B57.5050402@qumranet.com>
	 <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
	 <20080304133020.GC5301@v2.random>
	 <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
	 <20080304222030.GB8951@v2.random>
	 <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
	 <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
	 <1204908762.8514.114.camel@twins>  <20080307175019.GK24114@v2.random>
Content-Type: text/plain
Date: Fri, 07 Mar 2008 19:01:35 +0100
Message-Id: <1204912895.8514.120.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-03-07 at 18:50 +0100, Andrea Arcangeli wrote:

> Overall my effort is to try to avoid expand the list walk with
> explicit memory barriers like in EMM while trying to be equally
> efficient.

I think we can do with a smb_wmb(); like Christoph (and like
hlist_add_rcu()), but replace the smb_rmb() Christoph has with a
smp_read_barrier_depends().

That should give much the same results.

The reason Christoph can do without RCU is because he doesn't allow
unregister, and as soon as you drop that you'll end up with something
similar.

> Another issue is that the _begin/_end logic doesn't provide any
> guarantee that the _begin will start firing before _end, if a kernel
> module is loaded while another cpu is already running inside some
> munmap operation etc.. The KVM usage of mmu notifier has no problem
> with that detail, but KVM doesn't use _begin at all, I wonder if
> others would have problems. This is a kind of a separate problem, but
> quite related to the question if the notifiers must be guaranteed to
> start firing immediately after mmu_notifier_unregister;synchronize_rcu
> or not, that's why I mentioned it here.

Curious problem indeed. Would it make sense to require registering these
MMU notifiers when the process is still single threaded along with the
requirement that they can never be removed again from a running process?

For KVM this should be quite doable, but I must admit I haven't been
paying enough attention to know if its possible for these other users.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
