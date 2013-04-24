Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 0E3E86B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 15:23:15 -0400 (EDT)
Date: Wed, 24 Apr 2013 12:23:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: swap: Mark swap pages writeback before queueing for
 direct IO
Message-Id: <20130424122313.381167c5ad702fc991844bc7@linux-foundation.org>
In-Reply-To: <20130424185744.GB2144@suse.de>
References: <516E918B.3050309@redhat.com>
	<20130422133746.ffbbb70c0394fdbf1096c7ee@linux-foundation.org>
	<20130424185744.GB2144@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed, 24 Apr 2013 19:57:44 +0100 Mel Gorman <mgorman@suse.de> wrote:

> As pointed out by Andrew Morton, the swap-over-NFS writeback is not setting
> PageWriteback before it is queued for direct IO. While swap pages do not
> participate in BDI or process dirty accounting and the IO is synchronous,
> the writeback bit is still required and not setting it in this case was
> an oversight.  swapoff depends on the page writeback to synchronoise all
> pending writes on a swap page before it is reused. Swapcache freeing and
> reuse depend on checking the PageWriteback under lock to ensure the page
> is safe to reuse.
> 
> Direct IO handlers and the direct IO handler for NFS do not deal with
> PageWriteback as they are synchronous writes. In the case of NFS, it
> schedules pages (or a page in the case of swap) for IO and then waits
> synchronously for IO to complete in nfs_direct_write(). It is recognised
> that this is a slowdown from normal swap handling which is asynchronous
> and uses a completion handler. Shoving PageWriteback handling down into
> direct IO handlers looks like a bad fit to handle the swap case although
> it may have to be dealt with some day if swap is converted to use direct
> IO in general and bmap is finally done away with. At that point it will
> be necessary to refit asynchronous direct IO with completion handlers onto
> the swap subsystem.
> 
> As swapcache currently depends on PageWriteback to protect against races,
> this patch sets PageWriteback under the page lock before queueing it for
> direct IO. It is cleared when the direct IO handler returns. IO errors
> are treated similarly to the direct-to-bio case except PageError is not
> set as in the case of swap-over-NFS, it is likely to be a transient error.
> 
> It was asked what prevents such a page being reclaimed in parallel.
> With this patch applied, such a page will now be skipped (most of the time)
> or blocked until the writeback completes.  Reclaim checks PageWriteback
> under the page lock before calling try_to_free_swap and the page lock
> should prevent the page being requeued for IO before it is freed.
> 
> This and Jerome's related patch should considered for -stable as far
> back as 3.6 when swap-over-NFS was introduced.

Fair enough - PageWriteback should protect the page during the redirty.

> --- a/mm/page_io.c
> +++ b/mm/page_io.c
>
> ...
>
> @@ -223,8 +224,24 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>  			count_vm_event(PSWPOUT);
>  			ret = 0;
>  		} else {
> +			/*
> +			 * In the case of swap-over-nfs, this can be a
> +			 * temporary failure if the system has limited
> +			 * memory for allocating transmit buffers.
> +			 * Mark the page dirty and avoid
> +			 * rotate_reclaimable_page but rate-limit the
> +			 * messages but do not flag PageError like
> +			 * the normal direct-to-bio case as it could
> +			 * be temporary.
> +			 */
>  			set_page_dirty(page);
> +			ClearPageReclaim(page);
> +			if (printk_ratelimit()) {
> +				pr_err("Write-error on dio swapfile (%Lu)\n",
> +					(unsigned long long)page_file_offset(page));
> +			}
>  		}
> +		end_page_writeback(page);

A pox upon printk_ratelimit()!  Both its code comment and the
checkpatch warning explain why.

--- a/mm/page_io.c~mm-swap-mark-swap-pages-writeback-before-queueing-for-direct-io-fix
+++ a/mm/page_io.c
@@ -244,10 +244,8 @@ int __swap_writepage(struct page *page,
 			 */
 			set_page_dirty(page);
 			ClearPageReclaim(page);
-			if (printk_ratelimit()) {
-				pr_err("Write-error on dio swapfile (%Lu)\n",
-					(unsigned long long)page_file_offset(page));
-			}
+			pr_err_ratelimited("Write error on dio swapfile (%Lu)\n",
+				(unsigned long long)page_file_offset(page));
 		}
 		end_page_writeback(page);
 		return ret;

Do we need to cast the loff_t?  afaict all architectures use long long.
I didn't get a warning from sparc64 with the cast removed, and sparc64
is the one which likes to use different underlying types.

I think I'll remove it and wait for Fengguang's nastygram.

--- a/mm/page_io.c~mm-swap-mark-swap-pages-writeback-before-queueing-for-direct-io-fix-fix
+++ a/mm/page_io.c
@@ -245,7 +245,7 @@ int __swap_writepage(struct page *page,
 			set_page_dirty(page);
 			ClearPageReclaim(page);
 			pr_err_ratelimited("Write error on dio swapfile (%Lu)\n",
-				(unsigned long long)page_file_offset(page));
+				page_file_offset(page));
 		}
 		end_page_writeback(page);
 		return ret;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
