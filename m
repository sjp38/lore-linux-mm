Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C427F6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:11:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l99so10822131wrc.18
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 06:11:21 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id l11si18115257wrh.161.2017.12.22.06.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 06:11:20 -0800 (PST)
Received: from smtp02.buh.bitdefender.net (smtp.bitdefender.biz [10.17.80.76])
	by mx-sr.buh.bitdefender.com (Postfix) with ESMTP id 107C37FC7A
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 16:11:19 +0200 (EET)
From: Adalbert LazA?r <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
In-Reply-To: <3b9dd83a-5e13-97b5-3d87-14de288e88d8@oracle.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
	<20171218190642.7790-9-alazar@bitdefender.com>
	<3b9dd83a-5e13-97b5-3d87-14de288e88d8@oracle.com>
Date: Fri, 22 Dec 2017 16:11:40 +0200
Message-ID: <1513951900.E02F46f7.12019@host>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Patrick Colp <patrick.colp@oracle.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>, =?UTF-8?b?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>, Mircea =?iso-8859-1?q?C=EErjaliu?= <mcirjaliu@bitdefender.com>, Marian Rotariu <mrotariu@bitdefender.com>

We've made changes in all the places pointed by you, but read below.
Thanks again,
Adalbert

On Fri, 22 Dec 2017 02:34:45 -0500, Patrick Colp <patrick.colp@oracle.com> wrote:
> On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> > From: Adalbert Lazar <alazar@bitdefender.com>
> > 
> > This subsystem is split into three source files:
> >   - kvmi_msg.c - ABI and socket related functions
> >   - kvmi_mem.c - handle map/unmap requests from the introspector
> >   - kvmi.c - all the other
> > 
> > The new data used by this subsystem is attached to the 'kvm' and
> > 'kvm_vcpu' structures as opaque pointers (to 'kvmi' and 'kvmi_vcpu'
> > structures).
> > 
> > Besides the KVMI system, this patch exports the
> > kvm_vcpu_ioctl_x86_get_xsave() and the mm_find_pmd() functions,
> > adds a new vCPU request (KVM_REQ_INTROSPECTION) and a new VM ioctl
> > (KVM_INTROSPECTION) used to pass the connection file handle from QEMU.
> > 
> > Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
> > Signed-off-by: Adalbert LazA?r <alazar@bitdefender.com>
> > Signed-off-by: NicuE?or CA(R)E?u <ncitu@bitdefender.com>
> > Signed-off-by: Mircea CA(R)rjaliu <mcirjaliu@bitdefender.com>
> > Signed-off-by: Marian Rotariu <mrotariu@bitdefender.com>
> > ---
> >   arch/x86/include/asm/kvm_host.h |    1 +
> >   arch/x86/kvm/Makefile           |    1 +
> >   arch/x86/kvm/x86.c              |    4 +-
> >   include/linux/kvm_host.h        |    4 +
> >   include/linux/kvmi.h            |   32 +
> >   include/linux/mm.h              |    3 +
> >   include/trace/events/kvmi.h     |  174 +++++
> >   include/uapi/linux/kvm.h        |    8 +
> >   mm/internal.h                   |    5 -
> >   virt/kvm/kvmi.c                 | 1410 +++++++++++++++++++++++++++++++++++++++
> >   virt/kvm/kvmi_int.h             |  121 ++++
> >   virt/kvm/kvmi_mem.c             |  730 ++++++++++++++++++++
> >   virt/kvm/kvmi_msg.c             | 1134 +++++++++++++++++++++++++++++++
> >   13 files changed, 3620 insertions(+), 7 deletions(-)
> >   create mode 100644 include/linux/kvmi.h
> >   create mode 100644 include/trace/events/kvmi.h
> >   create mode 100644 virt/kvm/kvmi.c
> >   create mode 100644 virt/kvm/kvmi_int.h
> >   create mode 100644 virt/kvm/kvmi_mem.c
> >   create mode 100644 virt/kvm/kvmi_msg.c
> > 
> > +int kvmi_set_mem_access(struct kvm *kvm, u64 gpa, u8 access)
> > +{
> > +	struct kvmi_mem_access *m;
> > +	struct kvmi_mem_access *__m;
> > +	struct kvmi *ikvm = IKVM(kvm);
> > +	gfn_t gfn = gpa_to_gfn(gpa);
> > +
> > +	if (kvm_is_error_hva(gfn_to_hva_safe(kvm, gfn)))
> > +		kvm_err("Invalid gpa %llx (or memslot not available yet)", gpa);
> 
> If there's an error, should this not return or something instead of 
> continuing as if nothing is wrong?

It was a debug message masqueraded as an error message to be logged in dmesg.
The page will be tracked when the memslot becomes available.

> > +static bool alloc_kvmi(struct kvm *kvm)
> > +{
> > +	bool done;
> > +
> > +	mutex_lock(&kvm->lock);
> > +	done = (
> > +		maybe_delayed_init() == 0    &&
> > +		IKVM(kvm)            == NULL &&
> > +		__alloc_kvmi(kvm)    == true
> > +	);
> > +	mutex_unlock(&kvm->lock);
> > +
> > +	return done;
> > +}
> > +
> > +static void alloc_all_kvmi_vcpu(struct kvm *kvm)
> > +{
> > +	struct kvm_vcpu *vcpu;
> > +	int i;
> > +
> > +	mutex_lock(&kvm->lock);
> > +	kvm_for_each_vcpu(i, vcpu, kvm)
> > +		if (!IKVM(vcpu))
> > +			__alloc_vcpu_kvmi(vcpu);
> > +	mutex_unlock(&kvm->lock);
> > +}
> > +
> > +static bool setup_socket(struct kvm *kvm, struct kvm_introspection *qemu)
> > +{
> > +	struct kvmi *ikvm = IKVM(kvm);
> > +
> > +	if (is_introspected(ikvm)) {
> > +		kvm_err("Guest already introspected\n");
> > +		return false;
> > +	}
> > +
> > +	if (!kvmi_msg_init(ikvm, qemu->fd))
> > +		return false;
> 
> kvmi_msg_init assumes that ikvm is not NULL -- it makes no check and 
> then does "WRITE_ONCE(ikvm->sock, sock)". is_introspected() does check 
> if ikvm is NULL, but if it is, it returns false, which would still end 
> up here. There should be a check that ikvm is not NULL before this if 
> statement.

setup_socket() is called only when 'ikvm' is not NULL.

is_introspected() checks 'ikvm' because it is called from other contexts.
The real check is ikvm->sock (to see if the 'command channel' is 'active').

> > +
> > +	ikvm->cmd_allow_mask = -1; /* TODO: qemu->commands; */
> > +	ikvm->event_allow_mask = -1; /* TODO: qemu->events; */
> > +
> > +	alloc_all_kvmi_vcpu(kvm);
> > +	queue_work(wq, &ikvm->work);
> > +
> > +	return true;
> > +}
> > +
> > +/*
> > + * When called from outside a page fault handler, this call should
> > + * return ~0ull
> > + */
> > +static u64 kvmi_mmu_fault_gla(struct kvm_vcpu *vcpu, gpa_t gpa)
> > +{
> > +	u64 gla;
> > +	u64 gla_val;
> > +	u64 v;
> > +
> > +	if (!vcpu->arch.gpa_available)
> > +		return ~0ull;
> > +
> > +	gla = kvm_mmu_fault_gla(vcpu);
> > +	if (gla == ~0ull)
> > +		return gla;
> > +	gla_val = gla;
> > +
> > +	/* Handle the potential overflow by returning ~0ull */
> > +	if (vcpu->arch.gpa_val > gpa) {
> > +		v = vcpu->arch.gpa_val - gpa;
> > +		if (v > gla)
> > +			gla = ~0ull;
> > +		else
> > +			gla -= v;
> > +	} else {
> > +		v = gpa - vcpu->arch.gpa_val;
> > +		if (v > (U64_MAX - gla))
> > +			gla = ~0ull;
> > +		else
> > +			gla += v;
> > +	}
> > +
> > +	return gla;
> > +}
> > +
> > +static bool kvmi_track_preread(struct kvm_vcpu *vcpu, gpa_t gpa,
> > +			       u8 *new,
> > +			       int bytes,
> > +			       struct kvm_page_track_notifier_node *node,
> > +			       bool *data_ready)
> > +{
> > +	u64 gla;
> > +	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
> > +	bool ret = true;
> > +
> > +	if (kvm_mmu_nested_guest_page_fault(vcpu))
> > +		return ret;
> > +	gla = kvmi_mmu_fault_gla(vcpu, gpa);
> > +	ret = kvmi_page_fault_event(vcpu, gpa, gla, KVMI_PAGE_ACCESS_R);
> 
> Should you not check the value of ret here before proceeding?
> 

Indeed. These 'track' functions are new additions and aren't integrated
well with kvmi_page_fault_event(). We'll change this. The code is ugly
but 'safe' (ctx_size will be non-zero only with ret == true).

> > +	if (ivcpu && ivcpu->ctx_size > 0) {
> > +		int s = min_t(int, bytes, ivcpu->ctx_size);
> > +
> > +		memcpy(new, ivcpu->ctx_data, s);
> > +		ivcpu->ctx_size = 0;
> > +
> > +		if (*data_ready)
> > +			kvm_err("Override custom data");
> > +
> > +		*data_ready = true;
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +bool kvmi_hook(struct kvm *kvm, struct kvm_introspection *qemu)
> > +{
> > +	kvm_info("Hooking vm with fd: %d\n", qemu->fd);
> > +
> > +	kvm_page_track_register_notifier(kvm, &kptn_node);
> > +
> > +	return (alloc_kvmi(kvm) && setup_socket(kvm, qemu));
> 
> Is this safe? It could return false if the alloc fails (in which case 
> the caller has to do nothing) or if setting up the socket fails (in 
> which case the caller needs to free the allocated kvmi).
>

If the socket fails for any reason (eg. the introspection tool is
stopped == socket closed) 'the plan' is to signal QEMU to reconnect
(and call kvmi_hook() again) or else let the introspected VM continue (and
try to reconnect asynchronously).

I see that kvm_page_track_register_notifier() should not be called more
than once.

Maybe we should rename this to kvmi_rehook() or kvmi_reconnect().

> > +bool kvmi_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva)
> > +{
> > +	u32 action;
> > +	u64 gpa;
> > +
> > +	if (!is_event_enabled(vcpu->kvm, KVMI_EVENT_BREAKPOINT))
> > +		/* qemu will automatically reinject the breakpoint */
> > +		return false;
> > +
> > +	gpa = kvm_mmu_gva_to_gpa_read(vcpu, gva, NULL);
> > +
> > +	if (gpa == UNMAPPED_GVA)
> > +		kvm_err("%s: invalid gva: %llx", __func__, gva);
> 
> If the gpa is unmapped, shouldn't it return false rather than proceeding?
> 

This was just a debug message. I'm not sure if is possible for 'gpa'
to be unmapped. Even so, the introspection tool should still be notified.

> > +
> > +	action = kvmi_msg_send_bp(vcpu, gpa);
> > +
> > +	switch (action) {
> > +	case KVMI_EVENT_ACTION_CONTINUE:
> > +		break;
> > +	case KVMI_EVENT_ACTION_RETRY:
> > +		/* rip was most likely adjusted past the INT 3 instruction */
> > +		return true;
> > +	default:
> > +		handle_common_event_actions(vcpu, action);
> > +	}
> > +
> > +	/* qemu will automatically reinject the breakpoint */
> > +	return false;
> > +}
> > +EXPORT_SYMBOL(kvmi_breakpoint_event);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
