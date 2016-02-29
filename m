Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB826B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 14:11:39 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id ed16so7838287lbb.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:11:39 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id l190si13032838lfl.11.2016.02.29.11.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 11:11:37 -0800 (PST)
Received: by mail-lf0-x229.google.com with SMTP id v124so5089770lff.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:11:37 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 29 Feb 2016 11:11:37 -0800
Message-ID: <CANaxB-wA_3qh78NUBc2ODqYHyXJLK0O6FRCdWizXBRPpWoBaGQ@mail.gmail.com>
Subject: linux-next: Unable to write into a vma if it has been mapped without PROT_READ
From: Andrey Wagin <avagin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-next@vger.kernel.org, linux-mm@kvack.org

Hello Everyone,

I found that now we can't write into a vma if it was mapped without PROT_READ:

mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f2ac7eb8000
--- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_ACCERR, si_addr=0x7f2ac7eb8000} ---
+++ killed by SIGSEGV (core dumped) +++
Segmentation fault
[root@linux-next-test ~]# cat test.c
#include <sys/mman.h>
#include <stdlib.h>

int main()
{
    int *p;

    p = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    p[0] = 1;

    return 0;
}

[root@linux-next-test ~]# uname -a
Linux linux-next-test 4.5.0-rc6-next-20160229 #1 SMP Mon Feb 29
17:38:25 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

This issue appeared in 4.5.0-rc5-next-20160226.

https://ci.openvz.org/job/CRIU-linux-next/152/console

Thanks,
Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
