Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 437796B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 07:10:51 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so10598831pac.6
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:10:51 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id m132si39936131pfc.253.2016.10.19.04.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 04:10:50 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 10/10] mm: replace access_process_vm() write parameter with gup_flags
In-Reply-To: <20161013002020.3062-11-lstoakes@gmail.com>
References: <20161013002020.3062-1-lstoakes@gmail.com> <20161013002020.3062-11-lstoakes@gmail.com>
Date: Wed, 19 Oct 2016 22:10:46 +1100
Message-ID: <87twc84mrt.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@te>, chsingularity.net

Lorenzo Stoakes <lstoakes@gmail.com> writes:

> diff --git a/arch/powerpc/kernel/ptrace32.c b/arch/powerpc/kernel/ptrace32.c
> index f52b7db3..010b7b3 100644
> --- a/arch/powerpc/kernel/ptrace32.c
> +++ b/arch/powerpc/kernel/ptrace32.c
> @@ -74,7 +74,7 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
>  			break;
>  
>  		copied = access_process_vm(child, (u64)addrOthers, &tmp,
> -				sizeof(tmp), 0);
> +				sizeof(tmp), FOLL_FORCE);
>  		if (copied != sizeof(tmp))
>  			break;
>  		ret = put_user(tmp, (u32 __user *)data);

LGTM.

> @@ -179,7 +179,8 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
>  			break;
>  		ret = 0;
>  		if (access_process_vm(child, (u64)addrOthers, &tmp,
> -					sizeof(tmp), 1) == sizeof(tmp))
> +					sizeof(tmp),
> +					FOLL_FORCE | FOLL_WRITE) == sizeof(tmp))
>  			break;
>  		ret = -EIO;
>  		break;

If you're respinning this anyway, can you format that as:

		if (access_process_vm(child, (u64)addrOthers, &tmp, sizeof(tmp),
				      FOLL_FORCE | FOLL_WRITE) == sizeof(tmp))
  			break;

I realise you probably deliberately didn't do that to make the diff clearer.

Either way:

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
