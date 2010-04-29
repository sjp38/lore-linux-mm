Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5922C6B0220
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 12:21:51 -0400 (EDT)
Date: Thu, 29 Apr 2010 18:21:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100429162120.GC22108@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Mel,

did you see my proposed fix? I'm running with it applied, I'd be
interested if you can test it. Surely it will also work for new
anon-vma code in upstream, because at that point there's just 1
anon-vma and nothing else attached to the vma.

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=6efa1dfa5152ef8d7f26beb188d6877525a9dd03

I think it's wrong to try to handle the race in rmap walk by making
magic checks on vm_flags VM_GROWSDOWN|GROWSUP and
vma->vm_mm->map_count == 1, when we can fix it fully and simply in
exec.c by indexing two vmas in the same anon-vma with a different
vm_start so the pages will be found at all times by the rmap_walk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
