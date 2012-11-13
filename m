Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 389B66B0078
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 19:06:51 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5095196pad.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 16:06:50 -0800 (PST)
Date: Mon, 12 Nov 2012 16:06:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v7
 fix fix fix
In-Reply-To: <509D88C6.8030700@infradead.org>
Message-ID: <alpine.DEB.2.00.1211121553300.3841@chino.kir.corp.google.com>
References: <20121108231753.E6B7A100047@wpzn3.hot.corp.google.com> <509D88C6.8030700@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On Fri, 9 Nov 2012, Randy Dunlap wrote:

> on x86_64:
> 
> In file included from mm/mprotect.c:13:0:
> include/linux/shm.h:57:20: error: redefinition of 'do_shmat'
> include/linux/shm.h:57:20: note: previous definition of 'do_shmat' was here
> include/linux/shm.h:63:19: error: redefinition of 'is_file_shm_hugepages'
> include/linux/shm.h:63:19: note: previous definition of 'is_file_shm_hugepages' was here
> include/linux/shm.h:67:20: error: redefinition of 'exit_shm'
> include/linux/shm.h:67:20: note: previous definition of 'exit_shm' was here
> 
> In file included from include/linux/hugetlb.h:16:0,
>                  from mm/mmap.c:23:
> include/linux/shm.h:57:20: error: redefinition of 'do_shmat'
> include/linux/shm.h:57:20: note: previous definition of 'do_shmat' was here
> include/linux/shm.h:63:19: error: redefinition of 'is_file_shm_hugepages'
> include/linux/shm.h:63:19: note: previous definition of 'is_file_shm_hugepages' was here
> include/linux/shm.h:67:20: error: redefinition of 'exit_shm'
> include/linux/shm.h:67:20: note: previous definition of 'exit_shm' was here
> make[2]: *** [mm/mprotect.o] Error 1
> 

This is an elusive one, I couldn't reproduce it with master.  This appears 
to only happen on the akpm branch, correct?

It happens because of e37c64a9751a ("mm: support more pagesizes for 
MAP_HUGETLB/SHM_HUGETLB") adds a spurious "#endif" to include/linux/shm.h 
and gets reverted in master by 359078d82a20 ("Revert "mm: support more 
pagesizes for MAP_HUGETLB/SHM_HUGETLB"") because of another build failure 
that Stephen reports on November 8:

mm/mmap.c: In function 'SYSC_mmap_pgoff':
mm/mmap.c:1271:15: error: 'MAP_HUGE_SHIFT' undeclared (first use in this function)
mm/mmap.c:1271:15: note: each undeclared identifier is reported only once for each function it appears in
mm/mmap.c:1271:33: error: 'MAP_HUGE_MASK' undeclared (first use in this function)

I think the best bet would be to merge the following in -mm and then let 
Stephen revert it in master again if his build error persists for powerpc:


mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix-fix-fix

Fix the build:

include/linux/shm.h:57:20: error: redefinition of 'do_shmat'
include/linux/shm.h:57:20: note: previous definition of 'do_shmat' was here
include/linux/shm.h:63:19: error: redefinition of 'is_file_shm_hugepages'
include/linux/shm.h:63:19: note: previous definition of 'is_file_shm_hugepages' was here
include/linux/shm.h:67:20: error: redefinition of 'exit_shm'
include/linux/shm.h:67:20: note: previous definition of 'exit_shm' was here

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/shm.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -23,8 +23,6 @@ struct shmid_kernel /* private to the kernel */
 	struct task_struct	*shm_creator;
 };
 
-#endif
-
 /* shm_mode upper byte flags */
 #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
 #define SHM_LOCKED      02000   /* segment will not be swapped */
@@ -46,8 +44,6 @@ struct shmid_kernel /* private to the kernel */
 #define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
 #define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
 
-#ifdef __KERNEL__
-
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr,
 	      unsigned long shmlba);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
