Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0AA346B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 04:53:54 -0400 (EDT)
Date: Thu, 25 Apr 2013 09:53:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: swap: Mark swap pages writeback before queueing for
 direct IO
Message-ID: <20130425085350.GC2144@suse.de>
References: <516E918B.3050309@redhat.com>
 <20130422133746.ffbbb70c0394fdbf1096c7ee@linux-foundation.org>
 <20130424185744.GB2144@suse.de>
 <20130424122313.381167c5ad702fc991844bc7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130424122313.381167c5ad702fc991844bc7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed, Apr 24, 2013 at 12:23:13PM -0700, Andrew Morton wrote:
> >  		} else {
> > +			/*
> > +			 * In the case of swap-over-nfs, this can be a
> > +			 * temporary failure if the system has limited
> > +			 * memory for allocating transmit buffers.
> > +			 * Mark the page dirty and avoid
> > +			 * rotate_reclaimable_page but rate-limit the
> > +			 * messages but do not flag PageError like
> > +			 * the normal direct-to-bio case as it could
> > +			 * be temporary.
> > +			 */
> >  			set_page_dirty(page);
> > +			ClearPageReclaim(page);
> > +			if (printk_ratelimit()) {
> > +				pr_err("Write-error on dio swapfile (%Lu)\n",
> > +					(unsigned long long)page_file_offset(page));
> > +			}
> >  		}
> > +		end_page_writeback(page);
> 
> A pox upon printk_ratelimit()!  Both its code comment and the
> checkpatch warning explain why.
> 

Ok. There were few sensible options around dealing with the write
errors. swap_writepage() could go to sleep on a waitqueue but it's
putting IO rate limiting where it doesn't belong. Retrying silently
forever could be difficult to debug if the error really is permanent.

> --- a/mm/page_io.c~mm-swap-mark-swap-pages-writeback-before-queueing-for-direct-io-fix
> +++ a/mm/page_io.c
> @@ -244,10 +244,8 @@ int __swap_writepage(struct page *page,
>  			 */
>  			set_page_dirty(page);
>  			ClearPageReclaim(page);
> -			if (printk_ratelimit()) {
> -				pr_err("Write-error on dio swapfile (%Lu)\n",
> -					(unsigned long long)page_file_offset(page));
> -			}
> +			pr_err_ratelimited("Write error on dio swapfile (%Lu)\n",
> +				(unsigned long long)page_file_offset(page));
>  		}
>  		end_page_writeback(page);
>  		return ret;
> 
> Do we need to cast the loff_t?  afaict all architectures use long long.
> I didn't get a warning from sparc64 with the cast removed, and sparc64
> is the one which likes to use different underlying types.
> 
> I think I'll remove it and wait for Fengguang's nastygram.
> 

Sounds reasonable. I'll get cc'd on the same mails.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
