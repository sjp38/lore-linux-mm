Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 119748D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 17:24:04 -0500 (EST)
Date: Wed, 9 Mar 2011 14:23:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 30702] New: vmalloc(GFP_NOFS) can callback file system
 evict_inode, inducing deadlock.
Message-Id: <20110309142311.1d8073fe.akpm@linux-foundation.org>
In-Reply-To: <bug-30702-27@https.bugzilla.kernel.org/>
References: <bug-30702-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: prasadjoshi124@gmail.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, "Ricardo M. Correia" <ricardo.correia@oracle.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 7 Mar 2011 19:12:23 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30702
> 
>            Summary: vmalloc(GFP_NOFS) can callback file system
>                     evict_inode, inducing deadlock.

Yeah.

Ricardo has been working on this.  See the thread at
http://marc.info/?l=linux-mm&m=128942194520631&w=4

It's tough, and we've been bad, and progress is slow :(

>            Product: Memory Management
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: prasadjoshi124@gmail.com
>         Regression: No
> 
> 
> I am working on a propitiatory file system development. The problem I am facing
> is with calling __vmalloc in a lock. Though I am working on changing the code
> that I have, I thought it would be good to atleast report the VMALLOC problem.
> 
> The code looks something like this
> 
> const struct file_operations lzfs_file_operations = {
>     .write              = lzfs_vnop_write,
> };
> 
> ssize_t
> lzfs_vnop_write()
> {
>       mutex_lock(some global mutex);
>       ptr = __vmalloc(size, GFP_NOFS | __GFP_HIGHMEM, PAGE_KERNEL);
>       mutex_unlock(some global mutex);
> }
> 
> static const struct super_operations lzfs_super_ops = {
>     .evict_inode    = lzfs_evict_vnode,
> };
> 
> static void
> lzfs_evict_vnode(struct inode *inode)
> {
>       mutex_lock(some global mutex);
> 
>       some code for eviction;
> 
>       mutex_unlock(some global mutex);
> }
> 
> As the __vmalloc is called with GFP_NOFS, I was expecting the evict_inode (or
> clear_inode) would not be called when page cache is purned. But I noticed
> following oops message during the testing.
> 
> [ 5058.193312]  [<ffffffffa092a534>] lzfs_clear_vnode+0x104/0x160 [lzfs]
> [ 5058.193318]  [<ffffffff8116abc5>] clear_inode+0x75/0xf0
> [ 5058.193323]  [<ffffffff8116ac80>] dispose_list+0x40/0x150
> [ 5058.193328]  [<ffffffff8116af23>] prune_icache+0x193/0x2a0
> [ 5058.193332]  [<ffffffff811665e3>] ? prune_dcache+0x183/0x1d0
> [ 5058.193338]  [<ffffffff8116b081>] shrink_icache_memory+0x51/0x60
> [ 5058.193345]  [<ffffffff8110e6d4>] shrink_slab+0x124/0x180
> [ 5058.193349]  [<ffffffff8110ff0f>] do_try_to_free_pages+0x1cf/0x360
> [ 5058.193354]  [<ffffffff8111024b>] try_to_free_pages+0x6b/0x70
> [ 5058.193359]  [<ffffffff8110740a>] __alloc_pages_slowpath+0x27a/0x590
> [ 5058.193365]  [<ffffffff81107884>] __alloc_pages_nodemask+0x164/0x1d0
> [ 5058.193370]  [<ffffffff811397ba>] alloc_pages_current+0x9a/0x100
> [ 5058.193375]  [<ffffffff811066ce>] __get_free_pages+0xe/0x50
> [ 5058.193380]  [<ffffffff81042435>] pte_alloc_one_kernel+0x15/0x20
> [ 5058.193385]  [<ffffffff8111c86b>] __pte_alloc_kernel+0x1b/0xc0
> [ 5058.193391]  [<ffffffff8112ad63>] vmap_pte_range+0x183/0x1a0
> [ 5058.193395]  [<ffffffff8112aec6>] vmap_pud_range+0x146/0x1c0
> [ 5058.193400]  [<ffffffff8112afda>] vmap_page_range_noflush+0x9a/0xc0
> [ 5058.193405]  [<ffffffff8112b032>] map_vm_area+0x32/0x50
> [ 5058.193410]  [<ffffffff8112c4a8>] __vmalloc_area_node+0x108/0x190
> [ 5058.193426]  [<ffffffffa06591a0>] ? kv_alloc+0x90/0x130 [spl]
> [ 5058.193431]  [<ffffffff8112c392>] __vmalloc_node+0xa2/0xb0
> [ 5058.193443]  [<ffffffffa06591a0>] ? kv_alloc+0x90/0x130 [spl]
> [ 5058.193453]  [<ffffffff8112c712>] __vmalloc+0x22/0x30
> [ 5058.193464]  [<ffffffffa06591a0>] kv_alloc+0x90/0x130 [spl]
> [ 5058.194007]  [<ffffffffa0858136>] zfs_grow_blocksize+0x46/0xe0 [zfs]
> [ 5058.194063]  [<ffffffffa08547e8>] zfs_write+0xbb8/0x1100 [zfs]
> [ 5058.194075]  [<ffffffff8114e740>] ? mem_cgroup_charge_common+0x70/0x90
> [ 5058.194082]  [<ffffffffa092ced7>] lzfs_vnop_write+0xc7/0x3b0 [lzfs]
> [ 5058.194087]  [<ffffffff8111bacc>] ? do_anonymous_page+0x11c/0x350
> [ 5058.194096]  [<ffffffff81152ec8>] vfs_write+0xb8/0x1a0
> [ 5058.194100]  [<ffffffff81153711>] sys_write+0x51/0x80
> [ 5058.194105]  [<ffffffff8100a0f2>] system_call_fastpath+0x16/0x1b
> 
> The problem is with __vmalloc (map_vm_area) which discards the allocation flag
> while mapping the scattered physical pages contiguously into the virtual
> vmalloc area. 
> 
> 1482 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
> 1483                  pgprot_t prot, int node, void *caller)
> 1484 {
> 1525     if (map_vm_area(area, prot, &pages, gfp_mask))
> 1526         goto fail;
> 1527     return area->addr;
> 1532 }
> 
> The function map_vm_area() can result in calls to 
> pud_alloc
> pmd_alloc
> pte_alloc_kernel
> 
> Which allocate memory using flag GFP_KERNEL
> for example
> pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
> {
>     pte_t *pte;
> 
>     pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
>     return pte;
> }
> 
> The page allocation might trigger the clear_inode (or evict_inode) if the
> system is running short of the memory. Thus causing the oops.
> 
> Though non of the file system in Linux Kernel seems to calling vmalloc in a
> lock, it would be good to fix the problem anyway.
> 
> As far as I can understand the solution is to pass the gfp_mask down the call
> hierarchy. I wanted to send the patch with these changes, but soon I realized
> changes are needed at various places and are too much. I thought to reporting
> the problem first.
> 
> Thanks and Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
