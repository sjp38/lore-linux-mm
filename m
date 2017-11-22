Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA4A06B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:45:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c23so11047337pfl.1
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:45:58 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a13si14357277pgq.440.2017.11.22.14.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 14:45:57 -0800 (PST)
Subject: Re: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193112.6A962D6A@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711201518490.1734@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <82d2d82f-32a0-64e6-03b2-3ca0a9f97de6@linux.intel.com>
Date: Wed, 22 Nov 2017 14:45:54 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711201518490.1734@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 09:21 AM, Thomas Gleixner wrote:
>> +	pgd = native_get_shadow_pgd(pgd_offset_k(0UL));
>> +	for (i = PTRS_PER_PGD / 2; i < PTRS_PER_PGD; i++) {
>> +		unsigned long addr = PAGE_OFFSET + i * PGDIR_SIZE;
> This looks wrong. The kernel address space gets incremented by PGDIR_SIZE
> and does not make a jump from PAGE_OFFSET to PAGE_OFFSET + 256 * PGDIR_SIZE
> 
> 	int i, j;
> 
> 	for (i = PTRS_PER_PGD / 2, j = 0; i < PTRS_PER_PGD; i++, j++) {
> 		unsigned long addr = PAGE_OFFSET + j * PGDIR_SIZE;
> 
> Not that is has any effect right now. Neither p4d_alloc_one() nor
> pud_alloc_one() are using the 'addr' argument.

Ahh, you're saying that 'i' is effectively starting *at* PAGE_OFFSET
since it's halfway up the address space already doing PTRS_PER_PGD/2.
Adding PAGE_OFFSET to PAGE_OFFSET is nonsense.

Would it just be simpler to do:

>         for (i = PTRS_PER_PGD / 2; i < PTRS_PER_PGD; i++) {
>                 unsigned long addr = i * PGDIR_SIZE;

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
