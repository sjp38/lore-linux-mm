Date: Thu, 29 Nov 2007 15:07:57 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 16/19] Use page_cache_xxx in fs/ext4
Message-ID: <20071129040757.GD119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011148.032437954@sgi.com> <20071129034857.GW119954183@sgi.com> <Pine.LNX.4.64.0711281958250.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711281958250.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 07:58:45PM -0800, Christoph Lameter wrote:
> On Thu, 29 Nov 2007, David Chinner wrote:
> 
> > These three should use the pagesize variable.
> 
> ext4: use pagesize variable instead of the inline function
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/ext4/inode.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> Index: mm/fs/ext4/inode.c
> ===================================================================
> --- mm.orig/fs/ext4/inode.c	2007-11-28 19:56:18.234382799 -0800
> +++ mm/fs/ext4/inode.c	2007-11-28 19:57:10.774132672 -0800
> @@ -1693,17 +1693,16 @@ static int ext4_journalled_writepage(str
>  		 * doesn't seem much point in redirtying the page here.
>  		 */
>  		ClearPageChecked(page);
> -		ret = block_prepare_write(page, 0, page_cache_size(mapping),
> -					ext4_get_block);
> +		ret = block_prepare_write(page, 0, pagesize, ext4_get_block);
>  		if (ret != 0) {
>  			ext4_journal_stop(handle);
>  			goto out_unlock;
>  		}
>  		ret = walk_page_buffers(handle, page_buffers(page), 0,
> -			page_cache_size(mapping), NULL, do_journal_get_write_access);
> +			pagesize, NULL, do_journal_get_write_access);
>  
>  		err = walk_page_buffers(handle, page_buffers(page), 0,
> -			page_cache_size(mapping), NULL, write_end_fn);
> +			pagesize, NULL, write_end_fn);
>  		if (ret == 0)
>  			ret = err;
>  		EXT4_I(inode)->i_state |= EXT4_STATE_JDATA;

ok.

Cheers,

dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
