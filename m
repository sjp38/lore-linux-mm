Date: Mon, 4 Jun 2007 13:43:33 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: tmpfs and numa mempolicy
In-Reply-To: <20070603203003.64fd91a8.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
References: <20070603203003.64fd91a8.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Sun, 3 Jun 2007, Randy Dunlap wrote:
> 
> If someone mounts tmpfs as in
> 
> > mount -t tmpfs -o size=10g,nr_inodes=10k,mode=777,mpol=prefer:1 \
> 	tmpfs /mytmpfs
> 
> but does not have a node 1, bad things happen when /mytmpfs is accessed.
> (CONFIG_NUMA=y)
> 
> Is this just a case of shoot self in foot, DDT (don't do that)?

Thanks for finding that, Randy.

While it's true that you have to be privileged to mount in the first
place (so this isn't too serious), I don't think we can dismiss it as
just root shooting own foot: we are in the habit of validating mount
arguments to avoid obvious crashes, so ought to do something about this.

I've appended a patch to check node_online_map below, and update
tmpfs.txt accordingly.  I'm not entirely happy with it: you and I
rather need to undo it when testing whether the mpol= parsing works,
and it is more restrictive than Robin or I intended.

But it looks to me like mempolicy.c normally never lets a nonline
node get into any of its policies, and it would be a bit tedious,
error-prone and unnecessary overhead to relax that: so tmpfs mount
is at present a dangerous exception in this regard.

Would you be happy with this change, Robin?  I'm not very NUMArate:
do nodes in fact ever get onlined after early system startup?
If not, then this change would hardly be any real limitation.

Hugh

> a.  cp somefile /mytmpfs
> 
> Unable to handle kernel paging request at 00000000000019e8 RIP: 
>  [<ffffffff8026c369>] __alloc_pages+0x3e/0x2c6
> Pid: 3762, comm: cp Not tainted 2.6.22-rc3 #2
> Call Trace:
>  [<ffffffff8028494d>] shmem_swp_entry+0x4b/0x14a
>  [<ffffffff8028330a>] alloc_page_vma+0x7c/0x85
>  [<ffffffff8028548f>] shmem_getpage+0x453/0x6e8
>  [<ffffffff802868d1>] shmem_file_write+0x124/0x217
>  [<ffffffff8028c32d>] vfs_write+0xae/0x137
>  [<ffffffff8028c895>] sys_write+0x47/0x70
>  [<ffffffff8020948e>] system_call+0x7e/0x83
> 
> b.  umount /mytmpfs
> 
> kernel BUG at mm/shmem.c:775!

This umount BUG is just an untidy consequence of the first oops.


[PATCH] mount -t tmpfs -o mpol= check nodes online

Randy Dunlap reports that a tmpfs, mounted with NUMA mpol= specifying
an offline node, crashes as soon as data is allocated upon it.  Now
restrict it to online nodes, where before it restricted to MAX_NUMNODES.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
 Documentation/filesystems/tmpfs.txt |   10 +++++-----
 mm/shmem.c                          |    2 ++
 2 files changed, 7 insertions(+), 5 deletions(-)

--- 2.6.22-rc3/Documentation/filesystems/tmpfs.txt	2006-11-29 21:57:37.000000000 +0000
+++ linux/Documentation/filesystems/tmpfs.txt	2007-06-04 12:54:17.000000000 +0100
@@ -94,10 +94,10 @@ largest node numbers in the range.  For 
 
 Note that trying to mount a tmpfs with an mpol option will fail if the
 running kernel does not support NUMA; and will fail if its nodelist
-specifies a node >= MAX_NUMNODES.  If your system relies on that tmpfs
-being mounted, but from time to time runs a kernel built without NUMA
-capability (perhaps a safe recovery kernel), or configured to support
-fewer nodes, then it is advisable to omit the mpol option from automatic
+specifies a node which is not online.  If your system relies on that
+tmpfs being mounted, but from time to time runs a kernel built without
+NUMA capability (perhaps a safe recovery kernel), or with fewer nodes
+online, then it is advisable to omit the mpol option from automatic
 mount options.  It can be added later, when the tmpfs is already mounted
 on MountPoint, by 'mount -o remount,mpol=Policy:NodeList MountPoint'.
 
@@ -121,4 +121,4 @@ RAM/SWAP in 10240 inodes and it is only 
 Author:
    Christoph Rohland <cr@sap.com>, 1.12.01
 Updated:
-   Hugh Dickins <hugh@veritas.com>, 19 February 2006
+   Hugh Dickins <hugh@veritas.com>, 4 June 2007
--- 2.6.22-rc3/mm/shmem.c	2007-05-21 13:13:20.000000000 +0100
+++ linux/mm/shmem.c	2007-06-04 12:54:17.000000000 +0100
@@ -967,6 +967,8 @@ static inline int shmem_parse_mpol(char 
 		*nodelist++ = '\0';
 		if (nodelist_parse(nodelist, *policy_nodes))
 			goto out;
+		if (!nodes_subset(*policy_nodes, node_online_map))
+			goto out;
 	}
 	if (!strcmp(value, "default")) {
 		*policy = MPOL_DEFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
