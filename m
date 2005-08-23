Message-ID: <430A9A4A.50707@andrew.cmu.edu>
Date: Mon, 22 Aug 2005 23:38:50 -0400
From: Rahul Iyer <rni@andrew.cmu.edu>
MIME-Version: 1.0
Subject: writepage and high performance filesystems
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
As part of some research i was doing, i was looking at high bandwidth 
file systems which target to serve the data requirements of computing 
clusters. We think we are facing an issue here...

When memory pressure is felt, kswapd is woken up, and it calls 
balance_pgdat, which eventually results in pageout() being called. From 
the pageout() function on 2.6.11:

325        SetPageReclaim(page);
326        res = mapping->a_ops->writepage(page, &wbc);

This results in the writepage being called for each dirty page if it has 
a mapping pointer. A few of the researchers at CMU tell me that this 
behavior could be pretty bad for high bandwidth storage back ends. The 
reason being that breaking down a 500MB write into several 4K chunks 
results in underutilization of the disk bandwidth as there is 
unnecessary disk spinning between the 4K writes. Also, the pages are not 
evicted fast enough to maintain a steady stream of 4K writes to 
optimally utilize the storage bandwidth.

So, I was thinking about the solution to this...
Having the writepage function look like this might probably help...

static_int new_writepage (struct page *page, struct writeback_control *wbc)
{
    if (page->mapping->nr_coalesced < coalesce_limit)
        page->mapping->nr_coalesced++;
    else
        page->mapping->writepages(mapping, wbc);
}

where nr_coalesced is the number of pages currently coalesced before a 
write in the address_space and coalesce_limit is the number of dirty 
pages to coalesce before calling a writepages(). This of course required 
the addition of this variable to the address_space. coalesce_limit could 
be set through a /proc interface. Setting it to 0 would disable the 
coalescing.

writepages() is only called in the synchronous page_reclaim, i.e., 
try_to_free_pages() - via wakeup_bdflush(), but not in the kswapd code 
path. Is there any specific reason for this?

However, what would be the advantages of moving this into the kswapd 
code path?
I do realize that this could result in pages not getting written out 
when asked to, and so cause problems with memory reclaim, but given that 
this is a high bandwidth filesystem, there should be a lot of dirty 
pages and we should hit coalesce_limit pretty quickly. This would be the 
common case i presume. In the event of it not happening, we have the 
call to writepages() in try_to_free_pages(), so that would clear things 
for us. I agree this behavior is not desirable as try_to_free_pages() is 
synchronous, but this behavior should not be the common case.

Is my reasoning logical, or am I missing the bigger picture?

Thanks
Rahul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
