Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id BD6546B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:20:17 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so44912989wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:20:17 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTPS id h4si1288712wij.35.2015.09.15.13.20.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 13:20:16 -0700 (PDT)
Date: Tue, 15 Sep 2015 20:20:07 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <865804703.8653.1442348407762.JavaMail.zimbra@efficios.com>
In-Reply-To: <20150915130253.c1a0fbbab9ce93b38a2bfd43@linux-foundation.org>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com> <1441745010-14314-13-git-send-email-aarcange@redhat.com> <20150915130253.c1a0fbbab9ce93b38a2bfd43@linux-foundation.org>
Subject: Re: [PATCH 12/12] userfaultfd: register uapi generic syscall
 (aarch64)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang zhanghailiang <zhang.zhanghailiang@huawei.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, geert <geert@linux-m68k.org>

----- On Sep 15, 2015, at 4:02 PM, Andrew Morton akpm@linux-foundation.org wrote:

> On Tue,  8 Sep 2015 22:43:30 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
>> From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
>> 
>> Add the userfaultfd syscalls to uapi asm-generic, it was tested with
>> postcopy live migration on aarch64 with both 4k and 64k pagesize kernels.
>> 
>> ...
>>
>> --- a/include/uapi/asm-generic/unistd.h
>> +++ b/include/uapi/asm-generic/unistd.h
>> @@ -709,9 +709,11 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
>>  __SYSCALL(__NR_bpf, sys_bpf)
>>  #define __NR_execveat 281
>>  __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
>> +#define __NR_userfaultfd 282
>> +__SYSCALL(__NR_userfaultfd, sys_userfaultfd)
>>  
>>  #undef __NR_syscalls
>> -#define __NR_syscalls 282
>> +#define __NR_syscalls 283
> 
> sys_membarrier got there first.  Does this version look OK?

Hi Andrew,

Since userfaultfd also made it into 4.3-rc1, bumping the system
call number of sys_membarrier in asm-generic seems to be a good
approach to handle this conflict. We can probably expect conflicts
on other architectures too when architecture maintainers wire up
membarrier and userfaultfd.

Thanks!

Mathieu

> 
> From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> Subject: userfaultfd: register uapi generic syscall (aarch64)
> 
> Add the userfaultfd syscalls to uapi asm-generic, it was tested with
> postcopy live migration on aarch64 with both 4k and 64k pagesize kernels.
> 
> Signed-off-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
> include/uapi/asm-generic/unistd.h |    8 +++++---
> 1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff -puN
> include/uapi/asm-generic/unistd.h~userfaultfd-register-uapi-generic-syscall-aarch64
> include/uapi/asm-generic/unistd.h
> ---
> a/include/uapi/asm-generic/unistd.h~userfaultfd-register-uapi-generic-syscall-aarch64
> +++ a/include/uapi/asm-generic/unistd.h
> @@ -709,17 +709,19 @@ __SYSCALL(__NR_memfd_create, sys_memfd_c
> __SYSCALL(__NR_bpf, sys_bpf)
> #define __NR_execveat 281
> __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
> -#define __NR_membarrier 282
> +#define __NR_userfaultfd 282
> +__SYSCALL(__NR_userfaultfd, sys_userfaultfd)
> +#define __NR_membarrier 283
> __SYSCALL(__NR_membarrier, sys_membarrier)
> 
> #undef __NR_syscalls
> -#define __NR_syscalls 283
> +#define __NR_syscalls 284
> 
> /*
>  * All syscalls below here should go away really,
>  * these are provided for both review and as a porting
>  * help for the C library version.
> -*
> + *
>  * Last chance: are any of these important enough to
>  * enable by default?
>  */
> _

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
