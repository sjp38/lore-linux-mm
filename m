Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 3 Feb 2015 14:23:23 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 2/2] aio: make aio .mremap handle size changes
Message-ID: <20150203192323.GT2974@kvack.org>
References: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com> <798fafb96373cfab0707457a266dd137016cd1e9.1422986358.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <798fafb96373cfab0707457a266dd137016cd1e9.1422986358.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 03, 2015 at 11:18:53AM -0800, Shaohua Li wrote:
> mremap aio ring buffer to another smaller vma is legal. For example,
> mremap the ring buffer from the begining, though after the mremap, some
> ring buffer pages can't be accessed in userspace because vma size is
> shrinked. The problem is ctx->mmap_size isn't changed if the new ring
> buffer vma size is changed. Latter io_destroy will zap all vmas within
> mmap_size, which might zap unrelated vmas.

Nak.  Shrinking the aio ring buffer is not a supported operation and will 
cause the application to lose events.  Make the size changing mremap fail, 
as this patch will not make the system do the right thing.

		-ben

> Cc: Benjamin LaHaise <bcrl@kvack.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  fs/aio.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/aio.c b/fs/aio.c
> index 1b7893e..fa354cf 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -306,6 +306,7 @@ static void aio_ring_remap(struct file *file, struct vm_area_struct *vma)
>  		ctx = table->table[i];
>  		if (ctx && ctx->aio_ring_file == file) {
>  			ctx->user_id = ctx->mmap_base = vma->vm_start;
> +			ctx->mmap_size = vma->vm_end - vma->vm_start;
>  			break;
>  		}
>  	}
> -- 
> 1.8.1

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
