Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id A764F6B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 06:34:29 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id q9so2524936ykb.3
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 03:34:29 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s25si3990049yhg.139.2015.01.18.03.34.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 03:34:28 -0800 (PST)
Message-ID: <54BB9A32.7080703@oracle.com>
Date: Sun, 18 Jan 2015 06:34:10 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
References: <20140624201606.18273.44270.stgit@zurg> <20140624201614.18273.39034.stgit@zurg>
In-Reply-To: <20140624201614.18273.39034.stgit@zurg>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>Hugh Dickins <hughd@google.com>

On 06/24/2014 04:16 PM, Konstantin Khlebnikov wrote:
> This patch prints warning (if CONFIG_DEBUG_VM=y) when
> memory commitment becomes too negative.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

Hi Konstantin,

I seem to be hitting this warning when fuzzing on the latest -next kernel:

[  683.674323] ------------[ cut here ]------------
[  683.675552] WARNING: CPU: 12 PID: 25654 at mm/mmap.c:157 __vm_enough_memory+0x1b7/0x1d0()
[  683.676972] memory commitment underflow
[  683.678212] Modules linked in:
[  683.678219] CPU: 12 PID: 25654 Comm: trinity-c373 Not tainted 3.19.0-rc4-next-20150116-sasha-00054-g4ad498c-dirty #1744
[  683.678227]  ffffffff9c6f7e73 ffff8802c0883a58 ffffffff9b439fb2 0000000000000000
[  683.678231]  ffff8802c0883aa8 ffff8802c0883a98 ffffffff98159e1a ffff8802c0883ae8
[  683.678236]  0000000000000001 0000000000000000 ffffffffffff76f1 ffff8802a9749000
[  683.678243] Call Trace:
[  683.678288] dump_stack (lib/dump_stack.c:52)
[  683.678297] warn_slowpath_common (kernel/panic.c:447)
[  683.678302] warn_slowpath_fmt (kernel/panic.c:461)
[  683.678307] __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  683.678317] cap_vm_enough_memory (security/commoncap.c:958)
[  683.678323] security_vm_enough_memory_mm (security/security.c:212)
[  683.678331] shmem_getpage_gfp (mm/shmem.c:1161)
[  683.678337] shmem_write_begin (mm/shmem.c:1495)
[  683.678343] generic_perform_write (mm/filemap.c:2491)
[  683.678447] __generic_file_write_iter (mm/filemap.c:2632)
[  683.678452] generic_file_write_iter (mm/filemap.c:2659)
[  683.678458] do_iter_readv_writev (fs/read_write.c:680)
[  683.678461] do_readv_writev (fs/read_write.c:848)
[  683.678512] vfs_writev (fs/read_write.c:893)
[  683.678515] SyS_writev (fs/read_write.c:926 fs/read_write.c:917)
[  683.678520] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
