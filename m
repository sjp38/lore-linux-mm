Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 676AE6B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 18:23:25 -0400 (EDT)
Date: Sun, 18 Mar 2012 22:23:21 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [rfc][patches] fix for munmap/truncate races
Message-ID: <20120318222321.GE6589@ZenIV.linux.org.uk>
References: <20120318190744.GA6589@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120318190744.GA6589@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 18, 2012 at 07:07:45PM +0000, Al Viro wrote:
> 	Background: truncate() ends up going through the shared mappings
> of file being truncated (under ->i_mmap_mutex, to protect them from
> getting removed while we do that) and calling unmap_vmas() on them,
> with range passed to unmap_vmas() sitting entirely within the vma
> being passed to it.  The trouble is, unmap_vmas() expects a chain of
> vmas.  It will look into the next vma, see that it's beyond the range
> we'd been given and do nothing to it.  Fine, except that there's nothing
> to protect that next vma from being removed just as we do that - we do
> *not* hold ->i_mmap and ->i_mmap_mutex held on our file won't do anything
> to mappings that have nothing to do with the file in question.
> 
> 	There's an obvious way to deal with that - introducing a variant
> of unmap_vmas() that would handle a single vma and switch these callers
> of unmap_vmas() to using it.  It requires some preparations; below is
> the combined diff, for those who prefer to review the splitup, it is in
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git #vm

BTW, the missing part of pull request:

Shortlog:
Al Viro (6):
      VM: unmap_page_range() can return void
      VM: can't go through the inner loop in unmap_vmas() more than once...
      VM: make zap_page_range() return void
      VM: don't bother with feeding upper limit to tlb_finish_mmu() in exit_mmap()
      VM: make unmap_vmas() return void
      VM: make zap_page_range() callers that act on a single VMA use separate helper

Diffstat:
 include/linux/mm.h |    4 +-
 mm/memory.c        |  133 +++++++++++++++++++++++++++++++---------------------
 mm/mmap.c          |    5 +-
 3 files changed, 84 insertions(+), 58 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
