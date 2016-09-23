Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC486B0286
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:13:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so223277772pfv.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:13:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o4si7900128paa.223.2016.09.23.06.13.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 06:13:50 -0700 (PDT)
From: Robert Ho <robert.hu@intel.com>
Subject: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Date: Fri, 23 Sep 2016 21:12:33 +0800
Message-Id: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, oleg@redhat.com, dan.j.williams@intel.com, dave.hansen@intel.com
Cc: guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, robert.hu@intel.com

From: Xiao Guangrong <guangrong.xiao@linux.intel.com>

Recently, Redhat reported that nvml test suite failed on QEMU/KVM,
more detailed info please refer to:
   https://bugzilla.redhat.com/show_bug.cgi?id=1365721

Actually, this bug is not only for NVDIMM/DAX but also for any other file
systems. This simple test case abstracted from nvml can easily reproduce
this bug in common environment:

-------------------------- testcase.c -----------------------------

int
is_pmem_proc(const void *addr, size_t len)
{
        const char *caddr = addr;

        FILE *fp;
        if ((fp = fopen("/proc/self/smaps", "r")) == NULL) {
                printf("!/proc/self/smaps");
                return 0;
        }

        int retval = 0;         /* assume false until proven otherwise */
        char line[PROCMAXLEN];  /* for fgets() */
        char *lo = NULL;        /* beginning of current range in smaps file */
        char *hi = NULL;        /* end of current range in smaps file */
        int needmm = 0;         /* looking for mm flag for current range */
        while (fgets(line, PROCMAXLEN, fp) != NULL) {
                static const char vmflags[] = "VmFlags:";
                static const char mm[] = " wr";

                /* check for range line */
                if (sscanf(line, "%p-%p", &lo, &hi) == 2) {
                        if (needmm) {
                                /* last range matched, but no mm flag found */
                                printf("never found mm flag.\n");
                                break;
                        } else if (caddr < lo) {
                                /* never found the range for caddr */
                                printf("#######no match for addr %p.\n", caddr);
                                break;
                        } else if (caddr < hi) {
                                /* start address is in this range */
                                size_t rangelen = (size_t)(hi - caddr);

                                /* remember that matching has started */
                                needmm = 1;

                                /* calculate remaining range to search for */
                                if (len > rangelen) {
                                        len -= rangelen;
                                        caddr += rangelen;
                                        printf("matched %zu bytes in range "
                                                "%p-%p, %zu left over.\n",
                                                        rangelen, lo, hi, len);
                                } else {
                                        len = 0;
                                        printf("matched all bytes in range "
                                                        "%p-%p.\n", lo, hi);
                                }
                        }
                } else if (needmm && strncmp(line, vmflags,
                                        sizeof(vmflags) - 1) == 0) {
                        if (strstr(&line[sizeof(vmflags) - 1], mm) != NULL) {
                                printf("mm flag found.\n");
                                if (len == 0) {
                                        /* entire range matched */
                                        retval = 1;
                                        break;
                                }
                                needmm = 0;     /* saw what was needed */
                        } else {
                                /* mm flag not set for some or all of range */
                                printf("range has no mm flag.\n");
                                break;
                        }
                }
        }

        fclose(fp);

        printf("returning %d.\n", retval);
        return retval;
}

void *Addr;
size_t Size;

/*
 * worker -- the work each thread performs
 */
static void *
worker(void *arg)
{
        int *ret = (int *)arg;
        *ret =  is_pmem_proc(Addr, Size);
        return NULL;
}

int main(int argc, char *argv[])
{
        if (argc <  2 || argc > 3) {
                printf("usage: %s file [env].\n", argv[0]);
                return -1;
        }

        int fd = open(argv[1], O_RDWR);

        struct stat stbuf;
        fstat(fd, &stbuf);

        Size = stbuf.st_size;
        Addr = mmap(0, stbuf.st_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);

        close(fd);

        pthread_t threads[NTHREAD];
        int ret[NTHREAD];

        /* kick off NTHREAD threads */
        for (int i = 0; i < NTHREAD; i++)
                pthread_create(&threads[i], NULL, worker, &ret[i]);

        /* wait for all the threads to complete */
        for (int i = 0; i < NTHREAD; i++)
                pthread_join(threads[i], NULL);

        /* verify that all the threads return the same value */
        for (int i = 1; i < NTHREAD; i++) {
                if (ret[0] != ret[i]) {
                        printf("Error i %d ret[0] = %d ret[i] = %d.\n", i,
                                ret[0], ret[i]);
                }
        }

        printf("%d", ret[0]);
        return 0;
}

