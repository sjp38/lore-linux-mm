Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id E8E3A6B0032
	for <linux-mm@kvack.org>; Sun,  1 Sep 2013 08:04:07 -0400 (EDT)
Date: Sun, 1 Sep 2013 15:04:00 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v9 04/13] KVM: PPC: reserve a capability and KVM device
 type for realmode VFIO
Message-ID: <20130901120400.GA10627@redhat.com>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
 <1377679070-3515-5-git-send-email-aik@ozlabs.ru>
 <20130901112729.GI22899@redhat.com>
 <5223276B.601@ozlabs.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5223276B.601@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: linuxppc-dev@lists.ozlabs.org, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 01, 2013 at 09:39:23PM +1000, Alexey Kardashevskiy wrote:
> On 09/01/2013 09:27 PM, Gleb Natapov wrote:
> > On Wed, Aug 28, 2013 at 06:37:41PM +1000, Alexey Kardashevskiy wrote:
> >> This reserves a capability number for upcoming support
> >> of VFIO-IOMMU DMA operations in real mode.
> >>
> >> This reserves a number for a new "SPAPR TCE IOMMU" KVM device
> >> which is going to manage lifetime of SPAPR TCE IOMMU object.
> >>
> >> This defines an attribute of the "SPAPR TCE IOMMU" KVM device
> >> which is going to be used for initialization.
> >>
> >> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> >>
> >> ---
> >> Changes:
> >> v9:
> >> * KVM ioctl is replaced with "SPAPR TCE IOMMU" KVM device type with
> >> KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE attribute
> >>
> >> 2013/08/15:
> >> * fixed mistype in comments
> >> * fixed commit message which says what uses ioctls 0xad and 0xae
> >>
> >> 2013/07/16:
> >> * changed the number
> >>
> >> 2013/07/11:
> >> * changed order in a file, added comment about a gap in ioctl number
> >> ---
> >>  arch/powerpc/include/uapi/asm/kvm.h | 8 ++++++++
> >>  include/uapi/linux/kvm.h            | 2 ++
> >>  2 files changed, 10 insertions(+)
> >>
> >> diff --git a/arch/powerpc/include/uapi/asm/kvm.h b/arch/powerpc/include/uapi/asm/kvm.h
> >> index 0fb1a6e..c1ae1e5 100644
> >> --- a/arch/powerpc/include/uapi/asm/kvm.h
> >> +++ b/arch/powerpc/include/uapi/asm/kvm.h
> >> @@ -511,4 +511,12 @@ struct kvm_get_htab_header {
> >>  #define  KVM_XICS_MASKED		(1ULL << 41)
> >>  #define  KVM_XICS_PENDING		(1ULL << 42)
> >>  
> >> +/* SPAPR TCE IOMMU device specification */
> >> +struct kvm_create_spapr_tce_iommu_linkage {
> >> +	__u64 liobn;
> >> +	__u32 fd;
> >> +	__u32 flags;
> >> +};
> >> +#define KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE	0
> >> +
> >>  #endif /* __LINUX_KVM_POWERPC_H */
> >> diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
> >> index 99c2533..9d20630 100644
> >> --- a/include/uapi/linux/kvm.h
> >> +++ b/include/uapi/linux/kvm.h
> >> @@ -668,6 +668,7 @@ struct kvm_ppc_smmu_info {
> >>  #define KVM_CAP_IRQ_XICS 92
> >>  #define KVM_CAP_ARM_EL1_32BIT 93
> >>  #define KVM_CAP_SPAPR_MULTITCE 94
> >> +#define KVM_CAP_SPAPR_TCE_IOMMU 95
> >>  
> > You do not need capability to check for a device support. Device API
> > supports checking for that with KVM_CREATE_DEVICE_TEST flag to
> > KVM_CREATE_DEVICE ioctl.
> 
> Hm. I copied my device from KVM_DEV_TYPE_XICS and there is a capability for
> it - KVM_CAP_IRQ_XICS. Do We not need both capabilities? Or XICS is special
> in some way but SPAPR TCE IOMMU is not? I am confused, sorry.
> 
> 
Looking at it KVM_CAP_IRQ_XICS/KVM_CAP_IRQ_MPIC are not used to detect
device existence, but to link a device to vcpu. KVM_CAP_IRQ_MPIC was
introduced separately from MPIC device code.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
