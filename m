Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B04C6B0028
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 15:18:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e18so1676680pfi.23
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 12:18:50 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0072.outbound.protection.outlook.com. [104.47.40.72])
        by mx.google.com with ESMTPS id a21si9089341pgd.793.2018.03.25.12.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Mar 2018 12:18:49 -0700 (PDT)
Date: Sun, 25 Mar 2018 22:18:27 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH 1/2] rcu: declare rcu_eqs_special_set() in public header
Message-ID: <20180325191827.jgf2eunlyznp2h7w@yury-thinkpad>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-2-ynorov@caviumnetworks.com>
 <20180325191243.GH3675@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180325191243.GH3675@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 25, 2018 at 12:12:43PM -0700, Paul E. McKenney wrote:
> On Sun, Mar 25, 2018 at 08:50:03PM +0300, Yury Norov wrote:
> > rcu_eqs_special_set() is declared only in internal header
> > kernel/rcu/tree.h and stubbed in include/linux/rcutiny.h.
> > 
> > This patch declares rcu_eqs_special_set() in include/linux/rcutree.h, so
> > it can be used in non-rcu kernel code.
> > 
> > Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> > ---
> >  include/linux/rcutree.h | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
> > index fd996cdf1833..448f20f27396 100644
> > --- a/include/linux/rcutree.h
> > +++ b/include/linux/rcutree.h
> > @@ -74,6 +74,7 @@ static inline void synchronize_rcu_bh_expedited(void)
> >  void rcu_barrier(void);
> >  void rcu_barrier_bh(void);
> >  void rcu_barrier_sched(void);
> > +bool rcu_eqs_special_set(int cpu);
> >  unsigned long get_state_synchronize_rcu(void);
> >  void cond_synchronize_rcu(unsigned long oldstate);
> >  unsigned long get_state_synchronize_sched(void);
> 
> Good point, a bit hard to use otherwise.  ;-)
> 
> I removed the declaration from rcutree.h and updated the commit log as
> follows.  Does it look OK?
 
Of course.

Thanks,
Yury
 
> ------------------------------------------------------------------------
> 
> commit 4497105b718a819072d48a675916d9d200b5327f
> Author: Yury Norov <ynorov@caviumnetworks.com>
> Date:   Sun Mar 25 20:50:03 2018 +0300
> 
>     rcu: Declare rcu_eqs_special_set() in public header
>     
>     Because rcu_eqs_special_set() is declared only in internal header
>     kernel/rcu/tree.h and stubbed in include/linux/rcutiny.h, it is
>     inaccessible outside of the RCU implementation.  This patch therefore
>     moves the  rcu_eqs_special_set() declaration to include/linux/rcutree.h,
>     which allows it to be used in non-rcu kernel code.
>     
>     Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
> index fd996cdf1833..448f20f27396 100644
> --- a/include/linux/rcutree.h
> +++ b/include/linux/rcutree.h
> @@ -74,6 +74,7 @@ static inline void synchronize_rcu_bh_expedited(void)
>  void rcu_barrier(void);
>  void rcu_barrier_bh(void);
>  void rcu_barrier_sched(void);
> +bool rcu_eqs_special_set(int cpu);
>  unsigned long get_state_synchronize_rcu(void);
>  void cond_synchronize_rcu(unsigned long oldstate);
>  unsigned long get_state_synchronize_sched(void);
> diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
> index 59ad0e23c722..d5f617aaa744 100644
> --- a/kernel/rcu/tree.h
> +++ b/kernel/rcu/tree.h
> @@ -415,7 +415,6 @@ extern struct rcu_state rcu_preempt_state;
>  #endif /* #ifdef CONFIG_PREEMPT_RCU */
>  
>  int rcu_dynticks_snap(struct rcu_dynticks *rdtp);
> -bool rcu_eqs_special_set(int cpu);
>  
>  #ifdef CONFIG_RCU_BOOST
>  DECLARE_PER_CPU(unsigned int, rcu_cpu_kthread_status);
