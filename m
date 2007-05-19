Message-ID: <464F5FE4.2010607@cosmosbay.com>
Date: Sat, 19 May 2007 22:36:52 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH] MM : alloc_large_system_hash() can free some memory for
 non power-of-two bucketsize
References: <20070518115454.d3e32f4d.dada1@cosmosbay.com>	<20070519013724.3d4b74e0.akpm@linux-foundation.org>	<464F3CCF.2070901@cosmosbay.com> <20070519.115442.30184476.davem@davemloft.net>
In-Reply-To: <20070519.115442.30184476.davem@davemloft.net>
Content-Type: multipart/mixed;
 boundary="------------000202020007030807040908"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>, akpm@linux-foundation.org
Cc: dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000202020007030807040908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a ecrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 19 May 2007 20:07:11 +0200
> 
>> Maybe David has an idea how this can be done properly ?
>>
>> ref : http://marc.info/?l=linux-netdev&m=117706074825048&w=2
> 
> You need to use __GFP_COMP or similar to make this splitting+freeing
> thing work.
> 
> Otherwise the individual pages don't have page references, only
> the head page of the high-order page will.
> 

Oh thanks David for the hint.

I added a split_page() call and it seems to work now.


[PATCH] MM : alloc_large_system_hash() can free some memory for non 
power-of-two bucketsize

alloc_large_system_hash() is called at boot time to allocate space for several 
large hash tables.

Lately, TCP hash table was changed and its bucketsize is not a power-of-two 
anymore.

On most setups, alloc_large_system_hash() allocates one big page (order > 0) 
with __get_free_pages(GFP_ATOMIC, order). This single high_order page has a 
power-of-two size, bigger than the needed size.

We can free all pages that wont be used by the hash table.

On a 1GB i386 machine, this patch saves 128 KB of LOWMEM memory.

TCP established hash table entries: 32768 (order: 6, 393216 bytes)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------000202020007030807040908
Content-Type: text/plain;
 name="alloc_large.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="alloc_large.patch"

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ae96dd8..7c219eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3350,6 +3350,21 @@ void *__init alloc_large_system_hash(const char *tablename,
 			for (order = 0; ((1UL << order) << PAGE_SHIFT) < size; order++)
 				;
 			table = (void*) __get_free_pages(GFP_ATOMIC, order);
+			/*
+			 * If bucketsize is not a power-of-two, we may free
+			 * some pages at the end of hash table.
+			 */
+			if (table) {
+				unsigned long alloc_end = (unsigned long)table +
+						(PAGE_SIZE << order);
+				unsigned long used = (unsigned long)table +
+						PAGE_ALIGN(size);
+				split_page(virt_to_page(table), order);
+				while (used < alloc_end) {
+					free_page(used);
+					used += PAGE_SIZE;
+				}
+			}
 		}
 	} while (!table && size > PAGE_SIZE && --log2qty);
 

--------------000202020007030807040908--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
