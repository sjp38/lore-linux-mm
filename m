Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A86848E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 16:22:58 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id v72so22147931pgb.10
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 13:22:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9sor8243176pgs.11.2018.12.29.13.22.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 13:22:57 -0800 (PST)
Date: Sat, 29 Dec 2018 15:22:53 -0600
From: Dennis Zhou <dennis@kernel.org>
Subject: Re: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
Message-ID: <20181229212253.GA73871@dennisz-mbp>
References: <20181229013147.211079-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181229013147.211079-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Shakeel,

On Fri, Dec 28, 2018 at 05:31:47PM -0800, Shakeel Butt wrote:
> __alloc_percpu_gfp() can be called from atomic context, so, make
> pcpu_get_pages use the gfp provided to the higher layer.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/percpu-vm.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
> index d8078de912de..4f42c4c5c902 100644
> --- a/mm/percpu-vm.c
> +++ b/mm/percpu-vm.c
> @@ -21,6 +21,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
>  
>  /**
>   * pcpu_get_pages - get temp pages array
> + * @gfp: allocation flags passed to the underlying allocator
>   *
>   * Returns pointer to array of pointers to struct page which can be indexed
>   * with pcpu_page_idx().  Note that there is only one array and accesses
> @@ -29,7 +30,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
>   * RETURNS:
>   * Pointer to temp pages array on success.
>   */
> -static struct page **pcpu_get_pages(void)
> +static struct page **pcpu_get_pages(gfp_t gfp)
>  {
>  	static struct page **pages;
>  	size_t pages_size = pcpu_nr_units * pcpu_unit_pages * sizeof(pages[0]);
> @@ -37,7 +38,7 @@ static struct page **pcpu_get_pages(void)
>  	lockdep_assert_held(&pcpu_alloc_mutex);
>  
>  	if (!pages)
> -		pages = pcpu_mem_zalloc(pages_size, GFP_KERNEL);
> +		pages = pcpu_mem_zalloc(pages_size, gfp);
>  	return pages;
>  }
>  
> @@ -278,7 +279,7 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
>  {
>  	struct page **pages;
>  
> -	pages = pcpu_get_pages();
> +	pages = pcpu_get_pages(gfp);
>  	if (!pages)
>  		return -ENOMEM;
>  
> @@ -316,7 +317,7 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
>  	 * successful population attempt so the temp pages array must
>  	 * be available now.
>  	 */
> -	pages = pcpu_get_pages();
> +	pages = pcpu_get_pages(GFP_KERNEL);
>  	BUG_ON(!pages);
>  
>  	/* unmap and free */
> -- 
> 2.20.1.415.g653613c723-goog
> 

Sorry, I'm travelling today and was hoping to respond to this later
tonight.

So percpu memory is a little different as it's an intermediary. When you 
call __alloc_percpu_gfp() and it does not contain GFP_KERNEL, it is
considered atomic. So, we only service requests out of already
populated memory. pcpu_get_pages() is only called when we need to
populate/depopulate a chunk and will not be called if we need an atomic
allocation. Also, in all but the first case, it won't make an allocation
as pages is a static variable.

Furthermore, percpu only plumbs through certain gfp as not all make
sense [1].

[1] https://lore.kernel.org/lkml/cover.1518668149.git.dennisszhou@gmail.com/

Thanks,
Dennis
