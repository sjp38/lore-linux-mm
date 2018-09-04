Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E89286B6F55
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 16:14:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c22-v6so3296237qkb.18
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 13:14:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k8-v6si12333967qtp.52.2018.09.04.13.14.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 13:14:30 -0700 (PDT)
Date: Tue, 4 Sep 2018 16:14:25 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: allow
 get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) to trigger userfaults
Message-ID: <20180904201425.GH4762@redhat.com>
References: <20180831214848.23676-1-aarcange@redhat.com>
 <20180903163312.4d758536e1208f8927d886e9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180903163312.4d758536e1208f8927d886e9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Maxime Coquelin <maxime.coquelin@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi Andrew,

On Mon, Sep 03, 2018 at 04:33:12PM -0700, Andrew Morton wrote:
> On Fri, 31 Aug 2018 17:48:48 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) called a get_user_pages that
> > would not be waiting for userfaults before failing and it would hit on
> > a SIGBUS instead. Using get_user_pages_locked/unlocked instead will
> > allow get_mempolicy to allow userfaults to resolve the fault and fill
> > the hole, before grabbing the node id of the page.
> 
> What is the userspace visible impact of this change?

Yes that's a good question because there's a visible impact, but it's
of the non problematic kind.

>From code review, previously the syscall would have returned -EFAULT
(vm_fault_to_errno), now it will block and wait for an userfault (if
it's waken before the fault is resolved it'll still -EFAULT).

This way get_mempolicy will give a chance to an "unaware" app to be
compliant with userfaults.

The reason this visible change is that becoming "userfault compliant"
cannot regress anything: all other syscalls including read(2)/write(2)
had to become "userfault compliant" long time ago (that's one of the
things userfaultfd can do that PROT_NONE and trapping segfaults
can't).

So this is just one more syscall that become "userfault compliant"
like all other major ones already were.

This has been happening on virtio-bridge dpdk process which just
called get_mempolicy on the guest space post live migration, but
before the memory had a chance to be migrated to destination.

I didn't run an strace to be able to show the -EFAULT going away, but
I've the confirmation of the below debug aid information (only visible
with CONFIG_DEBUG_VM=y) going away with the patch:

    [20116.371461] FAULT_FLAG_ALLOW_RETRY missing 0
    [20116.371464] CPU: 1 PID: 13381 Comm: vhost-events Not tainted 4.17.12-200.fc28.x86_64 #1
    [20116.371465] Hardware name: LENOVO 20FAS2BN0A/20FAS2BN0A, BIOS N1CET54W (1.22 ) 02/10/2017
    [20116.371466] Call Trace:
    [20116.371473]  dump_stack+0x5c/0x80
    [20116.371476]  handle_userfault.cold.37+0x1b/0x22
    [20116.371479]  ? remove_wait_queue+0x20/0x60
    [20116.371481]  ? poll_freewait+0x45/0xa0
    [20116.371483]  ? do_sys_poll+0x31c/0x520
    [20116.371485]  ? radix_tree_lookup_slot+0x1e/0x50
    [20116.371488]  shmem_getpage_gfp+0xce7/0xe50
    [20116.371491]  ? page_add_file_rmap+0x1a/0x2c0
    [20116.371493]  shmem_fault+0x78/0x1e0
    [20116.371495]  ? filemap_map_pages+0x3a1/0x450
    [20116.371498]  __do_fault+0x1f/0xc0
    [20116.371500]  __handle_mm_fault+0xe2e/0x12f0
    [20116.371502]  handle_mm_fault+0xda/0x200
    [20116.371504]  __get_user_pages+0x238/0x790
    [20116.371506]  get_user_pages+0x3e/0x50
    [20116.371510]  kernel_get_mempolicy+0x40b/0x700
    [20116.371512]  ? vfs_write+0x170/0x1a0
    [20116.371515]  __x64_sys_get_mempolicy+0x21/0x30
    [20116.371517]  do_syscall_64+0x5b/0x160
    [20116.371520]  entry_SYSCALL_64_after_hwframe+0x44/0xa9

The above harmless debug message (not a kernel crash, just a
dump_stack()) is shown with CONFIG_DEBUG_VM=y to more quickly identify
and improve kernel spots that may have to become "userfaultfd
compliant" like this one (without having to run an strace and search
for syscall misbehavior). Spots like the above are more closer to a
kernel bug for the non-cooperative usages that Mike focuses on, than
for for dpdk qemu-cooperative usages that reproduced it, but it's
still nicer to get this fixed for dpdk too.

The part of the patch that that gave me to think is only the
implementation issue of mpol_get, but it looks like it should work
safe no matter the kind of mempolicy structure that is (the default
static policy also starts at 1 so it'll go to 2 and back to 1 without
crashing everything at 0).

Thanks!
Andrea
