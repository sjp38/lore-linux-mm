Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 58FCC6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 02:46:15 -0400 (EDT)
Received: by wiclp1 with SMTP id lp1so70497674wic.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 23:46:14 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id w1si2170766wju.16.2015.07.07.23.46.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Jul 2015 23:46:13 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 8 Jul 2015 07:46:11 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5D3581B08069
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 07:47:19 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t686k8hf22872136
	for <linux-mm@kvack.org>; Wed, 8 Jul 2015 06:46:08 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t686k7Mt011517
	for <linux-mm@kvack.org>; Wed, 8 Jul 2015 00:46:08 -0600
Date: Wed, 8 Jul 2015 08:46:07 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH V3 2/5] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
Message-ID: <20150708064607.GB7079@osiris>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
 <1436288623-13007-3-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436288623-13007-3-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 07, 2015 at 01:03:40PM -0400, Eric B Munson wrote:
> With the refactored mlock code, introduce new system calls for mlock,
> munlock, and munlockall.  The new calls will allow the user to specify
> what lock states are being added or cleared.  mlock2 and munlock2 are
> trivial at the moment, but a follow on patch will add a new mlock state
> making them useful.
> 
> munlock2 addresses a limitation of the current implementation.  If a
> user calls mlockall(MCL_CURRENT | MCL_FUTURE) and then later decides
> that MCL_FUTURE should be removed, they would have to call munlockall()
> followed by mlockall(MCL_CURRENT) which could potentially be very
> expensive.  The new munlockall2 system call allows a user to simply
> clear the MCL_FUTURE flag.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>

...

> diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
> index 1acad02..f6d81d6 100644
> --- a/arch/s390/kernel/syscalls.S
> +++ b/arch/s390/kernel/syscalls.S
> @@ -363,3 +363,6 @@ SYSCALL(sys_bpf,compat_sys_bpf)
>  SYSCALL(sys_s390_pci_mmio_write,compat_sys_s390_pci_mmio_write)
>  SYSCALL(sys_s390_pci_mmio_read,compat_sys_s390_pci_mmio_read)
>  SYSCALL(sys_execveat,compat_sys_execveat)
> +SYSCALL(sys_mlock2,compat_sys_mlock2)			/* 355 */
> +SYSCALL(sys_munlock2,compat_sys_munlock2)
> +SYSCALL(sys_munlockall2,compat_sys_munlockall2)

FWIW, you would also need to add matching lines to the two files

arch/s390/include/uapi/asm/unistd.h
arch/s390/kernel/compat_wrapper.c

so that the system call would be wired up on s390.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
