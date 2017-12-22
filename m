Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E68C6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 02:45:18 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 79so3441331iou.19
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 23:45:18 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id s86si3354441ioi.135.2017.12.21.23.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 23:45:13 -0800 (PST)
Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
From: Patrick Colp <patrick.colp@oracle.com>
Message-ID: <3b9dd83a-5e13-97b5-3d87-14de288e88d8@oracle.com>
Date: Fri, 22 Dec 2017 02:34:45 -0500
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-9-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>, =?UTF-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?= <mcirjaliu@bitdefender.com>, Marian Rotariu <mrotariu@bitdefender.com>

On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> From: Adalbert Lazar <alazar@bitdefender.com>
> 
> This subsystem is split into three source files:
>   - kvmi_msg.c - ABI and socket related functions
>   - kvmi_mem.c - handle map/unmap requests from the introspector
>   - kvmi.c - all the other
> 
> The new data used by this subsystem is attached to the 'kvm' and
> 'kvm_vcpu' structures as opaque pointers (to 'kvmi' and 'kvmi_vcpu'
> structures).
> 
> Besides the KVMI system, this patch exports the
> kvm_vcpu_ioctl_x86_get_xsave() and the mm_find_pmd() functions,
> adds a new vCPU request (KVM_REQ_INTROSPECTION) and a new VM ioctl
> (KVM_INTROSPECTION) used to pass the connection file handle from QEMU.
> 
> Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
> Signed-off-by: Adalbert LazA?r <alazar@bitdefender.com>
> Signed-off-by: NicuE?or CA(R)E?u <ncitu@bitdefender.com>
> Signed-off-by: Mircea CA(R)rjaliu <mcirjaliu@bitdefender.com>
> Signed-off-by: Marian Rotariu <mrotariu@bitdefender.com>
> ---
>   arch/x86/include/asm/kvm_host.h |    1 +
>   arch/x86/kvm/Makefile           |    1 +
>   arch/x86/kvm/x86.c              |    4 +-
>   include/linux/kvm_host.h        |    4 +
>   include/linux/kvmi.h            |   32 +
>   include/linux/mm.h              |    3 +
>   include/trace/events/kvmi.h     |  174 +++++
>   include/uapi/linux/kvm.h        |    8 +
>   mm/internal.h                   |    5 -
>   virt/kvm/kvmi.c                 | 1410 +++++++++++++++++++++++++++++++++++++++
>   virt/kvm/kvmi_int.h             |  121 ++++
>   virt/kvm/kvmi_mem.c             |  730 ++++++++++++++++++++
>   virt/kvm/kvmi_msg.c             | 1134 +++++++++++++++++++++++++++++++
>   13 files changed, 3620 insertions(+), 7 deletions(-)
>   create mode 100644 include/linux/kvmi.h
>   create mode 100644 include/trace/events/kvmi.h
>   create mode 100644 virt/kvm/kvmi.c
>   create mode 100644 virt/kvm/kvmi_int.h
>   create mode 100644 virt/kvm/kvmi_mem.c
>   create mode 100644 virt/kvm/kvmi_msg.c
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index 2cf03ed181e6..1e9e49eaee3b 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -73,6 +73,7 @@
>   #define KVM_REQ_HV_RESET		KVM_ARCH_REQ(20)
>   #define KVM_REQ_HV_EXIT			KVM_ARCH_REQ(21)
>   #define KVM_REQ_HV_STIMER		KVM_ARCH_REQ(22)
> +#define KVM_REQ_INTROSPECTION           KVM_ARCH_REQ(23)
>   
>   #define CR0_RESERVED_BITS                                               \
>   	(~(unsigned long)(X86_CR0_PE | X86_CR0_MP | X86_CR0_EM | X86_CR0_TS \
> diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
> index dc4f2fdf5e57..ab6225563526 100644
> --- a/arch/x86/kvm/Makefile
> +++ b/arch/x86/kvm/Makefile
> @@ -9,6 +9,7 @@ CFLAGS_vmx.o := -I.
>   KVM := ../../../virt/kvm
>   
>   kvm-y			+= $(KVM)/kvm_main.o $(KVM)/coalesced_mmio.o \
> +				$(KVM)/kvmi.o $(KVM)/kvmi_msg.o $(KVM)/kvmi_mem.o \
>   				$(KVM)/eventfd.o $(KVM)/irqchip.o $(KVM)/vfio.o
>   kvm-$(CONFIG_KVM_ASYNC_PF)	+= $(KVM)/async_pf.o
>   
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 74839859c0fd..cdfc7200a018 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -3346,8 +3346,8 @@ static void load_xsave(struct kvm_vcpu *vcpu, u8 *src)
>   	}
>   }
>   
> -static void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
> -					 struct kvm_xsave *guest_xsave)
> +void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
> +				  struct kvm_xsave *guest_xsave)
>   {
>   	if (boot_cpu_has(X86_FEATURE_XSAVE)) {
>   		memset(guest_xsave, 0, sizeof(struct kvm_xsave));
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 68e4d756f5c9..eae0598e18a5 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -274,6 +274,7 @@ struct kvm_vcpu {
>   	bool preempted;
>   	struct kvm_vcpu_arch arch;
>   	struct dentry *debugfs_dentry;
> +	void *kvmi;
>   };
>   
>   static inline int kvm_vcpu_exiting_guest_mode(struct kvm_vcpu *vcpu)
> @@ -446,6 +447,7 @@ struct kvm {
>   	struct srcu_struct srcu;
>   	struct srcu_struct irq_srcu;
>   	pid_t userspace_pid;
> +	void *kvmi;
>   };
>   
>   #define kvm_err(fmt, ...) \
> @@ -779,6 +781,8 @@ int kvm_arch_vcpu_ioctl_set_mpstate(struct kvm_vcpu *vcpu,
>   int kvm_arch_vcpu_ioctl_set_guest_debug(struct kvm_vcpu *vcpu,
>   					struct kvm_guest_debug *dbg);
>   int kvm_arch_vcpu_ioctl_run(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run);
> +void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
> +				  struct kvm_xsave *guest_xsave);
>   
>   int kvm_arch_init(void *opaque);
>   void kvm_arch_exit(void);
> diff --git a/include/linux/kvmi.h b/include/linux/kvmi.h
> new file mode 100644
> index 000000000000..7fac1d23f67c
> --- /dev/null
> +++ b/include/linux/kvmi.h
> @@ -0,0 +1,32 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef __KVMI_H__
> +#define __KVMI_H__
> +
> +#define kvmi_is_present() 1
> +
> +int kvmi_init(void);
> +void kvmi_uninit(void);
> +void kvmi_destroy_vm(struct kvm *kvm);
> +bool kvmi_hook(struct kvm *kvm, struct kvm_introspection *qemu);
> +void kvmi_vcpu_init(struct kvm_vcpu *vcpu);
> +void kvmi_vcpu_uninit(struct kvm_vcpu *vcpu);
> +bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
> +		   unsigned long old_value, unsigned long *new_value);
> +bool kvmi_msr_event(struct kvm_vcpu *vcpu, struct msr_data *msr);
> +void kvmi_xsetbv_event(struct kvm_vcpu *vcpu);
> +bool kvmi_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva);
> +bool kvmi_is_agent_hypercall(struct kvm_vcpu *vcpu);
> +void kvmi_hypercall_event(struct kvm_vcpu *vcpu);
> +bool kvmi_lost_exception(struct kvm_vcpu *vcpu);
> +void kvmi_trap_event(struct kvm_vcpu *vcpu);
> +bool kvmi_descriptor_event(struct kvm_vcpu *vcpu, u32 info,
> +			   unsigned long exit_qualification,
> +			   unsigned char descriptor, unsigned char write);
> +void kvmi_flush_mem_access(struct kvm *kvm);
> +void kvmi_handle_request(struct kvm_vcpu *vcpu);
> +int kvmi_host_mem_map(struct kvm_vcpu *vcpu, gva_t tkn_gva,
> +			     gpa_t req_gpa, gpa_t map_gpa);
> +int kvmi_host_mem_unmap(struct kvm_vcpu *vcpu, gpa_t map_gpa);
> +
> +
> +#endif
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ea818ff739cd..b659c7436789 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1115,6 +1115,9 @@ void page_address_init(void);
>   #define page_address_init()  do { } while(0)
>   #endif
>   
> +/* rmap.c */
> +extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
> +
>   extern void *page_rmapping(struct page *page);
>   extern struct anon_vma *page_anon_vma(struct page *page);
>   extern struct address_space *page_mapping(struct page *page);
> diff --git a/include/trace/events/kvmi.h b/include/trace/events/kvmi.h
> new file mode 100644
> index 000000000000..dc36fd3b30dc
> --- /dev/null
> +++ b/include/trace/events/kvmi.h
> @@ -0,0 +1,174 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM kvmi
> +
> +#if !defined(_TRACE_KVMI_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_KVMI_H
> +
> +#include <linux/tracepoint.h>
> +
> +#ifndef __TRACE_KVMI_STRUCTURES
> +#define __TRACE_KVMI_STRUCTURES
> +
> +#undef EN
> +#define EN(x) { x, #x }
> +
> +static const struct trace_print_flags kvmi_msg_id_symbol[] = {
> +	EN(KVMI_GET_VERSION),
> +	EN(KVMI_PAUSE_VCPU),
> +	EN(KVMI_GET_GUEST_INFO),
> +	EN(KVMI_GET_REGISTERS),
> +	EN(KVMI_SET_REGISTERS),
> +	EN(KVMI_GET_PAGE_ACCESS),
> +	EN(KVMI_SET_PAGE_ACCESS),
> +	EN(KVMI_INJECT_EXCEPTION),
> +	EN(KVMI_READ_PHYSICAL),
> +	EN(KVMI_WRITE_PHYSICAL),
> +	EN(KVMI_GET_MAP_TOKEN),
> +	EN(KVMI_CONTROL_EVENTS),
> +	EN(KVMI_CONTROL_CR),
> +	EN(KVMI_CONTROL_MSR),
> +	EN(KVMI_EVENT),
> +	EN(KVMI_EVENT_REPLY),
> +	EN(KVMI_GET_CPUID),
> +	EN(KVMI_GET_XSAVE),
> +	{-1, NULL}
> +};
> +
> +static const struct trace_print_flags kvmi_event_id_symbol[] = {
> +	EN(KVMI_EVENT_CR),
> +	EN(KVMI_EVENT_MSR),
> +	EN(KVMI_EVENT_XSETBV),
> +	EN(KVMI_EVENT_BREAKPOINT),
> +	EN(KVMI_EVENT_HYPERCALL),
> +	EN(KVMI_EVENT_PAGE_FAULT),
> +	EN(KVMI_EVENT_TRAP),
> +	EN(KVMI_EVENT_DESCRIPTOR),
> +	EN(KVMI_EVENT_CREATE_VCPU),
> +	EN(KVMI_EVENT_PAUSE_VCPU),
> +	{-1, NULL}
> +};
> +
> +static const struct trace_print_flags kvmi_action_symbol[] = {
> +	{KVMI_EVENT_ACTION_CONTINUE, "continue"},
> +	{KVMI_EVENT_ACTION_RETRY, "retry"},
> +	{KVMI_EVENT_ACTION_CRASH, "crash"},
> +	{-1, NULL}
> +};
> +
> +#endif /* __TRACE_KVMI_STRUCTURES */
> +
> +TRACE_EVENT(
> +	kvmi_msg_dispatch,
> +	TP_PROTO(__u16 id, __u16 size),
> +	TP_ARGS(id, size),
> +	TP_STRUCT__entry(
> +		__field(__u16, id)
> +		__field(__u16, size)
> +	),
> +	TP_fast_assign(
> +		__entry->id = id;
> +		__entry->size = size;
> +	),
> +	TP_printk("%s size %u",
> +		  trace_print_symbols_seq(p, __entry->id, kvmi_msg_id_symbol),
> +		  __entry->size)
> +);
> +
> +TRACE_EVENT(
> +	kvmi_send_event,
> +	TP_PROTO(__u32 id),
> +	TP_ARGS(id),
> +	TP_STRUCT__entry(
> +		__field(__u32, id)
> +	),
> +	TP_fast_assign(
> +		__entry->id = id;
> +	),
> +	TP_printk("%s",
> +		trace_print_symbols_seq(p, __entry->id, kvmi_event_id_symbol))
> +);
> +
> +#define KVMI_ACCESS_PRINTK() ({                                         \
> +	const char *saved_ptr = trace_seq_buffer_ptr(p);		\
> +	static const char * const access_str[] = {			\
> +		"---", "r--", "-w-", "rw-", "--x", "r-x", "-wx", "rwx"  \
> +	};							        \
> +	trace_seq_printf(p, "%s", access_str[__entry->access & 7]);	\
> +	saved_ptr;							\
> +})
> +
> +TRACE_EVENT(
> +	kvmi_set_mem_access,
> +	TP_PROTO(__u64 gfn, __u8 access, int err),
> +	TP_ARGS(gfn, access, err),
> +	TP_STRUCT__entry(
> +		__field(__u64, gfn)
> +		__field(__u8, access)
> +		__field(int, err)
> +	),
> +	TP_fast_assign(
> +		__entry->gfn = gfn;
> +		__entry->access = access;
> +		__entry->err = err;
> +	),
> +	TP_printk("gfn %llx %s %s %d",
> +		  __entry->gfn, KVMI_ACCESS_PRINTK(),
> +		  __entry->err ? "failed" : "succeeded", __entry->err)
> +);
> +
> +TRACE_EVENT(
> +	kvmi_apply_mem_access,
> +	TP_PROTO(__u64 gfn, __u8 access, int err),
> +	TP_ARGS(gfn, access, err),
> +	TP_STRUCT__entry(
> +		__field(__u64, gfn)
> +		__field(__u8, access)
> +		__field(int, err)
> +	),
> +	TP_fast_assign(
> +		__entry->gfn = gfn;
> +		__entry->access = access;
> +		__entry->err = err;
> +	),
> +	TP_printk("gfn %llx %s flush %s %d",
> +		  __entry->gfn, KVMI_ACCESS_PRINTK(),
> +		  __entry->err ? "failed" : "succeeded", __entry->err)
> +);
> +
> +TRACE_EVENT(
> +	kvmi_event_page_fault,
> +	TP_PROTO(__u64 gpa, __u64 gva, __u8 access, __u64 old_rip,
> +		 __u32 action, __u64 new_rip, __u32 ctx_size),
> +	TP_ARGS(gpa, gva, access, old_rip, action, new_rip, ctx_size),
> +	TP_STRUCT__entry(
> +		__field(__u64, gpa)
> +		__field(__u64, gva)
> +		__field(__u8, access)
> +		__field(__u64, old_rip)
> +		__field(__u32, action)
> +		__field(__u64, new_rip)
> +		__field(__u32, ctx_size)
> +	),
> +	TP_fast_assign(
> +		__entry->gpa = gpa;
> +		__entry->gva = gva;
> +		__entry->access = access;
> +		__entry->old_rip = old_rip;
> +		__entry->action = action;
> +		__entry->new_rip = new_rip;
> +		__entry->ctx_size = ctx_size;
> +	),
> +	TP_printk("gpa %llx %s gva %llx rip %llx -> %s rip %llx ctx %u",
> +		  __entry->gpa,
> +		  KVMI_ACCESS_PRINTK(),
> +		  __entry->gva,
> +		  __entry->old_rip,
> +		  trace_print_symbols_seq(p, __entry->action,
> +					  kvmi_action_symbol),
> +		  __entry->new_rip, __entry->ctx_size)
> +);
> +
> +#endif /* _TRACE_KVMI_H */
> +
> +#include <trace/define_trace.h>
> diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
> index 496e59a2738b..6b7c4469b808 100644
> --- a/include/uapi/linux/kvm.h
> +++ b/include/uapi/linux/kvm.h
> @@ -1359,6 +1359,14 @@ struct kvm_s390_ucas_mapping {
>   #define KVM_S390_GET_CMMA_BITS      _IOWR(KVMIO, 0xb8, struct kvm_s390_cmma_log)
>   #define KVM_S390_SET_CMMA_BITS      _IOW(KVMIO, 0xb9, struct kvm_s390_cmma_log)
>   
> +struct kvm_introspection {
> +	int fd;
> +	__u32 padding;
> +	__u32 commands;
> +	__u32 events;
> +};
> +#define KVM_INTROSPECTION      _IOW(KVMIO, 0xff, struct kvm_introspection)
> +
>   #define KVM_DEV_ASSIGN_ENABLE_IOMMU	(1 << 0)
>   #define KVM_DEV_ASSIGN_PCI_2_3		(1 << 1)
>   #define KVM_DEV_ASSIGN_MASK_INTX	(1 << 2)
> diff --git a/mm/internal.h b/mm/internal.h
> index e6bd35182dae..9d363c802305 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -92,11 +92,6 @@ extern unsigned long highest_memmap_pfn;
>   extern int isolate_lru_page(struct page *page);
>   extern void putback_lru_page(struct page *page);
>   
> -/*
> - * in mm/rmap.c:
> - */
> -extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
> -
>   /*
>    * in mm/page_alloc.c
>    */
> diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
> new file mode 100644
> index 000000000000..c4cdaeddac45
> --- /dev/null
> +++ b/virt/kvm/kvmi.c
> @@ -0,0 +1,1410 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * KVM introspection
> + *
> + * Copyright (C) 2017 Bitdefender S.R.L.
> + *
> + */
> +#include <linux/mmu_context.h>
> +#include <linux/random.h>
> +#include <uapi/linux/kvmi.h>
> +#include <uapi/asm/kvmi.h>
> +#include "../../arch/x86/kvm/x86.h"
> +#include "../../arch/x86/kvm/mmu.h"
> +#include <asm/vmx.h>
> +#include "cpuid.h"
> +#include "kvmi_int.h"
> +#include <asm/kvm_page_track.h>
> +
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/kvmi.h>
> +
> +struct kvmi_mem_access {
> +	struct list_head link;
> +	gfn_t gfn;
> +	u8 access;
> +	bool active[KVM_PAGE_TRACK_MAX];
> +	struct kvm_memory_slot *slot;
> +};
> +
> +static void wakeup_events(struct kvm *kvm);
> +static bool kvmi_page_fault_event(struct kvm_vcpu *vcpu, unsigned long gpa,
> +			   unsigned long gva, u8 access);
> +
> +static struct workqueue_struct *wq;
> +
> +static const u8 full_access = KVMI_PAGE_ACCESS_R |
> +			      KVMI_PAGE_ACCESS_W | KVMI_PAGE_ACCESS_X;
> +
> +static const struct {
> +	unsigned int allow_bit;
> +	enum kvm_page_track_mode track_mode;
> +} track_modes[] = {
> +	{ KVMI_PAGE_ACCESS_R, KVM_PAGE_TRACK_PREREAD },
> +	{ KVMI_PAGE_ACCESS_W, KVM_PAGE_TRACK_PREWRITE },
> +	{ KVMI_PAGE_ACCESS_X, KVM_PAGE_TRACK_PREEXEC },
> +};
> +
> +void kvmi_make_request(struct kvmi_vcpu *ivcpu, int req)
> +{
> +	set_bit(req, &ivcpu->requests);
> +	/* Make sure the bit is set when the worker wakes up */
> +	smp_wmb();
> +	up(&ivcpu->sem_requests);
> +}
> +
> +void kvmi_clear_request(struct kvmi_vcpu *ivcpu, int req)
> +{
> +	clear_bit(req, &ivcpu->requests);
> +}
> +
> +int kvmi_cmd_pause_vcpu(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +
> +	/*
> +	 * This vcpu is already stopped, executing this command
> +	 * as a result of the REQ_CMD bit being set
> +	 * (see kvmi_handle_request).
> +	 */
> +	if (ivcpu->pause)
> +		return -KVM_EBUSY;
> +
> +	ivcpu->pause = true;
> +
> +	return 0;
> +}
> +
> +static void kvmi_apply_mem_access(struct kvm *kvm,
> +				  struct kvm_memory_slot *slot,
> +				  struct kvmi_mem_access *m)
> +{
> +	int idx, k;

This should probably be i instead of k. I'm guessing you chose k to 
avoid confusion of i with idx. However, there's precedent already set 
for using i as a loop counter even in this case (e.g., look at 
kvm_scan_ioapic_routes() in arch/x86/kvm/irq_comm.c and 
init_rmode_identity_map() in arch/x86/kvm/vmx.c)

> +
> +	if (!slot) {
> +		slot = gfn_to_memslot(kvm, m->gfn);
> +		if (!slot)
> +			return;
> +	}
> +
> +	idx = srcu_read_lock(&kvm->srcu);
> +
> +	spin_lock(&kvm->mmu_lock);
> +
> +	for (k = 0; k < ARRAY_SIZE(track_modes); k++) {
> +		unsigned int allow_bit = track_modes[k].allow_bit;
> +		enum kvm_page_track_mode mode = track_modes[k].track_mode;
> +
> +		if (m->access & allow_bit) {
> +			if (m->active[mode] && m->slot == slot) {
> +				kvm_slot_page_track_remove_page(kvm, slot,
> +								m->gfn, mode);
> +				m->active[mode] = false;
> +				m->slot = NULL;
> +			}
> +		} else if (!m->active[mode] || m->slot != slot) {
> +			kvm_slot_page_track_add_page(kvm, slot, m->gfn, mode);
> +			m->active[mode] = true;
> +			m->slot = slot;
> +		}
> +	}
> +
> +	spin_unlock(&kvm->mmu_lock);
> +
> +	srcu_read_unlock(&kvm->srcu, idx);
> +}
> +
> +int kvmi_set_mem_access(struct kvm *kvm, u64 gpa, u8 access)
> +{
> +	struct kvmi_mem_access *m;
> +	struct kvmi_mem_access *__m;
> +	struct kvmi *ikvm = IKVM(kvm);
> +	gfn_t gfn = gpa_to_gfn(gpa);
> +
> +	if (kvm_is_error_hva(gfn_to_hva_safe(kvm, gfn)))
> +		kvm_err("Invalid gpa %llx (or memslot not available yet)", gpa);

If there's an error, should this not return or something instead of 
continuing as if nothing is wrong?

> +
> +	m = kzalloc(sizeof(struct kvmi_mem_access), GFP_KERNEL);

This should be "m = kzalloc(sizeof(*m), GFP_KERNEL);".

> +	if (!m)
> +		return -KVM_ENOMEM;
> +
> +	INIT_LIST_HEAD(&m->link);
> +	m->gfn = gfn;
> +	m->access = access;
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +	__m = radix_tree_lookup(&ikvm->access_tree, m->gfn);
> +	if (__m) {
> +		__m->access = m->access;
> +		if (list_empty(&__m->link))
> +			list_add_tail(&__m->link, &ikvm->access_list);
> +	} else {
> +		radix_tree_insert(&ikvm->access_tree, m->gfn, m);
> +		list_add_tail(&m->link, &ikvm->access_list);
> +		m = NULL;
> +	}
> +	mutex_unlock(&ikvm->access_tree_lock);
> +
> +	kfree(m);
> +
> +	return 0;
> +}
> +
> +static bool kvmi_test_mem_access(struct kvm *kvm, unsigned long gpa,
> +				 u8 access)
> +{
> +	struct kvmi_mem_access *m;
> +	struct kvmi *ikvm = IKVM(kvm);
> +
> +	if (!ikvm)
> +		return false;
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +	m = radix_tree_lookup(&ikvm->access_tree, gpa_to_gfn(gpa));
> +	mutex_unlock(&ikvm->access_tree_lock);
> +
> +	/*
> +	 * We want to be notified only for violations involving access
> +	 * bits that we've specifically cleared
> +	 */
> +	if (m && ((~m->access) & access))
> +		return true;
> +
> +	return false;
> +}
> +
> +static struct kvmi_mem_access *
> +kvmi_get_mem_access_unlocked(struct kvm *kvm, const gfn_t gfn)
> +{
> +	return radix_tree_lookup(&IKVM(kvm)->access_tree, gfn);
> +}
> +
> +static bool is_introspected(struct kvmi *ikvm)
> +{
> +	return (ikvm && ikvm->sock);
> +}
> +
> +void kvmi_flush_mem_access(struct kvm *kvm)
> +{
> +	struct kvmi *ikvm = IKVM(kvm);
> +
> +	if (!ikvm)
> +		return;
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +	while (!list_empty(&ikvm->access_list)) {
> +		struct kvmi_mem_access *m =
> +			list_first_entry(&ikvm->access_list,
> +					 struct kvmi_mem_access, link);
> +
> +		list_del_init(&m->link);
> +
> +		kvmi_apply_mem_access(kvm, NULL, m);
> +
> +		if (m->access == full_access) {
> +			radix_tree_delete(&ikvm->access_tree, m->gfn);
> +			kfree(m);
> +		}
> +	}
> +	mutex_unlock(&ikvm->access_tree_lock);
> +}
> +
> +static void kvmi_free_mem_access(struct kvm *kvm)
> +{
> +	void **slot;
> +	struct radix_tree_iter iter;
> +	struct kvmi *ikvm = IKVM(kvm);
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +	radix_tree_for_each_slot(slot, &ikvm->access_tree, &iter, 0) {
> +		struct kvmi_mem_access *m = *slot;
> +
> +		m->access = full_access;
> +		kvmi_apply_mem_access(kvm, NULL, m);
> +
> +		radix_tree_delete(&ikvm->access_tree, m->gfn);
> +		kfree(*slot);
> +	}
> +	mutex_unlock(&ikvm->access_tree_lock);
> +}
> +
> +static unsigned long *msr_mask(struct kvmi *ikvm, unsigned int *msr)
> +{
> +	switch (*msr) {
> +	case 0 ... 0x1fff:
> +		return ikvm->msr_mask.low;
> +	case 0xc0000000 ... 0xc0001fff:
> +		*msr &= 0x1fff;
> +		return ikvm->msr_mask.high;
> +	}
> +	return NULL;
> +}
> +
> +static bool test_msr_mask(struct kvmi *ikvm, unsigned int msr)
> +{
> +	unsigned long *mask = msr_mask(ikvm, &msr);
> +
> +	if (!mask)
> +		return false;
> +	if (!test_bit(msr, mask))
> +		return false;
> +
> +	return true;
> +}
> +
> +static int msr_control(struct kvmi *ikvm, unsigned int msr, bool enable)
> +{
> +	unsigned long *mask = msr_mask(ikvm, &msr);
> +
> +	if (!mask)
> +		return -KVM_EINVAL;
> +	if (enable)
> +		set_bit(msr, mask);
> +	else
> +		clear_bit(msr, mask);
> +	return 0;
> +}
> +
> +unsigned int kvmi_vcpu_mode(const struct kvm_vcpu *vcpu,
> +				   const struct kvm_sregs *sregs)
> +{
> +	unsigned int mode = 0;
> +
> +	if (is_long_mode((struct kvm_vcpu *) vcpu)) {
> +		if (sregs->cs.l)
> +			mode = 8;
> +		else if (!sregs->cs.db)
> +			mode = 2;
> +		else
> +			mode = 4;
> +	} else if (sregs->cr0 & X86_CR0_PE) {
> +		if (!sregs->cs.db)
> +			mode = 2;
> +		else
> +			mode = 4;
> +	} else if (!sregs->cs.db)
> +		mode = 2;
> +	else
> +		mode = 4;

If one branch of a conditional uses braces, then all branches should 
(regardless of if they are only a single statements). The final "else 
if" and "else" blocks here should both be wrapped in braces.

> +
> +	return mode;
> +}
> +
> +static int maybe_delayed_init(void)
> +{
> +	if (wq)
> +		return 0;
> +
> +	wq = alloc_workqueue("kvmi", WQ_CPU_INTENSIVE, 0);
> +	if (!wq)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +int kvmi_init(void)
> +{
> +	return 0;
> +}
> +
> +static void work_cb(struct work_struct *work)
> +{
> +	struct kvmi *ikvm = container_of(work, struct kvmi, work);
> +	struct kvm   *kvm = ikvm->kvm;

None of your other initial variable assignments are aligned like this. 
Any particular reason why this one is?

> +
> +	while (kvmi_msg_process(ikvm))
> +		;

Typically if you're going to have an empty while block, you stick the 
semi-colon at the end of the while line. So this would be:
	while (kvmi_msg_process(ikvm));

> +
> +	/* We are no longer interested in any kind of events */
> +	atomic_set(&ikvm->event_mask, 0);
> +
> +	/* Clean-up for the next kvmi_hook() call */
> +	ikvm->cr_mask = 0;
> +	memset(&ikvm->msr_mask, 0, sizeof(ikvm->msr_mask));
> +
> +	wakeup_events(kvm);
> +
> +	/* Restore the spte access rights */
> +	/* Shouldn't wait for reconnection? */
> +	kvmi_free_mem_access(kvm);
> +
> +	complete_all(&ikvm->finished);
> +}
> +
> +static void __alloc_vcpu_kvmi(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu = kzalloc(sizeof(struct kvmi_vcpu), GFP_KERNEL);
> +
> +	if (ivcpu) {
> +		sema_init(&ivcpu->sem_requests, 0);
> +
> +		/*
> +		 * Make sure the ivcpu is initialized
> +		 * before making it visible.
> +		 */
> +		smp_wmb();
> +
> +		vcpu->kvmi = ivcpu;
> +
> +		kvmi_make_request(ivcpu, REQ_INIT);
> +		kvm_make_request(KVM_REQ_INTROSPECTION, vcpu);
> +	}
> +}
> +
> +void kvmi_vcpu_init(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi *ikvm = IKVM(vcpu->kvm);
> +
> +	if (is_introspected(ikvm)) {
> +		mutex_lock(&vcpu->kvm->lock);
> +		__alloc_vcpu_kvmi(vcpu);
> +		mutex_unlock(&vcpu->kvm->lock);
> +	}
> +}
> +
> +void kvmi_vcpu_uninit(struct kvm_vcpu *vcpu)
> +{
> +	kfree(IVCPU(vcpu));
> +}
> +
> +static bool __alloc_kvmi(struct kvm *kvm)
> +{
> +	struct kvmi *ikvm = kzalloc(sizeof(struct kvmi), GFP_KERNEL);
> +
> +	if (ikvm) {
> +		INIT_LIST_HEAD(&ikvm->access_list);
> +		mutex_init(&ikvm->access_tree_lock);
> +		INIT_RADIX_TREE(&ikvm->access_tree, GFP_KERNEL);
> +		rwlock_init(&ikvm->sock_lock);
> +		init_completion(&ikvm->finished);
> +		INIT_WORK(&ikvm->work, work_cb);
> +
> +		kvm->kvmi = ikvm;
> +		ikvm->kvm = kvm; /* work_cb */
> +	}
> +
> +	return (ikvm != NULL);
> +}

Would it maybe be better to just put a check for ikvm at the top and 
return false, otherwise do all the in the if body then return true?

Like this:

static bool __alloc_kvmi(struct kvm *kvm)
{
	struct kvmi *ikvm = kzalloc(sizeof(struct kvmi), GFP_KERNEL);

	if (!ikvm)
		return false;

	INIT_LIST_HEAD(&ikvm->access_list);
	mutex_init(&ikvm->access_tree_lock);
	INIT_RADIX_TREE(&ikvm->access_tree, GFP_KERNEL);
	rwlock_init(&ikvm->sock_lock);
	init_completion(&ikvm->finished);
	INIT_WORK(&ikvm->work, work_cb);

	kvm->kvmi = ikvm;
	ikvm->kvm = kvm; /* work_cb */

	return true;
}

> +
> +static bool alloc_kvmi(struct kvm *kvm)
> +{
> +	bool done;
> +
> +	mutex_lock(&kvm->lock);
> +	done = (
> +		maybe_delayed_init() == 0    &&
> +		IKVM(kvm)            == NULL &&
> +		__alloc_kvmi(kvm)    == true
> +	);
> +	mutex_unlock(&kvm->lock);
> +
> +	return done;
> +}
> +
> +static void alloc_all_kvmi_vcpu(struct kvm *kvm)
> +{
> +	struct kvm_vcpu *vcpu;
> +	int i;
> +
> +	mutex_lock(&kvm->lock);
> +	kvm_for_each_vcpu(i, vcpu, kvm)
> +		if (!IKVM(vcpu))
> +			__alloc_vcpu_kvmi(vcpu);
> +	mutex_unlock(&kvm->lock);
> +}
> +
> +static bool setup_socket(struct kvm *kvm, struct kvm_introspection *qemu)
> +{
> +	struct kvmi *ikvm = IKVM(kvm);
> +
> +	if (is_introspected(ikvm)) {
> +		kvm_err("Guest already introspected\n");
> +		return false;
> +	}
> +
> +	if (!kvmi_msg_init(ikvm, qemu->fd))
> +		return false;

kvmi_msg_init assumes that ikvm is not NULL -- it makes no check and 
then does "WRITE_ONCE(ikvm->sock, sock)". is_introspected() does check 
if ikvm is NULL, but if it is, it returns false, which would still end 
up here. There should be a check that ikvm is not NULL before this if 
statement.

> +
> +	ikvm->cmd_allow_mask = -1; /* TODO: qemu->commands; */
> +	ikvm->event_allow_mask = -1; /* TODO: qemu->events; */
> +
> +	alloc_all_kvmi_vcpu(kvm);
> +	queue_work(wq, &ikvm->work);
> +
> +	return true;
> +}
> +
> +/*
> + * When called from outside a page fault handler, this call should
> + * return ~0ull
> + */
> +static u64 kvmi_mmu_fault_gla(struct kvm_vcpu *vcpu, gpa_t gpa)
> +{
> +	u64 gla;
> +	u64 gla_val;
> +	u64 v;
> +
> +	if (!vcpu->arch.gpa_available)
> +		return ~0ull;
> +
> +	gla = kvm_mmu_fault_gla(vcpu);
> +	if (gla == ~0ull)
> +		return gla;
> +	gla_val = gla;
> +
> +	/* Handle the potential overflow by returning ~0ull */
> +	if (vcpu->arch.gpa_val > gpa) {
> +		v = vcpu->arch.gpa_val - gpa;
> +		if (v > gla)
> +			gla = ~0ull;
> +		else
> +			gla -= v;
> +	} else {
> +		v = gpa - vcpu->arch.gpa_val;
> +		if (v > (U64_MAX - gla))
> +			gla = ~0ull;
> +		else
> +			gla += v;
> +	}
> +
> +	return gla;
> +}
> +
> +static bool kvmi_track_preread(struct kvm_vcpu *vcpu, gpa_t gpa,
> +			       u8 *new,
> +			       int bytes,
> +			       struct kvm_page_track_notifier_node *node,
> +			       bool *data_ready)
> +{
> +	u64 gla;
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +	bool ret = true;
> +
> +	if (kvm_mmu_nested_guest_page_fault(vcpu))
> +		return ret;
> +	gla = kvmi_mmu_fault_gla(vcpu, gpa);
> +	ret = kvmi_page_fault_event(vcpu, gpa, gla, KVMI_PAGE_ACCESS_R);

Should you not check the value of ret here before proceeding?

> +	if (ivcpu && ivcpu->ctx_size > 0) {
> +		int s = min_t(int, bytes, ivcpu->ctx_size);
> +
> +		memcpy(new, ivcpu->ctx_data, s);
> +		ivcpu->ctx_size = 0;
> +
> +		if (*data_ready)
> +			kvm_err("Override custom data");
> +
> +		*data_ready = true;
> +	}
> +
> +	return ret;
> +}
> +
> +static bool kvmi_track_prewrite(struct kvm_vcpu *vcpu, gpa_t gpa,
> +				const u8 *new,
> +				int bytes,
> +				struct kvm_page_track_notifier_node *node)
> +{
> +	u64 gla;
> +
> +	if (kvm_mmu_nested_guest_page_fault(vcpu))
> +		return true;
> +	gla = kvmi_mmu_fault_gla(vcpu, gpa);
> +	return kvmi_page_fault_event(vcpu, gpa, gla, KVMI_PAGE_ACCESS_W);
> +}
> +
> +static bool kvmi_track_preexec(struct kvm_vcpu *vcpu, gpa_t gpa,
> +				struct kvm_page_track_notifier_node *node)
> +{
> +	u64 gla;
> +
> +	if (kvm_mmu_nested_guest_page_fault(vcpu))
> +		return true;
> +	gla = kvmi_mmu_fault_gla(vcpu, gpa);
> +
> +	return kvmi_page_fault_event(vcpu, gpa, gla, KVMI_PAGE_ACCESS_X);
> +}
> +
> +static void kvmi_track_create_slot(struct kvm *kvm,
> +				   struct kvm_memory_slot *slot,
> +				   unsigned long npages,
> +				   struct kvm_page_track_notifier_node *node)
> +{
> +	struct kvmi *ikvm = IKVM(kvm);
> +	gfn_t start = slot->base_gfn;
> +	const gfn_t end = start + npages;
> +
> +	if (!ikvm)
> +		return;
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +
> +	while (start < end) {
> +		struct kvmi_mem_access *m;
> +
> +		m = kvmi_get_mem_access_unlocked(kvm, start);
> +		if (m)
> +			kvmi_apply_mem_access(kvm, slot, m);
> +		start++;
> +	}
> +
> +	mutex_unlock(&ikvm->access_tree_lock);
> +}
> +
> +static void kvmi_track_flush_slot(struct kvm *kvm, struct kvm_memory_slot *slot,
> +				  struct kvm_page_track_notifier_node *node)
> +{
> +	struct kvmi *ikvm = IKVM(kvm);
> +	gfn_t start = slot->base_gfn;
> +	const gfn_t end = start + slot->npages;
> +
> +	if (!ikvm)
> +		return;
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +
> +	while (start < end) {
> +		struct kvmi_mem_access *m;
> +
> +		m = kvmi_get_mem_access_unlocked(kvm, start);
> +		if (m) {
> +			u8 prev_access = m->access;
> +
> +			m->access = full_access;
> +			kvmi_apply_mem_access(kvm, slot, m);
> +			m->access = prev_access;
> +		}
> +		start++;
> +	}
> +
> +	mutex_unlock(&ikvm->access_tree_lock);
> +}
> +
> +static struct kvm_page_track_notifier_node kptn_node = {
> +	.track_preread = kvmi_track_preread,
> +	.track_prewrite = kvmi_track_prewrite,
> +	.track_preexec = kvmi_track_preexec,
> +	.track_create_slot = kvmi_track_create_slot,
> +	.track_flush_slot = kvmi_track_flush_slot
> +};
> +
> +bool kvmi_hook(struct kvm *kvm, struct kvm_introspection *qemu)
> +{
> +	kvm_info("Hooking vm with fd: %d\n", qemu->fd);
> +
> +	kvm_page_track_register_notifier(kvm, &kptn_node);
> +
> +	return (alloc_kvmi(kvm) && setup_socket(kvm, qemu));

Is this safe? It could return false if the alloc fails (in which case 
the caller has to do nothing) or if setting up the socket fails (in 
which case the caller needs to free the allocated kvmi).

> +}
> +
> +void kvmi_destroy_vm(struct kvm *kvm)
> +{
> +	struct kvmi *ikvm = IKVM(kvm);
> +
> +	if (ikvm) {
> +		kvmi_msg_uninit(ikvm);
> +
> +		mutex_destroy(&ikvm->access_tree_lock);
> +		kfree(ikvm);
> +	}
> +
> +	kvmi_mem_destroy_vm(kvm);
> +}
> +
> +void kvmi_uninit(void)
> +{
> +	if (wq) {
> +		destroy_workqueue(wq);
> +		wq = NULL;
> +	}
> +}
> +
> +void kvmi_get_msrs(struct kvm_vcpu *vcpu, struct kvmi_event *event)
> +{
> +	struct msr_data msr;
> +
> +	msr.host_initiated = true;
> +
> +	msr.index = MSR_IA32_SYSENTER_CS;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.sysenter_cs = msr.data;
> +
> +	msr.index = MSR_IA32_SYSENTER_ESP;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.sysenter_esp = msr.data;
> +
> +	msr.index = MSR_IA32_SYSENTER_EIP;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.sysenter_eip = msr.data;
> +
> +	msr.index = MSR_EFER;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.efer = msr.data;
> +
> +	msr.index = MSR_STAR;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.star = msr.data;
> +
> +	msr.index = MSR_LSTAR;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.lstar = msr.data;
> +
> +	msr.index = MSR_CSTAR;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.cstar = msr.data;
> +
> +	msr.index = MSR_IA32_CR_PAT;
> +	kvm_get_msr(vcpu, &msr);
> +	event->msrs.pat = msr.data;
> +}
> +
> +static bool is_event_enabled(struct kvm *kvm, int event_bit)
> +{
> +	struct kvmi *ikvm = IKVM(kvm);
> +
> +	return (ikvm && (atomic_read(&ikvm->event_mask) & event_bit));
> +}
> +
> +static int kvmi_vcpu_kill(int sig, struct kvm_vcpu *vcpu)
> +{
> +	int err = -ESRCH;
> +	struct pid *pid;
> +	struct siginfo siginfo[1] = { };
> +
> +	rcu_read_lock();
> +	pid = rcu_dereference(vcpu->pid);
> +	if (pid)
> +		err = kill_pid_info(sig, siginfo, pid);
> +	rcu_read_unlock();
> +
> +	return err;
> +}
> +
> +static void kvmi_vm_shutdown(struct kvm *kvm)
> +{
> +	int i;
> +	struct kvm_vcpu *vcpu;
> +
> +	mutex_lock(&kvm->lock);
> +	kvm_for_each_vcpu(i, vcpu, kvm) {
> +		kvmi_vcpu_kill(SIGTERM, vcpu);
> +	}
> +	mutex_unlock(&kvm->lock);
> +}
> +
> +/* TODO: Do we need a return code ? */
> +static void handle_common_event_actions(struct kvm_vcpu *vcpu, u32 action)
> +{
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CRASH:
> +		kvmi_vm_shutdown(vcpu->kvm);
> +		break;
> +
> +	default:
> +		kvm_err("Unsupported event action: %d\n", action);
> +	}
> +}
> +
> +bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
> +		   unsigned long old_value, unsigned long *new_value)
> +{
> +	struct kvm *kvm = vcpu->kvm;
> +	u64 ret_value;
> +	u32 action;
> +
> +	if (!is_event_enabled(kvm, KVMI_EVENT_CR))
> +		return true;
> +	if (!test_bit(cr, &IKVM(kvm)->cr_mask))
> +		return true;
> +	if (old_value == *new_value)
> +		return true;
> +
> +	action = kvmi_msg_send_cr(vcpu, cr, old_value, *new_value, &ret_value);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		*new_value = ret_value;
> +		return true;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	return false;
> +}
> +
> +bool kvmi_msr_event(struct kvm_vcpu *vcpu, struct msr_data *msr)
> +{
> +	struct kvm *kvm = vcpu->kvm;
> +	u64 ret_value;
> +	u32 action;
> +	struct msr_data old_msr = { .host_initiated = true,
> +				    .index = msr->index };
> +
> +	if (msr->host_initiated)
> +		return true;
> +	if (!is_event_enabled(kvm, KVMI_EVENT_MSR))
> +		return true;
> +	if (!test_msr_mask(IKVM(kvm), msr->index))
> +		return true;
> +	if (kvm_get_msr(vcpu, &old_msr))
> +		return true;
> +	if (old_msr.data == msr->data)
> +		return true;
> +
> +	action = kvmi_msg_send_msr(vcpu, msr->index, old_msr.data, msr->data,
> +				   &ret_value);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		msr->data = ret_value;
> +		return true;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	return false;
> +}
> +
> +void kvmi_xsetbv_event(struct kvm_vcpu *vcpu)
> +{
> +	u32 action;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_XSETBV))
> +		return;
> +
> +	action = kvmi_msg_send_xsetbv(vcpu);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		break;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +}
> +
> +bool kvmi_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva)
> +{
> +	u32 action;
> +	u64 gpa;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_BREAKPOINT))
> +		/* qemu will automatically reinject the breakpoint */
> +		return false;
> +
> +	gpa = kvm_mmu_gva_to_gpa_read(vcpu, gva, NULL);
> +
> +	if (gpa == UNMAPPED_GVA)
> +		kvm_err("%s: invalid gva: %llx", __func__, gva);

