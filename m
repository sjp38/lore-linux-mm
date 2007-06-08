Date: Fri, 8 Jun 2007 16:55:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
Message-Id: <20070608165505.aa15fcdb.akpm@linux-foundation.org>
In-Reply-To: <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	<20070606204432.b670a7b1.akpm@linux-foundation.org>
	<787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	<20070607162004.GA27802@vino.hallyn.com>
	<m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	<46697EDA.9000209@us.ibm.com>
	<m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 08 Jun 2007 17:43:34 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Some user space tools need to identify SYSV shared memory when
> examining /proc/<pid>/maps.  To do so they look for a block device
> with major zero, a dentry named SYSV<sysv key>, and having the minor of
> the internal sysv shared memory kernel mount.
> 
> To help these tools and to make it easier for people just browsing
> /proc/<pid>/maps this patch modifies hugetlb sysv shared memory to
> use the SYSV<key> dentry naming convention.
> 
> User space tools will still have to be aware that hugetlb sysv
> shared memory lives on a different internal kernel mount and so
> has a different block device minor number from the rest of sysv
> shared memory.

I assume this fix is preferred over Badari's?  If so, why?



From: Badari Pulavarty <pbadari@us.ibm.com>

shmid used to be stored as inode# for shared memory segments. Some of
the proc-ps tools use this from /proc/pid/maps.  Recent cleanups
to newseg() changed it.  This patch sets inode number back to shared
memory id to fix breakage.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
Cc: "Albert Cahalan" <acahalan@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 ipc/shm.c |    5 +++++
 1 files changed, 5 insertions(+)

diff -puN ipc/shm.c~restore-shmid-as-inode-to-fix-proc-pid-maps-abi-breakage ipc/shm.c
--- a/ipc/shm.c~restore-shmid-as-inode-to-fix-proc-pid-maps-abi-breakage
+++ a/ipc/shm.c
@@ -397,6 +397,11 @@ static int newseg (struct ipc_namespace 
 	shp->shm_nattch = 0;
 	shp->id = shm_buildid(ns, id, shp->shm_perm.seq);
 	shp->shm_file = file;
+	/*
+	 * shmid gets reported as "inode#" in /proc/pid/maps.
+	 * proc-ps tools use this. Changing this will break them.
+	 */
+	file->f_dentry->d_inode->i_ino = shp->id;
 
 	ns->shm_tot += numpages;
 	shm_unlock(shp);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
