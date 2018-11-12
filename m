Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 773C26B026E
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:08:51 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so5485758pgv.19
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 02:08:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u2si14360000pgo.544.2018.11.12.02.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 02:08:50 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wACA4Oip135230
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:08:49 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nq4xypq20-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:08:49 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 12 Nov 2018 10:08:47 -0000
Date: Mon, 12 Nov 2018 15:38:38 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: Re: [RFC PATCH v1 3/4] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Reply-To: bharata@linux.ibm.com
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-4-bharata@linux.ibm.com>
 <20181101104926.GF16399@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101104926.GF16399@350D>
Message-Id: <20181112100838.GG17399@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Thu, Nov 01, 2018 at 09:49:26PM +1100, Balbir Singh wrote:
> On Mon, Oct 22, 2018 at 10:48:36AM +0530, Bharata B Rao wrote:
> > H_SVM_INIT_START: Initiate securing a VM
> > H_SVM_INIT_DONE: Conclude securing a VM
> > 
> > During early guest init, these hcalls will be issued by UV.
> > As part of these hcalls, [un]register memslots with UV.
> > 
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> > ---
> >  arch/powerpc/include/asm/hvcall.h    |  4 ++-
> >  arch/powerpc/include/asm/kvm_host.h  |  1 +
> >  arch/powerpc/include/asm/ucall-api.h |  6 ++++
> >  arch/powerpc/kvm/book3s_hv.c         | 54 ++++++++++++++++++++++++++++
> >  4 files changed, 64 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
> > index 89e6b70c1857..6091276fef07 100644
> > --- a/arch/powerpc/include/asm/hvcall.h
> > +++ b/arch/powerpc/include/asm/hvcall.h
> > @@ -300,7 +300,9 @@
> >  #define H_INT_RESET             0x3D0
> >  #define H_SVM_PAGE_IN		0x3D4
> >  #define H_SVM_PAGE_OUT		0x3D8
> > -#define MAX_HCALL_OPCODE	H_SVM_PAGE_OUT
> > +#define H_SVM_INIT_START	0x3DC
> > +#define H_SVM_INIT_DONE		0x3E0
> > +#define MAX_HCALL_OPCODE	H_SVM_INIT_DONE
> >  
> >  /* H_VIOCTL functions */
> >  #define H_GET_VIOA_DUMP_SIZE	0x01
> > diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
> > index 194e6e0ff239..267f8c568bc3 100644
> > --- a/arch/powerpc/include/asm/kvm_host.h
> > +++ b/arch/powerpc/include/asm/kvm_host.h
> > @@ -292,6 +292,7 @@ struct kvm_arch {
> >  	struct dentry *debugfs_dir;
> >  	struct dentry *htab_dentry;
> >  	struct kvm_resize_hpt *resize_hpt; /* protected by kvm->lock */
> > +	bool svm_init_start; /* Indicates H_SVM_INIT_START has been called */
> >  #endif /* CONFIG_KVM_BOOK3S_HV_POSSIBLE */
> >  #ifdef CONFIG_KVM_BOOK3S_PR_POSSIBLE
> >  	struct mutex hpt_mutex;
> > diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
> > index 2c12f514f8ab..9ddfcf541211 100644
> > --- a/arch/powerpc/include/asm/ucall-api.h
> > +++ b/arch/powerpc/include/asm/ucall-api.h
> > @@ -17,4 +17,10 @@ static inline int uv_page_out(u64 lpid, u64 dw0, u64 dw1, u64 dw2, u64 dw3)
> >  	return U_SUCCESS;
> >  }
> >  
> > +static inline int uv_register_mem_slot(u64 lpid, u64 dw0, u64 dw1, u64 dw2,
> > +				       u64 dw3)
> > +{
> > +	return 0;
> > +}
> > +
> >  #endif	/* _ASM_POWERPC_UCALL_API_H */
> > diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
> > index 05084eb8aadd..47f366f634fd 100644
> > --- a/arch/powerpc/kvm/book3s_hv.c
> > +++ b/arch/powerpc/kvm/book3s_hv.c
> > @@ -819,6 +819,50 @@ static int kvmppc_get_yield_count(struct kvm_vcpu *vcpu)
> >  	return yield_count;
> >  }
> >  
> > +#ifdef CONFIG_PPC_SVM
> > +#include <asm/ucall-api.h>
> > +/*
> > + * TODO: Check if memslots related calls here need to be called
> > + * under any lock.
> > + */
> > +static unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> > +{
> > +	struct kvm_memslots *slots;
> > +	struct kvm_memory_slot *memslot;
> > +	int ret;
> > +
> > +	slots = kvm_memslots(kvm);
> > +	kvm_for_each_memslot(memslot, slots) {
> > +		ret = uv_register_mem_slot(kvm->arch.lpid,
> > +					   memslot->base_gfn << PAGE_SHIFT,
> > +					   memslot->npages * PAGE_SIZE,
> > +					   0, memslot->id);
> 
> For every memslot their is a corresponding registration in the ultravisor?
> Is there a corresponding teardown?

Yes, uv_unregister_mem_slot(), called during memory unplug time.

Regards,
Bharata.
