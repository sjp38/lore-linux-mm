Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3F23F6B0032
	for <linux-mm@kvack.org>; Sun,  1 Sep 2013 07:39:31 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3673637pdj.1
        for <linux-mm@kvack.org>; Sun, 01 Sep 2013 04:39:30 -0700 (PDT)
Message-ID: <5223276B.601@ozlabs.ru>
Date: Sun, 01 Sep 2013 21:39:23 +1000
From: Alexey Kardashevskiy <aik@ozlabs.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v9 04/13] KVM: PPC: reserve a capability and KVM device
 type for realmode VFIO
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru> <1377679070-3515-5-git-send-email-aik@ozlabs.ru> <20130901112729.GI22899@redhat.com>
In-Reply-To: <20130901112729.GI22899@redhat.com>
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

On 09/01/2013 09:27 PM, Gleb Natapov wrote:
> On Wed, Aug 28, 2013 at 06:37:41PM +1000, Alexey Kardashevskiy wrote:
>> This reserves a capability number for upcoming support
>> of VFIO-IOMMU DMA operations in real mode.
>>
>> This reserves a number for a new "SPAPR TCE IOMMU" KVM device
>> which is going to manage lifetime of SPAPR TCE IOMMU object.
>>
>> This defines an attribute of the "SPAPR TCE IOMMU" KVM device
>> which is going to be used for initialization.
>>
>> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
>>
>> ---
>> Changes:
>> v9:
>> * KVM ioctl is replaced with "SPAPR TCE IOMMU" KVM device type with
>> KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE attribute
>>
>> 2013/08/15:
>> * fixed mistype in comments
>> * fixed commit message which says what uses ioctls 0xad and 0xae
>>
>> 2013/07/16:
>> * changed the number
>>
>> 2013/07/11:
>> * changed order in a file, added comment about a gap in ioctl number
>> ---
>>  arch/powerpc/include/uapi/asm/kvm.h | 8 ++++++++
>>  include/uapi/linux/kvm.h            | 2 ++
>>  2 files changed, 10 insertions(+)
>>
>> diff --git a/arch/powerpc/include/uapi/asm/kvm.h b/arch/powerpc/include/uapi/asm/kvm.h
>> index 0fb1a6e..c1ae1e5 100644
>> --- a/arch/powerpc/include/uapi/asm/kvm.h
>> +++ b/arch/powerpc/include/uapi/asm/kvm.h
>> @@ -511,4 +511,12 @@ struct kvm_get_htab_header {
>>  #define  KVM_XICS_MASKED		(1ULL << 41)
>>  #define  KVM_XICS_PENDING		(1ULL << 42)
>>  
>> +/* SPAPR TCE IOMMU device specification */
>> +struct kvm_create_spapr_tce_iommu_linkage {
>> +	__u64 liobn;
>> +	__u32 fd;
>> +	__u32 flags;
>> +};
>> +#define KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE	0
>> +
>>  #endif /* __LINUX_KVM_POWERPC_H */
>> diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
>> index 99c2533..9d20630 100644
>> --- a/include/uapi/linux/kvm.h
>> +++ b/include/uapi/linux/kvm.h
>> @@ -668,6 +668,7 @@ struct kvm_ppc_smmu_info {
>>  #define KVM_CAP_IRQ_XICS 92
>>  #define KVM_CAP_ARM_EL1_32BIT 93
>>  #define KVM_CAP_SPAPR_MULTITCE 94
>> +#define KVM_CAP_SPAPR_TCE_IOMMU 95
>>  
> You do not need capability to check for a device support. Device API
> supports checking for that with KVM_CREATE_DEVICE_TEST flag to
> KVM_CREATE_DEVICE ioctl.

Hm. I copied my device from KVM_DEV_TYPE_XICS and there is a capability for
it - KVM_CAP_IRQ_XICS. Do We not need both capabilities? Or XICS is special
in some way but SPAPR TCE IOMMU is not? I am confused, sorry.


> 
>>  #ifdef KVM_CAP_IRQ_ROUTING
>>  
>> @@ -843,6 +844,7 @@ struct kvm_device_attr {
>>  #define KVM_DEV_TYPE_FSL_MPIC_20	1
>>  #define KVM_DEV_TYPE_FSL_MPIC_42	2
>>  #define KVM_DEV_TYPE_XICS		3
>> +#define KVM_DEV_TYPE_SPAPR_TCE_IOMMU	4
>>  
>>  /*
>>   * ioctls for VM fds
>> -- 
>> 1.8.4.rc4
> 
> --
> 			Gleb.
> 


-- 
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
