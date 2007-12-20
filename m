Date: Thu, 20 Dec 2007 14:09:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
In-Reply-To: <1198155938.6821.3.camel@twins>
Message-ID: <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
References: <1198155938.6821.3.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Dec 2007, Peter Zijlstra wrote:
> 
> Lennart asked for madvise(WILLNEED) to work on anonymous pages, he plans
> to use this to pre-fault pages. He currently uses: mlock/munlock for
> this purpose.

I certainly agree with this in principle: it just seems an unnecessary
and surprising restriction to refuse on anonymous vmas; I guess the only
reason for not adding this was not having anyone asking for it until now.
Though, does Lennart realize he could use MAP_POPULATE in the mmap?

> 
> [ compile tested only ]

I haven't tried it either, but generally it looks plausible.

> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 93ee375..eff60ce 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -100,6 +100,24 @@ out:
>  	return error;
>  }
>  
> +static long madvice_willneed_anon(struct vm_area_struct *vma,
> +				  struct vm_area_struct **prev,
> +				  unsigned long start, unsigned long end)

mavise.c uses "madvise_" rather than " madvice_" throughout,
so please go with the flow.

> +{
> +	int ret, len;
> +
> +	*prev = vma;
> +	if (end > vma->vm_end)
> +		end = vma->vm_end;

Please check, but I think the upper level ensures end is within range.

> +
> +	len = end - start;
> +	ret = get_user_pages(current, current->mm, start, len,
> +			0, 0, NULL, NULL);
> +	if (ret < 0)
> +		return ret;
> +	return ret == len ? 0 : -1;

It's not good to return -1 as an alternative to a real errno:
it'll look like -EPERM.  If you copied that from somewhere, better
send a patch to fix the somewhere!  Ah, yes, make_pages_present: it
happens that nobody is interested in its return value, so we could
make it a void; but that'd just be a cleanup.  What to do here if
non-negative ret less than len?  Oh, just return 0, that's good
enough in this case (the file case always returns 0).

Hmm, might it be better to use make_pages_present itself,
fixing its retval, rather than using get_user_pages directly?
(I'd hope the caching makes its repeat of find_vma not an overhead.)

Interesting divergence: make_pages_present faults in writable pages
in a writable vma, whereas the file case's force_page_cache_readahead
doesn't even insert the pages into the mm.

> +}
> +
>  /*
>   * Schedule all required I/O operations.  Do not wait for completion.
>   */
> @@ -110,7 +128,7 @@ static long madvise_willneed(struct vm_area_struct * vma,
>  	struct file *file = vma->vm_file;
>  
>  	if (!file)
> -		return -EBADF;
> +		return madvice_willneed_anon(vma, prev, start, end);
>  
>  	if (file->f_mapping->a_ops->get_xip_page) {
>  		/* no bad return value, but ignore advice */

And there's a correctly invisible hunk to the patch too: this
extension of MADV_WILLNEED also does not require down_write of
mmap_sem, so madvise_need_mmap_write can remain unchanged.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
