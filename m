Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C51326B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 22:43:27 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3538569pab.29
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 19:43:27 -0700 (PDT)
Message-ID: <5246423F.3010107@oracle.com>
Date: Sat, 28 Sep 2013 10:43:11 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com> <5237FDCC.5010109@oracle.com> <20130923220757.GC16191@variantweb.net> <524318DE.7070106@samsung.com> <20130925215744.GA25852@variantweb.net> <52455B05.1010603@samsung.com> <20130927220045.GA751@variantweb.net>
In-Reply-To: <20130927220045.GA751@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Tomasz Stanislawski <t.stanislaws@samsung.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>



On 09/28/2013 06:00 AM, Seth Jennings wrote:
> On Fri, Sep 27, 2013 at 12:16:37PM +0200, Tomasz Stanislawski wrote:
>> On 09/25/2013 11:57 PM, Seth Jennings wrote:
>>> On Wed, Sep 25, 2013 at 07:09:50PM +0200, Tomasz Stanislawski wrote:
>>>>> I just had an idea this afternoon to potentially kill both these birds with one
>>>>> stone: Replace the rbtree in zswap with an address_space.
>>>>>
>>>>> Each swap type would have its own page_tree to organize the compressed objects
>>>>> by type and offset (radix tree is more suited for this anyway) and a_ops that
>>>>> could be called by shrink_page_list() (writepage) or the migration code
>>>>> (migratepage).
>>>>>
>>>>> Then zbud pages could be put on the normal LRU list, maybe at the beginning of
>>>>> the inactive LRU so they would live for another cycle through the list, then be
>>>>> reclaimed in the normal way with the mapping->a_ops->writepage() pointing to a
>>>>> zswap_writepage() function that would decompress the pages and call
>>>>> __swap_writepage() on them.
>>>>>
>>>>> This might actually do away with the explicit pool size too as the compressed
>>>>> pool pages wouldn't be outside the control of the MM anymore.
>>>>>
>>>>> I'm just starting to explore this but I think it has promise.
>>>>>
>>>>> Seth
>>>>>
>>>>
>>>> Hi Seth,
>>>> There is a problem with the proposed idea.
>>>> The radix tree used 'struct address_space' is a part of
>>>> a bigger data structure.
>>>> The radix tree is used to translate an offset to a page.
>>>> That is ok for zswap. But struct page has a field named 'index'.
>>>> The MM assumes that this index is an offset in radix tree
>>>> where one can find the page. A lot is done by MM to sustain
>>>> this consistency.
>>>
>>> Yes, this is how it is for page cache pages.  However, the MM is able to
>>> work differently with anonymous pages.  In the case of an anonymous
>>> page, the mapping field points to an anon_vma struct, or, if ksm in
>>> enabled and dedup'ing the page, a private ksm tracking structure.  If
>>> the anonymous page is fully unmapped and resides only in the swap cache,
>>> the page mapping is NULL.  So there is precedent for the fields to mean
>>> other things.
>>
>> Hi Seth,
>> You are right that page->mapping is NULL for pages in swap_cache but
>> page_mapping() is not NULL in such a case. The mapping is taken from
>> struct address_space swapper_spaces[]. It is still an address space,
>> and it should preserve constraints for struct address_space.
>> The same happen for page->index and page_index().
>>
>>>
>>> The question is how to mark and identify zbud pages among the other page
>>> types that will be on the LRU.  There are many ways.  The question is
>>> what is the best and most acceptable way.
>>>
>>
>> If you consider hacking I have some idea how address_space could utilized for ZBUD.
>> One solution whould be using tags in a radix tree. Every entry in a radix tree
>> can have a few bits assigned to it. Currently 3 bits are supported:
>>
>> From include/linux/fs.h
>> #define PAGECACHE_TAG_DIRTY  0
>> #define PAGECACHE_TAG_WRITEBACK      1
>> #define PAGECACHE_TAG_TOWRITE        2
>>
>> You could add a new bit or utilize one of existing ones.
>>
>> The other idea is use a trick from a RB trees and scatter-gather lists.
>> I mean using the last bits of pointers to keep some metadata.
>> Values of 'struct page *' variables are aligned to a pointer alignment which is
>> 4 for 32-bit CPUs and 8 for 64-bit ones (not sure). This means that one could
>> could use the last bit of page pointer in a radix tree to track if a swap entry
>> refers to a lower or a higher part of a ZBUD page.
>> I think it is a serious hacking/obfuscation but it may work with the minimal
>> amount of changes to MM. Adding only (x&~3) while extracting page pointer is
>> probably enough.
>>
>> What do you think about this idea?
> 
> I think it is a good one.
> 
> I have to say that when I first came up with the idea, I was thinking
> the address space would be at the zswap layer and the radix slots would
> hold zbud handles, not struct page pointers.
> 
> However, as I have discovered today, this is problematic when it comes
> to reclaim and migration and serializing access.
> 
> I wanted to do as much as possible in the zswap layer since anything
> done in the zbud layer would need to be duplicated in any other future
> allocator that zswap wanted to support.
> 
> Unfortunately, zbud abstracts away the struct page and that visibility
> is needed to properly do what we are talking about.
> 
> So maybe it is inevitable that this will need to be in the zbud code
> with the radix tree slots pointing to struct pages after all.
> 

But in this way, zswap_frontswap_load() can't find zswap_entry. We still
need the rbtree in current zswap.

> I like the idea of masking the bit into the struct page pointer to
> indicate which buddy maps to the offset.
> 

I have no idea why we need this.
My idea is connect zbud page with a address space and add zbud page to
LRU list only without any radix tree.

zswap_entry can be still in rbtree or maybe changed to radix tree.
There is a sample code in my previous email.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
