Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1868D6B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 10:49:39 -0400 (EDT)
Received: by obbop1 with SMTP id op1so108427860obb.2
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 07:49:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id pz7si12302502oec.44.2015.08.09.07.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 07:49:38 -0700 (PDT)
Message-ID: <55C7687D.8070909@oracle.com>
Date: Sun, 09 Aug 2015 10:49:33 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Warning at mm/truncate.c:740
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Hi Jan,

I saw the following warning while fuzzing with trinity:

[385644.689209] WARNING: CPU: 1 PID: 23536 at mm/truncate.c:740 pagecache_isize_extended+0x124/0x180()
[385644.691780] Modules linked in:
[385644.692695] CPU: 1 PID: 23536 Comm: trinity-c242 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2417
[385644.695636]  ffffffffb21300e0 ffff8800ba3cfc40 ffffffffb1e89dfc 0000000000000000
[385644.708128]  ffff8800ba3cfc80 ffffffffa8325106 ffffffffa869fdd4 ffff88006bbe1f10
[385644.710046]  0000000000001007 ffff88006bbe1f60 ffff88006bbe1f10 ffff8803daa965a0
[385644.722774] Call Trace:
[385644.723591] dump_stack (lib/dump_stack.c:52)
[385644.725180] warn_slowpath_common (kernel/panic.c:448)
[385644.728983] warn_slowpath_null (kernel/panic.c:482)
[385644.730679] pagecache_isize_extended (mm/truncate.c:740 (discriminator 1))
[385644.732630] truncate_setsize (mm/truncate.c:710)
[385644.734469] v9fs_vfs_setattr_dotl (fs/9p/v9fs_vfs.h:81 fs/9p/vfs_inode_dotl.c:593)
[385644.753009] notify_change (fs/attr.c:270)
[385644.754303] do_truncate (fs/open.c:64)
[385644.759181] do_sys_ftruncate.constprop.5 (fs/open.c:193)
[385644.760669] SyS_ftruncate (fs/open.c:201)
[385644.761818] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)

But I'm not really sure how that happens... truncate_setsize() changes the inode
size before calling pagecache_isize_extended():

	i_size_write(inode, newsize);
	if (newsize > oldsize)
		pagecache_isize_extended(inode, oldsize, newsize);
	truncate_pagecache(inode, newsize);

And notify_change() is verifying that i_mutex is held:

	WARN_ON_ONCE(!mutex_is_locked(&inode->i_mutex));

So it doesn't look like a race either.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
