Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 52F156B0070
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 01:07:52 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so292970eek.15
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:07:51 -0700 (PDT)
Received: from mail-ee0-x22c.google.com (mail-ee0-x22c.google.com [2a00:1450:4013:c00::22c])
        by mx.google.com with ESMTPS id 43si1301739eer.207.2014.04.22.22.07.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 22:07:51 -0700 (PDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so297595eek.3
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:07:50 -0700 (PDT)
Message-ID: <53574AA5.1060205@gmail.com>
Date: Wed, 23 Apr 2014 07:07:49 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/4] ipc,shm: minor cleanups
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>
Cc: mtk.manpages@gmail.com, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/23/2014 04:53 AM, Davidlohr Bueso wrote:
> -  Breakup long function names/args.
> -  Cleaup variable declaration.
> -  s/current->mm/mm
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  ipc/shm.c | 40 +++++++++++++++++-----------------------
>  1 file changed, 17 insertions(+), 23 deletions(-)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index f000696..584d02e 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -480,15 +480,13 @@ static const struct vm_operations_struct shm_vm_ops = {
>  static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  {
>  	key_t key = params->key;
> -	int shmflg = params->flg;
> +	int id, error, shmflg = params->flg;

It's largely a matter of taste (and I may be in a minority), and I know
there's certainly precedent in the kernel code, but I don't much like the 
style of mixing variable declarations that have initializers, with other
unrelated declarations (e.g., variables without initializers). What is 
the gain? One less line of text? That's (IMO) more than offset by the 
small loss of readability.

Cheers,

Michael

>  	size_t size = params->u.size;
> -	int error;
> -	struct shmid_kernel *shp;
>  	size_t numpages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
> -	struct file *file;
>  	char name[13];
> -	int id;
>  	vm_flags_t acctflag = 0;
> +	struct shmid_kernel *shp;
> +	struct file *file;
>  
>  	if (size < SHMMIN || size > ns->shm_ctlmax)
>  		return -EINVAL;
> @@ -681,7 +679,8 @@ copy_shmid_from_user(struct shmid64_ds *out, void __user *buf, int version)
>  	}
>  }
>  
> -static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminfo64 *in, int version)
> +static inline unsigned long copy_shminfo_to_user(void __user *buf,
> +						 struct shminfo64 *in, int version)
>  {
>  	switch (version) {
>  	case IPC_64:
> @@ -711,8 +710,8 @@ static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminf
>   * Calculate and add used RSS and swap pages of a shm.
>   * Called with shm_ids.rwsem held as a reader
>   */
> -static void shm_add_rss_swap(struct shmid_kernel *shp,
> -	unsigned long *rss_add, unsigned long *swp_add)
> +static void shm_add_rss_swap(struct shmid_kernel *shp, unsigned long *rss_add,
> +			     unsigned long *swp_add)
>  {
>  	struct inode *inode;
>  
> @@ -739,7 +738,7 @@ static void shm_add_rss_swap(struct shmid_kernel *shp,
>   * Called with shm_ids.rwsem held as a reader
>   */
>  static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
> -		unsigned long *swp)
> +			 unsigned long *swp)
>  {
>  	int next_id;
>  	int total, in_use;
> @@ -1047,21 +1046,16 @@ out_unlock1:
>  long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
>  	      unsigned long shmlba)
>  {
> -	struct shmid_kernel *shp;
> -	unsigned long addr;
> -	unsigned long size;
> +	unsigned long addr, size, flags, prot, populate = 0;
>  	struct file *file;
> -	int    err;
> -	unsigned long flags;
> -	unsigned long prot;
> -	int acc_mode;
> +	int acc_mode, err = -EINVAL;
>  	struct ipc_namespace *ns;
>  	struct shm_file_data *sfd;
> +	struct shmid_kernel *shp;
>  	struct path path;
>  	fmode_t f_mode;
> -	unsigned long populate = 0;
> +	struct mm_struct *mm = current->mm;
>  
> -	err = -EINVAL;
>  	if (shmid < 0)
>  		goto out;
>  	else if ((addr = (ulong)shmaddr)) {
> @@ -1161,20 +1155,20 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
>  	if (err)
>  		goto out_fput;
>  
> -	down_write(&current->mm->mmap_sem);
> +	down_write(&mm->mmap_sem);
>  	if (addr && !(shmflg & SHM_REMAP)) {
>  		err = -EINVAL;
>  		if (addr + size < addr)
>  			goto invalid;
>  
> -		if (find_vma_intersection(current->mm, addr, addr + size))
> +		if (find_vma_intersection(mm, addr, addr + size))
>  			goto invalid;
>  		/*
>  		 * If shm segment goes below stack, make sure there is some
>  		 * space left for the stack to grow (at least 4 pages).
>  		 */
> -		if (addr < current->mm->start_stack &&
> -		    addr > current->mm->start_stack - size - PAGE_SIZE * 5)
> +		if (addr < mm->start_stack &&
> +		    addr > mm->start_stack - size - PAGE_SIZE * 5)
>  			goto invalid;
>  	}
>  
> @@ -1184,7 +1178,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
>  	if (IS_ERR_VALUE(addr))
>  		err = (long)addr;
>  invalid:
> -	up_write(&current->mm->mmap_sem);
> +	up_write(&mm->mmap_sem);
>  	if (populate)
>  		mm_populate(addr, populate);
>  
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
