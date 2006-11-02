Message-ID: <454960BA.9070801@yahoo.com.au>
Date: Thu, 02 Nov 2006 14:06:34 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
References: <000001c6fd9e$ef709230$8984030a@amr.corp.intel.com>
In-Reply-To: <000001c6fd9e$ef709230$8984030a@amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Hugh Dickins <hugh@veritas.com>, 'David Gibson' <david@gibson.dropbear.id.au>, g@ozlabs.org, Andrew Morton <akpm@osdl.org>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote:

>Nick Piggin wrote on Tuesday, October 31, 2006 10:19 PM
>
>>So what does the normal page fault path do? Just invalidates the private
>>page out of the page tables. A subsequent fault goes through the normal
>>shared page path, which detects the truncation as it would with any
>>shared fault. Right?
>>
>>hugetlb seems to pretty well follow the same pattern as memory.c in this
>>regard. I don't see the race?
>>
>
>I was originally worried about a case that one thread fault on a private
>mapping and get hold of a fresh page via alloc_huge_page(). While it executes
>clear_huge_page(), 2nd thread come by did a ftruncate. After first thread
>finish zeroing, I thought it will happily install a pte. But no, the inode
>size check will prevent that from happening.
>

Yes it should do.

>I was mislead by the comments in hugetlb_no_page() that page lock is used to
>guard against racing truncation.  Now I'm drifting back into what "racing
>truncation" the comment is referring to. What race does it trying to protect
>with page lock?
>

Probably attempting to fix a similar race as the do_no_page vs 
invalidate race
that I've been trying to fix for normal pages (and is currently handled for
truncate with truncate_count). However AFAIKS it is not page lock which 
protects
from truncate, but the page_table_lock (which the ptl scalability work might
have broken):

Here is the race for regular pagecache:
                     
check i_size          
find_get_page         
                       i_size_write
                       unmap_mapping_range
set_pte               
                       truncate_inode_pages

So we have now mapped a truncated page. I fix this by using find_lock_page
in the filemap_nopage path, but I found that it isn't enough alone.
truncate_inode_pages must also check whether the page is mapped (while
holding the page lock) and be prepared to unmap (like
invalidate_inode_pages does).

Now, when looking at hugepages, it seems to be designed to give you the
unmap_mapping_range vs fault exclusion with ptl (note that it rechecks
i_size inside ptl). However now I think unmap_mapping_range runs without
ptl, you again have a race.

I'll look into it a bit more and see if I can fix it up in my patchset.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
