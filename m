Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B22996B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 01:43:42 -0500 (EST)
Received: by lagj5 with SMTP id j5so986137lag.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:43:40 -0800 (PST)
Date: Thu, 12 Jan 2012 08:43:26 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
In-Reply-To: <alpine.DEB.2.00.1201111346180.21755@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1201120842140.2054@tux.localdomain>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com> <alpine.DEB.2.00.1201111346180.21755@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, lizf@cn.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 11 Jan 2012, Sasha Levin wrote:
>> memdup_user() is called when we need to copy data from userspace. This
>> means that a user is able to trigger warnings if the kmalloc() inside
>> memdup_user() fails.
>>
>> For example, this is one caused by writing to much data to ecryptdev:
>>
>> [  912.739685] ------------[ cut here ]------------
>> [  912.745080] WARNING: at mm/page_alloc.c:2217 __alloc_pages_nodemask+0x22c/0x910()
>> [  912.746525] Pid: 19977, comm: trinity Not tainted 3.2.0-next-20120110-sasha #120
>> [  912.747915] Call Trace:
>> [  912.748415]  [<ffffffff8115ec5c>] ? __alloc_pages_nodemask+0x22c/0x910
>> [  912.749651]  [<ffffffff8109a2d5>] warn_slowpath_common+0x75/0xb0
>> [  912.750756]  [<ffffffff8109a3d5>] warn_slowpath_null+0x15/0x20
>> [  912.751831]  [<ffffffff8115ec5c>] __alloc_pages_nodemask+0x22c/0x910
>> [  912.754230]  [<ffffffff81070fd5>] ? pvclock_clocksource_read+0x55/0xd0
>> [  912.755484]  [<ffffffff8106ff56>] ? kvm_clock_read+0x46/0x80
>> [  912.756565]  [<ffffffff810d1548>] ? sched_clock_cpu+0xc8/0x140
>> [  912.757667]  [<ffffffff810cc731>] ? get_parent_ip+0x11/0x50
>> [  912.758731]  [<ffffffff810cc731>] ? get_parent_ip+0x11/0x50
>> [  912.759890]  [<ffffffff81341a4b>] ? ecryptfs_miscdev_write+0x6b/0x240
>> [  912.761119]  [<ffffffff81196c80>] alloc_pages_current+0xa0/0x110
>> [  912.762269]  [<ffffffff8115ba1f>] __get_free_pages+0xf/0x40
>> [  912.763347]  [<ffffffff811a6082>] __kmalloc_track_caller+0x172/0x190
>> [  912.764561]  [<ffffffff8116f0ab>] memdup_user+0x2b/0x90
>> [  912.765526]  [<ffffffff81341a4b>] ecryptfs_miscdev_write+0x6b/0x240
>> [  912.766669]  [<ffffffff813419e0>] ? ecryptfs_miscdev_open+0x190/0x190
>> [  912.767832]  [<ffffffff811ba360>] do_loop_readv_writev+0x50/0x80
>> [  912.770735]  [<ffffffff811ba69e>] do_readv_writev+0x1ce/0x1e0
>> [  912.773059]  [<ffffffff8251bbbc>] ? __mutex_unlock_slowpath+0x10c/0x200
>> [  912.774634]  [<ffffffff810cc731>] ? get_parent_ip+0x11/0x50
>> [  912.775699]  [<ffffffff810cc8dd>] ? sub_preempt_count+0x9d/0xd0
>> [  912.776827]  [<ffffffff8251f09d>] ? retint_swapgs+0x13/0x1b
>> [  912.777887]  [<ffffffff811ba758>] vfs_writev+0x48/0x60
>> [  912.779162]  [<ffffffff811ba86f>] sys_writev+0x4f/0xb0
>> [  912.780152]  [<ffffffff8251f979>] system_call_fastpath+0x16/0x1b
>> [  912.793046] ---[ end trace 50c38c9cdee53379 ]---
>> [  912.793906] ecryptfs_miscdev_write: memdup_user returned error [-12]
>>
>> Failing memdup_user() shouldn't be generating warnings, instead it should
>> be notifying userspace about the error.
>>
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

On Wed, 11 Jan 2012, David Rientjes wrote:
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

Sasha, I suppose strndup_user() has the same kind of issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