If the gpa is unmapped, shouldn't it return false rather than proceeding?

> +
> +	action = kvmi_msg_send_bp(vcpu, gpa);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		break;
> +	case KVMI_EVENT_ACTION_RETRY:
> +		/* rip was most likely adjusted past the INT 3 instruction */
> +		return true;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	/* qemu will automatically reinject the breakpoint */
> +	return false;
> +}
> +EXPORT_SYMBOL(kvmi_breakpoint_event);
> +
> +#define KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT 24
> +bool kvmi_is_agent_hypercall(struct kvm_vcpu *vcpu)
> +{
> +	unsigned long subfunc1, subfunc2;
> +	bool longmode = is_64_bit_mode(vcpu);
> +	unsigned long nr = kvm_register_read(vcpu, VCPU_REGS_RAX);
> +
> +	if (longmode) {
> +		subfunc1 = kvm_register_read(vcpu, VCPU_REGS_RDI);
> +		subfunc2 = kvm_register_read(vcpu, VCPU_REGS_RSI);
> +	} else {
> +		nr &= 0xFFFFFFFF;
> +		subfunc1 = kvm_register_read(vcpu, VCPU_REGS_RBX);
> +		subfunc1 &= 0xFFFFFFFF;
> +		subfunc2 = kvm_register_read(vcpu, VCPU_REGS_RCX);
> +		subfunc2 &= 0xFFFFFFFF;
> +	}
> +
> +	return (nr == KVM_HC_XEN_HVM_OP
> +		&& subfunc1 == KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT
> +		&& subfunc2 == 0);
> +}
> +
> +void kvmi_hypercall_event(struct kvm_vcpu *vcpu)
> +{
> +	u32 action;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_HYPERCALL)
> +			|| !kvmi_is_agent_hypercall(vcpu))
> +		return;
> +
> +	action = kvmi_msg_send_hypercall(vcpu);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		break;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +}
> +
> +bool kvmi_page_fault_event(struct kvm_vcpu *vcpu, unsigned long gpa,
> +			   unsigned long gva, u8 access)
> +{
> +	struct kvm *kvm = vcpu->kvm;
> +	struct kvmi_vcpu *ivcpu;
> +	bool trap_access, ret = true;
> +	u32 ctx_size;
> +	u64 old_rip;
> +	u32 action;
> +
> +	if (!is_event_enabled(kvm, KVMI_EVENT_PAGE_FAULT))
> +		return true;
> +
> +	/* Have we shown interest in this page? */
> +	if (!kvmi_test_mem_access(kvm, gpa, access))
> +		return true;
> +
> +	ivcpu    = IVCPU(vcpu);
> +	ctx_size = sizeof(ivcpu->ctx_data);
> +	old_rip  = kvm_rip_read(vcpu);

Why are these assignments aligned liket this?

> +
> +	if (!kvmi_msg_send_pf(vcpu, gpa, gva, access, &action,
> +			      &trap_access,
> +			      ivcpu->ctx_data, &ctx_size))
> +		goto out;
> +
> +	ivcpu->ctx_size = 0;
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		ivcpu->ctx_size = ctx_size;
> +		break;
> +	case KVMI_EVENT_ACTION_RETRY:
> +		ret = false;
> +		break;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	/* TODO: trap_access -> don't REPeat the instruction */
> +out:
> +	trace_kvmi_event_page_fault(gpa, gva, access, old_rip, action,
> +				    kvm_rip_read(vcpu), ctx_size);
> +	return ret;
> +}
> +
> +bool kvmi_lost_exception(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +
> +	if (!ivcpu || !ivcpu->exception.injected)
> +		return false;
> +
> +	ivcpu->exception.injected = 0;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_TRAP))
> +		return false;
> +
> +	if ((vcpu->arch.exception.injected || vcpu->arch.exception.pending)
> +		&& vcpu->arch.exception.nr == ivcpu->exception.nr
> +		&& vcpu->arch.exception.error_code
> +			== ivcpu->exception.error_code)
> +		return false;
> +
> +	return true;
> +}
> +
> +void kvmi_trap_event(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +	u32 vector, type, err;
> +	u32 action;
> +
> +	if (vcpu->arch.exception.pending) {
> +		vector = vcpu->arch.exception.nr;
> +		err = vcpu->arch.exception.error_code;
> +
> +		if (kvm_exception_is_soft(vector))
> +			type = INTR_TYPE_SOFT_EXCEPTION;
> +		else
> +			type = INTR_TYPE_HARD_EXCEPTION;
> +	} else if (vcpu->arch.interrupt.pending) {
> +		vector = vcpu->arch.interrupt.nr;
> +		err = 0;
> +
> +		if (vcpu->arch.interrupt.soft)
> +			type = INTR_TYPE_SOFT_INTR;
> +		else
> +			type = INTR_TYPE_EXT_INTR;
> +	} else {
> +		vector = 0;
> +		type = 0;
> +		err = 0;
> +	}
> +
> +	kvm_err("New exception nr %d/%d err %x/%x addr %lx",
> +		vector, ivcpu->exception.nr,
> +		err, ivcpu->exception.error_code,
> +		vcpu->arch.cr2);
> +
> +	action = kvmi_msg_send_trap(vcpu, vector, type, err, vcpu->arch.cr2);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		break;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +}
> +
> +bool kvmi_descriptor_event(struct kvm_vcpu *vcpu, u32 info,
> +			   unsigned long exit_qualification,
> +			   unsigned char descriptor, unsigned char write)
> +{
> +	u32 action;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_DESCRIPTOR))
> +		return true;

