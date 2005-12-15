Date: Thu, 15 Dec 2005 15:34:27 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: 2.6.15-rc5-mm2 can't boot on ia64 due to changing on_each_cpu().
In-Reply-To: <43A0FE0D.6030100@jp.fujitsu.com>
References: <20051215030040.GA28660@kvack.org> <43A0FE0D.6030100@jp.fujitsu.com>
Message-Id: <20051215152450.2445.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

Thanks! It works!

BTW, I found same casted function at on_each_cpu() in parisc code.
 (arch/parisc/kernel/cache.c
  arch/parisc/kernel/smp.c
  arch/parisc/mm/init.c)

Are they also should fixed? 
I don't have parisc box. So, I don't know there is same trouble on
parisc box or not, and I can't test it.

Bye.


> Benjamin LaHaise wrote:
> > On Wed, Dec 14, 2005 at 06:56:58PM -0800, Andrew Morton wrote:
> > 
> >>Thanks.  I'll drop it.
> > 
> > 
> > Please don't.  Fix ia64's brain damage instead.  Function pointers 
> > should not be cast, period.
> > 
> > 		-ben
> 
> How about this?
> 
> Thanks,
> Kenji Kaneshige
> 
> 
> We need this patch on ia64 to convert on_each_cpu to a macro.
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> 
>  arch/ia64/kernel/smp.c         |    4 ++--
>  arch/ia64/kernel/smpboot.c     |    2 +-
>  arch/ia64/mm/tlb.c             |    6 +++---
>  include/asm-ia64/mmu_context.h |    4 ++--
>  include/asm-ia64/tlbflush.h    |    5 +++--
>  5 files changed, 11 insertions(+), 10 deletions(-)
> 
> Index: linux-2.6.15-rc5-mm2/arch/ia64/kernel/smpboot.c
> ===================================================================
> --- linux-2.6.15-rc5-mm2.orig/arch/ia64/kernel/smpboot.c
> +++ linux-2.6.15-rc5-mm2/arch/ia64/kernel/smpboot.c
> @@ -652,7 +652,7 @@ int __cpu_disable(void)
>  	remove_siblinginfo(cpu);
>  	cpu_clear(cpu, cpu_online_map);
>  	fixup_irqs();
> -	local_flush_tlb_all();
> +	local_flush_tlb_all(NULL);
>  	cpu_clear(cpu, cpu_callin_map);
>  	return 0;
>  }
> Index: linux-2.6.15-rc5-mm2/arch/ia64/mm/tlb.c
> ===================================================================
> --- linux-2.6.15-rc5-mm2.orig/arch/ia64/mm/tlb.c
> +++ linux-2.6.15-rc5-mm2/arch/ia64/mm/tlb.c
> @@ -81,7 +81,7 @@ wrap_mmu_context (struct mm_struct *mm)
>  		if (i != cpu)
>  			per_cpu(ia64_need_tlb_flush, i) = 1;
>  	put_cpu();
> -	local_flush_tlb_all();
> +	local_flush_tlb_all(NULL);
>  }
>  
>  void
> @@ -111,7 +111,7 @@ ia64_global_tlb_purge (struct mm_struct 
>  }
>  
>  void
> -local_flush_tlb_all (void)
> +local_flush_tlb_all (void *dummy)
>  {
>  	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
>  
> @@ -192,5 +192,5 @@ ia64_tlb_init (void)
>  	local_cpu_data->ptce_stride[0] = ptce_info.stride[0];
>  	local_cpu_data->ptce_stride[1] = ptce_info.stride[1];
>  
> -	local_flush_tlb_all();	/* nuke left overs from bootstrapping... */
> +	local_flush_tlb_all(NULL);/* nuke left overs from bootstrapping... */
>  }
> Index: linux-2.6.15-rc5-mm2/arch/ia64/kernel/smp.c
> ===================================================================
> --- linux-2.6.15-rc5-mm2.orig/arch/ia64/kernel/smp.c
> +++ linux-2.6.15-rc5-mm2/arch/ia64/kernel/smp.c
> @@ -225,7 +225,7 @@ smp_send_reschedule (int cpu)
>  void
>  smp_flush_tlb_all (void)
>  {
> -	on_each_cpu((void (*)(void *))local_flush_tlb_all, NULL, 1, 1);
> +	on_each_cpu(local_flush_tlb_all, NULL, 1, 1);
>  }
>  
>  void
> @@ -248,7 +248,7 @@ smp_flush_tlb_mm (struct mm_struct *mm)
>  	 * anyhow, and once a CPU is interrupted, the cost of local_flush_tlb_all() is
>  	 * rather trivial.
>  	 */
> -	on_each_cpu((void (*)(void *))local_finish_flush_tlb_mm, mm, 1, 1);
> +	on_each_cpu(local_finish_flush_tlb_mm, mm, 1, 1);
>  }
>  
>  /*
> Index: linux-2.6.15-rc5-mm2/include/asm-ia64/tlbflush.h
> ===================================================================
> --- linux-2.6.15-rc5-mm2.orig/include/asm-ia64/tlbflush.h
> +++ linux-2.6.15-rc5-mm2/include/asm-ia64/tlbflush.h
> @@ -23,7 +23,7 @@
>   * Flush everything (kernel mapping may also have changed due to
>   * vmalloc/vfree).
>   */
> -extern void local_flush_tlb_all (void);
> +extern void local_flush_tlb_all (void *dummy);
>  
>  #ifdef CONFIG_SMP
>    extern void smp_flush_tlb_all (void);
> @@ -34,8 +34,9 @@ extern void local_flush_tlb_all (void);
>  #endif
>  
>  static inline void
> -local_finish_flush_tlb_mm (struct mm_struct *mm)
> +local_finish_flush_tlb_mm (void *info)
>  {
> +	struct mm_struct *mm = (struct mm_struct *)info;
>  	if (mm == current->active_mm)
>  		activate_context(mm);
>  }
> Index: linux-2.6.15-rc5-mm2/include/asm-ia64/mmu_context.h
> ===================================================================
> --- linux-2.6.15-rc5-mm2.orig/include/asm-ia64/mmu_context.h
> +++ linux-2.6.15-rc5-mm2/include/asm-ia64/mmu_context.h
> @@ -60,13 +60,13 @@ enter_lazy_tlb (struct mm_struct *mm, st
>  static inline void
>  delayed_tlb_flush (void)
>  {
> -	extern void local_flush_tlb_all (void);
> +	extern void local_flush_tlb_all (void *);
>  	unsigned long flags;
>  
>  	if (unlikely(__ia64_per_cpu_var(ia64_need_tlb_flush))) {
>  		spin_lock_irqsave(&ia64_ctx.lock, flags);
>  		if (__ia64_per_cpu_var(ia64_need_tlb_flush)) {
> -			local_flush_tlb_all();
> +			local_flush_tlb_all(NULL);
>  			__ia64_per_cpu_var(ia64_need_tlb_flush) = 0;
>  		}
>  		spin_unlock_irqrestore(&ia64_ctx.lock, flags);
> 
> 

-- 
Yasunori Goto 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
