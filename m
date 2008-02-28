Date: Thu, 28 Feb 2008 01:38:17 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080228003817.GD8091@v2.random>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com> <200802201008.49933.nickpiggin@yahoo.com.au> <20080220010038.GQ7128@v2.random> <Pine.LNX.4.64.0802271436260.13186@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802271436260.13186@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2008 at 02:39:46PM -0800, Christoph Lameter wrote:
> On Wed, 20 Feb 2008, Andrea Arcangeli wrote:
> 
> > Well, xpmem requirements are complex. As as side effect of the
> > simplicity of my approach, my patch is 100% safe since #v1. Now it
> > also works for GRU and it cluster invalidates.
> 
> The patch has to satisfy RDMA, XPMEM, GRU and KVM. I keep hearing that we 
> have a KVM only solution that works 100% (which makes me just switch 
> ignore the rest of the argument because 100% solutions usually do not 
> exist).

I only said 100% safe, I didn't imply anything other than it won't
crash the kernel ;).

#v6 and #v7 only leaves XPMEM out AFIK, and that can be supported
later with a CONFIG_XPMEM that purely changes some VM locking. #v7
also provides maximum performance to GRU.

> > rcu_read_lock), no "atomic" parameters, and it doesn't open a window
> > where sptes have a view on older pages and linux pte has view on newer
> > pages (this can happen with remap_file_pages with my KVM swapping
> > patch to use V8 Christoph's patch).
> 
> Ok so you are now getting away from keeping the refcount elevated? That 
> was your design decision....

No, I'm not getting away from it. If I would get away from it, I would
be forced to implement invalidate_range_begin. However even if I don't
get away from it, the fact I only implement invalidate_range_end, and
that's called after the PT lock is dropped, opens a little window with
lost coherency (which may not be detectable by userland anyway). But this
little window is fine for KVM and it doesn't impose any security
risk. But clearly proving the locking safe becomes a bit more complex
in #v7 than in #v6.

> It would have helped if you would have repeated my answers that you had 
> already gotten before. You knew I was on vacation....

I didn't remember the BUG_ON crystal clear sorry, but not sure why you
think it was your call, this was a lowlevel XPMEM question and Robin
promptly answered/reminded about it infact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
