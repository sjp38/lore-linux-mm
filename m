Received: by nf-out-0910.google.com with SMTP id b2so2024796nfe
        for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:48:06 -0700 (PDT)
Message-ID: <29495f1d0703231548k377e3f8ds5f2ae529c34e4380@mail.gmail.com>
Date: Fri, 23 Mar 2007 15:48:05 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [patch 1/2] hugetlb: add resv argument to hugetlb_file_setup
In-Reply-To: <b040c32a0703231542r77030723o214255a5fa591dec@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0703231542r77030723o214255a5fa591dec@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 3/23/07, Ken Chen <kenchen@google.com> wrote:
> rename hugetlb_zero_setup() to hugetlb_file_setup() to better match
> function name convention like shmem implementation.  Also add an
> argument to the function to indicate whether file setup should reserve
> hugetlb page upfront or not.
>
> Signed-off-by: Ken Chen <kenchen@google.com>
>
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 8c718a3..981886f 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -734,7 +734,7 @@ static int can_do_hugetlb_shm(void)
>                         can_do_mlock());
>  }
>
> -struct file *hugetlb_zero_setup(size_t size)
> +struct file *hugetlb_file_setup(size_t size, int resv)
>  {
>         int error = -ENOMEM;
>         struct file *file;
> @@ -771,7 +771,7 @@ struct file *hugetlb_zero_setup(size_t s
>                 goto out_file;
>
>         error = -ENOMEM;
> -       if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
> +       if (resv && hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
>                 goto out_inode;
>
>         d_instantiate(dentry, inode);
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 3f3e7a6..55cccd8 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -163,7 +163,7 @@ static inline struct hugetlbfs_sb_info *
>
>  extern const struct file_operations hugetlbfs_file_operations;
>  extern struct vm_operations_struct hugetlb_vm_ops;
> -struct file *hugetlb_zero_setup(size_t);
> +struct file *hugetlb_file_setup(size_t, int);
>  int hugetlb_get_quota(struct address_space *mapping);
>  void hugetlb_put_quota(struct address_space *mapping);
>
> @@ -185,7 +185,7 @@ #else /* !CONFIG_HUGETLBFS */
>
>  #define is_file_hugepages(file)                0
>  #define set_file_hugepages(file)       BUG()
> -#define hugetlb_zero_setup(size)       ERR_PTR(-ENOSYS)
> +#define hugetlb_file_setup(size, resv) ERR_PTR(-ENOSYS)
>
>  #endif /* !CONFIG_HUGETLBFS */
>
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 4fefbad..c64643f 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -366,7 +366,7 @@ static int newseg (struct ipc_namespace
>
>         if (shmflg & SHM_HUGETLB) {
>                 /* hugetlb_zero_setup takes care of mlock user accounting */
> -               file = hugetlb_zero_setup(size);
> +               file = hugetlb_file_setup(size, 1);

Comment needs updating too.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
