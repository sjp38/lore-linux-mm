Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C70226B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:14:00 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id w127so4112288vkh.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:14:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b34si5535143qtb.136.2016.07.15.08.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 08:14:00 -0700 (PDT)
Date: Fri, 15 Jul 2016 17:14:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/14] resource limits: track highwater mark of locked
	memory
Message-ID: <20160715151408.GA32317@redhat.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com> <1468578983-28229-10-git-send-email-toiwoton@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468578983-28229-10-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alexander Graf <agraf@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On 07/15, Topi Miettinen wrote:
>
> Track maximum size of locked memory, to be able to configure
> RLIMIT_MEMLOCK resource limits. The information is available
> with taskstats and cgroupstats netlink socket.

So I personally still dislike the very idea of this series... but I won't
argue if you convince maintainers.

> @@ -2020,6 +2020,10 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
>  		return -ENOMEM;
>  
>  	update_resource_highwatermark(RLIMIT_STACK, actual_size);
> +	if (vma->vm_flags & VM_LOCKED)
> +		update_resource_highwatermark(RLIMIT_MEMLOCK,
> +					      (mm->locked_vm + grow) <<
> +					      PAGE_SHIFT);

Btw this is not right. The same for the previous patch which tracks
RLIMIT_STACK. The "current" task can debugger/etc.

Yes, yes, this just reminds that the whole rlimit logic in this path
is broken but still...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
