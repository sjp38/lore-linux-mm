Date: Mon, 9 Oct 2006 14:10:13 -0700
From: Mark Fasheh <mark.fasheh@oracle.com>
Subject: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
Message-ID: <20061009211013.GP6485@ca-server1.us.oracle.com>
Reply-To: Mark Fasheh <mark.fasheh@oracle.com>
References: <20061009140354.13840.71273.sendpatchset@linux.site> <20061009140414.13840.90825.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009140414.13840.90825.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Mon, Oct 09, 2006 at 06:12:26PM +0200, Nick Piggin wrote:
> Complexity and documentation issues aside, the locking protocol fails
> in the case where we would like to invalidate pagecache inside i_size.
That pretty much describes part of what ocfs2_data_convert_worker() does.
It's called when another node wants to take a lock at an incompatible level
on an inodes data.

This involves up to two steps, depending on the level of the lock requested.

1) It always syncs dirty data.

2) If it's dropping due to writes on another node, then pages will be
   invalidated and mappings torn down.


There's actually an ocfs2 patch to support shared writeable mappings in via
the ->page_mkwrite() callback, but I haven't pushed it upstream due to a bug
I found during some later testing. I believe the bug is a VM issue, and your
description of the race Andrea identified leads me to wonder if you all
might have just found it and fixed it for me :)


In short, I have an MPI test program which rotates through a set of
processes which have mmaped a pre-formatted file. One process writes some
data, the rest verify that they see the new data. When I run multiple
processes on multiple nodes, I will sometimes find that one of the processes
fails because it sees stale data.


FWIW, the overall approach taken in the patch below seems fine to me, though
I'm no VM expert :)

Not having ocfs2_data_convert_worker() call unmap_mapping_range() directly,
is ok as long as the intent of the function is preserved. You seem to be
doing this by having truncate_inode_pages() unmap instead.

Thanks,
	--Mark

--
Mark Fasheh
Senior Software Developer, Oracle
mark.fasheh@oracle.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
