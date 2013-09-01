Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 767B76B0032
	for <linux-mm@kvack.org>; Sun,  1 Sep 2013 08:06:18 -0400 (EDT)
Date: Sun, 1 Sep 2013 15:06:09 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v9 12/13] KVM: PPC: Add support for IOMMU in-kernel
 handling
Message-ID: <20130901120609.GJ22899@redhat.com>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
 <1377679841-3822-1-git-send-email-aik@ozlabs.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377679841-3822-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: linuxppc-dev@lists.ozlabs.org, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 28, 2013 at 06:50:41PM +1000, Alexey Kardashevskiy wrote:
> This allows the host kernel to handle H_PUT_TCE, H_PUT_TCE_INDIRECT
> and H_STUFF_TCE requests targeted an IOMMU TCE table without passing
> them to user space which saves time on switching to user space and back.
> 
> Both real and virtual modes are supported. The kernel tries to
> handle a TCE request in the real mode, if fails it passes the request
> to the virtual mode to complete the operation. If it a virtual mode
> handler fails, the request is passed to user space.
> 
> The first user of this is VFIO on POWER. Trampolines to the VFIO external
> user API functions are required for this patch.
> 
> This adds a "SPAPR TCE IOMMU" KVM device to associate a logical bus
> number (LIOBN) with an VFIO IOMMU group fd and enable in-kernel handling
> of map/unmap requests. The device supports a single attribute which is
> a struct with LIOBN and IOMMU fd. When the attribute is set, the device
> establishes the connection between KVM and VFIO.
> 
> Tests show that this patch increases transmission speed from 220MB/s
> to 750..1020MB/s on 10Gb network (Chelsea CXGB3 10Gb ethernet card).
> 
> Signed-off-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> 
> ---
> 
> Changes:
> v9:
> * KVM_CAP_SPAPR_TCE_IOMMU ioctl to KVM replaced with "SPAPR TCE IOMMU"
> KVM device
> * release_spapr_tce_table() is not shared between different TCE types
> * reduced the patch size by moving VFIO external API
> trampolines to separate patche
> * moved documentation from Documentation/virtual/kvm/api.txt to
> Documentation/virtual/kvm/devices/spapr_tce_iommu.txt
> 
> v8:
> * fixed warnings from check_patch.pl
> 
> 2013/07/11:
> * removed multiple #ifdef IOMMU_API as IOMMU_API is always enabled
> for KVM_BOOK3S_64
> * kvmppc_gpa_to_hva_and_get also returns host phys address. Not much sense
> for this here but the next patch for hugepages support will use it more.
> 
> 2013/07/06:
> * added realmode arch_spin_lock to protect TCE table from races
> in real and virtual modes
> * POWERPC IOMMU API is changed to support real mode
> * iommu_take_ownership and iommu_release_ownership are protected by
> iommu_table's locks
> * VFIO external user API use rewritten
> * multiple small fixes
> 
> 2013/06/27:
> * tce_list page is referenced now in order to protect it from accident
> invalidation during H_PUT_TCE_INDIRECT execution
> * added use of the external user VFIO API
> 
> 2013/06/05:
> * changed capability number
> * changed ioctl number
> * update the doc article number
> 
> 2013/05/20:
> * removed get_user() from real mode handlers
> * kvm_vcpu_arch::tce_tmp usage extended. Now real mode handler puts there
> translated TCEs, tries realmode_get_page() on those and if it fails, it
> passes control over the virtual mode handler which tries to finish
> the request handling
> * kvmppc_lookup_pte() now does realmode_get_page() protected by BUSY bit
> on a page
> * The only reason to pass the request to user mode now is when the user mode
> did not register TCE table in the kernel, in all other cases the virtual mode
> handler is expected to do the job
> ---
>  .../virtual/kvm/devices/spapr_tce_iommu.txt        |  37 +++
>  arch/powerpc/include/asm/kvm_host.h                |   4 +
>  arch/powerpc/kvm/book3s_64_vio.c                   | 310 ++++++++++++++++++++-
>  arch/powerpc/kvm/book3s_64_vio_hv.c                | 122 ++++++++
>  arch/powerpc/kvm/powerpc.c                         |   1 +
>  include/linux/kvm_host.h                           |   1 +
>  virt/kvm/kvm_main.c                                |   5 +
>  7 files changed, 477 insertions(+), 3 deletions(-)
>  create mode 100644 Documentation/virtual/kvm/devices/spapr_tce_iommu.txt
> 
> diff --git a/Documentation/virtual/kvm/devices/spapr_tce_iommu.txt b/Documentation/virtual/kvm/devices/spapr_tce_iommu.txt
> new file mode 100644
> index 0000000..4bc8fc3
> --- /dev/null
> +++ b/Documentation/virtual/kvm/devices/spapr_tce_iommu.txt
> @@ -0,0 +1,37 @@
> +SPAPR TCE IOMMU device
> +
> +Capability: KVM_CAP_SPAPR_TCE_IOMMU
> +Architectures: powerpc
> +
> +Device type supported: KVM_DEV_TYPE_SPAPR_TCE_IOMMU
> +
> +Groups:
> +  KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE
> +  Attributes: single attribute with pair { LIOBN, IOMMU fd}
> +
> +This is completely made up device which provides API to link
> +logical bus number (LIOBN) and IOMMU group. The user space has
> +to create a new SPAPR TCE IOMMU device per a logical bus.
> +
Why not have one device that can handle multimple links?

> +LIOBN is a PCI bus identifier from PPC64-server (sPAPR) DMA hypercalls
> +(H_PUT_TCE, H_PUT_TCE_INDIRECT, H_STUFF_TCE).
> +IOMMU group is a minimal isolated device set which can be passed to
> +the user space via VFIO.
> +
> +Right after creation the device is in uninitlized state and requires
> +a KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE attribute to be set.
> +The attribute contains liobn, IOMMU fd and flags:
> +
> +struct kvm_create_spapr_tce_iommu_linkage {
> +	__u64 liobn;
> +	__u32 fd;
> +	__u32 flags;
> +};
> +
> +The user space creates the SPAPR TCE IOMMU device, obtains
> +an IOMMU fd via VFIO ABI and sets the attribute to the SPAPR TCE IOMMU
> +device. At the moment of setting the attribute, the SPAPR TCE IOMMU
> +device links LIOBN to IOMMU group and makes necessary steps
> +to make sure that VFIO group will not disappear before KVM destroys.
> +
> +The kernel advertises this feature via KVM_CAP_SPAPR_TCE_IOMMU capability.
[skip]

> +
> +static int kvmppc_spapr_tce_iommu_get_attr(struct kvm_device *dev,
> +		struct kvm_device_attr *attr)
> +{
> +	struct kvmppc_spapr_tce_table *tt = dev->private;
> +	void __user *argp = (void __user *) attr->addr;
> +
> +	switch (attr->group) {
> +	case KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE:
> +		if (!tt)
> +			return -EFAULT;
Does not look like correct error code to return here. EINVAL may be?

> +		if (copy_to_user(&tt->link, argp, sizeof(tt->link)))
> +			return -EFAULT;
> +		return 0;
> +	}
> +	return -ENXIO;
> +}
> +

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
