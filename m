Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EB5CC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0903820679
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:21:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0903820679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F69E6B0003; Mon, 12 Aug 2019 16:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A8636B0005; Mon, 12 Aug 2019 16:21:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 796696B0006; Mon, 12 Aug 2019 16:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 51E6E6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:21:17 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 064D62DF0
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:21:17 +0000 (UTC)
X-FDA: 75814895394.22.cast54_282e5271fe72f
X-HE-Tag: cast54_282e5271fe72f
X-Filterd-Recvd-Size: 12820
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:21:15 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 13:20:31 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="204848918"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by fmsmga002.fm.intel.com with ESMTP; 12 Aug 2019 13:20:30 -0700
Date: Mon, 12 Aug 2019 13:20:30 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?Q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
Message-ID: <20190812202030.GB1437@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-2-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190809160047.8319-2-alazar@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 06:59:16PM +0300, Adalbert Laz=C4=83r wrote:
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index 72fa955f4a15..f70a6a1b6814 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -96,6 +96,13 @@ config KVM_MMU_AUDIT
>  	 This option adds a R/W kVM module parameter 'mmu_audit', which allow=
s
>  	 auditing of KVM MMU events at runtime.
> =20
> +config KVM_INTROSPECTION
> +	bool "VM Introspection"
> +	depends on KVM && (KVM_INTEL || KVM_AMD)
> +	help
> +	 This option enables functions to control the execution of VM-s, quer=
y
> +	 the state of the vCPU-s (GPR-s, MSR-s etc.).

This does a lot more than enable functions, it allows userspace to do all
of these things *while the VM is running*.  Everything above can already
be done by userspace.

The "-s" syntax is difficult to read and unnecessary, e.g. at first I
thought VM-s was referring to a new subsystem or feature introduced by
introspection.  VMs, vCPUs, GPRs, MSRs, etc...

> +
>  # OK, it's a little counter-intuitive to do this, but it puts it neatl=
y under
>  # the virtualization menu.
>  source "drivers/vhost/Kconfig"
> diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
> index 31ecf7a76d5a..312597bd47c7 100644
> --- a/arch/x86/kvm/Makefile
> +++ b/arch/x86/kvm/Makefile
> @@ -7,6 +7,7 @@ KVM :=3D ../../../virt/kvm
>  kvm-y			+=3D $(KVM)/kvm_main.o $(KVM)/coalesced_mmio.o \
>  				$(KVM)/eventfd.o $(KVM)/irqchip.o $(KVM)/vfio.o
>  kvm-$(CONFIG_KVM_ASYNC_PF)	+=3D $(KVM)/async_pf.o
> +kvm-$(CONFIG_KVM_INTROSPECTION) +=3D $(KVM)/kvmi.o
> =20
>  kvm-y			+=3D x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
>  			   i8254.o ioapic.o irq_comm.o cpuid.o pmu.o mtrr.o \
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index c38cc5eb7e73..582b0187f5a4 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -455,6 +455,10 @@ struct kvm {
>  	struct srcu_struct srcu;
>  	struct srcu_struct irq_srcu;
>  	pid_t userspace_pid;
> +
> +	struct completion kvmi_completed;
> +	refcount_t kvmi_ref;

The refcounting approach seems a bit backwards, and AFAICT is driven by
implementing unhook via a message, which also seems backwards.  I assume
hook and unhook are relatively rare events and not performance critical,
so make those the restricted/slow flows, e.g. force userspace to quiesce
the VM by making unhook() mutually exclusive with every vcpu ioctl() and
maybe anything that takes kvm->lock.=20

Then kvmi_ioctl_unhook() can use thread_stop() and kvmi_recv() just needs
to check kthread_should_stop().

That way kvmi doesn't need to be refcounted since it's guaranteed to be
alive if the pointer is non-null.  Eliminating the refcounting will clean
up a lot of the code by eliminating calls to kvmi_{get,put}(), e.g.
wrappers like kvmi_breakpoint_event() just check vcpu->kvmi, or maybe
even get dropped altogether.

> +	void *kvmi;

Why is this a void*?  Just forward declare struct kvmi in kvmi.h.

IMO this should be 'struct kvm_introspection *introspection', similar to
'struct kvm_vcpu_arch arch' and 'struct kvm_vmx'.  Ditto for the vCPU
flavor.  Local variables could be kvmi+vcpui, kvm_i+vcpu_i, or maybe
a more long form if someone can come up with a good abbreviation?

Using 'ikvm' as the local variable name when everything else refers to
introspection as 'kvmi' is especially funky.

>  };
> =20
>  #define kvm_err(fmt, ...) \
> diff --git a/include/linux/kvmi.h b/include/linux/kvmi.h
> new file mode 100644
> index 000000000000..e36de3f9f3de
> --- /dev/null
> +++ b/include/linux/kvmi.h
> @@ -0,0 +1,23 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef __KVMI_H__
> +#define __KVMI_H__
> +
> +#define kvmi_is_present() IS_ENABLED(CONFIG_KVM_INTROSPECTION)

