Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF6978E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 14:27:28 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so33857296edt.23
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 11:27:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si979277edi.431.2019.01.03.11.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 11:27:27 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 03 Jan 2019 20:27:26 +0100
From: Roman Penyaev <rpenyaev@suse.de>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix size check for
 remap_vmalloc_range_partial()
In-Reply-To: <20190103151357.GR31793@dhcp22.suse.cz>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-2-rpenyaev@suse.de>
 <20190103151357.GR31793@dhcp22.suse.cz>
Message-ID: <dba7cb2c2882e034c8c99b09a432313a@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R." Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org," linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 2019-01-03 16:13, Michal Hocko wrote:
> On Thu 03-01-19 15:59:52, Roman Penyaev wrote:
>> area->size can include adjacent guard page but get_vm_area_size()
>> returns actual size of the area.
>> 
>> This fixes possible kernel crash when userspace tries to map area
>> on 1 page bigger: size check passes but the following 
>> vmalloc_to_page()
>> returns NULL on last guard (non-existing) page.
> 
> Can this actually happen? I am not really familiar with all the callers
> of this API but VM_NO_GUARD is not really used wildly in the kernel.

Exactly, by default (VM_NO_GUARD is not set) each area has guard page,
thus the area->size will be bigger.  The bug is not reproduced if
VM_NO_GUARD is set.

> All I can see is kasan na arm64 which doesn't really seem to use it
> for vmalloc.
> 
> So is the problem real or this is a mere cleanup?

This is the real problem, try this hunk for any file descriptor which 
provides
mapping, or say modify epoll as example:

--------------------------------
diff --git a/fs/eventpoll.c b/fs/eventpoll.c

+static int ep_mmap(struct file *file, struct vm_area_struct *vma)
+{
+       void *mem;
+
+       mem = vmalloc_user(4096);
+       BUG_ON(!mem);
+       /* Do not care about mem leak */
+
+       return remap_vmalloc_range(vma, mem, 0);
+}
+
  /* File callbacks that implement the eventpoll file behaviour */
  static const struct file_operations eventpoll_fops = {
  #ifdef CONFIG_PROC_FS
         .show_fdinfo    = ep_show_fdinfo,
  #endif
+       .mmap           = ep_mmap,
         .release        = ep_eventpoll_release,
--------------------------------

and the following code from userspace, which maps 2 pages,
instead of 1:

--------------------------------
epfd = epoll_create1(0);
assert(epfd >= 0);

p = mmap(NULL, 2<<12, PROT_WRITE|PROT_READ, MAP_PRIVATE, epfd, 0);
assert(p != MAP_FAILED);
--------------------------------

You immediately get the following oops:

[   38.894571] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000008
[   38.899048] #PF error: [normal kernel read fault]
[   38.901487] PGD 0 P4D 0
[   38.902801] Oops: 0000 [#1] PREEMPT SMP PTI
[   38.904984] CPU: 2 PID: 399 Comm: mmap-epoll Not tainted 4.20.0-1 
#238
[   38.914064] RIP: 0010:vm_insert_page+0x3b/0x1d0
[   38.941181] Call Trace:
[   38.941656]  remap_vmalloc_range_partial+0x8d/0xd0
[   38.942417]  mmap_region+0x3c7/0x630
[   38.942982]  do_mmap+0x38d/0x560
[   38.943479]  vm_mmap_pgoff+0x9a/0xf0
[   38.944028]  ksys_mmap_pgoff+0x18e/0x220
[   38.944554]  do_syscall_64+0x48/0xf0
[   38.945076]  entry_SYSCALL_64_after_hwframe+0x44/0xa9

--
Roman
