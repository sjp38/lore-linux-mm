Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3EBAE6B0069
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:15:43 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id s10so168499147itb.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 16:15:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v6si14135808plk.133.2017.01.30.16.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 16:15:42 -0800 (PST)
Subject: Re: [PATCH v2 1/3] mm,fs,dax: Change ->pmd_fault to ->huge_fault
References: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
 <148545058784.17912.6353162518188733642.stgit@djiang5-desk3.ch.intel.com>
 <20170130234321.GA26702@linux.intel.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <79fcc6fe-77c5-7145-cf24-4a04df482803@intel.com>
Date: Mon, 30 Jan 2017 17:15:40 -0700
MIME-Version: 1.0
In-Reply-To: <20170130234321.GA26702@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: akpm@linux-foundation.org, dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, kirill.shutemov@linux.intel.com

On 01/30/2017 04:43 PM, Ross Zwisler wrote:
> On Thu, Jan 26, 2017 at 10:09:47AM -0700, Dave Jiang wrote:
>> In preparation for adding the ability to handle PUD pages, convert
>> ->pmd_fault to ->huge_fault.  The vm_fault structure is extended to
>> include a union of the different page table pointers that may be needed,
>> and three flag bits are reserved to indicate which type of pointer is in
>> the union.
>>
>> [DJ: Forward ported to 4.10-rc]
>>
>> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
>> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> 
> Hey Dave,
> 
> Running xfstests generic/030 with XFS + DAX gives me the following kernel BUG,
> which I bisected to this commit:
> 
> [  370.086205] ------------[ cut here ]------------
> [  370.087182] kernel BUG at arch/x86/mm/fault.c:1038!
> [  370.088336] invalid opcode: 0000 [#3] PREEMPT SMP
> [  370.089073] Modules linked in: dax_pmem nd_pmem dax nd_btt nd_e820 libnvdimm
> [  370.090212] CPU: 0 PID: 12415 Comm: xfs_io Tainted: G      D         4.10.0-rc5-mm1-00202-g7e90fc0 #10
> [  370.091648] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
> [  370.092946] task: ffff8800ac4f8000 task.stack: ffffc9001148c000
> [  370.093769] RIP: 0010:mm_fault_error+0x15e/0x190
> [  370.094410] RSP: 0000:ffffc9001148fe60 EFLAGS: 00010246
> [  370.095135] RAX: 0000000000000000 RBX: 0000000000000006 RCX: ffff8800ac4f8000
> [  370.096107] RDX: 00007f111c8e6400 RSI: 0000000000000006 RDI: ffffc9001148ff58
> [  370.097087] RBP: ffffc9001148fe88 R08: 0000000000000000 R09: ffff880510bd3300
> [  370.098072] R10: ffff8800ac4f8000 R11: 0000000000000000 R12: 00007f111c8e6400
> [  370.099057] R13: 00007f111c8e6400 R14: ffff880510bd3300 R15: 0000000000000055
> [  370.100135] FS:  00007f111d95e700(0000) GS:ffff880514800000(0000) knlGS:0000000000000000
> [  370.101238] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  370.102021] CR2: 00007f111c8e6400 CR3: 00000000add00000 CR4: 00000000001406f0
> [  370.103189] Call Trace:
> [  370.103537]  __do_page_fault+0x54e/0x590
> [  370.104090]  trace_do_page_fault+0x58/0x2c0
> [  370.104675]  do_async_page_fault+0x2c/0x90
> [  370.105342]  async_page_fault+0x28/0x30
> [  370.106044] RIP: 0033:0x405e9a
> [  370.106470] RSP: 002b:00007fffb7f30590 EFLAGS: 00010287
> [  370.107185] RAX: 00000000004e6400 RBX: 0000000000000057 RCX: 00000000004e7000
> [  370.108155] RDX: 00007f111c400000 RSI: 00000000004e7000 RDI: 0000000001c35080
> [  370.109157] RBP: 00000000004e6400 R08: 0000000000000014 R09: 1999999999999999
> [  370.110158] R10: 00007f111d2dc200 R11: 0000000000000000 R12: 0000000001c32fc0
> [  370.111165] R13: 0000000000000000 R14: 0000000000000c00 R15: 0000000000000005
> [  370.112171] Code: 07 00 00 00 e8 a4 ee ff ff e9 11 ff ff ff 4c 89 ea 48 89 de 45 31 c0 31 c9 e8 8f f7 ff ff 48 83 c4 08 5b 41 5c 41 5d 41 5e 5d c3 <0f> 0b 41 8b 94 24 80 04 00 00 49 8d b4 24 b0 06 00 00 4c 89 e9 
> [  370.114823] RIP: mm_fault_error+0x15e/0x190 RSP: ffffc9001148fe60
> [  370.115722] ---[ end trace 2ce10d930638254d ]---
> 
> 
> Can you let me know if you can reproduce this?

I reproduced. Will debug.

> 
> Thanks,
> - Ross
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
