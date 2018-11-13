Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8EBF6B0294
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:52:42 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id o28-v6so6356753pfk.10
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:52:42 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h3si19307674pgi.391.2018.11.12.21.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 21:52:41 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.9 16/17] userfaultfd: allow get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) to trigger userfaults
Date: Tue, 13 Nov 2018 00:52:22 -0500
Message-Id: <20181113055223.79060-16-sashal@kernel.org>
In-Reply-To: <20181113055223.79060-1-sashal@kernel.org>
References: <20181113055223.79060-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Andrea Arcangeli <aarcange@redhat.com>

[ Upstream commit 3b9aadf7278d16d7bed4d5d808501065f70898d8 ]

get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) called a get_user_pages that would
not be waiting for userfaults before failing and it would hit on a SIGBUS
instead.  Using get_user_pages_locked/unlocked instead will allow
get_mempolicy to allow userfaults to resolve the fault and fill the hole,
before grabbing the node id of the page.

If the user calls get_mempolicy() with MPOL_F_ADDR | MPOL_F_NODE for an
address inside an area managed by uffd and there is no page at that
address, the page allocation from within get_mempolicy() will fail
because get_user_pages() does not allow for page fault retry required
for uffd; the user will get SIGBUS.

With this patch, the page fault will be resolved by the uffd and the
get_mempolicy() will continue normally.

Background:

Via code review, previously the syscall would have returned -EFAULT
(vm_fault_to_errno), now it will block and wait for an userfault (if
it's waken before the fault is resolved it'll still -EFAULT).

This way get_mempolicy will give a chance to an "unaware" app to be
compliant with userfaults.

The reason this visible change is that becoming "userfault compliant"
cannot regress anything: all other syscalls including read(2)/write(2)
had to become "userfault compliant" long time ago (that's one of the
things userfaultfd can do that PROT_NONE and trapping segfaults can't).

So this is just one more syscall that become "userfault compliant" like
all other major ones already were.

This has been happening on virtio-bridge dpdk process which just called
get_mempolicy on the guest space post live migration, but before the
memory had a chance to be migrated to destination.

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
for syscall misbehavior).  Spots like the above are more closer to a
kernel bug for the non-cooperative usages that Mike focuses on, than
for for dpdk qemu-cooperative usages that reproduced it, but it's still
nicer to get this fixed for dpdk too.

The part of the patch that caused me to think is only the
implementation issue of mpol_get, but it looks like it should work safe
no matter the kind of mempolicy structure that is (the default static
policy also starts at 1 so it'll go to 2 and back to 1 without crashing
everything at 0).

[rppt@linux.vnet.ibm.com: changelog addition]
  http://lkml.kernel.org/r/20180904073718.GA26916@rapoport-lnx
Link: http://lkml.kernel.org/r/20180831214848.23676-1-aarcange@redhat.com
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Maxime Coquelin <maxime.coquelin@redhat.com>
Tested-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mempolicy.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 69c4a0c92ebb..625122adefe0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -845,16 +845,19 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 	}
 }
 
-static int lookup_node(unsigned long addr)
+static int lookup_node(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *p;
 	int err;
 
-	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
+	int locked = 1;
+	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p, &locked);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
 	}
+	if (locked)
+		up_read(&mm->mmap_sem);
 	return err;
 }
 
@@ -865,7 +868,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	int err;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
-	struct mempolicy *pol = current->mempolicy;
+	struct mempolicy *pol = current->mempolicy, *pol_refcount = NULL;
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -905,7 +908,16 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
-			err = lookup_node(addr);
+			/*
+			 * Take a refcount on the mpol, lookup_node()
+			 * wil drop the mmap_sem, so after calling
+			 * lookup_node() only "pol" remains valid, "vma"
+			 * is stale.
+			 */
+			pol_refcount = pol;
+			vma = NULL;
+			mpol_get(pol);
+			err = lookup_node(mm, addr);
 			if (err < 0)
 				goto out;
 			*policy = err;
@@ -940,7 +952,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		up_read(&mm->mmap_sem);
+	if (pol_refcount)
+		mpol_put(pol_refcount);
 	return err;
 }
 
-- 
2.17.1
