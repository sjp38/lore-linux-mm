Date: Fri, 4 Apr 2003 15:34:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: objrmap and vmtruncate
Message-ID: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I see you're going for locking the page around page_convert_anon,
to guard page->mapping against truncation.  Nice thought,
but the words "tip" and "iceberg" spring to mind.

Truncating a sys_remap_file_pages file?  You're the first to
begin to consider such an absurd possibility: vmtruncate_list
still believes vm_pgoff tells it what needs to be done.

I propose that we don't change vmtruncate_list, zap_page_range, ...
at all for this: let it unmap inappropriate pages, even from a
VM_LOCKED vma, that's just a price userspace pays for the
privilege of truncating a sys_remap_file_pages file.

But truncate_inode_pages should check page_mapped, and if so
try_to_unmap with a force flag to attack even VM_LOCKED vmas.
Sadly, if page_table_lock is held, it won't be able to unmap:
leave those for shrink_list?  But that won't find them once
page->mapping gone: page_convert_anon from here too?
What about invalidate_inode_pages2?

This will also cover some of the racy pages, which another cpu
found in the cache before vmtruncate started, but inserted into
page table after vmtruncate_list passed that way; but it won't
cover those racy pages which were found before, but are not yet
put into the page table (e.g. those where your page_convert_anon
bailed because page->mapping is now NULL).  Worth adding checks
for? but I don't think we have absolute locking against this.

Various places in rmap.c where !page->mapping is considered a
BUG(), but you've now drawn attention to the fact it may get
vmtruncated at any moment.  Easy to remove those BUG()s.

Consider page_add_rmap of page with NULL (or swapper_space)
mapping as Anon?  In which case move all the SetPageAnon stuff
inside rmap.c, and do ClearPageAnon inside there too?

Or, stop resetting page->mapping to NULL when we remove from
page cache?  So objrmap can still find the pages even though
find_get_page etc. cannot.

Sorry, off to replace my "?" key, it's worn out.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
