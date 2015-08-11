Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 919A76B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 06:08:40 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so41898984pdb.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 03:08:40 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id hr1si2641956pbc.43.2015.08.11.03.08.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Aug 2015 03:08:39 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.vnet.ibm.com>;
	Tue, 11 Aug 2015 20:08:34 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 16B642BB005F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 20:08:26 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7BA8Bse2097632
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 20:08:20 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7BA7q2J020530
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 20:07:52 +1000
Date: Tue, 11 Aug 2015 15:37:29 +0530
From: Bharata B Rao <bharata@linux.vnet.ibm.com>
Subject: Re: [Qemu-devel] [PATCH 19/23] userfaultfd: activate syscall
Message-ID: <20150811100728.GB4587@in.ibm.com>
Reply-To: bharata@linux.vnet.ibm.com
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-20-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431624680-20153-20-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andres Lagar-Cavilla <andreslc@google.com>, Mel Gorman <mgorman@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

On Thu, May 14, 2015 at 07:31:16PM +0200, Andrea Arcangeli wrote:
> This activates the userfaultfd syscall.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  arch/powerpc/include/asm/systbl.h      | 1 +
>  arch/powerpc/include/uapi/asm/unistd.h | 1 +
>  arch/x86/syscalls/syscall_32.tbl       | 1 +
>  arch/x86/syscalls/syscall_64.tbl       | 1 +
>  include/linux/syscalls.h               | 1 +
>  kernel/sys_ni.c                        | 1 +
>  6 files changed, 6 insertions(+)
> 
> diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
> index f1863a1..4741b15 100644
> --- a/arch/powerpc/include/asm/systbl.h
> +++ b/arch/powerpc/include/asm/systbl.h
> @@ -368,3 +368,4 @@ SYSCALL_SPU(memfd_create)
>  SYSCALL_SPU(bpf)
>  COMPAT_SYS(execveat)
>  PPC64ONLY(switch_endian)
> +SYSCALL_SPU(userfaultfd)
> diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
> index e4aa173..6ad58d4 100644
> --- a/arch/powerpc/include/uapi/asm/unistd.h
> +++ b/arch/powerpc/include/uapi/asm/unistd.h
> @@ -386,5 +386,6 @@
>  #define __NR_bpf		361
>  #define __NR_execveat		362
>  #define __NR_switch_endian	363
> +#define __NR_userfaultfd	364

May be it is a bit late to bring this up, but I needed the following fix
to userfault21 branch of your git tree to compile on powerpc.
----

powerpc: Bump up __NR_syscalls to account for __NR_userfaultfd

From: Bharata B Rao <bharata@linux.vnet.ibm.com>

With userfaultfd syscall, the number of syscalls will be 365 on PowerPC.
Reflect the same in __NR_syscalls.

Signed-off-by: Bharata B Rao <bharata@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/unistd.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index f4f8b66..4a055b6 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -12,7 +12,7 @@
 #include <uapi/asm/unistd.h>
 
 
-#define __NR_syscalls		364
+#define __NR_syscalls		365
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
