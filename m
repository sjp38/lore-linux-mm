From: Neil Brown <neilb@suse.de>
Date: Tue, 24 Apr 2007 16:07:35 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17965.40615.454568.662916@notabene.brown>
Subject: Re: [patch 06/44] mm: trim more holes
In-Reply-To: message from Nick Piggin on Tuesday April 24
References: <20070424012346.696840000@suse.de>
	<20070424013432.826128000@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday April 24, npiggin@suse.de wrote:
> 
> If prepare_write fails with AOP_TRUNCATED_PAGE, or if commit_write fails, then
> we may have failed the write operation despite prepare_write having
> instantiated blocks past i_size. Fix this, and consolidate the trimming into
> one place.
> 
..
> @@ -2025,40 +2012,53 @@ generic_file_buffered_write(struct kiocb
>  						cur_iov, iov_offset, bytes);
>  		flush_dcache_page(page);
>  		status = a_ops->commit_write(file, page, offset, offset+bytes);
> -		if (status == AOP_TRUNCATED_PAGE) {
> -			page_cache_release(page);
> -			continue;
> +		if (unlikely(status < 0))
> +			goto fs_write_aop_error;
> +		if (unlikely(copied != bytes)) {
> +			status = -EFAULT;
> +			goto fs_write_aop_error;
>  		}

It isn't clear to me that you are handling the case
       status == AOP_TRUNCATED_PAGE
here.  AOP_TRUNCATED_PAGE is > 0 (0x80001 to be precise)

Maybe ->commit_write cannot return AOP_TRUNCATED_PAGE.  If that is
true, then a comment to that effect (i.e. that the old code was wrong)
in the change log might easy review. 

Or did I miss something?

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
