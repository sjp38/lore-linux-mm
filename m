Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8616B6F0F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:14:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bg5-v6so2367449plb.20
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:14:44 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 17-v6si7471385pgl.166.2018.09.04.12.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 12:14:43 -0700 (PDT)
Date: Tue, 4 Sep 2018 12:14:25 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [RFC][PATCH 5/5] [PATCH 5/5] kvm-ept-idle: enable module
Message-ID: <20180904191424.GC5869@linux.intel.com>
References: <20180901112818.126790961@intel.com>
 <20180901124811.703808090@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180901124811.703808090@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat, Sep 01, 2018 at 07:28:23PM +0800, Fengguang Wu wrote:
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  arch/x86/kvm/Kconfig  | 11 +++++++++++
>  arch/x86/kvm/Makefile |  4 ++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index 1bbec387d289..4c6dec47fac6 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -96,6 +96,17 @@ config KVM_MMU_AUDIT
>  	 This option adds a R/W kVM module parameter 'mmu_audit', which allows
>  	 auditing of KVM MMU events at runtime.
>  
> +config KVM_EPT_IDLE
> +	tristate "KVM EPT idle page tracking"

KVM_MMU_IDLE_INTEL might be a more user friendly name, I doubt that
all Kconfig users would immediately associate EPT with Intel's two
dimensional paging.  And it meshes nicely with KVM_MMU_IDLE as a base
name if we ever want to move common functionality to its own module,
as well as all of the other KVM_MMU_* nomenclature.

> +	depends on KVM_INTEL
> +	depends on PROC_PAGE_MONITOR
> +	---help---
> +	  Provides support for walking EPT to get the A bits on Intel
> +	  processors equipped with the VT extensions.
> +
> +	  To compile this as a module, choose M here: the module
> +	  will be called kvm-ept-idle.
> +
>  # OK, it's a little counter-intuitive to do this, but it puts it neatly under
>  # the virtualization menu.
>  source drivers/vhost/Kconfig
> diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
> index dc4f2fdf5e57..5cad0590205d 100644
> --- a/arch/x86/kvm/Makefile
> +++ b/arch/x86/kvm/Makefile
> @@ -19,6 +19,10 @@ kvm-y			+= x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
>  kvm-intel-y		+= vmx.o pmu_intel.o
>  kvm-amd-y		+= svm.o pmu_amd.o
>  
> +kvm-ept-idle-y		+= ept_idle.o
> +
>  obj-$(CONFIG_KVM)	+= kvm.o
>  obj-$(CONFIG_KVM_INTEL)	+= kvm-intel.o
>  obj-$(CONFIG_KVM_AMD)	+= kvm-amd.o
> +
> +obj-$(CONFIG_KVM_EPT_IDLE)	+= kvm-ept-idle.o
> -- 
> 2.15.0
> 
> 
> 