It failed as some threads can not find the memory region in
"/proc/self/smaps" which is allocated in the main process

It is caused by proc fs which uses 'file->version' to indicate the VMA that
is the last one has already been handled by read() system call. When the
next read() issues, it uses the 'version' to find the VMA, then the next
VMA is what we want to handle, the related code is as follows:

        if (last_addr) {
                vma = find_vma(mm, last_addr);
                if (vma && (vma = m_next_vma(priv, vma)))
                        return vma;
        }

However, VMA will be lost if the last VMA is gone, e.g:

The process VMA list is A->B->C->D

CPU 0                                  CPU 1
read() system call
   handle VMA B
   version = B
return to userspace

                                   unmap VMA B

issue read() again to continue to get
the region info
   find_vma(version) will get VMA C
   m_next_vma(C) will get VMA D
   handle D
   !!! VMA C is lost !!!

In order to fix this bug, we make 'file->version' indicate the end address
of current VMA

Changelog:
v3:
	Thank Michal's pointing. Fix the incompletion of v2's fixing:
"/proc/<pid>/smaps will report counters for the full vma range while
the header (aka show_map_vma) will report shorter (non-overlapping) range"
    Add description in Documentation/filesystems/proc.txt, regarding maps,
smaps reading's guaruntees.

v2:
Thanks to Dave Hansen's comments, this version fixes the issue in v1 that
same virtual address range may be outputted twice, e.g:

Take two example VMAs:

	vma-A: (0x1000 -> 0x2000)
	vma-B: (0x2000 -> 0x3000)

read() #1: prints vma-A, sets m->version=0x2000

Now, merge A/B to make C:

	vma-C: (0x1000 -> 0x3000)

read() #2: find_vma(m->version=0x2000), returns vma-C, prints vma-C

The user will see two VMAs in their output:

	A: 0x1000->0x2000
	C: 0x1000->0x3000

Acked-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Signed-off-by: Robert Hu <robert.hu@intel.com>
---
 fs/proc/task_mmu.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f6fa99e..97abcf7 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
 static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
 {
 	if (m->count < m->size)	/* vma is copied successfully */
-		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
+		m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
 }
 
 static void *m_start(struct seq_file *m, loff_t *ppos)
@@ -176,14 +176,14 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 
 	if (last_addr) {
 		vma = find_vma(mm, last_addr);
-		if (vma && (vma = m_next_vma(priv, vma)))
+		if (vma)
 			return vma;
 	}
 
 	m->version = 0;
 	if (pos < mm->map_count) {
 		for (vma = mm->mmap; pos; pos--) {
-			m->version = vma->vm_start;
+			m->version = vma->vm_end;
 			vma = vma->vm_next;
 		}
 		return vma;
@@ -293,7 +293,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 	vm_flags_t flags = vma->vm_flags;
 	unsigned long ino = 0;
 	unsigned long long pgoff = 0;
-	unsigned long start, end;
+	unsigned long end, start = m->version;
 	dev_t dev = 0;
 	const char *name = NULL;
 
@@ -304,8 +304,13 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 		pgoff = ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
 	}
 
+	/*
+	 * the region [0, m->version) has already been handled, do not
+	 * handle it doubly.
+	 */
+	start = max(vma->vm_start, start);
+
 	/* We don't show the stack guard page in /proc/maps */
-	start = vma->vm_start;
 	if (stack_guard_page_start(vma, start))
 		start += PAGE_SIZE;
 	end = vma->vm_end;
@@ -786,7 +791,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "KernelPageSize: %8lu kB\n"
 		   "MMUPageSize:    %8lu kB\n"
 		   "Locked:         %8lu kB\n",
-		   (vma->vm_end - vma->vm_start) >> 10,
+		   (vma->vm_end - max(vma->vm_start, m->version)) >> 10,
 		   mss.resident >> 10,
 		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
 		   mss.shared_clean  >> 10,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
