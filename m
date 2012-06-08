Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 5CA2B6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 16:10:47 -0400 (EDT)
Date: Fri, 8 Jun 2012 13:10:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Resend PATCH v2] mm: Fix slab->page _count corruption.
Message-Id: <20120608131045.90708bda.akpm@linux-foundation.org>
In-Reply-To: <1338405610-1788-1-git-send-email-pshelar@nicira.com>
References: <1338405610-1788-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin B Shelar <pshelar@nicira.com>
Cc: cl@linux.com, penberg@kernel.org, aarcange@redhat.com, linux-mm@kvack.org, abhide@nicira.com

On Wed, 30 May 2012 12:20:10 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> On arches that do not support this_cpu_cmpxchg_double slab_lock is used
> to do atomic cmpxchg() on double word which contains page->_count.
> page count can be changed from get_page() or put_page() without taking
> slab_lock. That corrupts page counter.
> 
> Following patch fixes it by moving page->_count out of cmpxchg_double
> data. So that slub does no change it while updating slub meta-data in
> struct page.
> 
> Reported-by: Amey Bhide <abhide@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> ---
>  include/linux/mm_types.h |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 18b48c4..e54a6b0 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -57,8 +57,16 @@ struct page {
>  		};
>  
>  		union {
> +#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
> +    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
>  			/* Used for cmpxchg_double in slub */
>  			unsigned long counters;
> +#else
> +			/* Keep _count separate from slub cmpxchg_double data,
> +			 * As rest of double word is protected by slab_lock
> +			 * but _count is not. */
> +			unsigned counters;
> +#endif
>  
>  			struct {

OK.  I assume this bug has been there for quite some time.

How serious is it?  Have people been reporting it in real workloads? 
How to trigger it?  IOW, does this need -stable backporting?

Also, someone forgot to document these:

				struct {
					unsigned inuse:16;
					unsigned objects:15;
					unsigned frozen:1;
				};
pls fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
