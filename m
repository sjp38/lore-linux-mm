Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 220216B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 06:52:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so56682716wme.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 03:52:50 -0800 (PST)
Received: from mail-wj0-x22d.google.com (mail-wj0-x22d.google.com. [2a00:1450:400c:c01::22d])
        by mx.google.com with ESMTPS id s9si380083wmf.36.2016.12.01.03.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 03:52:48 -0800 (PST)
Received: by mail-wj0-x22d.google.com with SMTP id mp19so202733250wjc.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 03:52:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150810094315.GA3768@quack.suse.cz>
References: <55C7687D.8070909@oracle.com> <20150810094315.GA3768@quack.suse.cz>
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Thu, 1 Dec 2016 12:52:47 +0100
Message-ID: <CAOMGZ=FnDUgf2N9QLqaMpaokXdnZ9zNRVB_3=wkpzAp=AFHiAA@mail.gmail.com>
Subject: Re: Warning at mm/truncate.c:740
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>

On 10 August 2015 at 11:43, Jan Kara <jack@suse.cz> wrote:
> On Sun 09-08-15 10:49:33, Sasha Levin wrote:
>> I saw the following warning while fuzzing with trinity:
>>
>> [385644.689209] WARNING: CPU: 1 PID: 23536 at mm/truncate.c:740 pagecache_isize_extended+0x124/0x180()
>> [385644.691780] Modules linked in:
>> [385644.692695] CPU: 1 PID: 23536 Comm: trinity-c242 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2417
>> [385644.695636]  ffffffffb21300e0 ffff8800ba3cfc40 ffffffffb1e89dfc 0000000000000000
>> [385644.708128]  ffff8800ba3cfc80 ffffffffa8325106 ffffffffa869fdd4 ffff88006bbe1f10
>> [385644.710046]  0000000000001007 ffff88006bbe1f60 ffff88006bbe1f10 ffff8803daa965a0
>> [385644.722774] Call Trace:
>> [385644.723591] dump_stack (lib/dump_stack.c:52)
>> [385644.725180] warn_slowpath_common (kernel/panic.c:448)
>> [385644.728983] warn_slowpath_null (kernel/panic.c:482)
>> [385644.730679] pagecache_isize_extended (mm/truncate.c:740 (discriminator 1))
>> [385644.732630] truncate_setsize (mm/truncate.c:710)
>> [385644.734469] v9fs_vfs_setattr_dotl (fs/9p/v9fs_vfs.h:81 fs/9p/vfs_inode_dotl.c:593)
>> [385644.753009] notify_change (fs/attr.c:270)
>> [385644.754303] do_truncate (fs/open.c:64)
>> [385644.759181] do_sys_ftruncate.constprop.5 (fs/open.c:193)
>> [385644.760669] SyS_ftruncate (fs/open.c:201)
>> [385644.761818] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
>>
>> But I'm not really sure how that happens... truncate_setsize() changes the inode
>> size before calling pagecache_isize_extended():
>>
>>       i_size_write(inode, newsize);
>>       if (newsize > oldsize)
>>               pagecache_isize_extended(inode, oldsize, newsize);
>>       truncate_pagecache(inode, newsize);
>>
>> And notify_change() is verifying that i_mutex is held:
>>
>>       WARN_ON_ONCE(!mutex_is_locked(&inode->i_mutex));
>>
>> So it doesn't look like a race either.
>
> Well, looking at the code it can be a race which is specific to 9p
> filesystem. It seems to me that 9p can update i_size from
> v9fs_refresh_inode_dotl(). That can be called v9fs_lookup_revalidate()
> without holding i_mutex. Now I'm not sure d_revalidate() can really race
> with truncate on the same inode (whether there isn't something else
> protecting this). Al should know better...

FWIW I'm still hitting this on latest linus/master (4.9.0-rc7+).


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
