Date: Sat, 21 Apr 2007 02:55:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/10] mm: count writeback pages per BDI
Message-Id: <20070421025525.042ed73a.akpm@linux-foundation.org>
In-Reply-To: <20070420155503.334628394@chello.nl>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.334628394@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 17:52:02 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Count per BDI writeback pages.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/backing-dev.h |    1 +
>  mm/page-writeback.c         |   12 ++++++++++--
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/page-writeback.c
> ===================================================================
> --- linux-2.6.orig/mm/page-writeback.c	2007-04-20 15:27:28.000000000 +0200
> +++ linux-2.6/mm/page-writeback.c	2007-04-20 15:28:10.000000000 +0200
> @@ -979,14 +979,18 @@ int test_clear_page_writeback(struct pag
>  	int ret;
>  
>  	if (mapping) {
> +		struct backing_dev_info *bdi = mapping->backing_dev_info;
>  		unsigned long flags;
>  
>  		write_lock_irqsave(&mapping->tree_lock, flags);
>  		ret = TestClearPageWriteback(page);
> -		if (ret)
> +		if (ret) {
>  			radix_tree_tag_clear(&mapping->page_tree,
>  						page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
> +			if (bdi_cap_writeback_dirty(bdi))
> +				__dec_bdi_stat(bdi, BDI_WRITEBACK);

Why do we test bdi_cap_writeback_dirty() here?

If we remove that test, we end up accumulating statistics for
non-writebackable backing devs, but does that matter?  Probably the common
case is writebackable backing-devs, so eliminating the test-n-branch might
be a net microgain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
