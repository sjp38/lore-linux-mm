Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 81D8C6B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 15:16:02 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so6029788wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:16:02 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id x64si21962803wmx.5.2016.02.29.12.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 12:16:01 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id p65so7087289wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:16:01 -0800 (PST)
Date: Mon, 29 Feb 2016 23:15:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: linux-next: Unable to write into a vma if it has been mapped
 without PROT_READ
Message-ID: <20160229201559.GB13188@node.shutemov.name>
References: <CANaxB-wA_3qh78NUBc2ODqYHyXJLK0O6FRCdWizXBRPpWoBaGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANaxB-wA_3qh78NUBc2ODqYHyXJLK0O6FRCdWizXBRPpWoBaGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Wagin <avagin@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-next@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 29, 2016 at 11:11:37AM -0800, Andrey Wagin wrote:
> Hello Everyone,
> 
> I found that now we can't write into a vma if it was mapped without PROT_READ:
> 
> mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f2ac7eb8000
> --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_ACCERR, si_addr=0x7f2ac7eb8000} ---
> +++ killed by SIGSEGV (core dumped) +++
> Segmentation fault
> [root@linux-next-test ~]# cat test.c
> #include <sys/mman.h>
> #include <stdlib.h>
> 
> int main()
> {
>     int *p;
> 
>     p = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
>     p[0] = 1;
> 
>     return 0;
> }
> 
> [root@linux-next-test ~]# uname -a
> Linux linux-next-test 4.5.0-rc6-next-20160229 #1 SMP Mon Feb 29
> 17:38:25 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
> 
> This issue appeared in 4.5.0-rc5-next-20160226.
> 
> https://ci.openvz.org/job/CRIU-linux-next/152/console

Looks like the regression is caused by change in access_error() by commit
62b5f7d013fc ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")
as per next-20160229.

		/*
		 * Assume all accesses require either read or execute
		 * permissions.  This is not an instruction access, so
		 * it requires read permissions.
		 */
		if (!(vma->vm_flags & VM_READ))
			return 1;

The assumption is false, taking this testcase into account.

Dave?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
