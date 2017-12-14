Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAD346B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 01:10:41 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v69so2616914wrb.3
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 22:10:41 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id j15si2838552wra.472.2017.12.13.22.10.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 22:10:40 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: Add kernel MMU notifier to manage IOTLB/DEVTLB
References: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
 <1513213366-22594-2-git-send-email-baolu.lu@linux.intel.com>
 <a98903c2-e67c-a0cc-3ad1-60b9aa4e4c93@huawei.com>
 <5A31F232.90901@linux.intel.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <e7462b54-9d3a-abfd-8df2-2db3780de78d@huawei.com>
Date: Thu, 14 Dec 2017 14:07:38 +0800
MIME-Version: 1.0
In-Reply-To: <5A31F232.90901@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lu Baolu <baolu.lu@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Alex
 Williamson <alex.williamson@redhat.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Vegard Nossum <vegard.nossum@oracle.com>, Andy Lutomirski <luto@kernel.org>, Huang Ying <ying.huang@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, "xieyisheng (A)" <xieyisheng1@huawei.com>

On 2017/12/14 11:38, Lu Baolu wrote:
> Hi,
> 
> On 12/14/2017 11:10 AM, Bob Liu wrote:
>> On 2017/12/14 9:02, Lu Baolu wrote:
>>>> From: Huang Ying <ying.huang@intel.com>
>>>>
>>>> Shared Virtual Memory (SVM) allows a kernel memory mapping to be
>>>> shared between CPU and and a device which requested a supervisor
>>>> PASID. Both devices and IOMMU units have TLBs that cache entries
>>>> from CPU's page tables. We need to get a chance to flush them at
>>>> the same time when we flush the CPU TLBs.
>>>>
>>>> We already have an existing MMU notifiers for userspace updates,
>>>> however we lack the same thing for kernel page table updates. To
>> Sorry, I didn't get which situation need this notification.
>> Could you please describe the full scenario?
> 
> Okay.
> 
> 1. When an SVM capable driver calls intel_svm_bind_mm() with
>     SVM_FLAG_SUPERVISOR_MODE set in the @flags, the kernel
>     memory page mappings will be shared between CPUs and
>     the DMA remapping agent (a.k.a. IOMMU). The page table
>     entries will also be cached in both IOTLB (located in IOMMU)
>     and the DEVTLB (located in device).
> 

But who/what kind of real device has the requirement to access a kernel VA?
Looks like SVM_FLAG_SUPERVISOR_MODE is used by nobody?

Cheers,
Liubo

> 2. When vmalloc/vfree interfaces are called, the page mappings
>     for kernel memory might get changed. And current code calls
>     flush_tlb_kernel_range() to flush CPU TLBs only. The IOTLB or
>     DevTLB will be stale compared to that on the cpu for kernel
>     mappings.
> 
> We need a kernel mmu notification to flush TLBs in IOMMU and
> devices as well.
> 
> Best regards,
> Lu Baolu
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
