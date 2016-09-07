Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF9A6B0261
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 03:11:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so18594073pfb.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 00:11:22 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id uq4si39710612pac.274.2016.09.07.00.11.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 00:11:21 -0700 (PDT)
Subject: Re: [PATCH] Fix region lost in /proc/self/smaps
References: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
From: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Message-ID: <a5303d48-a80b-f7af-32e0-3b02d5c3cbfa@linux.intel.com>
Date: Wed, 7 Sep 2016 15:05:45 +0800
MIME-Version: 1.0
In-Reply-To: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com
Cc: gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com


Sorry, the title should be [PATCH] mm, proc: Fix region lost in /proc/self/smaps

On 09/07/2016 02:51 PM, Xiao Guangrong wrote:
> Recently, Redhat reported that nvml test suite failed on QEMU/KVM,
> more detailed info please refer to:
>    https://bugzilla.redhat.com/show_bug.cgi?id=1365721
>
> Actually, this bug is not only for NVDIMM/DAX but also for any other file
> systems. This simple test case abstracted from nvml can easily reproduce
> this bug in common environment:
>
> -------------------------- testcase.c -----------------------------
> #define PROCMAXLEN 4096
>
> int
> is_pmem_proc(const void *addr, size_t len)
> {
> 	const char *caddr = addr;
>
> 	FILE *fp;
> 	if ((fp = fopen("/proc/self/smaps", "r")) == NULL) {
> 		printf("!/proc/self/smaps");
> 		return 0;
> 	}
>
> 	int retval = 0;		/* assume false until proven otherwise */
> 	char line[PROCMAXLEN];	/* for fgets() */
> 	char *lo = NULL;	/* beginning of current range in smaps file */
> 	char *hi = NULL;	/* end of current range in smaps file */
> 	int needmm = 0;		/* looking for mm flag for current range */
> 	while (fgets(line, PROCMAXLEN, fp) != NULL) {
> 		static const char vmflags[] = "VmFlags:";
> 		static const char mm[] = " wr";
>
> 		/* check for range line */
> 		if (sscanf(line, "%p-%p", &lo, &hi) == 2) {
> 			if (needmm) {
> 				/* last range matched, but no mm flag found */
> 				printf("never found mm flag.\n");
> 				break;
> 			} else if (caddr < lo) {
> 				/* never found the range for caddr */
> 				printf("#######no match for addr %p.\n", caddr);
> 				break;
> 			} else if (caddr < hi) {
> 				/* start address is in this range */
> 				size_t rangelen = (size_t)(hi - caddr);
>
> 				/* remember that matching has started */
> 				needmm = 1;
>
> 				/* calculate remaining range to search for */
> 				if (len > rangelen) {
> 					len -= rangelen;
> 					caddr += rangelen;
> 					printf("matched %zu bytes in range "
> 						"%p-%p, %zu left over.\n",
> 							rangelen, lo, hi, len);
> 				} else {
> 					len = 0;
> 					printf("matched all bytes in range "
> 							"%p-%p.\n", lo, hi);
> 				}
> 			}
> 		} else if (needmm && strncmp(line, vmflags,
> 					sizeof(vmflags) - 1) == 0) {
> 			if (strstr(&line[sizeof(vmflags) - 1], mm) != NULL) {
> 				printf("mm flag found.\n");
> 				if (len == 0) {
> 					/* entire range matched */
> 					retval = 1;
> 					break;
> 				}
> 				needmm = 0;	/* saw what was needed */
> 			} else {
> 				/* mm flag not set for some or all of range */
> 				printf("range has no mm flag.\n");
> 				break;
> 			}
> 		}
> 	}
>
> 	fclose(fp);
>
> 	printf("returning %d.\n", retval);
> 	return retval;
> }
>
> #define NTHREAD 16
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
> 	int *ret = (int *)arg;
> 	*ret =  is_pmem_proc(Addr, Size);
> 	return NULL;
> }
>
> int main(int argc, char *argv[])
> {
> 	if (argc <  2 || argc > 3) {
> 		printf("usage: %s file [env].\n", argv[0]);
> 		return -1;
> 	}
>
> 	int fd = open(argv[1], O_RDWR);
>
> 	struct stat stbuf;
> 	fstat(fd, &stbuf);
>
> 	Size = stbuf.st_size;
> 	Addr = mmap(0, stbuf.st_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
>
> 	close(fd);
>
> 	pthread_t threads[NTHREAD];
> 	int ret[NTHREAD];
>
> 	/* kick off NTHREAD threads */
> 	for (int i = 0; i < NTHREAD; i++)
> 		pthread_create(&threads[i], NULL, worker, &ret[i]);
>
> 	/* wait for all the threads to complete */
> 	for (int i = 0; i < NTHREAD; i++)
> 		pthread_join(threads[i], NULL);
>
> 	/* verify that all the threads return the same value */
> 	for (int i = 1; i < NTHREAD; i++) {
> 		if (ret[0] != ret[i]) {
> 			printf("Error i %d ret[0] = %d ret[i] = %d.\n", i,
> 				ret[0], ret[i]);
> 		}
> 	}
>
> 	printf("%d", ret[0]);
> 	return 0;
> }
>
> # dd if=/dev/zero of=~/out bs=2M count=1
> # ./testcase ~/out
>
> It failed as some threads can not find the memory region in
> "/proc/self/smaps" which is allocated in the mail process
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
> However, VMA will be lost if the last VMA is gone, eg:
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
> In order to fix this bug, we make 'file->version' indicate the next VMA
> we want to handle
>
> Signed-off-by: Xiao Guangrong <guangrong.xiao@linux.intel.com>
> ---
>  fs/proc/task_mmu.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 187d84e..ace4a69 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -146,8 +146,12 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
>
>  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
>  {
> -	if (m->count < m->size)	/* vma is copied successfully */
> -		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> +	/* vma is copied successfully */
> +	if (m->count < m->size) {
> +		struct vm_area_struct *vma_next =  m_next_vma(m->private, vma);
> +
> +		m->version = vma_next ? vma_next->vm_start : -1UL;
> +	}
>  }
>
>  static void *m_start(struct seq_file *m, loff_t *ppos)
> @@ -176,15 +180,15 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
>
>  	if (last_addr) {
>  		vma = find_vma(mm, last_addr);
> -		if (vma && (vma = m_next_vma(priv, vma)))
> +		if (vma)
>  			return vma;
>  	}
>
>  	m->version = 0;
>  	if (pos < mm->map_count) {
>  		for (vma = mm->mmap; pos; pos--) {
> -			m->version = vma->vm_start;
>  			vma = vma->vm_next;
> +			m->version = vma->vm_start;
>  		}
>  		return vma;
>  	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
