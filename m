Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2B77B6B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 10:10:10 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id xk3so187674329obc.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 07:10:10 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id s77si3643989ois.16.2016.02.09.07.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 07:10:09 -0800 (PST)
Message-ID: <1455033795.2925.74.camel@hpe.com>
Subject: Re: [PATCH] x86/mm/vmfault: Make vmalloc_fault() handle large pages
From: Toshi Kani <toshi.kani@hpe.com>
Date: Tue, 09 Feb 2016 09:03:15 -0700
In-Reply-To: <20160209091003.GA10774@gmail.com>
References: <1454976038-22486-1-git-send-email-toshi.kani@hpe.com>
	 <20160209091003.GA10774@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, henning.schild@siemens.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2016-02-09 at 10:10 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hpe.com> wrote:
> 
> > Since 4.1, ioremap() supports large page (pud/pmd) mappings in x86_64
> > and PAE. A vmalloc_fault() however assumes that the vmalloc range is
> > limited to pte mappings.
> > 
> > pgd_ctor() sets the kernel's pgd entries to user's during fork(), which
> > makes user processes share the same page tables for the kernel
> > ranges.A A When a call to ioremap() is made at run-time that leads to
> > allocate a new 2nd level table (pud in 64-bit and pmd in PAE), user
> > process needs to re-sync with the updated kernel pgd entry with
> > vmalloc_fault().
> > 
> > Following changes are made to vmalloc_fault().
> 
> So what were the effects of this shortcoming? Were large page ioremap()s
> unusable? Was this harmless because no driver used this facility?
>
> If so then the changelog needs to spell this out clearly ...

Large page support of ioremap() has been used for persistent memory
mappings for a while.

In order to hit this problem, i.e. causing a vmalloc fault, a large mount
of ioremap allocations at run-time is required. A The following example
repeats allocation of 16GB range.

# cat /proc/vmallocinfo | grep memremap
0xffffc90040000000-0xffffc90440001000 17179873280 memremap+0xb4/0x110
phys=480000000 ioremap
0xffffc90480000000-0xffffc90880001000 17179873280 memremap+0xb4/0x110
phys=480000000 ioremap
0xffffc908c0000000-0xffffc90cc0001000 17179873280 memremap+0xb4/0x110
phys=c80000000 ioremap
0xffffc90d00000000-0xffffc91100001000 17179873280 memremap+0xb4/0x110
phys=c80000000 ioremap
0xffffc91140000000-0xffffc91540001000 17179873280 memremap+0xb4/0x110A 
phys=480000000 ioremap
A  :
0xffffc97300000000-0xffffc97700001000 17179873280 memremap+0xb4/0x110
phys=c80000000 ioremap
0xffffc97740000000-0xffffc97b40001000 17179873280 memremap+0xb4/0x110
phys=480000000 ioremap
0xffffc97b80000000-0xffffc97f80001000 17179873280 memremap+0xb4/0x110
phys=c80000000 ioremap
0xffffc97fc0000000-0xffffc983c0001000 17179873280 memremap+0xb4/0x110
phys=480000000 ioremap

The last ioremap call above crossed a 512GB boundary (0x8000000000), which
allocated a new pud table and updated the kernel pgd entry to point it.
A Because user process's page table does not have this pgd entry update, a
read/write syscall request to the range will hit a vmalloc fault. A Since
vmalloc_fault() does not handle a large page properly, this causes an Oops
as follows.

A BUG: unable to handle kernel paging request at ffff880840000ff8
A IP: [<ffffffff810664ae>] vmalloc_fault+0x1be/0x300
A PGD c7f03a067 PUD 0A 
A Oops: 0000 [#1] SM
A  A :
A Call Trace:
A [<ffffffff81067335>] __do_page_fault+0x285/0x3e0
A [<ffffffff810674bf>] do_page_fault+0x2f/0x80
A [<ffffffff810d6d85>] ? put_prev_entity+0x35/0x7a0
A [<ffffffff817a6888>] page_fault+0x28/0x30
A [<ffffffff813bb976>] ? memcpy_erms+0x6/0x10
A [<ffffffff817a0845>] ? schedule+0x35/0x80
A [<ffffffffa006350a>] ? pmem_rw_bytes+0x6a/0x190 [nd_pmem]
A [<ffffffff817a3713>] ? schedule_timeout+0x183/0x240
A [<ffffffffa028d2b3>] btt_log_read+0x63/0x140 [nd_btt]
A  A :
A [<ffffffff811201d0>] ? __symbol_put+0x60/0x60
A [<ffffffff8122dc60>] ? kernel_read+0x50/0x80
A [<ffffffff81124489>] SyS_finit_module+0xb9/0xf0
A [<ffffffff817a4632>] entry_SYSCALL_64_fastpath+0x1a/0xa4

Note that this issue is limited to 64-bit. A 32-bit only uses index 3 of the
pgd entry to cover the entire vmalloc range, which is always valid.

I will add this information to the change log.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
