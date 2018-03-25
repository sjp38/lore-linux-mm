Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C03FC6B0026
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 15:12:02 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a25so7390137qtj.20
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 12:12:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x11si6365362qtm.35.2018.03.25.12.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Mar 2018 12:12:01 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2PJAqfZ043438
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 15:12:00 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gx3qd2we7-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 15:12:00 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 25 Mar 2018 15:11:57 -0400
Date: Sun, 25 Mar 2018 12:12:43 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] rcu: declare rcu_eqs_special_set() in public header
Reply-To: paulmck@linux.vnet.ibm.com
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-2-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180325175004.28162-2-ynorov@caviumnetworks.com>
Message-Id: <20180325191243.GH3675@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 25, 2018 at 08:50:03PM +0300, Yury Norov wrote:
> rcu_eqs_special_set() is declared only in internal header
> kernel/rcu/tree.h and stubbed in include/linux/rcutiny.h.
> 
> This patch declares rcu_eqs_special_set() in include/linux/rcutree.h, so
> it can be used in non-rcu kernel code.
> 
> Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> ---
>  include/linux/rcutree.h | 1 +
>  1 file changed, 1 insertion(+)
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

Good point, a bit hard to use otherwise.  ;-)

I removed the declaration from rcutree.h and updated the commit log as
follows.  Does it look OK?

							Thanx, Paul

------------------------------------------------------------------------

commit 4497105b718a819072d48a675916d9d200b5327f
Author: Yury Norov <ynorov@caviumnetworks.com>
Date:   Sun Mar 25 20:50:03 2018 +0300

    rcu: Declare rcu_eqs_special_set() in public header
    
    Because rcu_eqs_special_set() is declared only in internal header
    kernel/rcu/tree.h and stubbed in include/linux/rcutiny.h, it is
    inaccessible outside of the RCU implementation.  This patch therefore
    moves the  rcu_eqs_special_set() declaration to include/linux/rcutree.h,
    which allows it to be used in non-rcu kernel code.
    
    Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index fd996cdf1833..448f20f27396 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -74,6 +74,7 @@ static inline void synchronize_rcu_bh_expedited(void)
 void rcu_barrier(void);
 void rcu_barrier_bh(void);
 void rcu_barrier_sched(void);
+bool rcu_eqs_special_set(int cpu);
 unsigned long get_state_synchronize_rcu(void);
 void cond_synchronize_rcu(unsigned long oldstate);
 unsigned long get_state_synchronize_sched(void);
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index 59ad0e23c722..d5f617aaa744 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -415,7 +415,6 @@ extern struct rcu_state rcu_preempt_state;
 #endif /* #ifdef CONFIG_PREEMPT_RCU */
 
 int rcu_dynticks_snap(struct rcu_dynticks *rdtp);
-bool rcu_eqs_special_set(int cpu);
 
 #ifdef CONFIG_RCU_BOOST
 DECLARE_PER_CPU(unsigned int, rcu_cpu_kthread_status);
