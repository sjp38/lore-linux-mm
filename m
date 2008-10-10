Message-ID: <48EFC243.7040505@inria.fr>
Date: Fri, 10 Oct 2008 22:59:47 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use a radix-tree to make do_move_pages() complexity
 linear
References: <48EDF9DA.7000508@inria.fr> <20081010125010.164bcbb8.akpm@linux-foundation.org> <48EFB6E6.4080708@inria.fr>
In-Reply-To: <48EFB6E6.4080708@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, nathalie.furmento@labri.fr
List-ID: <linux-mm.kvack.org>

Brice Goglin wrote:
> Andrew Morton wrote:
>   
>> On Thu, 09 Oct 2008 14:32:26 +0200
>> Brice Goglin <Brice.Goglin@inria.fr> wrote:
>>
>>   
>>     
>>> Add a radix-tree in do_move_pages() to associate each page with
>>> the struct page_to_node that describes its migration.
>>> new_page_node() can now easily find out the page_to_node of the
>>> given page instead of traversing the whole page_to_node array.
>>> So the overall complexity is linear instead of quadratic.
>>>
>>> We still need the page_to_node array since it is allocated by the
>>> caller (sys_move_page()) and used by do_pages_stat() when no target
>>> nodes are given by the application. And we need room to store all
>>> these page_to_node entries for do_move_pages() as well anyway.
>>>
>>> If a page is given twice by the application, the old code would
>>> return -EBUSY (failure from the second isolate_lru_page()). Now,
>>> radix_tree_insert() will return -EEXIST, and we convert it back
>>> to -EBUSY to keep the user-space ABI.
>>>
>>> The radix-tree is emptied at the end of do_move_pages() since
>>> new_page_node() doesn't know when an entry is used for the last
>>> time (unmap_and_move() could try another pass later).
>>> Marking pp->page as ZERO_PAGE(0) was actually never used. We now
>>> set it to NULL when pp is not in the radix-tree. It is faster
>>> than doing a loop of radix_tree_lookup_gang()+delete().
>>>     
>>>       
>> Any O(n*n) code always catches up with us in the end.  But I do think
>> that to merge this code we'd need some description of the problem which
>> we fixed.
>>
>> Please send a description of the situation under which the current code
>> performs unacceptably.  Some before-and-after quantitative measurements
>> would be good.
>>
>> Because it could be (as far as I know) that the problem is purely
>> theoretical, in which case we might not want the patch at all.
>>   
>>     
>
> Just try sys_move_pages() on a 10-100MB buffer, you'll get something
> like 50MB/s on a recent Opteron machine. This throughput decreases
> significantly with the number of pages. With this patch, we get about
> 350MB/s and the throughput is stable when the migrated buffer gets
> larger. I don't have detailled numbers at hand, I'll send them by monday.
>   

Here's some quickyl-gathered numbers for the duration of move_pages().
It's between nodes #2 and #3 of a quad-quad-core opteron 2347HE with
2.6.27-rc5 + perfmon2:

buffer (kB)	move_pages (us)		move_pages with patch (us)
4000		12351			12580
40000		223975			123024

As you can see, with the patch applied, the migration time for 10x more
pages is 10x more. Without the patch, it's 18x.

I'll see if I can implement what Christoph's ideas.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