How come it returns true here? The events below all return false from a 
similar condition check.

> +
> +	action = kvmi_msg_send_descriptor(vcpu, info, exit_qualification,
> +					  descriptor, write);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		return true;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	return false; /* TODO: double check this */
> +}
> +EXPORT_SYMBOL(kvmi_descriptor_event);
> +
> +static bool kvmi_create_vcpu_event(struct kvm_vcpu *vcpu)
> +{
> +	u32 action;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_CREATE_VCPU))
> +		return false;
> +
> +	action = kvmi_msg_send_create_vcpu(vcpu);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		break;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	return true;
> +}
> +
> +static bool kvmi_pause_vcpu_event(struct kvm_vcpu *vcpu)
> +{
> +	u32 action;
> +
> +	IVCPU(vcpu)->pause = false;
> +
> +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_PAUSE_VCPU))
> +		return false;
> +
> +	action = kvmi_msg_send_pause_vcpu(vcpu);
> +
> +	switch (action) {
> +	case KVMI_EVENT_ACTION_CONTINUE:
> +		break;
> +	default:
> +		handle_common_event_actions(vcpu, action);
> +	}
> +
> +	return true;
> +}
> +
> +/* TODO: refactor this function uto avoid recursive calls and the semaphore. */
> +void kvmi_handle_request(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +
> +	while (ivcpu->ev_rpl_waiting
> +		|| READ_ONCE(ivcpu->requests)) {
> +
> +		down(&ivcpu->sem_requests);
> +
> +		if (test_bit(REQ_INIT, &ivcpu->requests)) {
> +			/*
> +			 * kvmi_create_vcpu_event() may call this function
> +			 * again and won't return unless there is no more work
> +			 * to be done. The while condition will be evaluated
> +			 * to false, but we explicitly exit the loop to avoid
> +			 * surprizing the reader more than we already did.
> +			 */
> +			kvmi_clear_request(ivcpu, REQ_INIT);
> +			if (kvmi_create_vcpu_event(vcpu))
> +				break;
> +		} else if (test_bit(REQ_CMD, &ivcpu->requests)) {
> +			kvmi_msg_handle_vcpu_cmd(vcpu);
> +			/* it will clear the REQ_CMD bit */
> +			if (ivcpu->pause && !ivcpu->ev_rpl_waiting) {
> +				/* Same warnings as with REQ_INIT. */
> +				if (kvmi_pause_vcpu_event(vcpu))
> +					break;
> +			}
> +		} else if (test_bit(REQ_REPLY, &ivcpu->requests)) {
> +			kvmi_clear_request(ivcpu, REQ_REPLY);
> +			ivcpu->ev_rpl_waiting = false;
> +			if (ivcpu->have_delayed_regs) {
> +				kvm_arch_vcpu_set_regs(vcpu,
> +							&ivcpu->delayed_regs);
> +				ivcpu->have_delayed_regs = false;
> +			}
> +			if (ivcpu->pause) {
> +				/* Same warnings as with REQ_INIT. */
> +				if (kvmi_pause_vcpu_event(vcpu))
> +					break;
> +			}
> +		} else if (test_bit(REQ_CLOSE, &ivcpu->requests)) {
> +			kvmi_clear_request(ivcpu, REQ_CLOSE);
> +			break;
> +		} else {
> +			kvm_err("Unexpected request");
> +		}
> +	}
> +
> +	kvmi_flush_mem_access(vcpu->kvm);
> +	/* TODO: merge with kvmi_set_mem_access() */
> +}
> +
> +int kvmi_cmd_get_cpuid(struct kvm_vcpu *vcpu, u32 function, u32 index,
> +		       u32 *eax, u32 *ebx, u32 *ecx, u32 *edx)
> +{
> +	struct kvm_cpuid_entry2 *e;
> +
> +	e = kvm_find_cpuid_entry(vcpu, function, index);
> +	if (!e)
> +		return -KVM_ENOENT;
> +
> +	*eax = e->eax;
> +	*ebx = e->ebx;
> +	*ecx = e->ecx;
> +	*edx = e->edx;
> +
> +	return 0;
> +}
> +
> +int kvmi_cmd_get_guest_info(struct kvm_vcpu *vcpu, u16 *vcpu_cnt, u64 *tsc)
> +{
> +	/*
> +	 * Should we switch vcpu_cnt to unsigned int?
> +	 * If not, we should limit this to max u16 - 1
> +	 */
> +	*vcpu_cnt = atomic_read(&vcpu->kvm->online_vcpus);
> +	if (kvm_has_tsc_control)
> +		*tsc = 1000ul * vcpu->arch.virtual_tsc_khz;
> +	else
> +		*tsc = 0;
> +
> +	return 0;
> +}
> +
> +static int get_first_vcpu(struct kvm *kvm, struct kvm_vcpu **vcpu)
> +{
> +	struct kvm_vcpu *v;
> +
> +	if (!atomic_read(&kvm->online_vcpus))
> +		return -KVM_EINVAL;
> +
> +	v = kvm_get_vcpu(kvm, 0);
> +
> +	if (!v)
> +		return -KVM_EINVAL;
> +
> +	*vcpu = v;
> +
> +	return 0;
> +}
> +
> +int kvmi_cmd_get_registers(struct kvm_vcpu *vcpu, u32 *mode,
> +			   struct kvm_regs *regs,
> +			   struct kvm_sregs *sregs, struct kvm_msrs *msrs)
> +{
> +	struct kvm_msr_entry  *msr = msrs->entries;
> +	unsigned int	       n   = msrs->nmsrs;

Again with randomly aligning variables...

> +
> +	kvm_arch_vcpu_ioctl_get_regs(vcpu, regs);
> +	kvm_arch_vcpu_ioctl_get_sregs(vcpu, sregs);
> +	*mode = kvmi_vcpu_mode(vcpu, sregs);
> +
> +	for (; n--; msr++) {

The conditional portion of this for loop appears to not be a 
conditional? Either way, this is a pretty ugly way to write this.

> +		struct msr_data m   = { .index = msr->index };
> +		int		err = kvm_get_msr(vcpu, &m);

And again with the alignment...

> +
> +		if (err)
> +			return -KVM_EINVAL;
> +
> +		msr->data = m.data;
> +	}
> +
> +	return 0;
> +}
> +
> +int kvmi_cmd_set_registers(struct kvm_vcpu *vcpu, const struct kvm_regs *regs)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +
> +	if (ivcpu->ev_rpl_waiting) {
> +		memcpy(&ivcpu->delayed_regs, regs, sizeof(ivcpu->delayed_regs));
> +		ivcpu->have_delayed_regs = true;
> +	} else
> +		kvm_err("Drop KVMI_SET_REGISTERS");

