Date: Thu, 27 Apr 2006 16:05:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage addresss space op to
 shmem
In-Reply-To: <Pine.LNX.4.64.0604251153300.29020@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604271554060.27987@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604242046120.24647@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604241447520.8904@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604251153300.29020@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2006, Hugh Dickins wrote:

> Perhaps.  But there seem to be altogether too many ways through this
> code: this part of migrate_pages then starts to look rather like,
> but not exactly like, swap_page.  Feels like it needs refactoring.

Actually the code migrates dirty pages because dirty information is 
available in the pte and not in the dirty bit of the page struct. 

The branch in question is never taken because at that point the dirty 
bit is not set in the the page struct.

Later we call migrate_page(). migrate page unmaps the ptes and transfers 
the dirty bit from the pte into the page struct. At that point we do not 
check the dirty bit again and therefore the page will be migrated without 
writeout. That is why the fallback mechanism passed the tests a couple of 
months back and thats also why Lee reported that migration works for shmem 
without a migratepage() method.

So the current problem is that the fallback path will migrate dirty pages 
without regard to page dirty state. This may cause a problem for 
filesystems that keep additional state for dirty pages and that do not 
define their a migration method (The only filesystems with migration 
methods are currently ext2,3 and xfs).

I need to do some restructuring of migrate_page_remove_references() in 
order to check the dirty state later. No need for pageout anymore. 
Pageout contains more swap specific code that is not needed anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
