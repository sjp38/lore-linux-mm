Message-ID: <452C838A.70806@yahoo.com.au>
Date: Wed, 11 Oct 2006 15:39:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
References: <20061010121314.19693.75503.sendpatchset@linux.site>	<20061010121332.19693.37204.sendpatchset@linux.site> <20061010213843.4478ddfc.akpm@osdl.org>
In-Reply-To: <20061010213843.4478ddfc.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Tue, 10 Oct 2006 16:21:49 +0200 (CEST)
>Nick Piggin <npiggin@suse.de> wrote:
>
>
>>Fix the race between invalidate_inode_pages and do_no_page.
>>
>>Andrea Arcangeli identified a subtle race between invalidation of
>>pages from pagecache with userspace mappings, and do_no_page.
>>
>>The issue is that invalidation has to shoot down all mappings to the
>>page, before it can be discarded from the pagecache. Between shooting
>>down ptes to a particular page, and actually dropping the struct page
>>from the pagecache, do_no_page from any process might fault on that
>>page and establish a new mapping to the page just before it gets
>>discarded from the pagecache.
>>
>>The most common case where such invalidation is used is in file
>>truncation. This case was catered for by doing a sort of open-coded
>>seqlock between the file's i_size, and its truncate_count.
>>
>>Truncation will decrease i_size, then increment truncate_count before
>>unmapping userspace pages; do_no_page will read truncate_count, then
>>find the page if it is within i_size, and then check truncate_count
>>under the page table lock and back out and retry if it had
>>subsequently been changed (ptl will serialise against unmapping, and
>>ensure a potentially updated truncate_count is actually visible).
>>
>>Complexity and documentation issues aside, the locking protocol fails
>>in the case where we would like to invalidate pagecache inside i_size.
>>do_no_page can come in anytime and filemap_nopage is not aware of the
>>invalidation in progress (as it is when it is outside i_size). The
>>end result is that dangling (->mapping == NULL) pages that appear to
>>be from a particular file may be mapped into userspace with nonsense
>>data. Valid mappings to the same place will see a different page.
>>
>>Andrea implemented two working fixes, one using a real seqlock,
>>another using a page->flags bit. He also proposed using the page lock
>>in do_no_page, but that was initially considered too heavyweight.
>>However, it is not a global or per-file lock, and the page cacheline
>>is modified in do_no_page to increment _count and _mapcount anyway, so
>>a further modification should not be a large performance hit.
>>Scalability is not an issue.
>>
>>This patch implements this latter approach. ->nopage implementations
>>return with the page locked if it is possible for their underlying
>>file to be invalidated (in that case, they must set a special vm_flags
>>bit to indicate so). do_no_page only unlocks the page after setting
>>up the mapping completely. invalidation is excluded because it holds
>>the page lock during invalidation of each page (and ensures that the
>>page is not mapped while holding the lock).
>>
>>This allows significant simplifications in do_no_page.
>>
>>
>
>The (unchangelogged) changes to filemap_nopage() appear to have switched
>the try-the-read-twice logic into try-it-forever logic.  I think it'll hang
>if there's a bad sector?
>

It should fall out if there is an error. I think. I'll go through it again.

Some of the changes simply come about due to find_lock_page meaning that we
never see an !uptodate page unless it is an error, so some of that stuff can
come out.

But I see that it does read twice. Do you want that behaviour retained? It
seems like at this level it would be logical to read it once and let lower
layers take care of any retries?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
