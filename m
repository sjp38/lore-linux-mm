Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 063F16B04E1
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 23:16:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l20so1825795pgc.10
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 20:16:34 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id w12si3438418pfi.238.2018.01.04.20.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 20:16:33 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
Date: Fri, 5 Jan 2018 12:16:13 +0800
MIME-Version: 1.0
In-Reply-To: <20171123003447.1DB395E3@viggo.jf.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

Hi Dava,

On 2017/11/23 8:34, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> These patches are based on work from a team at Graz University of
> Technology: https://github.com/IAIK/KAISER .  This work would not have
> been possible without their work as a starting point.
> 
> KAISER is a countermeasure against side channel attacks against kernel
> virtual memory.  It leaves the existing page tables largely alone and
> refers to them as the "kernel page tables.  It adds a "shadow" pgd for
> every process which is intended for use when running userspace.  The
> shadow pgd maps all the same user memory as the "kernel" copy, but
> only maps a minimal set of kernel memory.
> 
> Whenever entering the kernel (syscalls, interrupts, exceptions), the
> pgd is switched to the "kernel" copy.  When switching back to user
> mode, the shadow pgd is used.
> 
> The minimalistic kernel page tables try to map only what is needed to
> enter/exit the kernel such as the entry/exit functions themselves and
> the interrupt descriptors (IDT).
> 
> === Page Table Poisoning ===
> 
> KAISER has two copies of the page tables: one for the kernel and
> one for when running in userspace.  

So, we have 2 page table, thinking about this case:
If _ONE_ process includes _TWO_ threads, one run in user space, the other
run in kernel, they can run in one core with Hyper-Threading, right? So both
userspace and kernel space is valid, right? And for one core with
Hyper-Threading, they may share TLB, so the timing problem described in
the paper may still exist?

Can this case still be protected by KAISER?

Thanks
Yisheng

> There is also a kernel
> portion of each of the page tables: the part that *maps* the
> kernel.
> 
> The kernel portion is relatively static and uses pre-populated
> PGDs.  Nobody ever calls set_pgd() on the kernel portion during
> normal operation.
> 
> The userspace portion of the page tables is updated frequently as
> userspace pages are mapped and page table pages are allocated.
> These updates of the userspace *portion* of the tables need to be
> reflected into both the kernel and user/shadow copies.
> 
> The original KAISER patches did this by effectively looking at the
> address that is being updated.  If it is <PAGE_OFFSET, it is
> considered to be doing an update for the userspace portion of the page
> tables and must make an entry in the shadow.
> 
> However, this has a wrinkle: there are a few places where low
> addresses are used in supervisor (kernel) mode.  When EFI calls
> are made, they use what are traditionally user addresses in
> supervisor mode and trip over these checks.  The trampoline code
> that used for booting secondary CPUs has a similar issue.
> 
> Remember, there are two things that KAISER needs performed on a
> userspace PGD:
> 
>  1. Populate the shadow itself
>  2. Poison the kernel PGD so it can not be used by userspace.
> 
> Only perform these actions when dealing with a user address *and* the
> PGD has _PAGE_USER set.  That way, in-kernel users of low addresses
> typically used by userspace are not accidentally poisoned.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