Peeking forward a few patches, introspection should have a module param.
The code is also inconsistent in its usage of kvmi_is_present() versus
#ifdef CONFIG_KVM_INTROSPECTION.

And maybe kvm_is_instrospection_enabled() so that the gating function has
a more descriptive name for first-time readers?

> +
> +#ifdef CONFIG_KVM_INTROSPECTION
> +
> +int kvmi_init(void);
> +void kvmi_uninit(void);
> +void kvmi_create_vm(struct kvm *kvm);
> +void kvmi_destroy_vm(struct kvm *kvm);
> +
> +#else
> +
> +static inline int kvmi_init(void) { return 0; }
> +static inline void kvmi_uninit(void) { }
> +static inline void kvmi_create_vm(struct kvm *kvm) { }
> +static inline void kvmi_destroy_vm(struct kvm *kvm) { }
> +
> +#endif /* CONFIG_KVM_INTROSPECTION */
> +
> +#endif
> diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
> new file mode 100644
> index 000000000000..dbf63ad0862f
> --- /dev/null
> +++ b/include/uapi/linux/kvmi.h
> @@ -0,0 +1,68 @@
> +/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
> +#ifndef _UAPI__LINUX_KVMI_H
> +#define _UAPI__LINUX_KVMI_H
> +
> +/*
> + * KVMI structures and definitions
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +
> +#define KVMI_VERSION 0x00000001
> +
> +enum {
> +	KVMI_EVENT_REPLY           =3D 0,
> +	KVMI_EVENT                 =3D 1,
> +
> +	KVMI_FIRST_COMMAND         =3D 2,
> +
> +	KVMI_GET_VERSION           =3D 2,
> +	KVMI_CHECK_COMMAND         =3D 3,
> +	KVMI_CHECK_EVENT           =3D 4,
> +	KVMI_GET_GUEST_INFO        =3D 5,
> +	KVMI_GET_VCPU_INFO         =3D 6,
> +	KVMI_PAUSE_VCPU            =3D 7,
> +	KVMI_CONTROL_VM_EVENTS     =3D 8,
> +	KVMI_CONTROL_EVENTS        =3D 9,
> +	KVMI_CONTROL_CR            =3D 10,
> +	KVMI_CONTROL_MSR           =3D 11,
> +	KVMI_CONTROL_VE            =3D 12,
> +	KVMI_GET_REGISTERS         =3D 13,
> +	KVMI_SET_REGISTERS         =3D 14,
> +	KVMI_GET_CPUID             =3D 15,
> +	KVMI_GET_XSAVE             =3D 16,
> +	KVMI_READ_PHYSICAL         =3D 17,
> +	KVMI_WRITE_PHYSICAL        =3D 18,
> +	KVMI_INJECT_EXCEPTION      =3D 19,
> +	KVMI_GET_PAGE_ACCESS       =3D 20,
> +	KVMI_SET_PAGE_ACCESS       =3D 21,
> +	KVMI_GET_MAP_TOKEN         =3D 22,
> +	KVMI_GET_MTRR_TYPE         =3D 23,
> +	KVMI_CONTROL_SPP           =3D 24,
> +	KVMI_GET_PAGE_WRITE_BITMAP =3D 25,
> +	KVMI_SET_PAGE_WRITE_BITMAP =3D 26,
> +	KVMI_CONTROL_CMD_RESPONSE  =3D 27,

Each command should be introduced along with the patch that adds the
associated functionality.

It'd be helpful to incorporate the scope of the command in the name,
e.g. VM vs. vCPU.

Why are VM and vCPU commands smushed together?

> +
> +	KVMI_NEXT_AVAILABLE_COMMAND,

Why not KVMI_NR_COMMANDS or KVM_NUM_COMMANDS?  At least be consistent
between COMMANDS and EVENTS below.

> +
> +};
> +
> +enum {
> +	KVMI_EVENT_UNHOOK      =3D 0,
> +	KVMI_EVENT_CR	       =3D 1,
> +	KVMI_EVENT_MSR	       =3D 2,
> +	KVMI_EVENT_XSETBV      =3D 3,
> +	KVMI_EVENT_BREAKPOINT  =3D 4,
> +	KVMI_EVENT_HYPERCALL   =3D 5,
> +	KVMI_EVENT_PF	       =3D 6,
> +	KVMI_EVENT_TRAP	       =3D 7,
> +	KVMI_EVENT_DESCRIPTOR  =3D 8,
> +	KVMI_EVENT_CREATE_VCPU =3D 9,
> +	KVMI_EVENT_PAUSE_VCPU  =3D 10,
> +	KVMI_EVENT_SINGLESTEP  =3D 11,
> +
> +	KVMI_NUM_EVENTS
> +};
> +
> +#endif /* _UAPI__LINUX_KVMI_H */
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 585845203db8..90e432d225ab 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -51,6 +51,7 @@
>  #include <linux/slab.h>
>  #include <linux/sort.h>
>  #include <linux/bsearch.h>
> +#include <linux/kvmi.h>
> =20
>  #include <asm/processor.h>
>  #include <asm/io.h>
> @@ -680,6 +681,8 @@ static struct kvm *kvm_create_vm(unsigned long type=
)
>  	if (r)
>  		goto out_err;
> =20
> +	kvmi_create_vm(kvm);
> +
>  	spin_lock(&kvm_lock);
>  	list_add(&kvm->vm_list, &vm_list);
>  	spin_unlock(&kvm_lock);
> @@ -725,6 +728,7 @@ static void kvm_destroy_vm(struct kvm *kvm)
>  	int i;
>  	struct mm_struct *mm =3D kvm->mm;
> =20
> +	kvmi_destroy_vm(kvm);
>  	kvm_uevent_notify_change(KVM_EVENT_DESTROY_VM, kvm);
>  	kvm_destroy_vm_debugfs(kvm);
>  	kvm_arch_sync_events(kvm);
> @@ -1556,7 +1560,7 @@ static int hva_to_pfn_remapped(struct vm_area_str=
uct *vma,
>  	 * Whoever called remap_pfn_range is also going to call e.g.
>  	 * unmap_mapping_range before the underlying pages are freed,
>  	 * causing a call to our MMU notifier.
> -	 */=20
> +	 */

Spurious whitespace change.

>  	kvm_get_pfn(pfn);
> =20
>  	*p_pfn =3D pfn;
> @@ -4204,6 +4208,9 @@ int kvm_init(void *opaque, unsigned vcpu_size, un=
signed vcpu_align,
>  	r =3D kvm_vfio_ops_init();
>  	WARN_ON(r);
> =20
> +	r =3D kvmi_init();
> +	WARN_ON(r);

Leftover development/debugging crud.

> +
>  	return 0;
> =20
>  out_unreg:
> @@ -4229,6 +4236,7 @@ EXPORT_SYMBOL_GPL(kvm_init);
> =20
>  void kvm_exit(void)
>  {
> +	kvmi_uninit();
>  	debugfs_remove_recursive(kvm_debugfs_dir);
>  	misc_deregister(&kvm_dev);
>  	kmem_cache_destroy(kvm_vcpu_cache);
> diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
> new file mode 100644
> index 000000000000..20638743bd03
> --- /dev/null
> +++ b/virt/kvm/kvmi.c
> @@ -0,0 +1,64 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * KVM introspection
> + *
> + * Copyright (C) 2017-2019 Bitdefender S.R.L.
> + *
> + */
> +#include <uapi/linux/kvmi.h>
> +#include "kvmi_int.h"
> +
> +int kvmi_init(void)
> +{
> +	return 0;
> +}
> +
> +void kvmi_uninit(void)
> +{
> +}
> +
> +struct kvmi * __must_check kvmi_get(struct kvm *kvm)
> +{
> +	if (refcount_inc_not_zero(&kvm->kvmi_ref))
> +		return kvm->kvmi;
> +
> +	return NULL;
> +}
> +
> +static void kvmi_destroy(struct kvm *kvm)
> +{
> +}
> +
> +static void kvmi_release(struct kvm *kvm)
> +{
> +	kvmi_destroy(kvm);
> +
> +	complete(&kvm->kvmi_completed);
> +}
> +
> +/* This function may be called from atomic context and must not sleep =
*/
> +void kvmi_put(struct kvm *kvm)
> +{
> +	if (refcount_dec_and_test(&kvm->kvmi_ref))
> +		kvmi_release(kvm);
> +}
> +
> +void kvmi_create_vm(struct kvm *kvm)
> +{
> +	init_completion(&kvm->kvmi_completed);
> +	complete(&kvm->kvmi_completed);

Pretty sure you don't want to be calling complete() here.

> +}
> +
> +void kvmi_destroy_vm(struct kvm *kvm)
> +{
> +	struct kvmi *ikvm;
> +
> +	ikvm =3D kvmi_get(kvm);
> +	if (!ikvm)
> +		return;
> +
> +	kvmi_put(kvm);
> +
> +	/* wait for introspection resources to be released */
> +	wait_for_completion_killable(&kvm->kvmi_completed);
> +}
> diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
> new file mode 100644
> index 000000000000..ac23ad6fc4df
> --- /dev/null
> +++ b/virt/kvm/kvmi_int.h
> @@ -0,0 +1,12 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef __KVMI_INT_H__
> +#define __KVMI_INT_H__
> +
> +#include <linux/kvm_host.h>
> +
> +#define IKVM(kvm) ((struct kvmi *)((kvm)->kvmi))
> +
> +struct kvmi {
> +};
> +
> +#endif

