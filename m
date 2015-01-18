Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id A0C156B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 13:36:45 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id hs14so25545700lab.8
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 10:36:44 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id w6si10095026laa.37.2015.01.18.10.36.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 10:36:44 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id p9so1770432lbv.8
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 10:36:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54BB9A32.7080703@oracle.com>
References: <20140624201606.18273.44270.stgit@zurg>
	<20140624201614.18273.39034.stgit@zurg>
	<54BB9A32.7080703@oracle.com>
Date: Sun, 18 Jan 2015 22:36:43 +0400
Message-ID: <CALYGNiPbTpTNme_Cp4AF0cDjRB=rQ2FJ=qRJ+G5cihQMhzsZEw@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Sun, Jan 18, 2015 at 2:34 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 06/24/2014 04:16 PM, Konstantin Khlebnikov wrote:
>> This patch prints warning (if CONFIG_DEBUG_VM=y) when
>> memory commitment becomes too negative.
>>
>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>
> Hi Konstantin,
>
> I seem to be hitting this warning when fuzzing on the latest -next kernel:

That might be unexpected change of shmem file which holds anon-vma data,
thanks to checkpoint-restore they are expoted via /proc/.../map_files

I've fixed truncate (https://lkml.org/lkml/2014/6/24/729) but there
are some other ways
to change i_size: write, fallocate and maybe something else.

We could seal this promblem (literally).

--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3355,6 +3355,9 @@ static struct file *__shmem_file_setup(const
char *name, loff_t size,
        if (!inode)
                goto put_memory;

+       if (!(flags & VM_NORESERVE))
+               SHMEM_I(inode)->seals |= F_SEAL_SHRINK | F_SEAL_GROW;
+
        inode->i_flags |= i_flags;
        d_instantiate(path.dentry, inode);
        inode->i_size = size;



>
> [  683.674323] ------------[ cut here ]------------
> [  683.675552] WARNING: CPU: 12 PID: 25654 at mm/mmap.c:157 __vm_enough_memory+0x1b7/0x1d0()
> [  683.676972] memory commitment underflow
> [  683.678212] Modules linked in:
> [  683.678219] CPU: 12 PID: 25654 Comm: trinity-c373 Not tainted 3.19.0-rc4-next-20150116-sasha-00054-g4ad498c-dirty #1744
> [  683.678227]  ffffffff9c6f7e73 ffff8802c0883a58 ffffffff9b439fb2 0000000000000000
> [  683.678231]  ffff8802c0883aa8 ffff8802c0883a98 ffffffff98159e1a ffff8802c0883ae8
> [  683.678236]  0000000000000001 0000000000000000 ffffffffffff76f1 ffff8802a9749000
> [  683.678243] Call Trace:
> [  683.678288] dump_stack (lib/dump_stack.c:52)
> [  683.678297] warn_slowpath_common (kernel/panic.c:447)
> [  683.678302] warn_slowpath_fmt (kernel/panic.c:461)
> [  683.678307] __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
> [  683.678317] cap_vm_enough_memory (security/commoncap.c:958)
> [  683.678323] security_vm_enough_memory_mm (security/security.c:212)
> [  683.678331] shmem_getpage_gfp (mm/shmem.c:1161)
> [  683.678337] shmem_write_begin (mm/shmem.c:1495)
> [  683.678343] generic_perform_write (mm/filemap.c:2491)
> [  683.678447] __generic_file_write_iter (mm/filemap.c:2632)
> [  683.678452] generic_file_write_iter (mm/filemap.c:2659)
> [  683.678458] do_iter_readv_writev (fs/read_write.c:680)
> [  683.678461] do_readv_writev (fs/read_write.c:848)
> [  683.678512] vfs_writev (fs/read_write.c:893)
> [  683.678515] SyS_writev (fs/read_write.c:926 fs/read_write.c:917)
> [  683.678520] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
>
>
> Thanks,
> Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