Since the if has braces, the else should too.

> +	return 0;
> +}
> +
> +int kvmi_cmd_get_page_access(struct kvm_vcpu *vcpu, u64 gpa, u8 *access)
> +{
> +	struct kvmi *ikvm = IKVM(vcpu->kvm);
> +	struct kvmi_mem_access *m;
> +
> +	mutex_lock(&ikvm->access_tree_lock);
> +	m = kvmi_get_mem_access_unlocked(vcpu->kvm, gpa_to_gfn(gpa));
> +	*access = m ? m->access : full_access;
> +	mutex_unlock(&ikvm->access_tree_lock);
> +
> +	return 0;
> +}
> +
> +static bool is_vector_valid(u8 vector)
> +{
> +	return true;
> +}
> +
> +static bool is_gva_valid(struct kvm_vcpu *vcpu, u64 gva)
> +{
> +	return true;
> +}
> +
> +int kvmi_cmd_inject_exception(struct kvm_vcpu *vcpu, u8 vector,
> +			      bool error_code_valid, u16 error_code,
> +			      u64 address)
> +{
> +	struct x86_exception e = {
> +		.vector = vector,
> +		.error_code_valid = error_code_valid,
> +		.error_code = error_code,
> +		.address = address,
> +	};
> +
> +	if (!(is_vector_valid(vector) && is_gva_valid(vcpu, address)))
> +		return -KVM_EINVAL;
> +
> +	if (e.vector == PF_VECTOR)
> +		kvm_inject_page_fault(vcpu, &e);
> +	else if (e.error_code_valid)
> +		kvm_queue_exception_e(vcpu, e.vector, e.error_code);
> +	else
> +		kvm_queue_exception(vcpu, e.vector);
> +
> +	if (IVCPU(vcpu)->exception.injected)
> +		kvm_err("Override exception");
> +
> +	IVCPU(vcpu)->exception.injected = 1;
> +	IVCPU(vcpu)->exception.nr = e.vector;
> +	IVCPU(vcpu)->exception.error_code = error_code_valid ? error_code : 0;
> +
> +	return 0;
> +}
> +
> +unsigned long gfn_to_hva_safe(struct kvm *kvm, gfn_t gfn)
> +{
> +	unsigned long hva;
> +
> +	mutex_lock(&kvm->slots_lock);
> +	hva = gfn_to_hva(kvm, gfn);
> +	mutex_unlock(&kvm->slots_lock);
> +
> +	return hva;
> +}
> +
> +static long get_user_pages_remote_unlocked(struct mm_struct *mm,
> +					   unsigned long start,
> +					   unsigned long nr_pages,
> +					   unsigned int gup_flags,
> +					   struct page **pages)
> +{
> +	long ret;
> +	struct task_struct *tsk = NULL;
> +	struct vm_area_struct **vmas = NULL;
> +	int locked = 1;
> +
> +	down_read(&mm->mmap_sem);
> +	ret =
> +	    get_user_pages_remote(tsk, mm, start, nr_pages, gup_flags, pages,
> +				  vmas, &locked);

Couldn't this line be "ret = get_user_pages_remote(..." and just break 
it on a different variable?

> +	if (locked)
> +		up_read(&mm->mmap_sem);
> +	return ret;
> +}
> +
> +int kvmi_cmd_read_physical(struct kvm *kvm, u64 gpa, u64 size, int (*send)(
> +				   struct kvmi *, const struct kvmi_msg_hdr *,
> +				   int err, const void *buf, size_t),
> +				   const struct kvmi_msg_hdr *ctx)
> +{
> +	int err, ec;
> +	unsigned long hva;
> +	struct page *page = NULL;
> +	void *ptr_page = NULL, *ptr = NULL;
> +	size_t ptr_size = 0;
> +	struct kvm_vcpu *vcpu;
> +
> +	ec = get_first_vcpu(kvm, &vcpu);
> +
> +	if (ec)
> +		goto out;
> +
> +	hva = gfn_to_hva_safe(kvm, gpa_to_gfn(gpa));
> +
> +	if (kvm_is_error_hva(hva)) {
> +		ec = -KVM_EINVAL;
> +		goto out;
> +	}
> +
> +	if (get_user_pages_remote_unlocked(kvm->mm, hva, 1, 0, &page) != 1) {
> +		ec = -KVM_EINVAL;
> +		goto out;
> +	}
> +
> +	ptr_page = kmap_atomic(page);
> +
> +	ptr = ptr_page + (gpa & ~PAGE_MASK);
> +	ptr_size = size;
> +
> +out:
> +	err = send(IKVM(kvm), ctx, ec, ptr, ptr_size);
> +
> +	if (ptr_page)
> +		kunmap_atomic(ptr_page);
> +	if (page)
> +		put_page(page);
> +	return err;
> +}
> +
> +int kvmi_cmd_write_physical(struct kvm *kvm, u64 gpa, u64 size, const void *buf)
> +{
> +	int err;
> +	unsigned long hva;
> +	struct page *page;
> +	void *ptr;
> +	struct kvm_vcpu *vcpu;
> +
> +	err = get_first_vcpu(kvm, &vcpu);
> +
> +	if (err)
> +		return err;
> +
> +	hva = gfn_to_hva_safe(kvm, gpa_to_gfn(gpa));
> +
> +	if (kvm_is_error_hva(hva))
> +		return -KVM_EINVAL;
> +
> +	if (get_user_pages_remote_unlocked(kvm->mm, hva, 1, FOLL_WRITE,
> +			&page) != 1)
> +		return -KVM_EINVAL;
> +
> +	ptr = kmap_atomic(page);
> +
> +	memcpy(ptr + (gpa & ~PAGE_MASK), buf, size);
> +
> +	kunmap_atomic(ptr);
> +	put_page(page);
> +
> +	return 0;
> +}
> +
> +int kvmi_cmd_alloc_token(struct kvm *kvm, struct kvmi_map_mem_token *token)
> +{
> +	int err = 0;
> +
> +	/* create random token */
> +	get_random_bytes(token, sizeof(struct kvmi_map_mem_token));
> +
> +	/* store token in HOST database */
> +	if (kvmi_store_token(kvm, token))
> +		err = -KVM_ENOMEM;
> +
> +	return err;
> +}

It seems like you could get rid of err altogether and just return 
-KVM_ENOMEM directly from the if body and 0 at the end.

> +
> +int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, u32 events)
> +{
> +	int err = 0;
> +
> +	if (events & ~KVMI_KNOWN_EVENTS)
> +		return -KVM_EINVAL;
> +
> +	if (events & KVMI_EVENT_BREAKPOINT) {
> +		if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_BREAKPOINT)) {
> +			struct kvm_guest_debug dbg = { };
> +
> +			dbg.control =
> +			    KVM_GUESTDBG_ENABLE | KVM_GUESTDBG_USE_SW_BP;
> +
> +			err = kvm_arch_vcpu_ioctl_set_guest_debug(vcpu, &dbg);
> +		}
> +	}
> +
> +	if (!err)
> +		atomic_set(&IKVM(vcpu->kvm)->event_mask, events);
> +
> +	return err;
> +}
> +
> +int kvmi_cmd_control_cr(struct kvmi *ikvm, bool enable, u32 cr)
> +{
> +	switch (cr) {
> +	case 0:
> +	case 3:
> +	case 4:
> +		if (enable)
> +			set_bit(cr, &ikvm->cr_mask);
> +		else
> +			clear_bit(cr, &ikvm->cr_mask);
> +		return 0;
> +
> +	default:
> +		return -KVM_EINVAL;
> +	}
> +}
> +
> +int kvmi_cmd_control_msr(struct kvm *kvm, bool enable, u32 msr)
> +{
> +	struct kvm_vcpu *vcpu;
> +	int err;
> +
> +	err = get_first_vcpu(kvm, &vcpu);
> +	if (err)
> +		return err;
> +
> +	err = msr_control(IKVM(kvm), msr, enable);
> +
> +	if (!err)
> +		kvm_arch_msr_intercept(vcpu, msr, enable);
> +
> +	return err;
> +}
> +
> +void wakeup_events(struct kvm *kvm)
> +{
> +	int i;
> +	struct kvm_vcpu *vcpu;
> +
> +	mutex_lock(&kvm->lock);
> +	kvm_for_each_vcpu(i, vcpu, kvm)
> +		kvmi_make_request(IVCPU(vcpu), REQ_CLOSE);
> +	mutex_unlock(&kvm->lock);
> +}
> diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
> new file mode 100644
> index 000000000000..5976b98f11cb
> --- /dev/null
> +++ b/virt/kvm/kvmi_int.h
> @@ -0,0 +1,121 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef __KVMI_INT_H__
> +#define __KVMI_INT_H__
> +
> +#include <linux/types.h>
> +#include <linux/kvm_host.h>
> +
> +#include <uapi/linux/kvmi.h>
> +
> +#define IVCPU(vcpu) ((struct kvmi_vcpu *)((vcpu)->kvmi))
> +
> +struct kvmi_vcpu {
> +	u8 ctx_data[256];
> +	u32 ctx_size;
> +	struct semaphore sem_requests;
> +	unsigned long requests;
> +	/* TODO: get this ~64KB buffer from a cache */
> +	u8 msg_buf[KVMI_MAX_MSG_SIZE];
> +	struct kvmi_event_reply ev_rpl;
> +	void *ev_rpl_ptr;
> +	size_t ev_rpl_size;
> +	size_t ev_rpl_received;
> +	u32 ev_seq;
> +	bool ev_rpl_waiting;
> +	struct {
> +		u16 error_code;
> +		u8 nr;
> +		bool injected;
> +	} exception;
> +	struct kvm_regs delayed_regs;
> +	bool have_delayed_regs;
> +	bool pause;
> +};
> +
> +#define IKVM(kvm) ((struct kvmi *)((kvm)->kvmi))
> +
> +struct kvmi {
> +	atomic_t event_mask;
> +	unsigned long cr_mask;
> +	struct {
> +		unsigned long low[BITS_TO_LONGS(8192)];
> +		unsigned long high[BITS_TO_LONGS(8192)];
> +	} msr_mask;
> +	struct radix_tree_root access_tree;
> +	struct mutex access_tree_lock;
> +	struct list_head access_list;
> +	struct work_struct work;
> +	struct socket *sock;
> +	rwlock_t sock_lock;
> +	struct completion finished;
> +	struct kvm *kvm;
> +	/* TODO: get this ~64KB buffer from a cache */
> +	u8 msg_buf[KVMI_MAX_MSG_SIZE];
> +	u32 cmd_allow_mask;
> +	u32 event_allow_mask;
> +};
> +
> +#define REQ_INIT   0
> +#define REQ_CMD    1
> +#define REQ_REPLY  2
> +#define REQ_CLOSE  3

Would these be better off being an enum?

