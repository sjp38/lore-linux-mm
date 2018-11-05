Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 057ED6B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 15:18:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b3-v6so11058080plr.17
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 12:18:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n9-v6si21952863pfh.96.2018.11.05.12.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 12:18:36 -0800 (PST)
Date: Mon, 5 Nov 2018 12:18:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mmu_notifier: rename mmu_notifier_synchronize() to
 <...>_barrier()
Message-Id: <20181105121833.200d5b53300a7ef4df7d349d@linux-foundation.org>
In-Reply-To: <20181105192955.26305-1-sean.j.christopherson@intel.com>
References: <20181105192955.26305-1-sean.j.christopherson@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Oded Gabbay <oded.gabbay@amd.com>

On Mon,  5 Nov 2018 11:29:55 -0800 Sean Christopherson <sean.j.christopherson@intel.com> wrote:

> ...and update its comment to explicitly reference its association with
> mmu_notifier_call_srcu().
> 
> Contrary to its name, mmu_notifier_synchronize() does not synchronize
> the notifier's SRCU instance, but rather waits for RCU callbacks to
> finished, i.e. it invokes rcu_barrier().  The RCU documentation is
> quite clear on this matter, explicitly calling out that rcu_barrier()
> does not imply synchronize_rcu().  The misnomer could lean an unwary
> developer to incorrectly assume that mmu_notifier_synchronize() can
> be used in conjunction with mmu_notifier_unregister_no_release() to
> implement a variation of mmu_notifier_unregister() that synchronizes
> SRCU without invoking ->release.  A Documentation-allergic and hasty
> developer could be further confused by the fact that rcu_barrier() is
> indeed a pass-through to synchronize_rcu()... in tiny SRCU.

Fair enough.

> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -35,12 +35,12 @@ void mmu_notifier_call_srcu(struct rcu_head *rcu,
>  }
>  EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
>  
> -void mmu_notifier_synchronize(void)
> +void mmu_notifier_barrier(void)
>  {
> -	/* Wait for any running method to finish. */
> +	/* Wait for any running RCU callbacks (see above) to finish. */
>  	srcu_barrier(&srcu);
>  }
> -EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
> +EXPORT_SYMBOL_GPL(mmu_notifier_barrier);
>  
>  /*
>   * This function can't run concurrently against mmu_notifier_register

But as it has no callers, why retain it?
