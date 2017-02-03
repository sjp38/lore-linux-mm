Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B539F6B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 14:01:39 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so32150611pgc.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 11:01:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e185si21467896pgc.284.2017.02.03.11.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 11:01:38 -0800 (PST)
Date: Fri, 3 Feb 2017 12:01:37 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] mm, dax: clear PMD or PUD size flags when in fall
 through path
Message-ID: <20170203190137.GA17709@linux.intel.com>
References: <148589842696.5820.16078080610311444794.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148589842696.5820.16078080610311444794.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, dave.hansen@linux.intel.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz

On Tue, Jan 31, 2017 at 02:33:47PM -0700, Dave Jiang wrote:
> Ross reported that:
> Running xfstests generic/030 with XFS + DAX gives me the following kernel BUG,
> which I bisected to this commit: mm,fs,dax: Change ->pmd_fault to ->huge_fault
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
> It appears that there are 2 issues. First, the size bits used for vm_fault
> needs to be shifted over. Otherwise, FAULT_FLAG_SIZE_PMD is clobbering
> FAULT_FLAG_INSTRUCTION. Second issue, after create_huge_pmd() is being
> called and is falling back to the pte fault handler, the FAULT_FLAG_SIZE_PMD
> flag remains and that causes the dax fault handler to go towards the pmd
> fault handler instead of the pte fault handler. Fixes are made for the pud
> and pmd fall through paths.
> 
> Reported-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>

Yep, this seems to solve the issue for me.  Thanks!

Tested-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
