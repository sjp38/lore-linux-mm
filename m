Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CAC606B015D
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 18:44:46 -0500 (EST)
Received: from 75-25-157-42.uvs.sntcca.sbcglobal.net ([75.25.157.42] helo=dogmatix)
	by byss.tchmachines.com with esmtpa (Exim 4.69)
	(envelope-from <kiran@scalex86.org>)
	id 1NqEWw-0006Le-5R
	for linux-mm@kvack.org; Fri, 12 Mar 2010 18:44:34 -0500
Resent-Message-ID: <20100312234442.GB4542@localhost.localdomain>
Resent-To: linux-mm@kvack.org
Date: Fri, 12 Mar 2010 15:41:15 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch] Oops on tmpfs remounts with mpol=default
Message-ID: <20100312234115.GA4542@localhost.localdomain>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="CUfgB8w4ZwR/yMy5"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

One of our customers reported an Oops when trying to remount a tmpfs mount
back with  'default' mempolicy after changing it to a non default policy.

Upon examination of code, I found that the kernel remount code tries to
dereference the 'NULL' mempolicy object returned by mpol_new at
mpol_parse_str.

Attached is the oops snippet.  Please find the proposed fix inline.

Thanks,
Kiran

---

Fix an 'oops' when a tmpfs mount point is remounted with the 'default'
mempolicy.

Upon remounting a tmpfs mount point with 'mpol=default' option, the remount
code crashed with a null pointer dereference.  The initial problem report was
on 2.6.27, but the problem exists in mainline 2.6.34-rc  as well. On
examining the code, we see that mpol_new returns NULL if default mempolicy
was requested.   This 'NULL' mempolicy is accessed to store the node mask
resulting in oops.

The following patch fixes the oops by avoiding dereferencing NULL if the
new mempolicy is NULL.
The patch also sets 'err' to 0 if MPOL_DEFAULT is passed (err is initialized
to 1 initially at mpol_parse_str())


Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index bda230e..a86277d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2213,10 +2213,14 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 			goto out;
 		mode = MPOL_PREFERRED;
 		break;
-
+	case MPOL_DEFAULT:
+		/*
+		 * mpol_new() enforces empty nodemask, ignores flags.
+		 */
+		err = 0;
+		break;
 	/*
 	 * case MPOL_BIND:    mpol_new() enforces non-empty nodemask.
-	 * case MPOL_DEFAULT: mpol_new() enforces empty nodemask, ignores flags.
 	 */
 	}
 
@@ -2250,7 +2254,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		if (ret) {
 			err = 1;
 			mpol_put(new);
-		} else if (no_context) {
+		} else if (no_context && new) {
 			/* save for contextualization */
 			new->w.user_nodemask = nodes;
 		}

--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=oops


[ 1159.848055] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
[ 1159.856087] IP: [<ffffffff810ac096>] mpol_parse_str+0x1c6/0x2b0
[ 1159.856472] PGD a7dfd067 PUD aa1fe067 PMD 0 
[ 1159.856472] Oops: 0002 [#1] SMP 
[ 1159.856472] last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:0a:01.0/local_cpus
[ 1159.876476] CPU 7 
[ 1159.876476] Modules linked in: nfs lockd nfs_acl sunrpc ecb cbc md5 aes_generic iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi
[ 1159.876476] 
[ 1159.876476] Pid: 6235, comm: mount Not tainted 2.6.34-rc1-00005-g522dba7 #5 B7DW3/B7DW3
[ 1159.876476] RIP: 0010:[<ffffffff810ac096>]  [<ffffffff810ac096>] mpol_parse_str+0x1c6/0x2b0
[ 1159.876476] RSP: 0018:ffff8800aa125d68  EFLAGS: 00010202
[ 1159.876476] RAX: 0000000000000000 RBX: ffff8800ab7ed000 RCX: 0000000000000000
[ 1159.876476] RDX: ffff8800aa125d78 RSI: 0000000000000001 RDI: 0000000000000000
[ 1159.876476] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000008
[ 1159.876476] R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000001
[ 1159.876476] R13: 0000000000000000 R14: 0000000000000000 R15: ffff8800aa125e58
[ 1159.876476] FS:  00007fc29bc47760(0000) GS:ffff8800ac400000(0000) knlGS:0000000000000000
[ 1159.876476] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1159.876476] CR2: 0000000000000010 CR3: 00000000a9a93000 CR4: 00000000000006e0
[ 1159.876476] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1159.876476] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1159.876476] Process mount (pid: 6235, threadinfo ffff8800aa124000, task ffff8800ab7ed000)
[ 1159.876476] Stack:
[ 1159.876476]  000001fe000001fe 00000001aafe0a80 ffff8800aafe0b48 ffffffff810ccb3f
[ 1159.876476] <0> 0000000000000000 0000006700000000 0000006800000068 0000000000000000
[ 1159.876476] <0> ffff8800a7663000 ffff8800a7663005 ffff8800aa125e28 ffff8800aa125de8
[ 1159.876476] Call Trace:
[ 1159.876476]  [<ffffffff810ccb3f>] ? mntput_no_expire+0x1f/0xa0
[ 1159.876476]  [<ffffffff8108c7ac>] ? shmem_parse_options+0x2ac/0x2e0
[ 1159.876476]  [<ffffffff810c1313>] ? do_path_lookup+0x33/0x60
[ 1159.876476]  [<ffffffff8108d42d>] ? shmem_remount_fs+0x5d/0x110
[ 1159.876476]  [<ffffffff810b735f>] ? do_remount_sb+0x7f/0x180
[ 1159.876476]  [<ffffffff810cdef8>] ? do_mount+0x668/0x800
[ 1159.876476]  [<ffffffff810cc4fd>] ? copy_mount_options+0x10d/0x180
[ 1159.876476]  [<ffffffff810ce125>] ? sys_mount+0x95/0xf0
[ 1159.876476]  [<ffffffff81002302>] ? system_call_fastpath+0x16/0x1b
[ 1159.876476] Code: 54 24 10 48 8d 74 24 20 48 89 ef e8 a5 e2 ff ff fe 83 cc 04 00 00 85 c0 75 1a 8b 74 24 0c 85 f6 0f 84 b8 fe ff ff 48 8b 44 24 20 <48> 89 45 10 e9 aa fe ff ff 48 85 ed 0f 84 ca 00 00 00 48 89 ef 
[ 1159.876476] RIP  [<ffffffff810ac096>] mpol_parse_str+0x1c6/0x2b0
[ 1159.876476]  RSP <ffff8800aa125d68>
[ 1159.876476] CR2: 0000000000000010
[ 1159.878411] ---[ end trace 0c86a8c1b0b4c73c ]---

--CUfgB8w4ZwR/yMy5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
