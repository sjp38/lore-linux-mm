Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 746B16B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 16:00:46 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH] tmpfs not interleaving properly
Date: Wed, 16 May 2012 20:00:39 +0000
Message-ID: <74F10842A85F514CA8D8C487E74474BB2C0429@P-EXMB1-DC21.corp.sgi.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

When tmpfs has the memory policy interleaved it always starts allocating at=
 each file at node 0.
When there are many small files the lower nodes fill up disproportionately.
My proposed solution is to start a file at a randomly chosen node.

Cc: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: stable@vger.kernel.org
Signed-off-by: Nathan T Zimmer <nzimmer@sgi.com>


diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h index 79ab=
255..38eda26 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -17,6 +17,7 @@ struct shmem_inode_info {
 		char		*symlink;	/* unswappable short symlink */
 	};
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
+	int			node_offset;	/* bias for interleaved nodes */
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct list_head	xattr_list;	/* list of shmem_xattr */
 	struct inode		vfs_inode;
diff --git a/mm/shmem.c b/mm/shmem.c
index f99ff3e..58ef512 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -819,7 +819,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
=20
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start =3D 0;
-	pvma.vm_pgoff =3D index;
+	pvma.vm_pgoff =3D index + info->node_offset;
 	pvma.vm_ops =3D NULL;
 	pvma.vm_policy =3D mpol_shared_policy_lookup(&info->policy, index);
=20
@@ -1153,6 +1153,7 @@ static struct inode *shmem_get_inode(struct super_blo=
ck *sb, const struct inode
 			inode->i_fop =3D &shmem_file_operations;
 			mpol_shared_policy_init(&info->policy,
 						 shmem_get_sbmpol(sbinfo));
+			info->node_offset =3D node_random(&node_online_map);
 			break;
 		case S_IFDIR:
 			inc_nlink(inode);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
