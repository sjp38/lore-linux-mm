Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D1C9D6B0005
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 11:27:38 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj3so1231522pad.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 08:27:38 -0800 (PST)
Date: Thu, 28 Feb 2013 08:27:35 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: slub error in fs/sysfs/bin.c related code
Message-ID: <20130228162735.GB26013@kroah.com>
References: <512F7FEE.2090803@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <512F7FEE.2090803@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Jones <davej@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm <linux-mm@kvack.org>

On Thu, Feb 28, 2013 at 11:03:58AM -0500, Sasha Levin wrote:
> Hi Greg,
> 
> While fuzzing with trinity inside a KVM tools guest, running latest -next kernel
> I got the following spew.
> 
> The open() and release() callbacks in the traces below point to fs/sysfs/bin.c.

Any hint as to which sysfs binary file you were accessing when this
happened?

> [  719.288925] =============================================================================
> [  719.290663] BUG kmalloc-4096 (Tainted: G        W   ): Redzone overwritten
> [  719.291764] -----------------------------------------------------------------------------
> [  719.291764]
> [  719.294527] Disabling lock debugging due to kernel taint
> [  719.294527] INFO: 0xffff88006d1a5520-0xffff88006d1a5520. First byte 0x0 instead of 0xcc
> [  719.294527] INFO: Allocated in open+0xb8/0x190 age=18922 cpu=1 pid=7095
> [  719.294527] 	__slab_alloc+0x622/0x6d0
> [  719.294527] 	kmem_cache_alloc_trace+0x123/0x2c0
> [  719.294527] 	open+0xb8/0x190
> [  719.294527] 	do_dentry_open+0x229/0x330
> [  719.294527] 	finish_open+0x54/0x70
> [  719.294527] 	do_last+0x56c/0x790
> [  719.294527] 	path_openat+0xbe/0x490
> [  719.294527] 	do_filp_open+0x44/0xa0
> [  719.294527] 	do_sys_open+0x133/0x1d0
> [  719.294527] 	sys_open+0x1c/0x20
> [  719.294527] 	tracesys+0xdd/0xe2
> [  719.294527] INFO: Freed in seq_release+0x18/0x30 age=18947 cpu=0 pid=31203
> [  719.294527] 	__slab_free+0x3c/0x590
> [  719.294527] 	kfree+0x2cb/0x2e0
> [  719.294527] 	seq_release+0x18/0x30
> [  719.294527] 	single_release+0x24/0x40
> [  719.294527] 	proc_reg_release+0xed/0x110
> [  719.294527] 	__fput+0x122/0x2d0
> [  719.294527] 	____fput+0x9/0x10
> [  719.294527] 	task_work_run+0xbe/0x100
> [  719.294527] 	do_notify_resume+0x7e/0xa0
> [  719.294527] 	int_signal+0x12/0x17
> [  719.294527] INFO: Slab 0xffffea0001b46800 objects=7 used=7 fp=0x          (null) flags=0x1ffc0000004081
> [  719.294527] INFO: Object 0xffff88006d1a4520 @offset=17696 fp=0x          (null)

Hm, where is sysfs in this traceback?  I don't see it mentioned anywhere
in this report, what am I missing?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
