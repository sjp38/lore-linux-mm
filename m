Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 80CC56B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:02:58 -0500 (EST)
Date: Thu, 8 Mar 2012 13:02:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-Id: <20120308130256.c7855cbd.akpm@linux-foundation.org>
In-Reply-To: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, tyhicks@canonical.com, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>

On Thu,  8 Mar 2012 14:45:16 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This fix the below lockdep warning

OK, what's going on here.

>  ======================================================
>  [ INFO: possible circular locking dependency detected ]
>  3.3.0-rc4+ #190 Not tainted
>  -------------------------------------------------------
>  shared/1568 is trying to acquire lock:
>   (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff811efa0f>] hugetlbfs_file_mmap+0x7d/0x108
> 
>  but task is already holding lock:
>   (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff+0xd4/0x12f
> 
>  which lock already depends on the new lock.
> 
> 
>  the existing dependency chain (in reverse order) is:
> 
>  -> #1 (&mm->mmap_sem){++++++}:
>         [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
>         [<ffffffff810ee439>] might_fault+0x6d/0x90
>         [<ffffffff8111bc12>] filldir+0x6a/0xc2
>         [<ffffffff81129942>] dcache_readdir+0x5c/0x222
>         [<ffffffff8111be58>] vfs_readdir+0x76/0xac
>         [<ffffffff8111bf6a>] sys_getdents+0x79/0xc9
>         [<ffffffff816940a2>] system_call_fastpath+0x16/0x1b
> 
>  -> #0 (&sb->s_type->i_mutex_key#12){+.+.+.}:
>         [<ffffffff8109f40a>] __lock_acquire+0xa6c/0xd60
>         [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
>         [<ffffffff816916be>] __mutex_lock_common+0x48/0x350
>         [<ffffffff81691a85>] mutex_lock_nested+0x2a/0x31
>         [<ffffffff811efa0f>] hugetlbfs_file_mmap+0x7d/0x108
>         [<ffffffff810f4fd0>] mmap_region+0x26f/0x466
>         [<ffffffff810f545b>] do_mmap_pgoff+0x294/0x2ee
>         [<ffffffff810f55a9>] sys_mmap_pgoff+0xf4/0x12f
>         [<ffffffff8103d1f2>] sys_mmap+0x1d/0x1f
>         [<ffffffff816940a2>] system_call_fastpath+0x16/0x1b
> 
>  other info that might help us debug this:
> 
>   Possible unsafe locking scenario:
> 
>         CPU0                    CPU1
>         ----                    ----
>    lock(&mm->mmap_sem);
>                                 lock(&sb->s_type->i_mutex_key#12);
>                                 lock(&mm->mmap_sem);
>    lock(&sb->s_type->i_mutex_key#12);
> 
>   *** DEADLOCK ***
> 
>  1 lock held by shared/1568:
>   #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff+0xd4/0x12f
> 
>  stack backtrace:
>  Pid: 1568, comm: shared Not tainted 3.3.0-rc4+ #190
>  Call Trace:
>   [<ffffffff81688bf9>] print_circular_bug+0x1f8/0x209
>   [<ffffffff8109f40a>] __lock_acquire+0xa6c/0xd60
>   [<ffffffff8110e7b6>] ? files_lglock_local_lock_cpu+0x61/0x61
>   [<ffffffff811efa0f>] ? hugetlbfs_file_mmap+0x7d/0x108
>   [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
>   [<ffffffff811efa0f>] ? hugetlbfs_file_mmap+0x7d/0x108
> 

Why have these lockdep warnings started coming out now - was the VFS
changed to newly take i_mutex somewhere in the directory handling?


Sigh.  Was lockdep_annotate_inode_mutex_key() sufficiently
self-explanatory to justify leaving it undocumented?

<goes off and reads e096d0c7e2e>

OK, the patch looks correct given the explanation in e096d0c7e2e, but
I'd like to understand why it becomes necessary only now.

> NOTE: This patch also require 
> http://thread.gmane.org/gmane.linux.file-systems/58795/focus=59565
> to remove the lockdep warning

And that patch has been basically ignored.

Sigh.  I guess I'll grab both patches, but I'm not confident in doing
so without an overall explanation of what is happening here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
