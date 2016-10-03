Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBDF96B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 07:52:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d64so78918251wmh.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 04:52:13 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 17si18396733wmm.91.2016.10.03.04.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 04:52:12 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id p138so14307993wmb.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 04:52:12 -0700 (PDT)
Date: Mon, 3 Oct 2016 13:52:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20161003115210.GA26768@dhcp22.suse.cz>
References: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Ho <robert.hu@intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, oleg@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Sat 01-10-16 12:42:37, Robert Ho wrote:
> Recently, Redhat reported that nvml test suite failed on QEMU/KVM,
> more detailed info please refer to:
>    https://bugzilla.redhat.com/show_bug.cgi?id=1365721
> 
> Actually, this bug is not only for NVDIMM/DAX but also for any other file
> systems. This simple test case abstracted from nvml can easily reproduce
> this bug in common environment:
> 
> -------------------------- testcase.c -----------------------------
> 
> int
> is_pmem_proc(const void *addr, size_t len)
> {
>         const char *caddr = addr;
> 
>         FILE *fp;
>         if ((fp = fopen("/proc/self/smaps", "r")) == NULL) {
>                 printf("!/proc/self/smaps");
>                 return 0;
>         }
> 
>         int retval = 0;         /* assume false until proven otherwise */
>         char line[PROCMAXLEN];  /* for fgets() */
>         char *lo = NULL;        /* beginning of current range in smaps file */
>         char *hi = NULL;        /* end of current range in smaps file */
>         int needmm = 0;         /* looking for mm flag for current range */
>         while (fgets(line, PROCMAXLEN, fp) != NULL) {
>                 static const char vmflags[] = "VmFlags:";
>                 static const char mm[] = " wr";
> 
>                 /* check for range line */
>                 if (sscanf(line, "%p-%p", &lo, &hi) == 2) {
>                         if (needmm) {
>                                 /* last range matched, but no mm flag found */
>                                 printf("never found mm flag.\n");
>                                 break;
>                         } else if (caddr < lo) {
>                                 /* never found the range for caddr */
>                                 printf("#######no match for addr %p.\n", caddr);
>                                 break;
>                         } else if (caddr < hi) {
>                                 /* start address is in this range */
>                                 size_t rangelen = (size_t)(hi - caddr);
> 
>                                 /* remember that matching has started */
>                                 needmm = 1;
> 
>                                 /* calculate remaining range to search for */
>                                 if (len > rangelen) {
>                                         len -= rangelen;
>                                         caddr += rangelen;
>                                         printf("matched %zu bytes in range "
>                                                 "%p-%p, %zu left over.\n",
>                                                         rangelen, lo, hi, len);
>                                 } else {
>                                         len = 0;
>                                         printf("matched all bytes in range "
>                                                         "%p-%p.\n", lo, hi);
>                                 }
>                         }
>                 } else if (needmm && strncmp(line, vmflags,
>                                         sizeof(vmflags) - 1) == 0) {
>                         if (strstr(&line[sizeof(vmflags) - 1], mm) != NULL) {
>                                 printf("mm flag found.\n");
>                                 if (len == 0) {
>                                         /* entire range matched */
>                                         retval = 1;
>                                         break;
>                                 }
>                                 needmm = 0;     /* saw what was needed */
>                         } else {
>                                 /* mm flag not set for some or all of range */
>                                 printf("range has no mm flag.\n");
>                                 break;
>                         }
>                 }
>         }
> 
>         fclose(fp);
> 
>         printf("returning %d.\n", retval);
>         return retval;
> }
> 
> void *Addr;
> size_t Size;
> 
> /*
>  * worker -- the work each thread performs
>  */
> static void *
> worker(void *arg)
> {
>         int *ret = (int *)arg;
>         *ret =  is_pmem_proc(Addr, Size);
>         return NULL;
> }
> 
> int main(int argc, char *argv[])
> {
>         if (argc <  2 || argc > 3) {
>                 printf("usage: %s file [env].\n", argv[0]);
>                 return -1;
>         }
> 
>         int fd = open(argv[1], O_RDWR);
> 
>         struct stat stbuf;
>         fstat(fd, &stbuf);
> 
>         Size = stbuf.st_size;
>         Addr = mmap(0, stbuf.st_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
> 
>         close(fd);
> 
>         pthread_t threads[NTHREAD];
>         int ret[NTHREAD];
> 
>         /* kick off NTHREAD threads */
>         for (int i = 0; i < NTHREAD; i++)
>                 pthread_create(&threads[i], NULL, worker, &ret[i]);
> 
>         /* wait for all the threads to complete */
>         for (int i = 0; i < NTHREAD; i++)
>                 pthread_join(threads[i], NULL);
> 
>         /* verify that all the threads return the same value */
>         for (int i = 1; i < NTHREAD; i++) {
>                 if (ret[0] != ret[i]) {
>                         printf("Error i %d ret[0] = %d ret[i] = %d.\n", i,
>                                 ret[0], ret[i]);
>                 }
>         }
> 
>         printf("%d", ret[0]);
>         return 0;
> }
> 
> It failed as some threads can not find the memory region in
> "/proc/self/smaps" which is allocated in the main process
> 
> It is caused by proc fs which uses 'file->version' to indicate the VMA that
> is the last one has already been handled by read() system call. When the
> next read() issues, it uses the 'version' to find the VMA, then the next
> VMA is what we want to handle, the related code is as follows:
> 
>         if (last_addr) {
>                 vma = find_vma(mm, last_addr);
>                 if (vma && (vma = m_next_vma(priv, vma)))
>                         return vma;
>         }
> 
> However, VMA will be lost if the last VMA is gone, e.g:
> 
> The process VMA list is A->B->C->D
> 
> CPU 0                                  CPU 1
> read() system call
>    handle VMA B
>    version = B
> return to userspace
> 
>                                    unmap VMA B
> 
> issue read() again to continue to get
> the region info
>    find_vma(version) will get VMA C
>    m_next_vma(C) will get VMA D
>    handle D
>    !!! VMA C is lost !!!
> 
> In order to fix this bug, we make 'file->version' indicate the end address
> of current VMA

I guess you wanted to finish that sentence, right?
"
m_start will then look up a vma which with vma_start < last_vm_end and
moves on to the next vma if we found the same or an overlapping vma.
This will guarantee that we will not miss an exclusive vma but we can
still miss one if the previous vma was shrunk. This is acceptable
because guaranteeing "never miss a vma" is simply not feasible. User has
to cope with some inconsistencies if the file is not read in one go.
"
 
> Changelog:
> v4:
> 	Thank Oleg Nesterov <oleg@redhat.com>'s contribution, making the patch
> more simplified. We now only need to 1) use vm_end in m->version for remember
> last vma 2) in m_start(), by judging the found vma's vm_start, determine
> whether use it or its successor.
> 
> v3:
> 	Thank Michal's pointing. Fix the incompletion of v2's fixing:
> "/proc/<pid>/smaps will report counters for the full vma range while
> the header (aka show_map_vma) will report shorter (non-overlapping) range"
>     Add description in Documentation/filesystems/proc.txt, regarding maps,
> smaps reading's guaruntees.
> 
> v2:
> Thanks to Dave Hansen's comments, this version fixes the issue in v1 that
> same virtual address range may be outputted twice, e.g:

