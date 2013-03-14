Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 981616B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 21:38:03 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id x4so1699560obh.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:38:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51409575.9060304@mimc.co.uk>
References: <51409575.9060304@mimc.co.uk>
Date: Thu, 14 Mar 2013 09:38:02 +0800
Message-ID: <CAJd=RBB=2XRwN-eCQDnBjwnm57-2C+OSairhyUrPdVMoLCfj1w@mail.gmail.com>
Subject: Re: Kernel oops on mmap ?
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Jackson <mpfj-list@mimc.co.uk>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Russell King <linux@arm.linux.org.uk>

[cc Russell]
On Wed, Mar 13, 2013 at 11:04 PM, Mark Jackson <mpfj-list@mimc.co.uk> wrote:
> Can any help diagnose what my userspace task is doing to get the followings oops ?
>
> [   42.587772] Unable to handle kernel paging request at virtual address bfac6004
> [   42.595431] pgd = cf748000
> [   42.598291] [bfac6004] *pgd=00000000

None pgd, why is pgd_none_or_clear_bad() not triggered?

> [   42.602079] Internal error: Oops: 5 [#1] ARM
> [   42.606592] CPU: 0    Not tainted  (3.8.0-next-20130225-00001-g2d0ce24-dirty #38)
> [   42.614509] PC is at unmap_single_vma+0x2d8/0x5bc
> [   42.619476] LR is at unmap_single_vma+0x29c/0x5bc
> [   42.624447] pc : [<c00aed0c>]    lr : [<c00aecd0>]    psr: 60000013
> [   42.624447] sp : cf685d88  ip : 8f9523cd  fp : cf680004
> [   42.636567] r10: 00000000  r9 : bfac6000  r8 : 00200000
> [   42.642079] r7 : cf685e00  r6 : cf5e93a8  r5 : cf5e93ac  r4 : 000ea000
> [   42.648969] r3 : 00000001  r2 : 00000000  r1 : 00000040  r0 : 00000000
> [   42.655864] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> [   42.663400] Control: 10c5387d  Table: 8f748019  DAC: 00000015
> [   42.669467] Process rdserver (pid: 673, stack limit = 0xcf684238)
> [   42.675902] Stack: (0xcf685d88 to 0xcf686000)
> [   42.680507] 5d80:                   cf2ff06c cf5a28b8 cf2ff040 00000000 8f9523cd cf680000
> [   42.689145] 5da0: 0021d000 0021cfff c0c8ea80 00000000 ffffff35 00000000 f451edbe cf5a28b8
> [   42.697786] 5dc0: ffffffff cf685e00 00000000 00000000 cf6716e8 cf2ff040 cf5956c0 c00af730
> [   42.706421] 5de0: 00000000 cf5a58c0 cf5a2548 cf2ff040 cf685e00 cf301c80 cf5a58c0 c00b5884
> [   42.715061] 5e00: cf2ff040 00000001 00000000 00000080 00000000 000000d2 00000400 cf796000
> [   42.723698] 5e20: cf301c80 cf5a58c0 cf6716e8 cf2ff040 cf5956c0 c0402400 60000013 cf2ff090
> [   42.732338] 5e40: cf2ff060 cf2ff040 00000000 cf684000 cf301c80 c00364d4 cf2ff040 cf671340
> [   42.740975] 5e60: cf684000 c00ccb90 cf60ae40 cf301c80 cf60aea4 cf685e88 cf60ae74 cf684000
> [   42.749616] 5e80: 00000001 c010a29c cf301c80 00000080 00000000 cf301d80 0000000d 00000000
> [   42.758252] 5ea0: cf684000 cf55cd80 00000001 c057dd34 cf684000 c0109774 000002a1 c0075390
> [   42.766892] 5ec0: 00000002 00000000 00000000 c00cd260 00000000 00000000 cf671340 c057dd18
> [   42.775529] 5ee0: 00000002 00000000 c057dd18 cf301c80 fffffff8 00000000 c057e674 c057dd34
> [   42.784164] 5f00: cf684000 c010a05c 000002a1 c00cd24c 00000001 00000000 c00cd19c befff000
> [   42.792800] 5f20: cf684000 00000001 00000001 cf684000 00000001 cf6c4128 00000001 cf301c80
> [   42.801439] 5f40: becefdbc becef378 00000000 c00cd790 00000001 00000000 c00cd40c 00000ff0
> [   42.810074] 5f60: cf5a590c cf5a58c0 cf671560 00000000 00000000 cf343000 becefdbc becef378
> [   42.818710] 5f80: 0000000b c0013968 cf684000 00000000 becef3a0 c00cda98 becef3b4 00000000
> [   42.827346] 5fa0: becefbec c00137c0 becef3b4 00000000 0021c8f0 becef378 becefdbc b6ead190
> [   42.835981] 5fc0: becef3b4 00000000 becefbec 0000000b 00000000 0001f300 00000000 becef3a0
> [   42.844616] 5fe0: becef384 becef370 b6e97c7c b6e6ae88 60000010 0021c8f0 00000000 00000000
> [   42.853266] [<c00aed0c>] (unmap_single_vma+0x2d8/0x5bc) from [<c00af730>] (unmap_vmas+0x54/0x68)
> [   42.862552] [<c00af730>] (unmap_vmas+0x54/0x68) from [<c00b5884>] (exit_mmap+0xd0/0x1f4)
> [   42.871106] [<c00b5884>] (exit_mmap+0xd0/0x1f4) from [<c00364d4>] (mmput+0x34/0xb8)
> [   42.879202] [<c00364d4>] (mmput+0x34/0xb8) from [<c00ccb90>] (flush_old_exec+0x240/0x4c8)
> [   42.887849] [<c00ccb90>] (flush_old_exec+0x240/0x4c8) from [<c010a29c>] (load_elf_binary+0x240/0x1204)
> [   42.897687] [<c010a29c>] (load_elf_binary+0x240/0x1204) from [<c00cd24c>] (search_binary_handler+0xe4/0x1f4)
> [   42.908075] [<c00cd24c>] (search_binary_handler+0xe4/0x1f4) from [<c00cd790>] (do_execve+0x434/0x4ec)
> [   42.917816] [<c00cd790>] (do_execve+0x434/0x4ec) from [<c00cda98>] (sys_execve+0x30/0x44)
> [   42.926465] [<c00cda98>] (sys_execve+0x30/0x44) from [<c00137c0>] (ret_fast_syscall+0x0/0x3c)
> [   42.935472] Code: 0affffa4 e59d000c e3500000 1a0000a2 (e5993004)
> [   42.941912] ---[ end trace 8e32e7f68f5ea19a ]---
>
> Cheers
> Mark J.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
