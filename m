Message-ID: <452AF312.1020207@yahoo.com.au>
Date: Tue, 10 Oct 2006 11:10:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
References: <20061009140354.13840.71273.sendpatchset@linux.site> <20061009140414.13840.90825.sendpatchset@linux.site> <20061009211013.GP6485@ca-server1.us.oracle.com>
In-Reply-To: <20061009211013.GP6485@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Mark Fasheh wrote:
> Hi Nick,
> 
> On Mon, Oct 09, 2006 at 06:12:26PM +0200, Nick Piggin wrote:
> 
>>Complexity and documentation issues aside, the locking protocol fails
>>in the case where we would like to invalidate pagecache inside i_size.
> 
> That pretty much describes part of what ocfs2_data_convert_worker() does.
> It's called when another node wants to take a lock at an incompatible level
> on an inodes data.
> 
> This involves up to two steps, depending on the level of the lock requested.
> 
> 1) It always syncs dirty data.
> 
> 2) If it's dropping due to writes on another node, then pages will be
>    invalidated and mappings torn down.

Yep, your unmap_mapping_range, and invalidate_inode_pages2 calls in there
are all subject to this bug (provided the pages being invalidated are visible
and able to be mmap()ed).

> There's actually an ocfs2 patch to support shared writeable mappings in via
> the ->page_mkwrite() callback, but I haven't pushed it upstream due to a bug
> I found during some later testing. I believe the bug is a VM issue, and your
> description of the race Andrea identified leads me to wonder if you all
> might have just found it and fixed it for me :)
> 
> 
> In short, I have an MPI test program which rotates through a set of
> processes which have mmaped a pre-formatted file. One process writes some
> data, the rest verify that they see the new data. When I run multiple
> processes on multiple nodes, I will sometimes find that one of the processes
> fails because it sees stale data.

This is roughly similar to what my test program does that I wrote to
reproduce the bug. So it wouldn't surprise me.

> FWIW, the overall approach taken in the patch below seems fine to me, though
> I'm no VM expert :)
> 
> Not having ocfs2_data_convert_worker() call unmap_mapping_range() directly,
> is ok as long as the intent of the function is preserved. You seem to be
> doing this by having truncate_inode_pages() unmap instead.

truncate_inode_pages now unmaps the pages internally, so you should
be OK there. If you're expecting this to happen frequently with mapped
pages, it is probably more efficient to call the full unmap_mapping_range
before you call truncate_inode_pages...

[ Somewhere on my todo list is a cleanup of mm/truncate.c ;) ]

If you want a stable patchset for testing, the previous one to linux-mm
starting with "[patch 1/3] mm: fault vs invalidate/truncate check" went
through some stress testing here...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
