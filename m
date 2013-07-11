Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7476C6B0039
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 06:41:57 -0400 (EDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 11 Jul 2013 11:36:14 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id B18D31B0806B
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 11:41:53 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6BAfgfn32112774
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 10:41:42 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6BAfq34006460
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 04:41:53 -0600
Message-ID: <51DE8BE1.8000902@de.ibm.com>
Date: Thu, 11 Jul 2013 12:41:37 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] PF: Async page fault support on s390
References: <1373461195-27628-1-git-send-email-dingel@linux.vnet.ibm.com> <1373461195-27628-5-git-send-email-dingel@linux.vnet.ibm.com> <20130711090411.GA8575@redhat.com>
In-Reply-To: <20130711090411.GA8575@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/07/13 11:04, Gleb Natapov wrote:
> On Wed, Jul 10, 2013 at 02:59:55PM +0200, Dominik Dingel wrote:
>> This patch enables async page faults for s390 kvm guests.
>> It provides the userspace API to enable, disable or get the status of this
>> feature. Also it includes the diagnose code, called by the guest to enable
>> async page faults.
>>
>> The async page faults will use an already existing guest interface for this
>> purpose, as described in "CP Programming Services (SC24-6084)".
>>
>> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> Christian, looks good now?

Looks good, but I just had a  discussion with Dominik about several other cases 
(guest driven reboot, qemu driven reboot, life migration). This patch should 
allow all these cases (independent from this patch we need an ioctl to flush the
list of pending interrupts to do so, but reboot is currently broken in that
regard anyway - patch is currently being looked at)

We are currently discussion if we should get rid of the APF_STATUS and let 
the kernel wait for outstanding page faults before returning from KVM_RUN
or if we go with this patch and let userspace wait for completion. 

Will discuss this with Dominik, Conny and Alex. So lets defer that till next
week, ok?


