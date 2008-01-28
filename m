Date: Mon, 28 Jan 2008 20:40:05 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
Message-ID: <20080128194005.GE7233@v2.random>
References: <20080125055606.102986685@sgi.com> <20080125114229.GA7454@v2.random> <479DFE7F.9030305@qumranet.com> <20080128172521.GC7233@v2.random> <Pine.LNX.4.64.0801281103030.14003@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801281103030.14003@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Izik Eidus <izike@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2008 at 11:04:43AM -0800, Christoph Lameter wrote:
> On Mon, 28 Jan 2008, Andrea Arcangeli wrote:
> 
> > So I'd like to know what can we do to help to merge the 4 patches from
> > Christoph in mainline, I'd appreciate comments on them so we can help
> > to address any outstanding issue!
> 
> There are still some pending issues (RCU troubles). I will post V2 today.

With regard to the synchronize_rcu troubles they also be left to the
notifier-user to solve. Certainly having the synchronize_rcu like in
your last incremental patches in _release, will require less
complications (kvm pins the mm so I suppose we could batch the
call_rcu externally too). But _release is not a fast-path for KVM
usage so your V2 is sure ok (and simpler to deal with) too.

For registration synchronize_rcu is the only way, if the notifiers
have to fire synchronously before mmu_notifier_register returns but
that also can be left up to the caller if required (for example KVM
doesn't need that). Otherwise there could be two mmu_notifier_register
and mmu_notifier_register_rcu where the latter calls synchronize_rcu
before returning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
