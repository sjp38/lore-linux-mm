Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E51F06B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 15:49:36 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t22-v6so10490674pfi.13
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 12:49:36 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q132-v6si30506900pfc.198.2018.11.05.12.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 12:49:35 -0800 (PST)
Date: Mon, 5 Nov 2018 12:49:34 -0800
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [PATCH] mm/mmu_notifier: rename mmu_notifier_synchronize() to
 <...>_barrier()
Message-ID: <20181105204934.GA27247@linux.intel.com>
References: <20181105192955.26305-1-sean.j.christopherson@intel.com>
 <20181105121833.200d5b53300a7ef4df7d349d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105121833.200d5b53300a7ef4df7d349d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Oded Gabbay <oded.gabbay@amd.com>

On Mon, Nov 05, 2018 at 12:18:33PM -0800, Andrew Morton wrote:
> On Mon,  5 Nov 2018 11:29:55 -0800 Sean Christopherson <sean.j.christopherson@intel.com> wrote:
> 
> > ...and update its comment to explicitly reference its association with
> > mmu_notifier_call_srcu().
> > 
> > Contrary to its name, mmu_notifier_synchronize() does not synchronize
> > the notifier's SRCU instance, but rather waits for RCU callbacks to
> > finished, i.e. it invokes rcu_barrier().  The RCU documentation is
> > quite clear on this matter, explicitly calling out that rcu_barrier()
> > does not imply synchronize_rcu().  The misnomer could lean an unwary
> > developer to incorrectly assume that mmu_notifier_synchronize() can
> > be used in conjunction with mmu_notifier_unregister_no_release() to
> > implement a variation of mmu_notifier_unregister() that synchronizes
> > SRCU without invoking ->release.  A Documentation-allergic and hasty
> > developer could be further confused by the fact that rcu_barrier() is
> > indeed a pass-through to synchronize_rcu()... in tiny SRCU.
> 
> Fair enough.
> 
> > --- a/mm/mmu_notifier.c
> > +++ b/mm/mmu_notifier.c
> > @@ -35,12 +35,12 @@ void mmu_notifier_call_srcu(struct rcu_head *rcu,
> >  }
> >  EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
> >  
> > -void mmu_notifier_synchronize(void)
> > +void mmu_notifier_barrier(void)
> >  {
> > -	/* Wait for any running method to finish. */
> > +	/* Wait for any running RCU callbacks (see above) to finish. */
> >  	srcu_barrier(&srcu);
> >  }
> > -EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
> > +EXPORT_SYMBOL_GPL(mmu_notifier_barrier);
> >  
> >  /*
> >   * This function can't run concurrently against mmu_notifier_register
> 
> But as it has no callers, why retain it?

I was hesitant to remove it altogether since it was explicitly added to
complement mmu_notifier_call_srcu()[1] even though the initial user of
mmu_notifier_call_srcu() didn't use mmu_notifier_synchronize()[2].  I
assume there was a good reason for adding the barrier function, but
maybe that's a bad assumption.

[1] b972216e27d1 ("mmu_notifier: add call_srcu and sync function for listener to delay call and sync")
[2] https://lore.kernel.org/patchwork/patch/515318/