> 
>> ---
>>  Documentation/s390/kvm.txt       |  24 +++++++++
>>  arch/s390/include/asm/kvm_host.h |  22 ++++++++
>>  arch/s390/include/uapi/asm/kvm.h |  10 ++++
>>  arch/s390/kvm/Kconfig            |   2 +
>>  arch/s390/kvm/Makefile           |   2 +-
>>  arch/s390/kvm/diag.c             |  63 +++++++++++++++++++++++
>>  arch/s390/kvm/interrupt.c        |  43 +++++++++++++---
>>  arch/s390/kvm/kvm-s390.c         | 107 ++++++++++++++++++++++++++++++++++++++-
>>  arch/s390/kvm/kvm-s390.h         |   4 ++
>>  arch/s390/kvm/sigp.c             |   6 +++
>>  include/uapi/linux/kvm.h         |   2 +
>>  11 files changed, 276 insertions(+), 9 deletions(-)
>>
>> diff --git a/Documentation/s390/kvm.txt b/Documentation/s390/kvm.txt
>> index 85f3280..707b7e9 100644
>> --- a/Documentation/s390/kvm.txt
>> +++ b/Documentation/s390/kvm.txt
>> @@ -70,6 +70,30 @@ floating interrupts are:
>>  KVM_S390_INT_VIRTIO
>>  KVM_S390_INT_SERVICE
>>  
>> +ioctl:      KVM_S390_APF_ENABLE:
>> +args:       none
>> +This ioctl is used to enable the async page fault interface. So in a
>> +host page fault case the host can now submit pfault tokens to the guest.
>> +
>> +ioctl:      KVM_S390_APF_DISABLE:
>> +args:       none
>> +This ioctl is used to disable the async page fault interface. From this point
>> +on no new pfault tokens will be issued to the guest. Already existing async
>> +page faults are not covered by this and will be normally handled.
>> +
>> +ioctl:      KVM_S390_APF_STATUS:
>> +args:       none
>> +This ioctl allows the userspace to get the current status of the APF feature.
>> +The main purpose for this, is to ensure that no pfault tokens will be lost
>> +during live migration or similar management operations.
>> +The possible return values are:
>> +KVM_S390_APF_DISABLED_NON_PENDING
>> +KVM_S390_APF_DISABLED_PENDING
>> +KVM_S390_APF_ENABLED_NON_PENDING
>> +KVM_S390_APF_ENABLED_PENDING
>> +Caution: if KVM_S390_APF is enabled the PENDING status could be already changed
>> +as soon as the ioctl returns to userspace.
>> +
>>  3. ioctl calls to the kvm-vcpu file descriptor
>>  KVM does support the following ioctls on s390 that are common with other
>>  architectures and do behave the same:
>> diff --git a/arch/s390/include/asm/kvm_host.h b/arch/s390/include/asm/kvm_host.h
>> index cd30c3d..e8012fc 100644
>> --- a/arch/s390/include/asm/kvm_host.h
>> +++ b/arch/s390/include/asm/kvm_host.h
>> @@ -257,6 +257,10 @@ struct kvm_vcpu_arch {
>>  		u64		stidp_data;
>>  	};
>>  	struct gmap *gmap;
>> +#define KVM_S390_PFAULT_TOKEN_INVALID	(-1UL)
>> +	unsigned long pfault_token;
>> +	unsigned long pfault_select;
>> +	unsigned long pfault_compare;
>>  };
>>  
>>  struct kvm_vm_stat {
>> @@ -282,6 +286,24 @@ static inline bool kvm_is_error_hva(unsigned long addr)
>>  	return addr == KVM_HVA_ERR_BAD;
>>  }
>>  
>> +#define ASYNC_PF_PER_VCPU	64
>> +struct kvm_vcpu;
>> +struct kvm_async_pf;
>> +struct kvm_arch_async_pf {
>> +	unsigned long pfault_token;
>> +};
>> +
>> +bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
>> +
>> +void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
>> +			       struct kvm_async_pf *work);
>> +
>> +void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
>> +				     struct kvm_async_pf *work);
>> +
>> +void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
>> +				 struct kvm_async_pf *work);
>> +
>>  extern int sie64a(struct kvm_s390_sie_block *, u64 *);
>>  extern char sie_exit;
>>  #endif
>> diff --git a/arch/s390/include/uapi/asm/kvm.h b/arch/s390/include/uapi/asm/kvm.h
>> index d25da59..b6c83e0 100644
>> --- a/arch/s390/include/uapi/asm/kvm.h
>> +++ b/arch/s390/include/uapi/asm/kvm.h
>> @@ -57,4 +57,14 @@ struct kvm_sync_regs {
>>  #define KVM_REG_S390_EPOCHDIFF	(KVM_REG_S390 | KVM_REG_SIZE_U64 | 0x2)
>>  #define KVM_REG_S390_CPU_TIMER  (KVM_REG_S390 | KVM_REG_SIZE_U64 | 0x3)
>>  #define KVM_REG_S390_CLOCK_COMP (KVM_REG_S390 | KVM_REG_SIZE_U64 | 0x4)
>> +
>> +/* ioctls used for setting/getting status of APF on s390x */
>> +#define KVM_S390_APF_ENABLE	1
>> +#define KVM_S390_APF_DISABLE	2
>> +#define KVM_S390_APF_STATUS	3
>> +#define KVM_S390_APF_DISABLED_NON_PENDING	0
>> +#define KVM_S390_APF_DISABLED_PENDING		1
>> +#define KVM_S390_APF_ENABLED_NON_PENDING	2
>> +#define KVM_S390_APF_ENABLED_PENDING		3
>> +
>>  #endif
>> diff --git a/arch/s390/kvm/Kconfig b/arch/s390/kvm/Kconfig
>> index 70b46ea..4993eed 100644
>> --- a/arch/s390/kvm/Kconfig
>> +++ b/arch/s390/kvm/Kconfig
>> @@ -23,6 +23,8 @@ config KVM
>>  	select ANON_INODES
>>  	select HAVE_KVM_CPU_RELAX_INTERCEPT
>>  	select HAVE_KVM_EVENTFD
>> +	select KVM_ASYNC_PF
>> +	select KVM_ASYNC_PF_DIRECT
>>  	---help---
>>  	  Support hosting paravirtualized guest machines using the SIE
>>  	  virtualization capability on the mainframe. This should work
>> diff --git a/arch/s390/kvm/Makefile b/arch/s390/kvm/Makefile
>> index 40b4c64..63bfc28 100644
>> --- a/arch/s390/kvm/Makefile
>> +++ b/arch/s390/kvm/Makefile
>> @@ -7,7 +7,7 @@
>>  # as published by the Free Software Foundation.
>>  
>>  KVM := ../../../virt/kvm
>> -common-objs = $(KVM)/kvm_main.o $(KVM)/eventfd.o
>> +common-objs = $(KVM)/kvm_main.o $(KVM)/eventfd.o $(KVM)/async_pf.o
>>  
>>  ccflags-y := -Ivirt/kvm -Iarch/s390/kvm
>>  
>> diff --git a/arch/s390/kvm/diag.c b/arch/s390/kvm/diag.c
>> index 3074475..3d210af 100644
>> --- a/arch/s390/kvm/diag.c
>> +++ b/arch/s390/kvm/diag.c
>> @@ -17,6 +17,7 @@
>>  #include "kvm-s390.h"
>>  #include "trace.h"
>>  #include "trace-s390.h"
>> +#include "gaccess.h"
>>  
>>  static int diag_release_pages(struct kvm_vcpu *vcpu)
>>  {
>> @@ -46,6 +47,66 @@ static int diag_release_pages(struct kvm_vcpu *vcpu)
>>  	return 0;
>>  }
>>  
>> +static int __diag_page_ref_service(struct kvm_vcpu *vcpu)
>> +{
>> +	struct prs_parm {
>> +		u16 code;
>> +		u16 subcode;
>> +		u16 parm_len;
>> +		u16 parm_version;
>> +		u64 token_addr;
>> +		u64 select_mask;
>> +		u64 compare_mask;
>> +		u64 zarch;
>> +	};
>> +	struct prs_parm parm;
>> +	int rc;
>> +	u16 rx = (vcpu->arch.sie_block->ipa & 0xf0) >> 4;
>> +	u16 ry = (vcpu->arch.sie_block->ipa & 0x0f);
>> +	if (copy_from_guest(vcpu, &parm, vcpu->run->s.regs.gprs[rx], sizeof(parm)))
>> +		return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
>> +
>> +	if (parm.parm_version != 2 || parm.parm_len < 0x5)
>> +		return kvm_s390_inject_program_int(vcpu, PGM_SPECIFICATION);
>> +
>> +	switch (parm.subcode) {
>> +	case 0: /* TOKEN */
>> +		if ((parm.zarch >> 63) != 1 || parm.token_addr & 7 ||
>> +		    (parm.compare_mask & parm.select_mask) != parm.compare_mask)
>> +			return kvm_s390_inject_program_int(vcpu, PGM_SPECIFICATION);
>> +
>> +		vcpu->arch.pfault_token = parm.token_addr;
>> +		vcpu->arch.pfault_select = parm.select_mask;
>> +		vcpu->arch.pfault_compare = parm.compare_mask;
>> +		vcpu->run->s.regs.gprs[ry] = 0;
>> +		rc = 0;
>> +		break;
>> +	case 1: 
>> +		/* 
>> +		 * CANCEL 
>> +		 * Specification allows to let already pending tokens survive
>> +		 * the cancel, therefore to reduce code complexity, we assume, all
>> +		 * outstanding tokens as already pending.
>> +		 */
>> +		if (vcpu->run->s.regs.gprs[rx] & 7)
>> +			return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
>> +
>> +		vcpu->run->s.regs.gprs[ry] = 0;
>> +
>> +		if (vcpu->arch.pfault_token == KVM_S390_PFAULT_TOKEN_INVALID)
>> +			vcpu->run->s.regs.gprs[ry] = 1;
>> +
>> +		vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
>> +		rc = 0;
>> +		break;
>> +	default:
>> +		rc = -EOPNOTSUPP;
>> +		break;
>> +	}
>> +
>> +	return rc;
>> +}
>> +
>>  static int __diag_time_slice_end(struct kvm_vcpu *vcpu)
>>  {
>>  	VCPU_EVENT(vcpu, 5, "%s", "diag time slice end");
>> @@ -143,6 +204,8 @@ int kvm_s390_handle_diag(struct kvm_vcpu *vcpu)
>>  		return __diag_time_slice_end(vcpu);
>>  	case 0x9c:
>>  		return __diag_time_slice_end_directed(vcpu);
>> +	case 0x258:
>> +		return __diag_page_ref_service(vcpu);
>>  	case 0x308:
>>  		return __diag_ipl_functions(vcpu);
>>  	case 0x500:
>> diff --git a/arch/s390/kvm/interrupt.c b/arch/s390/kvm/interrupt.c
>> index 7f35cb3..00e7feb 100644
>> --- a/arch/s390/kvm/interrupt.c
>> +++ b/arch/s390/kvm/interrupt.c
>> @@ -31,7 +31,7 @@ static int is_ioint(u64 type)
>>  	return ((type & 0xfffe0000u) != 0xfffe0000u);
>>  }
>>  
>> -static int psw_extint_disabled(struct kvm_vcpu *vcpu)
>> +int psw_extint_disabled(struct kvm_vcpu *vcpu)
>>  {
>>  	return !(vcpu->arch.sie_block->gpsw.mask & PSW_MASK_EXT);
>>  }
>> @@ -78,11 +78,8 @@ static int __interrupt_is_deliverable(struct kvm_vcpu *vcpu,
>>  			return 1;
>>  		return 0;
>>  	case KVM_S390_INT_SERVICE:
>> -		if (psw_extint_disabled(vcpu))
>> -			return 0;
>> -		if (vcpu->arch.sie_block->gcr[0] & 0x200ul)
>> -			return 1;
>> -		return 0;
>> +	case KVM_S390_INT_PFAULT_INIT:
>> +	case KVM_S390_INT_PFAULT_DONE:
>>  	case KVM_S390_INT_VIRTIO:
>>  		if (psw_extint_disabled(vcpu))
>>  			return 0;
>> @@ -150,6 +147,8 @@ static void __set_intercept_indicator(struct kvm_vcpu *vcpu,
>>  	case KVM_S390_INT_EXTERNAL_CALL:
>>  	case KVM_S390_INT_EMERGENCY:
>>  	case KVM_S390_INT_SERVICE:
>> +	case KVM_S390_INT_PFAULT_INIT:
>> +	case KVM_S390_INT_PFAULT_DONE:
>>  	case KVM_S390_INT_VIRTIO:
>>  		if (psw_extint_disabled(vcpu))
>>  			__set_cpuflag(vcpu, CPUSTAT_EXT_INT);
>> @@ -223,6 +222,26 @@ static void __do_deliver_interrupt(struct kvm_vcpu *vcpu,
>>  		rc |= put_guest(vcpu, inti->ext.ext_params,
>>  				(u32 __user *)__LC_EXT_PARAMS);
>>  		break;
>> +	case KVM_S390_INT_PFAULT_INIT:
>> +		rc  = put_guest(vcpu, 0x2603, (u16 __user *) __LC_EXT_INT_CODE);
>> +		rc |= put_guest(vcpu, 0x0600, (u16 __user *) __LC_EXT_CPU_ADDR);
>> +		rc |= copy_to_guest(vcpu, __LC_EXT_OLD_PSW,
>> +				    &vcpu->arch.sie_block->gpsw, sizeof(psw_t));
>> +		rc |= copy_from_guest(vcpu, &vcpu->arch.sie_block->gpsw,
>> +				      __LC_EXT_NEW_PSW, sizeof(psw_t));
>> +		rc |= put_guest(vcpu, inti->ext.ext_params2,
>> +				(u64 __user *) __LC_EXT_PARAMS2);
>> +		break;
>> +	case KVM_S390_INT_PFAULT_DONE:
>> +		rc  = put_guest(vcpu, 0x2603, (u16 __user *) __LC_EXT_INT_CODE);
>> +		rc |= put_guest(vcpu, 0x0680, (u16 __user *) __LC_EXT_CPU_ADDR);
>> +		rc |= copy_to_guest(vcpu, __LC_EXT_OLD_PSW,
>> +				    &vcpu->arch.sie_block->gpsw, sizeof(psw_t));
>> +		rc |= copy_from_guest(vcpu, &vcpu->arch.sie_block->gpsw,
>> +				      __LC_EXT_NEW_PSW, sizeof(psw_t));
>> +		rc |= put_guest(vcpu, inti->ext.ext_params2,
>> +				(u64 __user *) __LC_EXT_PARAMS2);
>> +		break;
>>  	case KVM_S390_INT_VIRTIO:
>>  		VCPU_EVENT(vcpu, 4, "interrupt: virtio parm:%x,parm64:%llx",
>>  			   inti->ext.ext_params, inti->ext.ext_params2);
>> @@ -357,7 +376,7 @@ static int __try_deliver_ckc_interrupt(struct kvm_vcpu *vcpu)
>>  	return 1;
>>  }
>>  
>> -static int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu)
>> +int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu)
>>  {
>>  	struct kvm_s390_local_interrupt *li = &vcpu->arch.local_int;
>>  	struct kvm_s390_float_interrupt *fi = vcpu->arch.local_int.float_int;
>> @@ -681,6 +700,11 @@ int kvm_s390_inject_vm(struct kvm *kvm,
>>  		inti->type = s390int->type;
>>  		inti->ext.ext_params = s390int->parm;
>>  		break;
>> +	case KVM_S390_INT_PFAULT_INIT:
>> +	case KVM_S390_INT_PFAULT_DONE:
>> +		inti->type = s390int->type;
>> +		inti->ext.ext_params2 = s390int->parm64;
>> +		break;
>>  	case KVM_S390_PROGRAM_INT:
>>  	case KVM_S390_SIGP_STOP:
>>  	case KVM_S390_INT_EXTERNAL_CALL:
>> @@ -811,6 +835,11 @@ int kvm_s390_inject_vcpu(struct kvm_vcpu *vcpu,
>>  		inti->type = s390int->type;
>>  		inti->mchk.mcic = s390int->parm64;
>>  		break;
>> +	case KVM_S390_INT_PFAULT_INIT:
>> +	case KVM_S390_INT_PFAULT_DONE:
>> +		inti->type = s390int->type;
>> +		inti->ext.ext_params2 = s390int->parm64;
>> +		break;
>>  	case KVM_S390_INT_VIRTIO:
>>  	case KVM_S390_INT_SERVICE:
>>  	case KVM_S390_INT_IO_MIN...KVM_S390_INT_IO_MAX:
>> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
>> index 702daca..ef70296 100644
>> --- a/arch/s390/kvm/kvm-s390.c
>> +++ b/arch/s390/kvm/kvm-s390.c
>> @@ -145,6 +145,7 @@ int kvm_dev_ioctl_check_extension(long ext)
>>  #ifdef CONFIG_KVM_S390_UCONTROL
>>  	case KVM_CAP_S390_UCONTROL:
>>  #endif
>> +	case KVM_CAP_ASYNC_PF:
>>  	case KVM_CAP_SYNC_REGS:
>>  	case KVM_CAP_ONE_REG:
>>  	case KVM_CAP_ENABLE_CAP:
>> @@ -186,6 +187,33 @@ long kvm_arch_vm_ioctl(struct file *filp,
>>  	int r;
>>  
>>  	switch (ioctl) {
>> +	case KVM_S390_APF_ENABLE:
>> +		set_bit(1, &kvm->arch.gmap->pfault_enabled);
>> +		r = 0;
>> +		break;
>> +	case KVM_S390_APF_DISABLE:
>> +		clear_bit(1, &kvm->arch.gmap->pfault_enabled);
>> +		r = 0;
>> +		break;
>> +	case KVM_S390_APF_STATUS: {
>> +		bool pfaults_pending = false;
>> +		unsigned int i;
>> +		struct kvm_vcpu *vcpu;
>> +		r = 0;
>> +		if (test_bit(1, &kvm->arch.gmap->pfault_enabled))
>> +			r += 2;
>> +
>> +		kvm_for_each_vcpu(i, vcpu, kvm) {
>> +			spin_lock(&vcpu->async_pf.lock);
>> +			if (vcpu->async_pf.queued > 0)
>> +				pfaults_pending = true;
>> +			spin_unlock(&vcpu->async_pf.lock);
>> +		}
>> +
>> +		if (pfaults_pending)
>> +			r += 1;
>> +		break;
>> +	}
>>  	case KVM_S390_INTERRUPT: {
>>  		struct kvm_s390_interrupt s390int;
>>  
>> @@ -264,6 +292,7 @@ void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
>>  {
>>  	VCPU_EVENT(vcpu, 3, "%s", "free cpu");
>>  	trace_kvm_s390_destroy_vcpu(vcpu->vcpu_id);
>> +	kvm_clear_async_pf_completion_queue(vcpu);
>>  	if (!kvm_is_ucontrol(vcpu->kvm)) {
>>  		clear_bit(63 - vcpu->vcpu_id,
>>  			  (unsigned long *) &vcpu->kvm->arch.sca->mcn);
>> @@ -313,6 +342,9 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
>>  /* Section: vcpu related */
>>  int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
>>  {
>> +	vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
>> +	kvm_clear_async_pf_completion_queue(vcpu);
>> +	kvm_async_pf_wakeup_all(vcpu);
>>  	if (kvm_is_ucontrol(vcpu->kvm)) {
>>  		vcpu->arch.gmap = gmap_alloc(current->mm);
>>  		if (!vcpu->arch.gmap)
>> @@ -370,6 +402,7 @@ static void kvm_s390_vcpu_initial_reset(struct kvm_vcpu *vcpu)
>>  	vcpu->arch.guest_fpregs.fpc = 0;
>>  	asm volatile("lfpc %0" : : "Q" (vcpu->arch.guest_fpregs.fpc));
>>  	vcpu->arch.sie_block->gbea = 1;
>> +	vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
>>  	atomic_set_mask(CPUSTAT_STOPPED, &vcpu->arch.sie_block->cpuflags);
>>  }
>>  
>> @@ -691,10 +724,81 @@ static void kvm_arch_fault_in_sync(struct kvm_vcpu *vcpu)
>>  	up_read(&mm->mmap_sem);
>>  }
>>  
>> +static void __kvm_inject_pfault_token(struct kvm_vcpu *vcpu, bool start_token,
>> +				      unsigned long token)
>> +{
>> +	struct kvm_s390_interrupt inti;
>> +	inti.parm64 = token;
>> +
>> +	if (start_token) {
>> +		inti.type = KVM_S390_INT_PFAULT_INIT;
>> +		if (kvm_s390_inject_vcpu(vcpu, &inti))
>> +			WARN(1, "pfault interrupt injection failed");
>> +	} else {
>> +		inti.type = KVM_S390_INT_PFAULT_DONE;
>> +		if (kvm_s390_inject_vm(vcpu->kvm, &inti))
>> +			WARN(1, "pfault interrupt injection failed");
>> +	}
>> +}
>> +
>> +void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
>> +				     struct kvm_async_pf *work)
>> +{
>> +	__kvm_inject_pfault_token(vcpu, true, work->arch.pfault_token);
>> +}
>> +
>> +void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
>> +				 struct kvm_async_pf *work)
>> +{
>> +	__kvm_inject_pfault_token(vcpu, false, work->arch.pfault_token);
>> +}
>> +
>> +void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
>> +			       struct kvm_async_pf *work)
>> +{
>> +	/* s390 will always inject the page directly */
>> +}
>> +
>> +bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu)
>> +{
>> +	/*
>> +	 * s390 will always inject the page directly,
>> +	 * but we still want check_async_completion to cleanup
>> +	 */
>> +	return true;
>> +}
>> +
>> +static int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu)
>> +{
>> +	hva_t hva = gmap_fault(current->thread.gmap_addr, vcpu->arch.gmap);
>> +	struct kvm_arch_async_pf arch;
>> +
>> +	if (vcpu->arch.pfault_token == KVM_S390_PFAULT_TOKEN_INVALID)
>> +		return 0;
>> +	if ((vcpu->arch.sie_block->gpsw.mask & vcpu->arch.pfault_select) !=
>> +	    vcpu->arch.pfault_compare)
>> +		return 0;
>> +	if (psw_extint_disabled(vcpu))
>> +		return 0;
>> +	if (kvm_cpu_has_interrupt(vcpu))
>> +		return 0;
>> +	if (!(vcpu->arch.sie_block->gcr[0] & 0x200ul))
>> +		return 0;
>> +
>> +	if (copy_from_guest(vcpu, &arch.pfault_token, vcpu->arch.pfault_token, 8)) {
>> +		/* already in error case, insert the interrupt and return 0 */
>> +		int ign = kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
>> +		return ign - ign;
>> +	}
>> +	return kvm_setup_async_pf(vcpu, current->thread.gmap_addr, hva, &arch);
>> +}
>> +
>>  static int __vcpu_run(struct kvm_vcpu *vcpu)
>>  {
>>  	int rc;
>>  
>> +	kvm_check_async_pf_completion(vcpu);
>> +
>>  	memcpy(&vcpu->arch.sie_block->gg14, &vcpu->run->s.regs.gprs[14], 16);
>>  
>>  	if (need_resched())
>> @@ -725,7 +829,8 @@ static int __vcpu_run(struct kvm_vcpu *vcpu)
>>  		if (kvm_is_ucontrol(vcpu->kvm)) {
>>  			rc = SIE_INTERCEPT_UCONTROL;
>>  		} else if (current->thread.gmap_pfault) {
>> -			kvm_arch_fault_in_sync(vcpu);
>> +			if (!kvm_arch_setup_async_pf(vcpu))
>> +				kvm_arch_fault_in_sync(vcpu);
>>  			current->thread.gmap_pfault = 0;
>>  			rc = 0;
>>  		} else {
>> diff --git a/arch/s390/kvm/kvm-s390.h b/arch/s390/kvm/kvm-s390.h
>> index 028ca9f..d0f4d2a 100644
>> --- a/arch/s390/kvm/kvm-s390.h
>> +++ b/arch/s390/kvm/kvm-s390.h
>> @@ -148,4 +148,8 @@ void exit_sie_sync(struct kvm_vcpu *vcpu);
>>  /* implemented in diag.c */
>>  int kvm_s390_handle_diag(struct kvm_vcpu *vcpu);
>>  
>> +/* implemented in interrupt.c */
>> +int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu);
>> +int psw_extint_disabled(struct kvm_vcpu *vcpu);
>> +
>>  #endif
>> diff --git a/arch/s390/kvm/sigp.c b/arch/s390/kvm/sigp.c
>> index bec398c..a6a0f02 100644
>> --- a/arch/s390/kvm/sigp.c
>> +++ b/arch/s390/kvm/sigp.c
>> @@ -186,6 +186,12 @@ int kvm_s390_inject_sigp_stop(struct kvm_vcpu *vcpu, int action)
>>  static int __sigp_set_arch(struct kvm_vcpu *vcpu, u32 parameter)
>>  {
>>  	int rc;
>> +	unsigned int i;
>> +	struct kvm_vcpu *vcpu_to_set;
>> +
>> +	kvm_for_each_vcpu(i, vcpu_to_set, vcpu->kvm) {
>> +		vcpu_to_set->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
>> +	}
>>  
>>  	switch (parameter & 0xff) {
>>  	case 0:
>> diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
>> index acccd08..fae432c 100644
>> --- a/include/uapi/linux/kvm.h
>> +++ b/include/uapi/linux/kvm.h
>> @@ -413,6 +413,8 @@ struct kvm_s390_psw {
>>  #define KVM_S390_PROGRAM_INT		0xfffe0001u
>>  #define KVM_S390_SIGP_SET_PREFIX	0xfffe0002u
>>  #define KVM_S390_RESTART		0xfffe0003u
>> +#define KVM_S390_INT_PFAULT_INIT	0xfffe0004u
>> +#define KVM_S390_INT_PFAULT_DONE	0xfffe0005u
>>  #define KVM_S390_MCHK			0xfffe1000u
>>  #define KVM_S390_INT_VIRTIO		0xffff2603u
>>  #define KVM_S390_INT_SERVICE		0xffff2401u
>> -- 
>> 1.8.2.2
> 
> --
> 			Gleb.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
