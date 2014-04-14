Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 819176B00DC
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 07:14:40 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so3819970wiv.1
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 04:14:38 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id i17si5068017wjq.235.2014.04.14.04.14.37
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 04:14:38 -0700 (PDT)
Message-ID: <534BC31A.7060705@arm.com>
Date: Mon, 14 Apr 2014 12:14:34 +0100
From: Marc Zyngier <marc.zyngier@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] ARM: mm: support big-endian page tables
References: <5301B4AF.1040305@huawei.com> <5327F75F.1010406@huawei.com> <20140414104300.GA3530@arm.com>
In-Reply-To: <20140414104300.GA3530@arm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Wang Nan <wangnan0@huawei.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Ben Dooks <ben.dooks@codethink.co.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 14/04/14 11:43, Will Deacon wrote:
> (catching up on old email)
> 
> On Tue, Mar 18, 2014 at 07:35:59AM +0000, Jianguo Wu wrote:
>> Cloud you please take a look at this?
> 
> [...]
> 
>> On 2014/2/17 15:05, Jianguo Wu wrote:
>>> When enable LPAE and big-endian in a hisilicon board, while specify
>>> mem=384M mem=512M@7680M, will get bad page state:
>>>
>>> Freeing unused kernel memory: 180K (c0466000 - c0493000)
>>> BUG: Bad page state in process init  pfn:fa442
>>> page:c7749840 count:0 mapcount:-1 mapping:  (null) index:0x0
>>> page flags: 0x40000400(reserved)
>>> Modules linked in:
>>> CPU: 0 PID: 1 Comm: init Not tainted 3.10.27+ #66
>>> [<c000f5f0>] (unwind_backtrace+0x0/0x11c) from [<c000cbc4>] (show_stack+0x10/0x14)
>>> [<c000cbc4>] (show_stack+0x10/0x14) from [<c009e448>] (bad_page+0xd4/0x104)
>>> [<c009e448>] (bad_page+0xd4/0x104) from [<c009e520>] (free_pages_prepare+0xa8/0x14c)
>>> [<c009e520>] (free_pages_prepare+0xa8/0x14c) from [<c009f8ec>] (free_hot_cold_page+0x18/0xf0)
>>> [<c009f8ec>] (free_hot_cold_page+0x18/0xf0) from [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8)
>>> [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8) from [<c00b6458>] (handle_mm_fault+0xf4/0x120)
>>> [<c00b6458>] (handle_mm_fault+0xf4/0x120) from [<c0013754>] (do_page_fault+0xfc/0x354)
>>> [<c0013754>] (do_page_fault+0xfc/0x354) from [<c0008400>] (do_DataAbort+0x2c/0x90)
>>> [<c0008400>] (do_DataAbort+0x2c/0x90) from [<c0008fb4>] (__dabt_usr+0x34/0x40)
> 
> [...]
> 
>>> The bug is happened in cpu_v7_set_pte_ext(ptep, pte):
>>> when pte is 64-bit, for little-endian, will store low 32-bit in r2,
>>> high 32-bit in r3; for big-endian, will store low 32-bit in r3,
>>> high 32-bit in r2, this will cause wrong pfn stored in pte,
>>> so we should exchange r2 and r3 for big-endian.
> 
> I believe that Marc (added to CC) has been running LPAE-enabled, big-endian
> KVM guests without any issues, so it seems unlikely that we're storing the
> PTEs backwards. Can you check the configuration of SCTLR.EE?

So, for the record:

root@when-the-lie-s-so-big:~# cat /proc/cpuinfo 
processor	: 0
model name	: ARMv7 Processor rev 4 (v7b)
Features	: swp half thumb fastmult vfp edsp thumbee neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm 
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x0
CPU part	: 0xc07
CPU revision	: 4

processor	: 1
model name	: ARMv7 Processor rev 4 (v7b)
Features	: swp half thumb fastmult vfp edsp thumbee neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm 
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x0
CPU part	: 0xc07
CPU revision	: 4

Hardware	: Dummy Virtual Machine
Revision	: 0000
Serial		: 0000000000000000
root@when-the-lie-s-so-big:~# uname -a
Linux when-the-lie-s-so-big 3.14.0+ #2465 SMP PREEMPT Tue Apr 8 13:05:11 BST 2014 armv7b GNU/Linux

Now, looking at the patch, I think it makes some sense:
- Depending on the endianness, we have to test the L_PTE_NONE in one 
word on the other, and possibly clear L_PTE_VALID
- Same for L_PTE_DIRTY, respectively setting L_PTE_RDONLY

The commit message looks wrong though, as it mention the PTE storage in 
memory (which looks completely fine to me, and explain why I was able to
boot a guest). As none of my guest RAM is above 4GB IPA, I didn't see 
the corruption of bit 32 in the PTE (which should have been bit 0,
corresponding to L_PTE_VALID).

So, provided that the commit message is rewritten to match the what it does,
I'm fine with that patch.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