> +
> +/* kvmi_msg.c */
> +bool kvmi_msg_init(struct kvmi *ikvm, int fd);
> +bool kvmi_msg_process(struct kvmi *ikvm);
> +void kvmi_msg_uninit(struct kvmi *ikvm);
> +void kvmi_msg_handle_vcpu_cmd(struct kvm_vcpu *vcpu);
> +u32 kvmi_msg_send_cr(struct kvm_vcpu *vcpu, u32 cr, u64 old_value,
> +		     u64 new_value, u64 *ret_value);
> +u32 kvmi_msg_send_msr(struct kvm_vcpu *vcpu, u32 msr, u64 old_value,
> +		      u64 new_value, u64 *ret_value);
> +u32 kvmi_msg_send_xsetbv(struct kvm_vcpu *vcpu);
> +u32 kvmi_msg_send_bp(struct kvm_vcpu *vcpu, u64 gpa);
> +u32 kvmi_msg_send_hypercall(struct kvm_vcpu *vcpu);
> +bool kvmi_msg_send_pf(struct kvm_vcpu *vcpu, u64 gpa, u64 gva, u32 mode,
> +		      u32 *action, bool *trap_access, u8 *ctx,
> +		      u32 *ctx_size);
> +u32 kvmi_msg_send_trap(struct kvm_vcpu *vcpu, u32 vector, u32 type,
> +		       u32 error_code, u64 cr2);
> +u32 kvmi_msg_send_descriptor(struct kvm_vcpu *vcpu, u32 info,
> +			     u64 exit_qualification, u8 descriptor, u8 write);
> +u32 kvmi_msg_send_create_vcpu(struct kvm_vcpu *vcpu);
> +u32 kvmi_msg_send_pause_vcpu(struct kvm_vcpu *vcpu);
> +
> +/* kvmi.c */
> +int kvmi_cmd_get_guest_info(struct kvm_vcpu *vcpu, u16 *vcpu_cnt, u64 *tsc);
> +int kvmi_cmd_pause_vcpu(struct kvm_vcpu *vcpu);
> +int kvmi_cmd_get_registers(struct kvm_vcpu *vcpu, u32 *mode,
> +			   struct kvm_regs *regs, struct kvm_sregs *sregs,
> +			   struct kvm_msrs *msrs);
> +int kvmi_cmd_set_registers(struct kvm_vcpu *vcpu, const struct kvm_regs *regs);
> +int kvmi_cmd_get_page_access(struct kvm_vcpu *vcpu, u64 gpa, u8 *access);
> +int kvmi_cmd_inject_exception(struct kvm_vcpu *vcpu, u8 vector,
> +			      bool error_code_valid, u16 error_code,
> +			      u64 address);
> +int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, u32 events);
> +int kvmi_cmd_get_cpuid(struct kvm_vcpu *vcpu, u32 function, u32 index,
> +		       u32 *eax, u32 *ebx, u32 *rcx, u32 *edx);
> +int kvmi_cmd_read_physical(struct kvm *kvm, u64 gpa, u64 size,
> +			   int (*send)(struct kvmi *,
> +					const struct kvmi_msg_hdr*,
> +					int err, const void *buf, size_t),
> +			   const struct kvmi_msg_hdr *ctx);
> +int kvmi_cmd_write_physical(struct kvm *kvm, u64 gpa, u64 size,
> +			    const void *buf);
> +int kvmi_cmd_alloc_token(struct kvm *kvm, struct kvmi_map_mem_token *token);
> +int kvmi_cmd_control_cr(struct kvmi *ikvm, bool enable, u32 cr);
> +int kvmi_cmd_control_msr(struct kvm *kvm, bool enable, u32 msr);
> +int kvmi_set_mem_access(struct kvm *kvm, u64 gpa, u8 access);
> +void kvmi_make_request(struct kvmi_vcpu *ivcpu, int req);
> +void kvmi_clear_request(struct kvmi_vcpu *ivcpu, int req);
> +unsigned int kvmi_vcpu_mode(const struct kvm_vcpu *vcpu,
> +			    const struct kvm_sregs *sregs);
> +void kvmi_get_msrs(struct kvm_vcpu *vcpu, struct kvmi_event *event);
> +unsigned long gfn_to_hva_safe(struct kvm *kvm, gfn_t gfn);
> +void kvmi_mem_destroy_vm(struct kvm *kvm);
> +
> +/* kvmi_mem.c */
> +int kvmi_store_token(struct kvm *kvm, struct kvmi_map_mem_token *token);
> +
> +#endif
> diff --git a/virt/kvm/kvmi_mem.c b/virt/kvm/kvmi_mem.c
> new file mode 100644
> index 000000000000..c766357678e6
> --- /dev/null
> +++ b/virt/kvm/kvmi_mem.c
> @@ -0,0 +1,730 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * KVM introspection memory mapping implementation
> + *
> + * Copyright (C) 2017 Bitdefender S.R.L.
> + *
> + * Author:
> + *   Mircea Cirjaliu <mcirjaliu@bitdefender.com>
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/kvm_host.h>
> +#include <linux/rmap.h>
> +#include <linux/list.h>
> +#include <linux/slab.h>
> +#include <linux/pagemap.h>
> +#include <linux/swap.h>
> +#include <linux/spinlock.h>
> +#include <linux/printk.h>
> +#include <linux/kvmi.h>
> +#include <linux/huge_mm.h>
> +
> +#include <uapi/linux/kvmi.h>
> +
> +#include "kvmi_int.h"
> +
> +
> +static struct list_head mapping_list;
> +static spinlock_t mapping_lock;
> +
> +struct host_map {
> +	struct list_head mapping_list;
> +	gpa_t map_gpa;
> +	struct kvm *machine;
> +	gpa_t req_gpa;
> +};
> +
> +
> +static struct list_head token_list;
> +static spinlock_t token_lock;
> +
> +struct token_entry {
> +	struct list_head token_list;
> +	struct kvmi_map_mem_token token;
> +	struct kvm *kvm;
> +};
> +
> +
> +int kvmi_store_token(struct kvm *kvm, struct kvmi_map_mem_token *token)
> +{
> +	struct token_entry *tep;
> +
> +	print_hex_dump_debug("kvmi: new token ", DUMP_PREFIX_NONE,
> +			     32, 1, token, sizeof(struct kvmi_map_mem_token),
> +			     false);
> +
> +	tep = kmalloc(sizeof(struct token_entry), GFP_KERNEL);

	tep = kmalloc(sizeof(*tep), GFP_KERNEL)

> +	if (tep == NULL)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&tep->token_list);
> +	memcpy(&tep->token, token, sizeof(struct kvmi_map_mem_token));

Here too it might be better to do "sizeof(*token)"

> +	tep->kvm = kvm;
> +
> +	spin_lock(&token_lock);
> +	list_add_tail(&tep->token_list, &token_list);
> +	spin_unlock(&token_lock);
> +
> +	return 0;
> +}
> +
> +static struct kvm *find_machine_at(struct kvm_vcpu *vcpu, gva_t tkn_gva)
> +{
> +	long result;
> +	gpa_t tkn_gpa;
> +	struct kvmi_map_mem_token token;
> +	struct list_head *cur;
> +	struct token_entry *tep, *found = NULL;
> +	struct kvm *target_kvm = NULL;
> +
> +	/* machine token is passed as pointer */
> +	tkn_gpa = kvm_mmu_gva_to_gpa_system(vcpu, tkn_gva, NULL);
> +	if (tkn_gpa == UNMAPPED_GVA)
> +		return NULL;
> +
> +	/* copy token to local address space */
> +	result = kvm_read_guest(vcpu->kvm, tkn_gpa, &token, sizeof(token));
> +	if (IS_ERR_VALUE(result)) {
> +		kvm_err("kvmi: failed copying token from user\n");
> +		return ERR_PTR(result);
> +	}
> +
> +	/* consume token & find the VM */
> +	spin_lock(&token_lock);
> +	list_for_each(cur, &token_list) {
> +		tep = list_entry(cur, struct token_entry, token_list);
> +
> +		if (!memcmp(&token, &tep->token, sizeof(token))) {
> +			list_del(&tep->token_list);
> +			found = tep;
> +			break;
> +		}
> +	}
> +	spin_unlock(&token_lock);
> +
> +	if (found != NULL) {
> +		target_kvm = found->kvm;
> +		kfree(found);
> +	}
> +
> +	return target_kvm;
> +}
> +
> +static void remove_vm_token(struct kvm *kvm)
> +{
> +	struct list_head *cur, *next;
> +	struct token_entry *tep;
> +
> +	spin_lock(&token_lock);
> +	list_for_each_safe(cur, next, &token_list) {
> +		tep = list_entry(cur, struct token_entry, token_list);
> +
> +		if (tep->kvm == kvm) {
> +			list_del(&tep->token_list);
> +			kfree(tep);
> +		}
> +	}
> +	spin_unlock(&token_lock);
> +
> +}

There's an extra blank line at the end of this function (before the brace).

