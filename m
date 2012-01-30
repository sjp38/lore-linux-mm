Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5C9566B0068
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:16:04 -0500 (EST)
Received: by iadk27 with SMTP id k27so7884686iad.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 09:16:03 -0800 (PST)
Date: Mon, 30 Jan 2012 09:15:58 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
Message-ID: <20120130171558.GB3355@google.com>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Antipov <dmitry.antipov@linaro.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, Jan 30, 2012 at 12:37:34PM +0400, Dmitry Antipov wrote:
> Fix pcpu_alloc() to return ZERO_SIZE_PTR if requested size is 0;
> fix free_percpu() to check passed pointer with ZERO_OR_NULL_PTR.
> 
> Signed-off-by: Dmitry Antipov <dmitry.antipov@linaro.org>
> ---
>  mm/percpu.c |   16 +++++++++++-----
>  1 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index f47af91..e903a19 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -702,7 +702,8 @@ static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
>   * Does GFP_KERNEL allocation.
>   *
>   * RETURNS:
> - * Percpu pointer to the allocated area on success, NULL on failure.
> + * ZERO_SIZE_PTR if @size is zero, percpu pointer to the
> + * allocated area on success or NULL on failure.
>   */
>  static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
>  {
> @@ -713,7 +714,10 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
>  	unsigned long flags;
>  	void __percpu *ptr;
>  
> -	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
> +	if (unlikely(!size))
> +		return ZERO_SIZE_PTR;

Percpu pointers are in a different address space and using
ZERO_SIZE_PTR directly will trigger sparse address space warning.
Also, I'm not entirely sure whether 16 is guaranteed to be unused in
percpu address space (maybe it is but I don't think we have anything
enforcing that).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
