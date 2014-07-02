Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 21F9A6B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 05:42:03 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id l6so9571046qcy.32
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 02:42:02 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id o46si10697047qgd.86.2014.07.02.02.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 02 Jul 2014 02:42:02 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N82009FDW9LYW80@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 02 Jul 2014 10:41:45 +0100 (BST)
Message-id: <53B3D3AA.3000408@samsung.com>
Date: Wed, 02 Jul 2014 12:40:58 +0300
From: Dmitry Kasatkin <d.kasatkin@samsung.com>
Subject: IMA: kernel reading files opened with O_DIRECT
Content-transfer-encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, viro@ZenIV.linux.org.uk, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>

Hi,

We are looking for advice on reading files opened for direct_io.

IMA subsystem (security/integrity/ima) reads file content to kernel
buffer with kernel_read() like function to calculate a file hash.
It does not open another instance of 'struct file' but uses one
allocated via 'open' system call.

It works well when file was opened without O_DIRECT flag. In such case
file content is read to the page cache and VFS simply copying data to
the buffer. When buffer is a kernel buffer, it is successfully manged like:

old_fs = get_fs();
set_fs(get_ds());
result = vfs_read(file, (void __user *)addr, count, &pos);
set_fs(old_fs);

In the case when file was opened with O_DIRECT flag, filesystem code
copying data directly to user-space memory and set_fs(get_ds()) trick
does not work anymore.

To overcome this problem we thought about following possible solutions.

1. Allocate user-space memory with vm_mmap().

It works when when file is opened. current->mm is there...
But IMA has certain case to re-read the file at file close.
If file was not explicitly closed with 'close', it will be closed at
process termination somewhere in do_exit().
But at the time file is closing from there, 'current->mm' has already
gone and vm_mmap() fails.

2. Temporarily clear O_DIRECT in file->f_flags.

This is how it looked like in the proposed patch some time ago...

https://lkml.org/lkml/2013/2/20/601

In such approach, by clearing a flag, VFS would be able to write data to
kernel buffer.
But in such case we force to populate page cache which was not an
intention of the process using O_DIRECT.

There reason for the patch was actually a deadlock, because IMA takes
i_mutex and VFS direct_io code also took it.

Al Viro rejected the patch as from his opinion we contaminated locking
rules.

Now we will introduce internal locking and deadlock would not happen
anyway and temporarily clearing O_DIRECT is not to workaround locking
but to be able to read to kernel buffer.

3. Open another instance of the file with 'dentry_open'

Such case would be also similar to temporarily clearing as we would
populate the page cache...

Yeah. O_DIRECT use is certainly rare.. 'man 2 open' has interesting
statement from Linus... :)

"The thing that has always disturbed me about O_DIRECT is that the whole
interface is just stupid, and was probably designed by a deranged monkey
on some serious mind-controlling substances."?Linus

But anyway, there was few complains about deadlock with IMA+O_DIRECT.
Currently we made a patch that when IMA is enabled it does not
measure/appraise files opened with O_DIRECT. Instead it can be
configured to block and log or allow and log O_DIRECT access...

But we would want to cover O_DIRECT case completely and be able to read
file..

Greg KH advised me to write to linux-mm and Andrew as well and ask about
advices on possibility to handle O_DIRECT files.

Is temporarily clearing O_DIRECT flag really unacceptable or not?

Or may be there is a way to allocate "special" user-space like buffer
for kernel and use it with O_DIRECT?

Thanks,
Dmitry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
