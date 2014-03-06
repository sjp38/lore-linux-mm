Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EAE8F6B0035
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 01:16:16 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz1so2197067pad.7
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 22:16:16 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id e2si4200425pba.151.2014.03.05.22.16.15
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 22:16:15 -0800 (PST)
Date: Thu, 06 Mar 2014 14:16:13 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 450/471] arch/powerpc/kernel/mce.c:77:36: error:
 incompatible types when initializing type 'struct machine_check_event *'
 using type 'struct machine_check_event'
Message-ID: <531812ad.J3oOCBntqUQesCtg%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
commit: 58ce2542a731938deecca455835fb7b399111728 [450/471] powerpc: handle new __get_cpu_var calls in 3.14
config: make ARCH=powerpc allmodconfig

All error/warnings:

   arch/powerpc/kernel/mce.c: In function 'save_mce_event':
>> arch/powerpc/kernel/mce.c:77:36: error: incompatible types when initializing type 'struct machine_check_event *' using type 'struct machine_check_event'
     struct machine_check_event *mce = __this_cpu_read(mce_event[index]);
                                       ^
   arch/powerpc/kernel/mce.c: In function 'get_mce_event':
>> arch/powerpc/kernel/mce.c:156:10: error: incompatible types when assigning to type 'struct machine_check_event *' from type 'struct machine_check_event'
      mc_evt = __this_cpu_read(mce_event[index]);
             ^

vim +77 arch/powerpc/kernel/mce.c

    71	void save_mce_event(struct pt_regs *regs, long handled,
    72			    struct mce_error_info *mce_err,
    73			    uint64_t addr)
    74	{
    75		uint64_t srr1;
    76		int index = __this_cpu_inc_return(mce_nest_count);
  > 77		struct machine_check_event *mce = __this_cpu_read(mce_event[index]);
    78	
    79		/*
    80		 * Return if we don't have enough space to log mce event.
    81		 * mce_nest_count may go beyond MAX_MC_EVT but that's ok,
    82		 * the check below will stop buffer overrun.
    83		 */
    84		if (index >= MAX_MC_EVT)
    85			return;
    86	
    87		/* Populate generic machine check info */
    88		mce->version = MCE_V1;
    89		mce->srr0 = regs->nip;
    90		mce->srr1 = regs->msr;
    91		mce->gpr3 = regs->gpr[3];
    92		mce->in_use = 1;
    93	
    94		mce->initiator = MCE_INITIATOR_CPU;
    95		if (handled)
    96			mce->disposition = MCE_DISPOSITION_RECOVERED;
    97		else
    98			mce->disposition = MCE_DISPOSITION_NOT_RECOVERED;
    99		mce->severity = MCE_SEV_ERROR_SYNC;
   100	
   101		srr1 = regs->msr;
   102	
   103		/*
   104		 * Populate the mce error_type and type-specific error_type.
   105		 */
   106		mce_set_error_info(mce, mce_err);
   107	
   108		if (!addr)
   109			return;
   110	
   111		if (mce->error_type == MCE_ERROR_TYPE_TLB) {
   112			mce->u.tlb_error.effective_address_provided = true;
   113			mce->u.tlb_error.effective_address = addr;
   114		} else if (mce->error_type == MCE_ERROR_TYPE_SLB) {
   115			mce->u.slb_error.effective_address_provided = true;
   116			mce->u.slb_error.effective_address = addr;
   117		} else if (mce->error_type == MCE_ERROR_TYPE_ERAT) {
   118			mce->u.erat_error.effective_address_provided = true;
   119			mce->u.erat_error.effective_address = addr;
   120		} else if (mce->error_type == MCE_ERROR_TYPE_UE) {
   121			mce->u.ue_error.effective_address_provided = true;
   122			mce->u.ue_error.effective_address = addr;
   123		}
   124		return;
   125	}
   126	
   127	/*
   128	 * get_mce_event:
   129	 *	mce	Pointer to machine_check_event structure to be filled.
   130	 *	release Flag to indicate whether to free the event slot or not.
   131	 *		0 <= do not release the mce event. Caller will invoke
   132	 *		     release_mce_event() once event has been consumed.
   133	 *		1 <= release the slot.
   134	 *
   135	 *	return	1 = success
   136	 *		0 = failure
   137	 *
   138	 * get_mce_event() will be called by platform specific machine check
   139	 * handle routine and in KVM.
   140	 * When we call get_mce_event(), we are still in interrupt context and
   141	 * preemption will not be scheduled until ret_from_expect() routine
   142	 * is called.
   143	 */
   144	int get_mce_event(struct machine_check_event *mce, bool release)
   145	{
   146		int index = __this_cpu_read(mce_nest_count) - 1;
   147		struct machine_check_event *mc_evt;
   148		int ret = 0;
   149	
   150		/* Sanity check */
   151		if (index < 0)
   152			return ret;
   153	
   154		/* Check if we have MCE info to process. */
   155		if (index < MAX_MC_EVT) {
 > 156			mc_evt = __this_cpu_read(mce_event[index]);
   157			/* Copy the event structure and release the original */
   158			if (mce)
   159				*mce = *mc_evt;

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
