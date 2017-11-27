Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1DA76B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 21:18:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d15so23696577pfl.0
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:18:39 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w5si23618758pfw.216.2017.11.26.18.18.37
        for <linux-mm@kvack.org>;
        Sun, 26 Nov 2017 18:18:38 -0800 (PST)
Date: Mon, 27 Nov 2017 11:18:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Detecting page cache trashing state
Message-ID: <20171127021835.GA27255@bbox>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
 <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
 <20171025175424.GA14039@cmpxchg.org>
 <d7bc14d7-5ae4-f16d-da38-2bc36d9deae8@cisco.com>
 <bfbfaaa1-2b12-f26f-218a-ff6804f47eae@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <bfbfaaa1-2b12-f26f-218a-ff6804f47eae@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)" <rruslich@cisco.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

Hello,

On Mon, Nov 20, 2017 at 09:40:56PM +0200, Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco) wrote:
> Hi Johannes,
> 
> I tested with your patches but situation is still mostly the same.
> 
> Spend some time for debugging and found that the problem is squashfs
> specific (probably some others fs's too).
> The point is that iowait for squashfs reads will be awaited inside squashfs
> readpage() callback.
> Here is some backtrace for page fault handling to illustrate this:
> 
>  1)               |  handle_mm_fault() {
>  1)               |    filemap_fault() {
>  1)               |      __do_page_cache_readahead()
>  1)               |        add_to_page_cache_lru()
>  1)               |        squashfs_readpage() {
>  1)               |          squashfs_readpage_block() {
>  1)               |            squashfs_get_datablock() {
>  1)               |              squashfs_cache_get() {
>  1)               |                squashfs_read_data() {
>  1)               |                  ll_rw_block() {
>  1)               |                    submit_bh_wbc.isra.42()
>  1)               |                  __wait_on_buffer() {
>  1)               |                    io_schedule() {
>  ------------------------------------------
>  0)   kworker-79   =>    <idle>-0
>  ------------------------------------------
>  0)   0.382 us    |  blk_complete_request();
>  0)               |  blk_done_softirq() {
>  0)               |    blk_update_request() {
>  0)               |      end_buffer_read_sync()
>  0) + 38.559 us   |    }
>  0) + 48.367 us   |  }
>  ------------------------------------------
>  0)   kworker-79   =>  memhog-781
>  ------------------------------------------
>  0) ! 278.848 us  |                    }
>  0) ! 279.612 us  |                  }
>  0)               |                  squashfs_decompress() {
>  0) # 4919.082 us |                    squashfs_xz_uncompress();
>  0) # 4919.864 us |                  }
>  0) # 5479.212 us |                } /* squashfs_read_data */
>  0) # 5479.749 us |              } /* squashfs_cache_get */
>  0) # 5480.177 us |            } /* squashfs_get_datablock */
>  0)               |            squashfs_copy_cache() {
>  0)   0.057 us    |              unlock_page();
>  0) ! 142.773 us  |            }
>  0) # 5624.113 us |          } /* squashfs_readpage_block */
>  0) # 5628.814 us |        } /* squashfs_readpage */
>  0) # 5665.097 us |      } /* __do_page_cache_readahead */
>  0) # 5667.437 us |    } /* filemap_fault */
>  0) # 5672.880 us |  } /* handle_mm_fault */
> 
> As you can see squashfs_read_data() schedules IO by ll_rw_block() and then
> it waits for IO to finish inside wait_on_buffer().
> After that read buffer is decompressed and page is unlocked inside
> squashfs_readpage() handler.
> 
> Thus by the the time when filemap_fault() calls lock_page_or_retry() page
> will be uptodate and unlocked,
> wait_on_page_bit() is not called at all, and time spent for read/decompress
> is not accounted.

A weakness in current approach is that it relies on page lock.
It means it cannot work with sychronous devices like DAX, zram and
so on, I think.

Johannes, Can we add memdelay_enter to every fault handler's prologue?
and we can check it in epilogue whether the faulted page is workingset.
If is was, we can accumuate the spent time.
It would work with synchronous devices, esp, zram without hacking
some FSes like squashfs.

I think page fault handler/kswapd/direct reclaim would cover most of
cases of *real* memory pressure but un[lock]page freinds would cover
superfluously, for example, FSes can call it easily without memory
pressure.

> 
> Tried to apply quick workaround for test:
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index c4ca702..5e2be2b 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -126,9 +126,21 @@ static int read_pages(struct address_space *mapping,
> struct file *filp,
> 
>      for (page_idx = 0; page_idx < nr_pages; page_idx++) {
>          struct page *page = lru_to_page(pages);
> +        bool refault = false;
> +        unsigned long mdflags;
> +
>          list_del(&page->lru);
> -        if (!add_to_page_cache_lru(page, mapping, page->index, gfp))
> +        if (!add_to_page_cache_lru(page, mapping, page->index, gfp)) {
> +            if (!PageUptodate(page) && PageWorkingset(page)) {
> +                memdelay_enter(&mdflags);
> +                refault = true;
> +            }
> +
>              mapping->a_ops->readpage(filp, page);
> +
> +            if (refault)
> +                memdelay_leave(&mdflags);
> +        }
>          put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
