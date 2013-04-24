Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4D8126B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 07:01:50 -0400 (EDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH v2 5/6] mm: Support address range reclaim
References: <1366767664-17541-1-git-send-email-minchan@kernel.org>
	<1366767664-17541-6-git-send-email-minchan@kernel.org>
Date: Wed, 24 Apr 2013 20:01:48 +0900
In-Reply-To: <1366767664-17541-6-git-send-email-minchan@kernel.org> (Minchan
	Kim's message of "Wed, 24 Apr 2013 10:41:03 +0900")
Message-ID: <87wqrs9opv.fsf@sejong.aot.lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>

Hi Minchan,

On Wed, 24 Apr 2013 10:41:03 +0900, Minchan Kim wrote:
> This patch adds address range reclaim of a process.
> The requirement is following as,
>
> Like webkit1, it uses a address space for handling multi tabs.
> IOW, it uses *one* process model so all tabs shares address space
> of the process. In such scenario, per-process reclaim is rather
> coarse-grained so this patch supports more fine-grained reclaim
> for being able to reclaim target address range of the process.
> For reclaim target range, you should use following format.
>
> 	echo [addr] [size-byte] > /proc/pid/reclaim
>
> addr should be page-aligned.
>
> So now reclaim konb's interface is following as.
>
> echo file > /proc/pid/reclaim
> 	reclaim file-backed pages only
>
> echo anon > /proc/pid/reclaim
> 	reclaim anonymous pages only
>
> echo all > /proc/pid/reclaim
> 	reclaim all pages
>
> echo $((1<<20)) 8192 > /proc/pid/reclaim
> 	reclaim pages in (0x100000 - 0x102000)
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  fs/proc/task_mmu.c | 88 ++++++++++++++++++++++++++++++++++++++++++++----------
>  mm/internal.h      |  3 ++
>  2 files changed, 76 insertions(+), 15 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 79b674e..dff9756 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -12,6 +12,7 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/mm_inline.h>
> +#include <linux/ctype.h>
>  
>  #include <asm/elf.h>
>  #include <asm/uaccess.h>
> @@ -1239,11 +1240,14 @@ static ssize_t reclaim_write(struct file *file, const char __user *buf,
>  				size_t count, loff_t *ppos)
>  {
>  	struct task_struct *task;
> -	char buffer[PROC_NUMBUF];
> +	char buffer[200];
>  	struct mm_struct *mm;
>  	struct vm_area_struct *vma;
>  	enum reclaim_type type;
>  	char *type_buf;
> +	struct mm_walk reclaim_walk = {};
> +	unsigned long start = 0;
> +	unsigned long end = 0;
>  
>  	memset(buffer, 0, sizeof(buffer));
>  	if (count > sizeof(buffer) - 1)
> @@ -1259,42 +1263,96 @@ static ssize_t reclaim_write(struct file *file, const char __user *buf,
>  		type = RECLAIM_ANON;
>  	else if (!strcmp(type_buf, "all"))
>  		type = RECLAIM_ALL;
> +	else if (isdigit(*type_buf))
> +		type = RECLAIM_RANGE;
>  	else
> -		return -EINVAL;
> +		goto out_err;
> +
> +	if (type == RECLAIM_RANGE) {
> +		int ret;
> +		size_t len;
> +		unsigned long len_in;
> +		char *token;
> +
> +		token = strsep(&type_buf, " ");
> +		if (!token)
> +			goto out_err;
> +		ret = kstrtoul(token, 10, &start);

Why not using

		start = memparse(token, NULL);

to support something like:

  # echo 0x100000 8K > /proc/pid/reclaim


Thanks,
Namhyung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