> +
> +
> +static int add_to_list(gpa_t map_gpa, struct kvm *machine, gpa_t req_gpa)
> +{
> +	struct host_map *map;
> +
> +	map = kmalloc(sizeof(struct host_map), GFP_KERNEL);

	map = kmalloc(sizeof(*map), GFP_KERNEL);

> +	if (map == NULL)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&map->mapping_list);
> +	map->map_gpa = map_gpa;
> +	map->machine = machine;
> +	map->req_gpa = req_gpa;
> +
> +	spin_lock(&mapping_lock);
> +	list_add_tail(&map->mapping_list, &mapping_list);
> +	spin_unlock(&mapping_lock);
> +
> +	return 0;
> +}
> +
> +static struct host_map *extract_from_list(gpa_t map_gpa)
> +{
> +	struct list_head *cur;
> +	struct host_map *map;
> +
> +	spin_lock(&mapping_lock);
> +	list_for_each(cur, &mapping_list) {
> +		map = list_entry(cur, struct host_map, mapping_list);
> +
> +		/* found - extract and return */
> +		if (map->map_gpa == map_gpa) {
> +			list_del(&map->mapping_list);
> +			spin_unlock(&mapping_lock);
> +
> +			return map;
> +		}
> +	}
> +	spin_unlock(&mapping_lock);
> +
> +	return NULL;
> +}
> +
> +static void remove_vm_from_list(struct kvm *kvm)
> +{
> +	struct list_head *cur, *next;
> +	struct host_map *map;
> +
> +	spin_lock(&mapping_lock);
> +
> +	list_for_each_safe(cur, next, &mapping_list) {
> +		map = list_entry(cur, struct host_map, mapping_list);
> +
> +		if (map->machine == kvm) {
> +			list_del(&map->mapping_list);
> +			kfree(map);
> +		}
> +	}
> +
> +	spin_unlock(&mapping_lock);
> +}
> +
> +static void remove_entry(struct host_map *map)
> +{
> +	kfree(map);
> +}
> +
> +
> +static struct vm_area_struct *isolate_page_vma(struct vm_area_struct *vma,
> +					       unsigned long addr)
> +{
> +	int result;
> +
> +	/* corner case */
> +	if (vma_pages(vma) == 1)
> +		return vma;
> +
> +	if (addr != vma->vm_start) {
> +		/* first split only if address in the middle */
> +		result = split_vma(vma->vm_mm, vma, addr, false);
> +		if (IS_ERR_VALUE((long)result))
> +			return ERR_PTR((long)result);
> +
> +		vma = find_vma(vma->vm_mm, addr);
> +		if (vma == NULL)
> +			return ERR_PTR(-ENOENT);
> +
> +		/* corner case (again) */
> +		if (vma_pages(vma) == 1)
> +			return vma;
> +	}
> +
> +	result = split_vma(vma->vm_mm, vma, addr + PAGE_SIZE, true);
> +	if (IS_ERR_VALUE((long)result))
> +		return ERR_PTR((long)result);
> +
> +	vma = find_vma(vma->vm_mm, addr);
> +	if (vma == NULL)
> +		return ERR_PTR(-ENOENT);
> +
> +	BUG_ON(vma_pages(vma) != 1);
> +
> +	return vma;
> +}
> +
> +static int redirect_rmap(struct vm_area_struct *req_vma, struct page *req_page,
> +			 struct vm_area_struct *map_vma)
> +{
> +	int result;
> +
> +	unlink_anon_vmas(map_vma);
> +
> +	result = anon_vma_fork(map_vma, req_vma);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out;

Why not just return result here?

> +
> +	page_dup_rmap(req_page, false);
> +
> +out:
> +	return result;
> +}
> +
> +static int host_map_fix_ptes(struct vm_area_struct *map_vma, hva_t map_hva,
> +			     struct page *req_page, struct page *map_page)
> +{
> +	struct mm_struct *map_mm = map_vma->vm_mm;
> +
> +	pmd_t *pmd;
> +	pte_t *ptep;
> +	spinlock_t *ptl;
> +	pte_t newpte;
> +
> +	unsigned long mmun_start;
> +	unsigned long mmun_end;
> +
> +	/* classic replace_page() code */
> +	pmd = mm_find_pmd(map_mm, map_hva);
> +	if (!pmd)
> +		return -EFAULT;
> +
> +	mmun_start = map_hva;
> +	mmun_end = map_hva + PAGE_SIZE;
> +	mmu_notifier_invalidate_range_start(map_mm, mmun_start, mmun_end);
> +
> +	ptep = pte_offset_map_lock(map_mm, pmd, map_hva, &ptl);
> +
> +	/* create new PTE based on requested page */
> +	newpte = mk_pte(req_page, map_vma->vm_page_prot);
> +	newpte = pte_set_flags(newpte, pte_flags(*ptep));
> +
> +	flush_cache_page(map_vma, map_hva, pte_pfn(*ptep));
> +	ptep_clear_flush_notify(map_vma, map_hva, ptep);
> +	set_pte_at_notify(map_mm, map_hva, ptep, newpte);
> +
> +	pte_unmap_unlock(ptep, ptl);
> +
> +	mmu_notifier_invalidate_range_end(map_mm, mmun_start, mmun_end);
> +
> +	return 0;
> +}
> +
> +static void discard_page(struct page *map_page)
> +{
> +	lock_page(map_page);
> +	// TODO: put_anon_vma() ???? - should be here
> +	page_remove_rmap(map_page, false);
> +	if (!page_mapped(map_page))
> +		try_to_free_swap(map_page);
> +	unlock_page(map_page);
> +	put_page(map_page);
> +}
> +
> +static void kvmi_split_huge_pmd(struct vm_area_struct *req_vma,
> +				hva_t req_hva, struct page *req_page)
> +{
> +	bool tail = false;
> +
> +	/* move reference count from compound head... */
> +	if (PageTail(req_page)) {
> +		tail = true;
> +		put_page(req_page);
> +	}
> +
> +	if (PageCompound(req_page))
> +		split_huge_pmd_address(req_vma, req_hva, false, NULL);
> +
> +	/* ... to the actual page, after splitting */
> +	if (tail)
> +		get_page(req_page);
> +}
> +
> +static int kvmi_map_action(struct mm_struct *req_mm, hva_t req_hva,
> +			   struct mm_struct *map_mm, hva_t map_hva)
> +{
> +	struct vm_area_struct *req_vma;
> +	struct page *req_page = NULL;
> +
> +	struct vm_area_struct *map_vma;
> +	struct page *map_page;
> +
> +	long nrpages;
> +	int result = 0;
> +
> +	/* VMAs will be modified */
> +	down_write(&req_mm->mmap_sem);
> +	down_write(&map_mm->mmap_sem);
> +
> +	/* get host page corresponding to requested address */
> +	nrpages = get_user_pages_remote(NULL, req_mm,
> +		req_hva, 1, 0,
> +		&req_page, &req_vma, NULL);
> +	if (nrpages == 0) {
> +		kvm_err("kvmi: no page for req_hva %016lx\n", req_hva);
> +		result = -ENOENT;
> +		goto out_err;
> +	} else if (IS_ERR_VALUE(nrpages)) {
> +		result = nrpages;
> +		kvm_err("kvmi: get_user_pages_remote() failed with result %d\n",
> +			result);
> +		goto out_err;
> +	}
> +
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(req_page, "req_page before remap");
> +
> +	/* find (not get) local page corresponding to target address */
> +	map_vma = find_vma(map_mm, map_hva);
> +	if (map_vma == NULL) {
> +		kvm_err("kvmi: no local VMA found for remapping\n");
> +		result = -ENOENT;
> +		goto out_err;
> +	}
> +
> +	map_page = follow_page(map_vma, map_hva, 0);
> +	if (IS_ERR_VALUE(map_page)) {
> +		result = PTR_ERR(map_page);
> +		kvm_debug("kvmi: follow_page() failed with result %d\n",
> +			result);
> +		goto out_err;
> +	} else if (map_page == NULL) {
> +		result = -ENOENT;
> +		kvm_debug("kvmi: follow_page() returned no page\n");
> +		goto out_err;
> +	}
> +
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(map_page, "map_page before remap");
> +
> +	/* split local VMA for rmap redirecting */
> +	map_vma = isolate_page_vma(map_vma, map_hva);
> +	if (IS_ERR_VALUE(map_vma)) {
> +		result = PTR_ERR(map_vma);
> +		kvm_debug("kvmi: isolate_page_vma() failed with result %d\n",
> +			result);
> +		goto out_err;
> +	}
> +
> +	/* split remote huge page */
> +	kvmi_split_huge_pmd(req_vma, req_hva, req_page);
> +
> +	/* re-link VMAs */
> +	result = redirect_rmap(req_vma, req_page, map_vma);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out_err;
> +
> +	/* also redirect page tables */
> +	result = host_map_fix_ptes(map_vma, map_hva, req_page, map_page);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out_err;
> +
> +	/* the old page will be discarded */
> +	discard_page(map_page);
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(map_page, "map_page after being discarded");
> +
> +	/* done */
> +	goto out_finalize;
> +
> +out_err:
> +	/* get_user_pages_remote() incremented page reference count */
> +	if (req_page != NULL)
> +		put_page(req_page);
> +
> +out_finalize:
> +	/* release semaphores in reverse order */
> +	up_write(&map_mm->mmap_sem);
> +	up_write(&req_mm->mmap_sem);
> +
> +	return result;
> +}
> +
> +int kvmi_host_mem_map(struct kvm_vcpu *vcpu, gva_t tkn_gva,
> +	gpa_t req_gpa, gpa_t map_gpa)
> +{
> +	int result = 0;
> +	struct kvm *target_kvm;
> +
> +	gfn_t req_gfn;
> +	hva_t req_hva;
> +	struct mm_struct *req_mm;
> +
> +	gfn_t map_gfn;
> +	hva_t map_hva;
> +	struct mm_struct *map_mm = vcpu->kvm->mm;
> +
> +	kvm_debug("kvmi: mapping request req_gpa %016llx, map_gpa %016llx\n",
> +		  req_gpa, map_gpa);
> +
> +	/* get the struct kvm * corresponding to the token */
> +	target_kvm = find_machine_at(vcpu, tkn_gva);
> +	if (IS_ERR_VALUE(target_kvm))
> +		return PTR_ERR(target_kvm);

Since the else if block below has braces, this if block should have 
braces too.

> +	else if (target_kvm == NULL) {
> +		kvm_err("kvmi: unable to find target machine\n");
> +		return -ENOENT;
> +	}
> +	kvm_get_kvm(target_kvm);
> +	req_mm = target_kvm->mm;
> +
> +	/* translate source addresses */
> +	req_gfn = gpa_to_gfn(req_gpa);
> +	req_hva = gfn_to_hva_safe(target_kvm, req_gfn);
> +	if (kvm_is_error_hva(req_hva)) {
> +		kvm_err("kvmi: invalid req HVA %016lx\n", req_hva);
> +		result = -EFAULT;
> +		goto out;
> +	}
> +
> +	kvm_debug("kvmi: req_gpa %016llx, req_gfn %016llx, req_hva %016lx\n",
> +		  req_gpa, req_gfn, req_hva);
> +
> +	/* translate destination addresses */
> +	map_gfn = gpa_to_gfn(map_gpa);
> +	map_hva = gfn_to_hva_safe(vcpu->kvm, map_gfn);
> +	if (kvm_is_error_hva(map_hva)) {
> +		kvm_err("kvmi: invalid map HVA %016lx\n", map_hva);
> +		result = -EFAULT;
> +		goto out;
> +	}
> +
> +	kvm_debug("kvmi: map_gpa %016llx, map_gfn %016llx, map_hva %016lx\n",
> +		map_gpa, map_gfn, map_hva);
> +
> +	/* go to step 2 */
> +	result = kvmi_map_action(req_mm, req_hva, map_mm, map_hva);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out;
> +
> +	/* add mapping to list */
> +	result = add_to_list(map_gpa, target_kvm, req_gpa);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out;
> +
> +	/* all fine */
> +	kvm_debug("kvmi: mapping of req_gpa %016llx successful\n", req_gpa);
> +
> +out:
> +	/* mandatory dec refernce count */
> +	kvm_put_kvm(target_kvm);
> +
> +	return result;
> +}
> +
> +
> +static int restore_rmap(struct vm_area_struct *map_vma, hva_t map_hva,
> +			struct page *req_page, struct page *new_page)
> +{
> +	int result;
> +
> +	/* decouple links to anon_vmas */
> +	unlink_anon_vmas(map_vma);
> +	map_vma->anon_vma = NULL;
> +
> +	/* allocate new anon_vma */
> +	result = anon_vma_prepare(map_vma);
> +	if (IS_ERR_VALUE((long)result))
> +		return result;
> +
> +	lock_page(new_page);
> +	page_add_new_anon_rmap(new_page, map_vma, map_hva, false);
> +	unlock_page(new_page);
> +
> +	/* decrease req_page mapcount */
> +	atomic_dec(&req_page->_mapcount);
> +
> +	return 0;
> +}
> +
> +static int host_unmap_fix_ptes(struct vm_area_struct *map_vma, hva_t map_hva,
> +			       struct page *new_page)
> +{
> +	struct mm_struct *map_mm = map_vma->vm_mm;
> +	pmd_t *pmd;
> +	pte_t *ptep;
> +	spinlock_t *ptl;
> +	pte_t newpte;
> +
> +	unsigned long mmun_start;
> +	unsigned long mmun_end;
> +
> +	/* page replacing code */
> +	pmd = mm_find_pmd(map_mm, map_hva);
> +	if (!pmd)
> +		return -EFAULT;
> +
> +	mmun_start = map_hva;
> +	mmun_end = map_hva + PAGE_SIZE;
> +	mmu_notifier_invalidate_range_start(map_mm, mmun_start, mmun_end);
> +
> +	ptep = pte_offset_map_lock(map_mm, pmd, map_hva, &ptl);
> +
> +	newpte = mk_pte(new_page, map_vma->vm_page_prot);
> +	newpte = pte_set_flags(newpte, pte_flags(*ptep));
> +
> +	/* clear cache & MMU notifier entries */
> +	flush_cache_page(map_vma, map_hva, pte_pfn(*ptep));
> +	ptep_clear_flush_notify(map_vma, map_hva, ptep);
> +	set_pte_at_notify(map_mm, map_hva, ptep, newpte);
> +
> +	pte_unmap_unlock(ptep, ptl);
> +
> +	mmu_notifier_invalidate_range_end(map_mm, mmun_start, mmun_end);
> +
> +	return 0;
> +}
> +
> +static int kvmi_unmap_action(struct mm_struct *req_mm,
> +			     struct mm_struct *map_mm, hva_t map_hva)
> +{
> +	struct vm_area_struct *map_vma;
> +	struct page *req_page = NULL;
> +	struct page *new_page = NULL;
> +
> +	int result;
> +
> +	/* VMAs will be modified */
> +	down_write(&req_mm->mmap_sem);
> +	down_write(&map_mm->mmap_sem);
> +
> +	/* find destination VMA for mapping */
> +	map_vma = find_vma(map_mm, map_hva);
> +	if (map_vma == NULL) {
> +		result = -ENOENT;
> +		kvm_err("kvmi: no local VMA found for unmapping\n");
> +		goto out_err;
> +	}
> +
> +	/* find (not get) page mapped to destination address */
> +	req_page = follow_page(map_vma, map_hva, 0);
> +	if (IS_ERR_VALUE(req_page)) {
> +		result = PTR_ERR(req_page);
> +		kvm_err("kvmi: follow_page() failed with result %d\n", result);
> +		goto out_err;
> +	} else if (req_page == NULL) {
> +		result = -ENOENT;
> +		kvm_err("kvmi: follow_page() returned no page\n");
> +		goto out_err;
> +	}
> +
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(req_page, "req_page before decoupling");
> +
> +	/* Returns NULL when no page can be allocated. */
> +	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, map_vma, map_hva);
> +	if (new_page == NULL) {
> +		result = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(new_page, "new_page after allocation");
> +
> +	/* should fix the rmap tree */
> +	result = restore_rmap(map_vma, map_hva, req_page, new_page);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out_err;
> +
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(req_page, "req_page after decoupling");
> +
> +	/* page table fixing here */
> +	result = host_unmap_fix_ptes(map_vma, map_hva, new_page);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out_err;
> +
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		dump_page(new_page, "new_page after unmapping");
> +
> +	goto out_finalize;
> +
> +out_err:
> +	if (new_page != NULL)
> +		put_page(new_page);
> +
> +out_finalize:
> +	/* reference count was inc during get_user_pages_remote() */
> +	if (req_page != NULL) {
> +		put_page(req_page);
> +
> +		if (IS_ENABLED(CONFIG_DEBUG_VM))
> +			dump_page(req_page, "req_page after release");
> +	}
> +
> +	/* release semaphores in reverse order */
> +	up_write(&map_mm->mmap_sem);
> +	up_write(&req_mm->mmap_sem);
> +
> +	return result;
> +}
> +
> +int kvmi_host_mem_unmap(struct kvm_vcpu *vcpu, gpa_t map_gpa)
> +{
> +	struct kvm *target_kvm;
> +	struct mm_struct *req_mm;
> +
> +	struct host_map *map;
> +	int result;
> +
> +	gfn_t map_gfn;
> +	hva_t map_hva;
> +	struct mm_struct *map_mm = vcpu->kvm->mm;
> +
> +	kvm_debug("kvmi: unmap request for map_gpa %016llx\n", map_gpa);
> +
> +	/* get the struct kvm * corresponding to map_gpa */
> +	map = extract_from_list(map_gpa);
> +	if (map == NULL) {
> +		kvm_err("kvmi: map_gpa %016llx not mapped\n", map_gpa);
> +		return -ENOENT;
> +	}
> +	target_kvm = map->machine;
> +	kvm_get_kvm(target_kvm);
> +	req_mm = target_kvm->mm;
> +
> +	kvm_debug("kvmi: req_gpa %016llx of machine %016lx mapped in map_gpa %016llx\n",
> +		  map->req_gpa, (unsigned long) map->machine, map->map_gpa);
> +
> +	/* address where we did the remapping */
> +	map_gfn = gpa_to_gfn(map_gpa);
> +	map_hva = gfn_to_hva_safe(vcpu->kvm, map_gfn);
> +	if (kvm_is_error_hva(map_hva)) {
> +		result = -EFAULT;
> +		kvm_err("kvmi: invalid HVA %016lx\n", map_hva);
> +		goto out;
> +	}
> +
> +	kvm_debug("kvmi: map_gpa %016llx, map_gfn %016llx, map_hva %016lx\n",
> +		  map_gpa, map_gfn, map_hva);
> +
> +	/* go to step 2 */
> +	result = kvmi_unmap_action(req_mm, map_mm, map_hva);
> +	if (IS_ERR_VALUE((long)result))
> +		goto out;
> +
> +	kvm_debug("kvmi: unmap of map_gpa %016llx successful\n", map_gpa);
> +
> +out:
> +	kvm_put_kvm(target_kvm);
> +
> +	/* remove entry whatever happens above */
> +	remove_entry(map);
> +
> +	return result;
> +}
> +
> +void kvmi_mem_destroy_vm(struct kvm *kvm)
> +{
> +	kvm_debug("kvmi: machine %016lx was torn down\n",
> +		(unsigned long) kvm);
> +
> +	remove_vm_from_list(kvm);
> +	remove_vm_token(kvm);
> +}
> +
> +
> +int kvm_intro_host_init(void)
> +{
> +	/* token database */
> +	INIT_LIST_HEAD(&token_list);
> +	spin_lock_init(&token_lock);
> +
> +	/* mapping database */
> +	INIT_LIST_HEAD(&mapping_list);
> +	spin_lock_init(&mapping_lock);
> +
> +	kvm_info("kvmi: initialized host memory introspection\n");
> +
> +	return 0;
> +}
> +
> +void kvm_intro_host_exit(void)
> +{
> +	// ...
> +}
> +
> +module_init(kvm_intro_host_init)
> +module_exit(kvm_intro_host_exit)
> diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
> new file mode 100644
> index 000000000000..b1b20eb6332d
> --- /dev/null
> +++ b/virt/kvm/kvmi_msg.c
> @@ -0,0 +1,1134 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * KVM introspection
> + *
> + * Copyright (C) 2017 Bitdefender S.R.L.
> + *
> + */
> +#include <linux/file.h>
> +#include <linux/net.h>
> +#include <linux/kvm_host.h>
> +#include <linux/kvmi.h>
> +#include <asm/virtext.h>
> +
> +#include <uapi/linux/kvmi.h>
> +#include <uapi/asm/kvmi.h>
> +
> +#include "kvmi_int.h"
> +
> +#include <trace/events/kvmi.h>
> +
> +/*
> + * TODO: break these call paths
> + *   kvmi.c        work_cb
> + *   kvmi_msg.c    kvmi_dispatch_message
> + *   kvmi.c        kvmi_cmd_... / kvmi_make_request
> + *   kvmi_msg.c    kvmi_msg_reply
> + *
> + *   kvmi.c        kvmi_X_event
> + *   kvmi_msg.c    kvmi_send_event
> + *   kvmi.c        kvmi_handle_request
> + */
> +
> +/* TODO: move some of the code to arch/x86 */
> +
> +static atomic_t seq_ev = ATOMIC_INIT(0);
> +
> +static u32 new_seq(void)
> +{
> +	return atomic_inc_return(&seq_ev);
> +}
> +
> +static const char *event_str(unsigned int e)
> +{
> +	switch (e) {
> +	case KVMI_EVENT_CR:
> +		return "CR";
> +	case KVMI_EVENT_MSR:
> +		return "MSR";
> +	case KVMI_EVENT_XSETBV:
> +		return "XSETBV";
> +	case KVMI_EVENT_BREAKPOINT:
> +		return "BREAKPOINT";
> +	case KVMI_EVENT_HYPERCALL:
> +		return "HYPERCALL";
> +	case KVMI_EVENT_PAGE_FAULT:
> +		return "PAGE_FAULT";
> +	case KVMI_EVENT_TRAP:
> +		return "TRAP";
> +	case KVMI_EVENT_DESCRIPTOR:
> +		return "DESCRIPTOR";
> +	case KVMI_EVENT_CREATE_VCPU:
> +		return "CREATE_VCPU";
> +	case KVMI_EVENT_PAUSE_VCPU:
> +		return "PAUSE_VCPU";
> +	default:
> +		return "EVENT?";
> +	}
> +}
> +
> +static const char * const msg_IDs[] = {
> +	[KVMI_GET_VERSION]      = "KVMI_GET_VERSION",
> +	[KVMI_GET_GUEST_INFO]   = "KVMI_GET_GUEST_INFO",
> +	[KVMI_PAUSE_VCPU]       = "KVMI_PAUSE_VCPU",
> +	[KVMI_GET_REGISTERS]    = "KVMI_GET_REGISTERS",
> +	[KVMI_SET_REGISTERS]    = "KVMI_SET_REGISTERS",
> +	[KVMI_GET_PAGE_ACCESS]  = "KVMI_GET_PAGE_ACCESS",
> +	[KVMI_SET_PAGE_ACCESS]  = "KVMI_SET_PAGE_ACCESS",
> +	[KVMI_INJECT_EXCEPTION] = "KVMI_INJECT_EXCEPTION",
> +	[KVMI_READ_PHYSICAL]    = "KVMI_READ_PHYSICAL",
> +	[KVMI_WRITE_PHYSICAL]   = "KVMI_WRITE_PHYSICAL",
> +	[KVMI_GET_MAP_TOKEN]    = "KVMI_GET_MAP_TOKEN",
> +	[KVMI_CONTROL_EVENTS]   = "KVMI_CONTROL_EVENTS",
> +	[KVMI_CONTROL_CR]       = "KVMI_CONTROL_CR",
> +	[KVMI_CONTROL_MSR]      = "KVMI_CONTROL_MSR",
> +	[KVMI_EVENT]            = "KVMI_EVENT",
> +	[KVMI_EVENT_REPLY]      = "KVMI_EVENT_REPLY",
> +	[KVMI_GET_CPUID]        = "KVMI_GET_CPUID",
> +	[KVMI_GET_XSAVE]        = "KVMI_GET_XSAVE",
> +};
> +
> +static size_t sizeof_get_registers(const void *r)
> +{
> +	const struct kvmi_get_registers *req = r;
> +
> +	return sizeof(*req) + sizeof(req->msrs_idx[0]) * req->nmsrs;
> +}
> +
> +static size_t sizeof_get_page_access(const void *r)
> +{
> +	const struct kvmi_get_page_access *req = r;
> +
> +	return sizeof(*req) + sizeof(req->gpa[0]) * req->count;
> +}
> +
> +static size_t sizeof_set_page_access(const void *r)
> +{
> +	const struct kvmi_set_page_access *req = r;
> +
> +	return sizeof(*req) + sizeof(req->entries[0]) * req->count;
> +}
> +
> +static size_t sizeof_write_physical(const void *r)
> +{
> +	const struct kvmi_write_physical *req = r;
> +
> +	return sizeof(*req) + req->size;
> +}
> +
> +static const struct {
> +	size_t size;
> +	size_t (*cbk_full_size)(const void *msg);
> +} msg_bytes[] = {
> +	[KVMI_GET_VERSION]      = { 0, NULL },
> +	[KVMI_GET_GUEST_INFO]   = { sizeof(struct kvmi_get_guest_info), NULL },
> +	[KVMI_PAUSE_VCPU]       = { sizeof(struct kvmi_pause_vcpu), NULL },
> +	[KVMI_GET_REGISTERS]    = { sizeof(struct kvmi_get_registers),
> +						sizeof_get_registers },
> +	[KVMI_SET_REGISTERS]    = { sizeof(struct kvmi_set_registers), NULL },
> +	[KVMI_GET_PAGE_ACCESS]  = { sizeof(struct kvmi_get_page_access),
> +						sizeof_get_page_access },
> +	[KVMI_SET_PAGE_ACCESS]  = { sizeof(struct kvmi_set_page_access),
> +						sizeof_set_page_access },
> +	[KVMI_INJECT_EXCEPTION] = { sizeof(struct kvmi_inject_exception),
> +					NULL },
> +	[KVMI_READ_PHYSICAL]    = { sizeof(struct kvmi_read_physical), NULL },
> +	[KVMI_WRITE_PHYSICAL]   = { sizeof(struct kvmi_write_physical),
> +						sizeof_write_physical },
> +	[KVMI_GET_MAP_TOKEN]    = { 0, NULL },
> +	[KVMI_CONTROL_EVENTS]   = { sizeof(struct kvmi_control_events), NULL },
> +	[KVMI_CONTROL_CR]       = { sizeof(struct kvmi_control_cr), NULL },
> +	[KVMI_CONTROL_MSR]      = { sizeof(struct kvmi_control_msr), NULL },
> +	[KVMI_GET_CPUID]        = { sizeof(struct kvmi_get_cpuid), NULL },
> +	[KVMI_GET_XSAVE]        = { sizeof(struct kvmi_get_xsave), NULL },
> +};
> +
> +static int kvmi_sock_read(struct kvmi *ikvm, void *buf, size_t size)
> +{
> +	struct kvec i = {
> +		.iov_base = buf,
> +		.iov_len = size,
> +	};
> +	struct msghdr m = { };
> +	int rc;
> +
> +	read_lock(&ikvm->sock_lock);
> +
> +	if (likely(ikvm->sock))
> +		rc = kernel_recvmsg(ikvm->sock, &m, &i, 1, size, MSG_WAITALL);
> +	else
> +		rc = -EPIPE;
> +
> +	if (rc > 0)
> +		print_hex_dump_debug("read: ", DUMP_PREFIX_NONE, 32, 1,
> +					buf, rc, false);
> +
> +	read_unlock(&ikvm->sock_lock);
> +
> +	if (unlikely(rc != size)) {
> +		kvm_err("kernel_recvmsg: %d\n", rc);
> +		if (rc >= 0)
> +			rc = -EPIPE;
> +		return rc;
> +	}
> +
> +	return 0;
> +}
> +
> +static int kvmi_sock_write(struct kvmi *ikvm, struct kvec *i, size_t n,
> +			   size_t size)
> +{
> +	struct msghdr m = { };
> +	int rc, k;
> +
> +	read_lock(&ikvm->sock_lock);
> +
> +	if (likely(ikvm->sock))
> +		rc = kernel_sendmsg(ikvm->sock, &m, i, n, size);
> +	else
> +		rc = -EPIPE;
> +
> +	for (k = 0; k < n; k++)
> +		print_hex_dump_debug("write: ", DUMP_PREFIX_NONE, 32, 1,
> +				     i[k].iov_base, i[k].iov_len, false);
> +
> +	read_unlock(&ikvm->sock_lock);
> +
> +	if (unlikely(rc != size)) {
> +		kvm_err("kernel_sendmsg: %d\n", rc);
> +		if (rc >= 0)
> +			rc = -EPIPE;
> +		return rc;
> +	}
> +
> +	return 0;
> +}
> +
> +static const char *id2str(int i)
> +{
> +	return (i < ARRAY_SIZE(msg_IDs) && msg_IDs[i] ? msg_IDs[i] : "unknown");
> +}
> +
> +static struct kvmi_vcpu *kvmi_vcpu_waiting_for_reply(struct kvm *kvm, u32 seq)
> +{
> +	struct kvmi_vcpu *found = NULL;
> +	struct kvm_vcpu *vcpu;
> +	int i;
> +
> +	mutex_lock(&kvm->lock);
> +
> +	kvm_for_each_vcpu(i, vcpu, kvm) {
> +		/* kvmi_send_event */
> +		smp_rmb();
> +		if (READ_ONCE(IVCPU(vcpu)->ev_rpl_waiting)
> +		    && seq == IVCPU(vcpu)->ev_seq) {
> +			found = IVCPU(vcpu);
> +			break;
> +		}
> +	}
> +
> +	mutex_unlock(&kvm->lock);
> +
> +	return found;
> +}
> +
> +static bool kvmi_msg_dispatch_reply(struct kvmi *ikvm,
> +				    const struct kvmi_msg_hdr *msg)
> +{
> +	struct kvmi_vcpu *ivcpu;
> +	int err;
> +
> +	ivcpu = kvmi_vcpu_waiting_for_reply(ikvm->kvm, msg->seq);
> +	if (!ivcpu) {
> +		kvm_err("%s: unexpected event reply (seq=%u)\n", __func__,
> +			msg->seq);
> +		return false;
> +	}
> +
> +	if (msg->size == sizeof(ivcpu->ev_rpl) + ivcpu->ev_rpl_size) {
> +		err = kvmi_sock_read(ikvm, &ivcpu->ev_rpl,
> +					sizeof(ivcpu->ev_rpl));
> +		if (!err && ivcpu->ev_rpl_size)
> +			err = kvmi_sock_read(ikvm, ivcpu->ev_rpl_ptr,
> +						ivcpu->ev_rpl_size);
> +	} else {
> +		kvm_err("%s: invalid event reply size (max=%zu, recv=%u, expected=%zu)\n",
> +			__func__, ivcpu->ev_rpl_size, msg->size,
> +			sizeof(ivcpu->ev_rpl) + ivcpu->ev_rpl_size);
> +		err = -1;
> +	}
> +
> +	ivcpu->ev_rpl_received = err ? -1 : ivcpu->ev_rpl_size;
> +
> +	kvmi_make_request(ivcpu, REQ_REPLY);
> +
> +	return (err == 0);
> +}
> +
> +static bool consume_sock_bytes(struct kvmi *ikvm, size_t n)
> +{
> +	while (n) {
> +		u8 buf[256];
> +		size_t chunk = min(n, sizeof(buf));
> +
> +		if (kvmi_sock_read(ikvm, buf, chunk) != 0)
> +			return false;
> +
> +		n -= chunk;
> +	}
> +
> +	return true;
> +}
> +
> +static int kvmi_msg_reply(struct kvmi *ikvm,
> +			  const struct kvmi_msg_hdr *msg,
> +			  int err, const void *rpl, size_t rpl_size)
> +{
> +	struct kvmi_error_code ec;
> +	struct kvmi_msg_hdr h;
> +	struct kvec vec[3] = {
> +		{.iov_base = &h,           .iov_len = sizeof(h) },
> +		{.iov_base = &ec,          .iov_len = sizeof(ec)},
> +		{.iov_base = (void *) rpl, .iov_len = rpl_size  },
> +	};
> +	size_t size = sizeof(h) + sizeof(ec) + (err ? 0 : rpl_size);
> +	size_t n = err ? ARRAY_SIZE(vec)-1 : ARRAY_SIZE(vec);
> +
> +	memset(&h, 0, sizeof(h));
> +	h.id = msg->id;
> +	h.seq = msg->seq;
> +	h.size = size - sizeof(h);
> +
> +	memset(&ec, 0, sizeof(ec));
> +	ec.err = err;
> +
> +	return kvmi_sock_write(ikvm, vec, n, size);
> +}
> +
> +static int kvmi_msg_vcpu_reply(struct kvm_vcpu *vcpu,
> +				const struct kvmi_msg_hdr *msg,
> +				int err, const void *rpl, size_t size)
> +{
> +	/*
> +	 * As soon as we reply to this vCPU command, we can get another one,
> +	 * and we must signal that the incoming buffer (ivcpu->msg_buf)
> +	 * is ready by clearing this bit/request.
> +	 */
> +	kvmi_clear_request(IVCPU(vcpu), REQ_CMD);
> +
> +	return kvmi_msg_reply(IKVM(vcpu->kvm), msg, err, rpl, size);
> +}
> +
> +bool kvmi_msg_init(struct kvmi *ikvm, int fd)
> +{
> +	struct socket *sock;
> +	int r;
> +
> +	sock = sockfd_lookup(fd, &r);
> +
> +	if (!sock) {
> +		kvm_err("Invalid file handle: %d\n", fd);
> +		return false;
> +	}
> +
> +	WRITE_ONCE(ikvm->sock, sock);
> +
> +	return true;
> +}
> +
> +void kvmi_msg_uninit(struct kvmi *ikvm)
> +{
> +	kvm_info("Wake up the receiving thread\n");
> +
> +	read_lock(&ikvm->sock_lock);
> +
> +	if (ikvm->sock)
> +		kernel_sock_shutdown(ikvm->sock, SHUT_RDWR);
> +
> +	read_unlock(&ikvm->sock_lock);
> +
> +	kvm_info("Wait for the receiving thread to complete\n");
> +	wait_for_completion(&ikvm->finished);
> +}
> +
> +static int handle_get_version(struct kvmi *ikvm,
> +			      const struct kvmi_msg_hdr *msg, const void *req)
> +{
> +	struct kvmi_get_version_reply rpl;
> +
> +	memset(&rpl, 0, sizeof(rpl));
> +	rpl.version = KVMI_VERSION;
> +
> +	return kvmi_msg_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
> +}
> +
> +static struct kvm_vcpu *kvmi_get_vcpu(struct kvmi *ikvm, int vcpu_id)
> +{
> +	struct kvm *kvm = ikvm->kvm;
> +
> +	if (vcpu_id >= atomic_read(&kvm->online_vcpus))
> +		return NULL;
> +
> +	return kvm_get_vcpu(kvm, vcpu_id);
> +}
> +
> +static bool invalid_page_access(u64 gpa, u64 size)
> +{
> +	u64 off = gpa & ~PAGE_MASK;
> +
> +	return (size == 0 || size > PAGE_SIZE || off + size > PAGE_SIZE);
> +}
> +
> +static int handle_read_physical(struct kvmi *ikvm,
> +				const struct kvmi_msg_hdr *msg,
> +				const void *_req)
> +{
> +	const struct kvmi_read_physical *req = _req;
> +
> +	if (invalid_page_access(req->gpa, req->size))
> +		return -EINVAL;
> +
> +	return kvmi_cmd_read_physical(ikvm->kvm, req->gpa, req->size,
> +				      kvmi_msg_reply, msg);
> +}
> +
> +static int handle_write_physical(struct kvmi *ikvm,
> +				 const struct kvmi_msg_hdr *msg,
> +				 const void *_req)
> +{
> +	const struct kvmi_write_physical *req = _req;
> +	int ec;
> +
> +	if (invalid_page_access(req->gpa, req->size))
> +		return -EINVAL;
> +
> +	ec = kvmi_cmd_write_physical(ikvm->kvm, req->gpa, req->size, req->data);
> +
> +	return kvmi_msg_reply(ikvm, msg, ec, NULL, 0);
> +}
> +
> +static int handle_get_map_token(struct kvmi *ikvm,
> +				const struct kvmi_msg_hdr *msg,
> +				const void *_req)
> +{
> +	struct kvmi_get_map_token_reply rpl;
> +	int ec;
> +
> +	ec = kvmi_cmd_alloc_token(ikvm->kvm, &rpl.token);
> +
> +	return kvmi_msg_reply(ikvm, msg, ec, &rpl, sizeof(rpl));
> +}
> +
> +static int handle_control_cr(struct kvmi *ikvm,
> +			     const struct kvmi_msg_hdr *msg, const void *_req)
> +{
> +	const struct kvmi_control_cr *req = _req;
> +	int ec;
> +
> +	ec = kvmi_cmd_control_cr(ikvm, req->enable, req->cr);
> +
> +	return kvmi_msg_reply(ikvm, msg, ec, NULL, 0);
> +}
> +
> +static int handle_control_msr(struct kvmi *ikvm,
> +			      const struct kvmi_msg_hdr *msg, const void *_req)
> +{
> +	const struct kvmi_control_msr *req = _req;
> +	int ec;
> +
> +	ec = kvmi_cmd_control_msr(ikvm->kvm, req->enable, req->msr);
> +
> +	return kvmi_msg_reply(ikvm, msg, ec, NULL, 0);
> +}
> +
> +/*
> + * These commands are executed on the receiving thread/worker.
> + */
> +static int (*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
> +			     const void *) = {
> +	[KVMI_GET_VERSION]    = handle_get_version,
> +	[KVMI_READ_PHYSICAL]  = handle_read_physical,
> +	[KVMI_WRITE_PHYSICAL] = handle_write_physical,
> +	[KVMI_GET_MAP_TOKEN]  = handle_get_map_token,
> +	[KVMI_CONTROL_CR]     = handle_control_cr,
> +	[KVMI_CONTROL_MSR]    = handle_control_msr,
> +};
> +
> +static int handle_get_guest_info(struct kvm_vcpu *vcpu,
> +				 const struct kvmi_msg_hdr *msg,
> +				 const void *req)
> +{
> +	struct kvmi_get_guest_info_reply rpl;
> +
> +	memset(&rpl, 0, sizeof(rpl));
> +	kvmi_cmd_get_guest_info(vcpu, &rpl.vcpu_count, &rpl.tsc_speed);
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, 0, &rpl, sizeof(rpl));
> +}
> +
> +static int handle_pause_vcpu(struct kvm_vcpu *vcpu,
> +			     const struct kvmi_msg_hdr *msg,
> +			     const void *req)
> +{
> +	int ec = kvmi_cmd_pause_vcpu(vcpu);
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, ec, NULL, 0);
> +}
> +
> +static void *alloc_get_registers_reply(const struct kvmi_msg_hdr *msg,
> +				       const struct kvmi_get_registers *req,
> +				       size_t *rpl_size)
> +{
> +	struct kvmi_get_registers_reply *rpl;
> +	u16 k, n = req->nmsrs;
> +
> +	*rpl_size = sizeof(*rpl) + sizeof(rpl->msrs.entries[0]) * n;
> +
> +	rpl = kzalloc(*rpl_size, GFP_KERNEL);
> +
> +	if (rpl) {
> +		rpl->msrs.nmsrs = n;
> +
> +		for (k = 0; k < n; k++)
> +			rpl->msrs.entries[k].index = req->msrs_idx[k];
> +	}
> +
> +	return rpl;
> +}
> +
> +static int handle_get_registers(struct kvm_vcpu *vcpu,
> +				const struct kvmi_msg_hdr *msg, const void *req)
> +{
> +	struct kvmi_get_registers_reply *rpl;
> +	size_t rpl_size = 0;
> +	int err, ec;
> +
> +	rpl = alloc_get_registers_reply(msg, req, &rpl_size);
> +
> +	if (!rpl)
> +		ec = -KVM_ENOMEM;
> +	else
> +		ec = kvmi_cmd_get_registers(vcpu, &rpl->mode,
> +						&rpl->regs, &rpl->sregs,
> +						&rpl->msrs);
> +
> +	err = kvmi_msg_vcpu_reply(vcpu, msg, ec, rpl, rpl_size);
> +	kfree(rpl);
> +	return err;
> +}
> +
> +static int handle_set_registers(struct kvm_vcpu *vcpu,
> +				const struct kvmi_msg_hdr *msg,
> +				const void *_req)
> +{
> +	const struct kvmi_set_registers *req = _req;
> +	int ec;
> +
> +	ec = kvmi_cmd_set_registers(vcpu, &req->regs);
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, ec, NULL, 0);
> +}
> +
> +static int handle_get_page_access(struct kvm_vcpu *vcpu,
> +				  const struct kvmi_msg_hdr *msg,
> +				  const void *_req)
> +{
> +	const struct kvmi_get_page_access *req = _req;
> +	struct kvmi_get_page_access_reply *rpl = NULL;
> +	size_t rpl_size = 0;
> +	u16 k, n = req->count;
> +	int err, ec = 0;
> +
> +	if (req->view != 0 && !kvm_eptp_switching_supported) {
> +		ec = -KVM_ENOSYS;
> +		goto out;
> +	}
> +
> +	if (req->view != 0) { /* TODO */
> +		ec = -KVM_EINVAL;
> +		goto out;
> +	}
> +
> +	rpl_size = sizeof(*rpl) + sizeof(rpl->access[0]) * n;
> +	rpl = kzalloc(rpl_size, GFP_KERNEL);
> +
> +	if (!rpl) {
> +		ec = -KVM_ENOMEM;
> +		goto out;
> +	}
> +
> +	for (k = 0; k < n && ec == 0; k++)
> +		ec = kvmi_cmd_get_page_access(vcpu, req->gpa[k],
> +						&rpl->access[k]);
> +
> +out:
> +	err = kvmi_msg_vcpu_reply(vcpu, msg, ec, rpl, rpl_size);
> +	kfree(rpl);
> +	return err;
> +}
> +
> +static int handle_set_page_access(struct kvm_vcpu *vcpu,
> +				  const struct kvmi_msg_hdr *msg,
> +				  const void *_req)
> +{
> +	const struct kvmi_set_page_access *req = _req;
> +	struct kvm *kvm = vcpu->kvm;
> +	u16 k, n = req->count;
> +	int ec = 0;
> +
> +	if (req->view != 0) {
> +		if (!kvm_eptp_switching_supported)
> +			ec = -KVM_ENOSYS;
> +		else
> +			ec = -KVM_EINVAL; /* TODO */
> +	} else {
> +		for (k = 0; k < n; k++) {
> +			u64 gpa   = req->entries[k].gpa;
> +			u8 access = req->entries[k].access;
> +			int ec0;
> +
> +			if (access &  ~(KVMI_PAGE_ACCESS_R |
> +					KVMI_PAGE_ACCESS_W |
> +					KVMI_PAGE_ACCESS_X))
> +				ec0 = -KVM_EINVAL;
> +			else
> +				ec0 = kvmi_set_mem_access(kvm, gpa, access);
> +
> +			if (ec0 && !ec)
> +				ec = ec0;
> +
> +			trace_kvmi_set_mem_access(gpa_to_gfn(gpa), access, ec0);
> +		}
> +	}
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, ec, NULL, 0);
> +}
> +
> +static int handle_inject_exception(struct kvm_vcpu *vcpu,
> +				   const struct kvmi_msg_hdr *msg,
> +				   const void *_req)
> +{
> +	const struct kvmi_inject_exception *req = _req;
> +	int ec;
> +
> +	ec = kvmi_cmd_inject_exception(vcpu, req->nr, req->has_error,
> +				       req->error_code, req->address);
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, ec, NULL, 0);
> +}
> +
> +static int handle_control_events(struct kvm_vcpu *vcpu,
> +				 const struct kvmi_msg_hdr *msg,
> +				 const void *_req)
> +{
> +	const struct kvmi_control_events *req = _req;
> +	u32 not_allowed = ~IKVM(vcpu->kvm)->event_allow_mask;
> +	u32 unknown = ~KVMI_KNOWN_EVENTS;
> +	int ec;
> +
> +	if (req->events & unknown)
> +		ec = -KVM_EINVAL;
> +	else if (req->events & not_allowed)
> +		ec = -KVM_EPERM;
> +	else
> +		ec = kvmi_cmd_control_events(vcpu, req->events);
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, ec, NULL, 0);
> +}
> +
> +static int handle_get_cpuid(struct kvm_vcpu *vcpu,
> +			    const struct kvmi_msg_hdr *msg,
> +			    const void *_req)
> +{
> +	const struct kvmi_get_cpuid *req = _req;
> +	struct kvmi_get_cpuid_reply rpl;
> +	int ec;
> +
> +	memset(&rpl, 0, sizeof(rpl));
> +
> +	ec = kvmi_cmd_get_cpuid(vcpu, req->function, req->index,
> +					&rpl.eax, &rpl.ebx, &rpl.ecx,
> +					&rpl.edx);
> +
> +	return kvmi_msg_vcpu_reply(vcpu, msg, ec, &rpl, sizeof(rpl));
> +}
> +
> +static int handle_get_xsave(struct kvm_vcpu *vcpu,
> +			    const struct kvmi_msg_hdr *msg, const void *req)
> +{
> +	struct kvmi_get_xsave_reply *rpl;
> +	size_t rpl_size = sizeof(*rpl) + sizeof(struct kvm_xsave);
> +	int ec = 0, err;
> +
> +	rpl = kzalloc(rpl_size, GFP_KERNEL);
> +
> +	if (!rpl)
> +		ec = -KVM_ENOMEM;

Again, because the else block has braces, the if should too.

> +	else {
> +		struct kvm_xsave *area;
> +
> +		area = (struct kvm_xsave *)&rpl->region[0];
> +		kvm_vcpu_ioctl_x86_get_xsave(vcpu, area);
> +	}
> +
> +	err = kvmi_msg_vcpu_reply(vcpu, msg, ec, rpl, rpl_size);
> +	kfree(rpl);
> +	return err;
> +}
> +
> +/*
> + * These commands are executed on the vCPU thread. The receiving thread
> + * saves the command into kvmi_vcpu.msg_buf[] and signals the vCPU to handle
> + * the command (including sending back the reply).
> + */
> +static int (*const msg_vcpu[])(struct kvm_vcpu *,
> +			       const struct kvmi_msg_hdr *, const void *) = {
> +	[KVMI_GET_GUEST_INFO]   = handle_get_guest_info,
> +	[KVMI_PAUSE_VCPU]       = handle_pause_vcpu,
> +	[KVMI_GET_REGISTERS]    = handle_get_registers,
> +	[KVMI_SET_REGISTERS]    = handle_set_registers,
> +	[KVMI_GET_PAGE_ACCESS]  = handle_get_page_access,
> +	[KVMI_SET_PAGE_ACCESS]  = handle_set_page_access,
> +	[KVMI_INJECT_EXCEPTION] = handle_inject_exception,
> +	[KVMI_CONTROL_EVENTS]   = handle_control_events,
> +	[KVMI_GET_CPUID]        = handle_get_cpuid,
> +	[KVMI_GET_XSAVE]        = handle_get_xsave,
> +};
> +
> +void kvmi_msg_handle_vcpu_cmd(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +	struct kvmi_msg_hdr *msg = (void *) ivcpu->msg_buf;
> +	u8 *req = ivcpu->msg_buf + sizeof(*msg);
> +	int err;
> +
> +	err = msg_vcpu[msg->id](vcpu, msg, req);
> +
> +	if (err)
> +		kvm_err("%s: id:%u (%s) err:%d\n", __func__, msg->id,
> +			id2str(msg->id), err);
> +
> +	/*
> +	 * No error code is returned.
> +	 *
> +	 * The introspector gets its error code from the message handler
> +	 * or the socket is closed (and QEMU should reconnect).
> +	 */
> +}
> +
> +static int kvmi_msg_recv_varlen(struct kvmi *ikvm, size_t(*cbk) (const void *),
> +				size_t min_n, size_t msg_size)
> +{
> +	size_t extra_n;
> +	u8 *extra_buf;
> +	int err;
> +
> +	if (min_n > msg_size) {
> +		kvm_err("%s: got %zu bytes instead of min %zu\n",
> +			__func__, msg_size, min_n);
> +		return -EINVAL;
> +	}
> +
> +	if (!min_n)
> +		return 0;
> +
> +	err = kvmi_sock_read(ikvm, ikvm->msg_buf, min_n);
> +
> +	extra_buf = ikvm->msg_buf + min_n;
> +	extra_n = msg_size - min_n;
> +
> +	if (!err && extra_n) {
> +		if (cbk(ikvm->msg_buf) == msg_size)
> +			err = kvmi_sock_read(ikvm, extra_buf, extra_n);
> +		else
> +			err = -EINVAL;
> +	}
> +
> +	return err;
> +}
> +
> +static int kvmi_msg_recv_n(struct kvmi *ikvm, size_t n, size_t msg_size)
> +{
> +	if (n != msg_size) {
> +		kvm_err("%s: got %zu bytes instead of %zu\n",
> +			__func__, msg_size, n);
> +		return -EINVAL;
> +	}
> +
> +	if (!n)
> +		return 0;
> +
> +	return kvmi_sock_read(ikvm, ikvm->msg_buf, n);
> +}
> +
> +static int kvmi_msg_recv(struct kvmi *ikvm, const struct kvmi_msg_hdr *msg)
> +{
> +	size_t (*cbk)(const void *) = msg_bytes[msg->id].cbk_full_size;
> +	size_t expected = msg_bytes[msg->id].size;
> +
> +	if (cbk)
> +		return kvmi_msg_recv_varlen(ikvm, cbk, expected, msg->size);
> +	else
> +		return kvmi_msg_recv_n(ikvm, expected, msg->size);
> +}
> +
> +struct vcpu_msg_hdr {
> +	__u16 vcpu;
> +	__u16 padding[3];
> +};
> +
> +static int kvmi_msg_queue_to_vcpu(struct kvmi *ikvm,
> +				  const struct kvmi_msg_hdr *msg)
> +{
> +	struct vcpu_msg_hdr *vcpu_hdr = (struct vcpu_msg_hdr *)ikvm->msg_buf;
> +	struct kvmi_vcpu *ivcpu;
> +	struct kvm_vcpu *vcpu;
> +
> +	if (msg->size < sizeof(*vcpu_hdr)) {
> +		kvm_err("%s: invalid vcpu message: %d\n", __func__, msg->size);
> +		return -EINVAL; /* ABI error */
> +	}
> +
> +	vcpu = kvmi_get_vcpu(ikvm, vcpu_hdr->vcpu);
> +
> +	if (!vcpu) {
> +		kvm_err("%s: invalid vcpu: %d\n", __func__, vcpu_hdr->vcpu);
> +		return kvmi_msg_reply(ikvm, msg, -KVM_EINVAL, NULL, 0);
> +	}
> +
> +	ivcpu = vcpu->kvmi;
> +
> +	if (!ivcpu) {
> +		kvm_err("%s: not introspected vcpu: %d\n",
> +			__func__, vcpu_hdr->vcpu);
> +		return kvmi_msg_reply(ikvm, msg, -KVM_EAGAIN, NULL, 0);
> +	}
> +
> +	if (test_bit(REQ_CMD, &ivcpu->requests)) {
> +		kvm_err("%s: vcpu is busy: %d\n", __func__, vcpu_hdr->vcpu);
> +		return kvmi_msg_reply(ikvm, msg, -KVM_EBUSY, NULL, 0);
> +	}
> +
> +	memcpy(ivcpu->msg_buf, msg, sizeof(*msg));
> +	memcpy(ivcpu->msg_buf + sizeof(*msg), ikvm->msg_buf, msg->size);
> +
> +	kvmi_make_request(ivcpu, REQ_CMD);
> +	kvm_make_request(KVM_REQ_INTROSPECTION, vcpu);
> +	kvm_vcpu_kick(vcpu);
> +
> +	return 0;
> +}
> +
> +static bool kvmi_msg_dispatch_cmd(struct kvmi *ikvm,
> +				  const struct kvmi_msg_hdr *msg)
> +{
> +	int err = kvmi_msg_recv(ikvm, msg);
> +
> +	if (err)
> +		goto out;
> +
> +	if (!KVMI_ALLOWED_COMMAND(msg->id, ikvm->cmd_allow_mask)) {
> +		err = kvmi_msg_reply(ikvm, msg, -KVM_EPERM, NULL, 0);
> +		goto out;
> +	}
> +
> +	if (msg_vcpu[msg->id])
> +		err = kvmi_msg_queue_to_vcpu(ikvm, msg);
> +	else
> +		err = msg_vm[msg->id](ikvm, msg, ikvm->msg_buf);
> +
> +out:
> +	if (err)
> +		kvm_err("%s: id:%u (%s) err:%d\n", __func__, msg->id,
> +			id2str(msg->id), err);
> +
> +	return (err == 0);
> +}
> +
> +static bool handle_unsupported_msg(struct kvmi *ikvm,
> +				   const struct kvmi_msg_hdr *msg)
> +{
> +	int err;
> +
> +	kvm_err("%s: %u\n", __func__, msg->id);
> +
> +	err = consume_sock_bytes(ikvm, msg->size);
> +
> +	if (!err)
> +		err = kvmi_msg_reply(ikvm, msg, -KVM_ENOSYS, NULL, 0);
> +
> +	return (err == 0);
> +}
> +
> +static bool kvmi_msg_dispatch(struct kvmi *ikvm)
> +{
> +	struct kvmi_msg_hdr msg;
> +	int err;
> +
> +	err = kvmi_sock_read(ikvm, &msg, sizeof(msg));
> +
> +	if (err) {
> +		kvm_err("%s: can't read\n", __func__);
> +		return false;
> +	}
> +
> +	trace_kvmi_msg_dispatch(msg.id, msg.size);
> +
> +	kvm_debug("%s: id:%u (%s) size:%u\n", __func__, msg.id,
> +		  id2str(msg.id), msg.size);
> +
> +	if (msg.id == KVMI_EVENT_REPLY)
> +		return kvmi_msg_dispatch_reply(ikvm, &msg);
> +
> +	if (msg.id >= ARRAY_SIZE(msg_bytes)
> +	    || (!msg_vm[msg.id] && !msg_vcpu[msg.id]))
> +		return handle_unsupported_msg(ikvm, &msg);
> +
> +	return kvmi_msg_dispatch_cmd(ikvm, &msg);
> +}
> +
> +static void kvmi_sock_close(struct kvmi *ikvm)
> +{
> +	kvm_info("%s\n", __func__);
> +
> +	write_lock(&ikvm->sock_lock);
> +
> +	if (ikvm->sock) {
> +		kvm_info("Release the socket\n");
> +		sockfd_put(ikvm->sock);
> +
> +		ikvm->sock = NULL;
> +	}
> +
> +	write_unlock(&ikvm->sock_lock);
> +}
> +
> +bool kvmi_msg_process(struct kvmi *ikvm)
> +{
> +	if (!kvmi_msg_dispatch(ikvm)) {
> +		kvmi_sock_close(ikvm);
> +		return false;
> +	}
> +	return true;
> +}
> +
> +static void kvmi_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev,
> +			     u32 ev_id)
> +{
> +	memset(ev, 0, sizeof(*ev));
> +	ev->vcpu = vcpu->vcpu_id;
> +	ev->event = ev_id;
> +	kvm_arch_vcpu_ioctl_get_regs(vcpu, &ev->regs);
> +	kvm_arch_vcpu_ioctl_get_sregs(vcpu, &ev->sregs);
> +	ev->mode = kvmi_vcpu_mode(vcpu, &ev->sregs);
> +	kvmi_get_msrs(vcpu, ev);
> +}
> +
> +static bool kvmi_send_event(struct kvm_vcpu *vcpu, u32 ev_id,
> +			    void *ev,  size_t ev_size,
> +			    void *rpl, size_t rpl_size)
> +{
> +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> +	struct kvmi_event common;
> +	struct kvmi_msg_hdr h;
> +	struct kvec vec[3] = {
> +		{.iov_base = &h,      .iov_len = sizeof(h)     },
> +		{.iov_base = &common, .iov_len = sizeof(common)},
> +		{.iov_base = ev,      .iov_len = ev_size       },
> +	};
> +	size_t msg_size = sizeof(h) + sizeof(common) + ev_size;
> +	size_t n = ev_size ? ARRAY_SIZE(vec) : ARRAY_SIZE(vec)-1;
> +
> +	memset(&h, 0, sizeof(h));
> +	h.id = KVMI_EVENT;
> +	h.seq = new_seq();
> +	h.size = msg_size - sizeof(h);
> +
> +	kvmi_setup_event(vcpu, &common, ev_id);
> +
> +	ivcpu->ev_rpl_ptr = rpl;
> +	ivcpu->ev_rpl_size = rpl_size;
> +	ivcpu->ev_seq = h.seq;
> +	ivcpu->ev_rpl_received = -1;
> +	WRITE_ONCE(ivcpu->ev_rpl_waiting, true);
> +	/* kvmi_vcpu_waiting_for_reply() */
> +	smp_wmb();
> +
> +	trace_kvmi_send_event(ev_id);
> +
> +	kvm_debug("%s: %-11s(seq:%u) size:%lu vcpu:%d\n",
> +		  __func__, event_str(ev_id), h.seq, ev_size, vcpu->vcpu_id);
> +
> +	if (kvmi_sock_write(IKVM(vcpu->kvm), vec, n, msg_size) == 0)
> +		kvmi_handle_request(vcpu);
> +
> +	kvm_debug("%s: reply for %-11s(seq:%u) size:%lu vcpu:%d\n",
> +		  __func__, event_str(ev_id), h.seq, rpl_size, vcpu->vcpu_id);
> +
> +	return (ivcpu->ev_rpl_received >= 0);
> +}
> +
> +u32 kvmi_msg_send_cr(struct kvm_vcpu *vcpu, u32 cr, u64 old_value,
> +		     u64 new_value, u64 *ret_value)
> +{
> +	struct kvmi_event_cr e;
> +	struct kvmi_event_cr_reply r;
> +
> +	memset(&e, 0, sizeof(e));
> +	e.cr = cr;
> +	e.old_value = old_value;
> +	e.new_value = new_value;
> +
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_CR, &e, sizeof(e),
> +				&r, sizeof(r))) {
> +		*ret_value = new_value;
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +	}
> +
> +	*ret_value = r.new_val;
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_msr(struct kvm_vcpu *vcpu, u32 msr, u64 old_value,
> +		      u64 new_value, u64 *ret_value)
> +{
> +	struct kvmi_event_msr e;
> +	struct kvmi_event_msr_reply r;
> +
> +	memset(&e, 0, sizeof(e));
> +	e.msr = msr;
> +	e.old_value = old_value;
> +	e.new_value = new_value;
> +
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_MSR, &e, sizeof(e),
> +				&r, sizeof(r))) {
> +		*ret_value = new_value;
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +	}
> +
> +	*ret_value = r.new_val;
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_xsetbv(struct kvm_vcpu *vcpu)
> +{
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_XSETBV, NULL, 0, NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_bp(struct kvm_vcpu *vcpu, u64 gpa)
> +{
> +	struct kvmi_event_breakpoint e;
> +
> +	memset(&e, 0, sizeof(e));
> +	e.gpa = gpa;
> +
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_BREAKPOINT,
> +				&e, sizeof(e), NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_hypercall(struct kvm_vcpu *vcpu)
> +{
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_HYPERCALL, NULL, 0, NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +bool kvmi_msg_send_pf(struct kvm_vcpu *vcpu, u64 gpa, u64 gva, u32 mode,
> +		      u32 *action, bool *trap_access, u8 *ctx_data,
> +		      u32 *ctx_size)
> +{
> +	u32 max_ctx_size = *ctx_size;
> +	struct kvmi_event_page_fault e;
> +	struct kvmi_event_page_fault_reply r;
> +
> +	memset(&e, 0, sizeof(e));
> +	e.gpa = gpa;
> +	e.gva = gva;
> +	e.mode = mode;
> +
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_PAGE_FAULT, &e, sizeof(e),
> +				&r, sizeof(r)))
> +		return false;
> +
> +	*action = IVCPU(vcpu)->ev_rpl.action;
> +	*trap_access = r.trap_access;
> +	*ctx_size = 0;
> +
> +	if (r.ctx_size <= max_ctx_size) {
> +		*ctx_size = min_t(u32, r.ctx_size, sizeof(r.ctx_data));
> +		if (*ctx_size)
> +			memcpy(ctx_data, r.ctx_data, *ctx_size);
> +	} else {
> +		kvm_err("%s: ctx_size (recv:%u max:%u)\n", __func__,
> +			r.ctx_size, *ctx_size);
> +		/*
> +		 * TODO: This is an ABI error.
> +		 * We should shutdown the socket?
> +		 */
> +	}
> +
> +	return true;
> +}
> +
> +u32 kvmi_msg_send_trap(struct kvm_vcpu *vcpu, u32 vector, u32 type,
> +		       u32 error_code, u64 cr2)
> +{
> +	struct kvmi_event_trap e;
> +
> +	memset(&e, 0, sizeof(e));
> +	e.vector = vector;
> +	e.type = type;
> +	e.error_code = error_code;
> +	e.cr2 = cr2;
> +
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_TRAP, &e, sizeof(e), NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_descriptor(struct kvm_vcpu *vcpu, u32 info,
> +			     u64 exit_qualification, u8 descriptor, u8 write)
> +{
> +	struct kvmi_event_descriptor e;
> +
> +	memset(&e, 0, sizeof(e));
> +	e.descriptor = descriptor;
> +	e.write = write;
> +
> +	if (cpu_has_vmx()) {
> +		e.arch.vmx.instr_info = info;
> +		e.arch.vmx.exit_qualification = exit_qualification;
> +	} else {
> +		e.arch.svm.exit_info = info;
> +	}
> +
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_DESCRIPTOR,
> +				&e, sizeof(e), NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_create_vcpu(struct kvm_vcpu *vcpu)
> +{
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_CREATE_VCPU, NULL, 0, NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> +
> +u32 kvmi_msg_send_pause_vcpu(struct kvm_vcpu *vcpu)
> +{
> +	if (!kvmi_send_event(vcpu, KVMI_EVENT_PAUSE_VCPU, NULL, 0, NULL, 0))
> +		return KVMI_EVENT_ACTION_CONTINUE;
> +
> +	return IVCPU(vcpu)->ev_rpl.action;
> +}
> 


Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
