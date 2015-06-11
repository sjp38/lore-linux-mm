Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2376B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 07:03:48 -0400 (EDT)
Received: by yhan67 with SMTP id n67so1299101yha.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 04:03:47 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id q4si87549yhb.152.2015.06.11.04.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 04:03:47 -0700 (PDT)
Message-ID: <55796B0B.8060503@citrix.com>
Date: Thu, 11 Jun 2015 12:03:39 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V4 14/16] xen: move p2m list if conflicting
 with e820 map
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
 <1433765217-16333-15-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-15-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/15 13:06, Juergen Gross wrote:
> Check whether the hypervisor supplied p2m list is placed at a location
> which is conflicting with the target E820 map. If this is the case
> relocate it to a new area unused up to now and compliant to the E820
> map.
> 
> As the p2m list might by huge (up to several GB) and is required to be
> mapped virtually, set up a temporary mapping for the copied list.
> 
> For pvh domains just delete the p2m related information from start
> info instead of reserving the p2m memory, as we don't need it at all.
> 
> For 32 bit kernels adjust the memblock_reserve() parameters in order
> to cover the page tables only. This requires to memblock_reserve() the
> start_info page on it's own.

This commit breaks 32-bit PV domUs.

I've dropped this whole series for now because:

a) you've clearly not tested this series enough with domUs.
b) patch #12 (mm: provide early_memremap_ro to establish read-only
mapping) is lacking an ack from an MM maintainer (sorry for not noticing
this earlier).

Please try again for 4.3.

David

[    0.050840] Unpacking initramfs...
[    0.050979] BUG: unable to handle kernel paging request at c22c2008
[    0.050986] IP: [<c128373d>] memcpy+0x1d/0x40
[    0.050992] *pdpt = 0000000001e97027 *pde = 00000000022c3067 *pte =
80000000022c2061
[    0.051002] Oops: 0003 [#1] SMP
[    0.051008] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
4.1.0-rc5.davidvr #11
[    0.051013] task: df498000 ti: df492000 task.ti: df492000
[    0.051018] EIP: e019:[<c128373d>] EFLAGS: 00010206 CPU: 0
[    0.051023] EIP is at memcpy+0x1d/0x40
[    0.051027] EAX: c22c2000 EBX: 00001000 ECX: 000003fe EDX: c20ca160
[    0.051032] ESI: c20ca168 EDI: c22c2008 EBP: df493ce0 ESP: df493cd4
[    0.051037]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: e021
[    0.051042] CR0: 80050033 CR2: c22c2008 CR3: 016d2000 CR4: 00042660
[    0.051049] Stack:
[    0.051052]  00001000 00001000 00000000 df493d04 c1288df8 c111f6c5
df493de8 c22c2000
[    0.051062]  c22c3000 00001000 00001000 00000000 df493d58 c110a5e5
00001000 00000000
[    0.052004]  00001000 00000001 df493d44 df493d48 df498000 00000001
c146fbe0 df5a7000
[    0.052004] Call Trace:
[    0.052004]  [<c1288df8>] iov_iter_copy_from_user_atomic+0xd8/0x190
[    0.052004]  [<c111f6c5>] ? shmem_write_begin+0x55/0x90
[    0.052004]  [<c110a5e5>] generic_perform_write+0xc5/0x1a0
[    0.052004]  [<c110a852>] __generic_file_write_iter+0x192/0x1d0
[    0.052004]  [<c110a99c>] generic_file_write_iter+0x10c/0x300
[    0.052004]  [<c145e2f7>] ? __mutex_unlock_slowpath+0xb7/0x1f0
[    0.052004]  [<c10a3ae1>] ? lock_acquire+0xc1/0x240
[    0.052004]  [<c114a8f9>] __vfs_write+0xa9/0xe0
[    0.052004]  [<c114aaa0>] vfs_write+0x80/0x150
[    0.052004]  [<c11674f2>] ? __fdget+0x12/0x20
[    0.052004]  [<c114ac88>] SyS_write+0x58/0xc0
[    0.052004]  [<c162db20>] xwrite+0x27/0x53
[    0.052004]  [<c162db70>] do_copy+0x24/0xde
[    0.052004]  [<c162d6a3>] write_buffer+0x1e/0x2d
[    0.052004]  [<c162d931>] unpack_to_rootfs+0xe6/0x2ae
[    0.052004]  [<c10ad997>] ? vprintk_default+0x37/0x40
[    0.052004]  [<c162e049>] populate_rootfs+0x51/0x9b
[    0.052004]  [<c162cda4>] do_one_initcall+0x110/0x1bb
[    0.052004]  [<c162dff8>] ? maybe_link.part.1+0xe9/0xe9
[    0.052004]  [<c107c068>] ? parameq+0x18/0x70
[    0.052004]  [<c162c5ac>] ? repair_env_string+0x12/0x51
[    0.052004]  [<c162dff8>] ? maybe_link.part.1+0xe9/0xe9
[    0.052004]  [<c107c349>] ? parse_args+0x289/0x4b0
[    0.052004]  [<c14601de>] ? _raw_spin_unlock_irqrestore+0x3e/0x60
[    0.052004]  [<c1072ce3>] ? __usermodehelper_set_disable_depth+0x43/0x50

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
