Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 040FD6B0006
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 06:36:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x98-v6so3428071ede.0
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 03:36:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r8si625489edm.118.2018.11.11.03.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 03:36:03 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wABBStYx111991
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 06:36:02 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2npdhdummw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 06:36:01 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Sun, 11 Nov 2018 11:36:00 -0000
Date: Sun, 11 Nov 2018 12:35:53 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: crashkernel=512M is no longer working on this aarch64 server
In-Reply-To: <1A7E2E89-34DB-41A0-BBA2-323073A7E298@gmx.us>
References: <1A7E2E89-34DB-41A0-BBA2-323073A7E298@gmx.us>
MIME-Version: 1.0
Message-Id: <20181111123553.3a35a15c@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@gmx.us>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sat, 10 Nov 2018 23:41:34 -0500
Qian Cai <cai@gmx.us> wrote:

> It was broken somewhere between b00d209241ff and 3541833fd1f2.
> 
> [    0.000000] cannot allocate crashkernel (size:0x20000000)
> 
> Where a good one looks like this,
> 
> [    0.000000] crashkernel reserved: 0x0000000008600000 - 0x0000000028600000 (512 MB)
> 
> Some commits look more suspicious than others.
> 
>       mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
>       mm: introduce mm_[p4d|pud|pmd]_folded
>       mm: make the __PAGETABLE_PxD_FOLDED defines non-empty

The intent of these three patches is to add extra checks to the
pgtable_bytes accounting function. If applied incorrectly the expected
result would be warnings like this:
  BUG: non-zero pgtables_bytes on freeing mm: 16384

The change Linus worried about affects the __PAGETABLE_PxD_FOLDED defines.
These defines are used with #ifdef, #ifndef, and __is_defined() for the
new mm_p?d_folded() macros. I can not see how this would make a difference
for your iomem setup.

> # diff -u ../iomem.good.txt ../iomem.bad.txt 
> --- ../iomem.good.txt	2018-11-10 22:28:20.092614398 -0500
> +++ ../iomem.bad.txt	2018-11-10 20:39:54.930294479 -0500
> @@ -1,9 +1,8 @@
>  00000000-3965ffff : System RAM
>    00080000-018cffff : Kernel code
> -  018d0000-020affff : reserved
> -  020b0000-045affff : Kernel data
> -  08600000-285fffff : Crash kernel
> -  28730000-2d5affff : reserved
> +  018d0000-0762ffff : reserved
> +  07630000-09b2ffff : Kernel data
> +  231b0000-2802ffff : reserved
>    30ec0000-30ecffff : reserved
>    35660000-3965ffff : reserved
>  39660000-396fffff : reserved
> @@ -127,7 +126,7 @@
>    7c5200000-7c520ffff : 0004:48:00.0
>  1040000000-17fbffffff : System RAM
>    13fbfd0000-13fdfdffff : reserved
> -  16fba80000-17fbfdffff : reserved
> +  16fafd0000-17fbfdffff : reserved
>    17fbfe0000-17fbffffff : reserved
>  1800000000-1ffbffffff : System RAM
>    1bfbff0000-1bfdfeffff : reserved

The easiest way to verify if the three commits have something to do with your
problem is to revert them and run your test. Can you do that please ?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
