Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1294F828EE
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 16:44:06 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c2so193824973vkg.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 13:44:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l12si16268079qtb.131.2016.06.13.13.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 13:44:05 -0700 (PDT)
Date: Mon, 13 Jun 2016 14:43:59 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [RFC 12/18] limits: track RLIMIT_MEMLOCK actual max
Message-ID: <20160613144359.677edee4@ul30vt.home>
In-Reply-To: <1465847065-3577-13-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
	<1465847065-3577-13-git-send-email-toiwoton@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Nikhil Rao <nikhil.rao@intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "open list:IA64 Itanium PLATFORM" <linux-ia64@vger.kernel.org>, "open
 list:KERNEL VIRTUAL MACHINE KVM FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open
 list:KERNEL VIRTUAL MACHINE KVM" <kvm@vger.kernel.org>, "open
 list:LINUX FOR POWERPC 32-BIT AND 64-BIT" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:BPF
 Safe dynamic programs and tools" <netdev@vger.kernel.org>, "open list:MEMORY
 MANAGEMENT" <linux-mm@kvack.org>

On Mon, 13 Jun 2016 22:44:19 +0300
Topi Miettinen <toiwoton@gmail.com> wrote:

> Track maximum size of locked memory, presented in /proc/self/limits.
> 
> Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
> ---
>  arch/ia64/kernel/perfmon.c                 |  1 +
>  arch/powerpc/kvm/book3s_64_vio.c           |  1 +
>  arch/powerpc/mm/mmu_context_iommu.c        |  1 +
>  drivers/infiniband/core/umem.c             |  1 +
>  drivers/infiniband/hw/hfi1/user_pages.c    |  1 +
>  drivers/infiniband/hw/qib/qib_user_pages.c |  1 +
>  drivers/infiniband/hw/usnic/usnic_uiom.c   |  2 ++
>  drivers/misc/mic/scif/scif_rma.c           |  1 +
>  drivers/vfio/vfio_iommu_spapr_tce.c        |  2 ++
>  drivers/vfio/vfio_iommu_type1.c            |  2 ++
>  include/linux/sched.h                      | 10 ++++++++--
>  kernel/bpf/syscall.c                       |  6 ++++++
>  kernel/events/core.c                       |  1 +
>  mm/mlock.c                                 |  7 +++++++
>  mm/mmap.c                                  |  3 +++
>  mm/mremap.c                                |  3 +++
>  16 files changed, 41 insertions(+), 2 deletions(-)
...  
>
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index 2ba1942..4c6e7a3 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -312,6 +312,8 @@ static long vfio_pin_pages(unsigned long vaddr, long npage,
>  		}
>  	}
>  
> +	bump_rlimit(RLIMIT_MEMLOCK, (current->mm->locked_vm + i) << PAGE_SHIFT);
> +
>  	if (!rsvd)
>  		vfio_lock_acct(i);
>  


Not all cases passing through here bump rlimit (see: rsvd), there's an
entire case above the other end of this closing bracket that does bump
rlimit but returns before here, and I wonder why we wouldn't just do
this in our vfio_lock_acct() accounting function anyway.  Thanks,

Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