I am not sure how the two above are helpful as the patch has been
reworked basically.

> Take two example VMAs:
> 
> 	vma-A: (0x1000 -> 0x2000)
> 	vma-B: (0x2000 -> 0x3000)
> 
> read() #1: prints vma-A, sets m->version=0x2000
> 
> Now, merge A/B to make C:
> 
> 	vma-C: (0x1000 -> 0x3000)
> 
> read() #2: find_vma(m->version=0x2000), returns vma-C, prints vma-C
> 
> The user will see two VMAs in their output:
> 
> 	A: 0x1000->0x2000
> 	C: 0x1000->0x3000
> 

{Suggested,Signed-off}-by: Oleg Nesterov <oleg@redhat.com>
?

> Acked-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Xiao Guangrong <guangrong.xiao@linux.intel.com>
> Signed-off-by: Robert Hu <robert.hu@intel.com>

Anyway this is definitely an improvement!

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  fs/proc/task_mmu.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f6fa99e..45f42c8 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
>  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
>  {
>  	if (m->count < m->size)	/* vma is copied successfully */
> -		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> +		m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
>  }
>  
>  static void *m_start(struct seq_file *m, loff_t *ppos)
> @@ -175,8 +175,10 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
>  	priv->tail_vma = get_gate_vma(mm);
>  
>  	if (last_addr) {
> -		vma = find_vma(mm, last_addr);
> -		if (vma && (vma = m_next_vma(priv, vma)))
> +		vma = find_vma(mm, last_addr - 1);
> +		if (vma && vma->vm_start <= last_addr)
> +			vma = m_next_vma(priv, vma);
> +		if (vma)
>  			return vma;
>  	}
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
