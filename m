Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id AAB286B005A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 04:48:10 -0500 (EST)
Message-ID: <50A0C5D2.7000806@web.de>
Date: Mon, 12 Nov 2012 10:48:02 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <1352356737-14413-1-git-send-email-m.szyprowski@samsung.com> <20121111172243.GB821@lunn.ch>
In-Reply-To: <20121111172243.GB821@lunn.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lunn <andrew@lunn.ch>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 11.11.2012 18:22, Andrew Lunn wrote:
 > On Thu, Nov 08, 2012 at 07:38:57AM +0100, Marek Szyprowski wrote:
 >> dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag, 
regardless
 >> the flags provided by the caller. This causes excessive pruning of
 >> emergency memory pools without any good reason. This patch changes 
the code
 >> to correctly use gfp flags provided by the dmapool caller. This should
 >> solve the dmapool usage on ARM architecture, where GFP_ATOMIC DMA
 >> allocations can be served only from the special, very limited memory 
pool.
 >>
 >> Reported-by: Soren Moch <smoch@web.de>
Please use
Reported-by: Soeren Moch <smoch@web.de>

 >> Reported-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
 >> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
 >
 > Tested-by: Andrew Lunn <andrew@lunn.ch>
 >
 > I tested this on a Kirkwood QNAP after removing the call to
 > init_dma_coherent_pool_size().
 >
 >     Andrew

Tested-by: Soeren Moch <smoch@web.de>

Now I had a chance to test this patch on my Kirkwood guruplug
system with linux-3.6.6 . It is running much better now, but with the
original 256K coherent pool size I still see errors after several hours
of runtime:

Nov 12 09:42:32 guru kernel: ERROR: 256 KiB atomic DMA coherent pool is 
too small!
Nov 12 09:42:32 guru kernel: Please increase it with coherent_pool= 
kernel parameter!

   Soeren

 >> ---
 >>  mm/dmapool.c |   27 +++++++--------------------
 >>  1 file changed, 7 insertions(+), 20 deletions(-)
 >>
 >> diff --git a/mm/dmapool.c b/mm/dmapool.c
 >> index c5ab33b..86de9b2 100644
 >> --- a/mm/dmapool.c
 >> +++ b/mm/dmapool.c
 >> @@ -62,8 +62,6 @@ struct dma_page {        /* cacheable header for 
'allocation' bytes */
 >>      unsigned int offset;
 >>  };
 >>
 >> -#define    POOL_TIMEOUT_JIFFIES    ((100 /* msec */ * HZ) / 1000)
 >> -
 >>  static DEFINE_MUTEX(pools_lock);
 >>
 >>  static ssize_t
 >> @@ -227,7 +225,6 @@ static struct dma_page *pool_alloc_page(struct 
dma_pool *pool, gfp_t mem_flags)
 >>          memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
 >>  #endif
 >>          pool_initialise_page(pool, page);
 >> -        list_add(&page->page_list, &pool->page_list);
 >>          page->in_use = 0;
 >>          page->offset = 0;
 >>      } else {
 >> @@ -315,30 +312,21 @@ void *dma_pool_alloc(struct dma_pool *pool, 
gfp_t mem_flags,
 >>      might_sleep_if(mem_flags & __GFP_WAIT);
 >>
 >>      spin_lock_irqsave(&pool->lock, flags);
 >> - restart:
 >>      list_for_each_entry(page, &pool->page_list, page_list) {
 >>          if (page->offset < pool->allocation)
 >>              goto ready;
 >>      }
 >> -    page = pool_alloc_page(pool, GFP_ATOMIC);
 >> -    if (!page) {
 >> -        if (mem_flags & __GFP_WAIT) {
 >> -            DECLARE_WAITQUEUE(wait, current);
 >>
 >> -            __set_current_state(TASK_UNINTERRUPTIBLE);
 >> -            __add_wait_queue(&pool->waitq, &wait);
 >> -            spin_unlock_irqrestore(&pool->lock, flags);
 >> +    /* pool_alloc_page() might sleep, so temporarily drop 
&pool->lock */
 >> +    spin_unlock_irqrestore(&pool->lock, flags);
 >>
 >> -            schedule_timeout(POOL_TIMEOUT_JIFFIES);
 >> +    page = pool_alloc_page(pool, mem_flags);
 >> +    if (!page)
 >> +        return NULL;
 >>
 >> -            spin_lock_irqsave(&pool->lock, flags);
 >> -            __remove_wait_queue(&pool->waitq, &wait);
 >> -            goto restart;
 >> -        }
 >> -        retval = NULL;
 >> -        goto done;
 >> -    }
 >> +    spin_lock_irqsave(&pool->lock, flags);
 >>
 >> +    list_add(&page->page_list, &pool->page_list);
 >>   ready:
 >>      page->in_use++;
 >>      offset = page->offset;
 >> @@ -348,7 +336,6 @@ void *dma_pool_alloc(struct dma_pool *pool, 
gfp_t mem_flags,
 >>  #ifdef    DMAPOOL_DEBUG
 >>      memset(retval, POOL_POISON_ALLOCATED, pool->size);
 >>  #endif
 >> - done:
 >>      spin_unlock_irqrestore(&pool->lock, flags);
 >>      return retval;
 >>  }
 >> --
 >> 1.7.9.5
 >>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
