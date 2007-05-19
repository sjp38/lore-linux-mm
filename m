Date: Sat, 19 May 2007 01:37:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MM : alloc_large_system_hash() can free some memory for
 non power-of-two bucketsize
Message-Id: <20070519013724.3d4b74e0.akpm@linux-foundation.org>
In-Reply-To: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
References: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007 11:54:54 +0200 Eric Dumazet <dada1@cosmosbay.com> wrote:

> alloc_large_system_hash() is called at boot time to allocate space for several large hash tables.
> 
> Lately, TCP hash table was changed and its bucketsize is not a power-of-two anymore.
> 
> On most setups, alloc_large_system_hash() allocates one big page (order > 0) with __get_free_pages(GFP_ATOMIC, order). This single high_order page has a power-of-two size, bigger than the needed size.

Watch the 200-column text, please.

> We can free all pages that wont be used by the hash table.
> 
> On a 1GB i386 machine, this patch saves 128 KB of LOWMEM memory.
> 
> TCP established hash table entries: 32768 (order: 6, 393216 bytes)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ae96dd8..2e0ba08 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3350,6 +3350,20 @@ void *__init alloc_large_system_hash(const char *tablename,
>  			for (order = 0; ((1UL << order) << PAGE_SHIFT) < size; order++)
>  				;
>  			table = (void*) __get_free_pages(GFP_ATOMIC, order);
> +			/*
> +			 * If bucketsize is not a power-of-two, we may free
> +			 * some pages at the end of hash table.
> +			 */
> +			if (table) {
> +				unsigned long alloc_end = (unsigned long)table +
> +						(PAGE_SIZE << order);
> +				unsigned long used = (unsigned long)table +
> +						PAGE_ALIGN(size);
> +				while (used < alloc_end) {
> +					free_page(used);
> +					used += PAGE_SIZE;
> +				}
> +			}
>  		}
>  	} while (!table && size > PAGE_SIZE && --log2qty);
>  

It went BUG.

static inline int put_page_testzero(struct page *page)
{
	VM_BUG_ON(atomic_read(&page->_count) == 0);
	return atomic_dec_and_test(&page->_count);
}

http://userweb.kernel.org/~akpm/s5000523.jpg
http://userweb.kernel.org/~akpm/config-vmm.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
