Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07C526B0011
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:21:09 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id v20-v6so8601697otd.10
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 03:21:09 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b13-v6si255884oih.293.2018.03.27.03.21.07
        for <linux-mm@kvack.org>;
        Tue, 27 Mar 2018 03:21:07 -0700 (PDT)
Date: Tue, 27 Mar 2018 11:21:17 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Message-ID: <20180327102116.GA2464@arm.com>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180325175004.28162-3-ynorov@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 25, 2018 at 08:50:04PM +0300, Yury Norov wrote:
> kick_all_cpus_sync() forces all CPUs to sync caches by sending broadcast IPI.
> If CPU is in extended quiescent state (idle task or nohz_full userspace), this
> work may be done at the exit of this state. Delaying synchronization helps to
> save power if CPU is in idle state and decrease latency for real-time tasks.
> 
> This patch introduces kick_active_cpus_sync() and uses it in mm/slab and arm64
> code to delay syncronization.
> 
> For task isolation (https://lkml.org/lkml/2017/11/3/589), IPI to the CPU running
> isolated task would be fatal, as it breaks isolation. The approach with delaying
> of synchronization work helps to maintain isolated state.
> 
> I've tested it with test from task isolation series on ThunderX2 for more than
> 10 hours (10k giga-ticks) without breaking isolation.
> 
> Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> ---
>  arch/arm64/kernel/insn.c |  2 +-
>  include/linux/smp.h      |  2 ++
>  kernel/smp.c             | 24 ++++++++++++++++++++++++
>  mm/slab.c                |  2 +-
>  4 files changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> index 2718a77da165..9d7c492e920e 100644
> --- a/arch/arm64/kernel/insn.c
> +++ b/arch/arm64/kernel/insn.c
> @@ -291,7 +291,7 @@ int __kprobes aarch64_insn_patch_text(void *addrs[], u32 insns[], int cnt)
>  			 * synchronization.
>  			 */
>  			ret = aarch64_insn_patch_text_nosync(addrs[0], insns[0]);
> -			kick_all_cpus_sync();
> +			kick_active_cpus_sync();
>  			return ret;
>  		}
>  	}

I think this means that runtime modifications to the kernel text might not
be picked up by CPUs coming out of idle. Shouldn't we add an ISB on that
path to avoid executing stale instructions?

Will
