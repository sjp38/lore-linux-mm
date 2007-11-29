Date: Thu, 29 Nov 2007 14:48:57 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 16/19] Use page_cache_xxx in fs/ext4
Message-ID: <20071129034857.GW119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011148.032437954@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011148.032437954@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:08PM -0800, Christoph Lameter wrote:
> @@ -1677,6 +1676,7 @@ static int ext4_journalled_writepage(str
>  	handle_t *handle = NULL;
>  	int ret = 0;
>  	int err;
> +	int pagesize = page_cache_size(inode->i_mapping);
>  
>  	if (ext4_journal_current_handle())
>  		goto no_write;
> @@ -1693,17 +1693,17 @@ static int ext4_journalled_writepage(str
>  		 * doesn't seem much point in redirtying the page here.
>  		 */
>  		ClearPageChecked(page);
> -		ret = block_prepare_write(page, 0, PAGE_CACHE_SIZE,
> +		ret = block_prepare_write(page, 0, page_cache_size(mapping),
>  					ext4_get_block);
>  		if (ret != 0) {
>  			ext4_journal_stop(handle);
>  			goto out_unlock;
>  		}
>  		ret = walk_page_buffers(handle, page_buffers(page), 0,
> -			PAGE_CACHE_SIZE, NULL, do_journal_get_write_access);
> +			page_cache_size(mapping), NULL, do_journal_get_write_access);
>  
>  		err = walk_page_buffers(handle, page_buffers(page), 0,
> -				PAGE_CACHE_SIZE, NULL, write_end_fn);
> +			page_cache_size(mapping), NULL, write_end_fn);

These three should use the pagesize variable.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
