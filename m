Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 64A828D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 07:41:13 -0500 (EST)
Date: Thu, 20 Jan 2011 07:40:43 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same
 inode
Message-ID: <20110120124043.GA4347@infradead.org>
References: <E1PftfG-0007w1-Ek@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1PftfG-0007w1-Ek@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hughd@google.com, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 01:30:58PM +0100, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> Running a fuse filesystem with multiple open()'s in parallel can
> trigger a "kernel BUG at mm/truncate.c:475"
> 
> The reason is, unmap_mapping_range() is not prepared for more than
> one concurrent invocation per inode.  For example:
> 
>   thread1: going through a big range, stops in the middle of a vma and
>      stores the restart address in vm_truncate_count.
> 
>   thread2: comes in with a small (e.g. single page) unmap request on
>      the same vma, somewhere before restart_address, finds that the
>      vma was already unmapped up to the restart address and happily
>      returns without doing anything.
> 
> Another scenario would be two big unmap requests, both having to
> restart the unmapping and each one setting vm_truncate_count to its
> own value.  This could go on forever without any of them being able to
> finish.
> 
> Truncate and hole punching already serialize with i_mutex.  Other
> callers of unmap_mapping_range() do not, and it's difficult to get
> i_mutex protection for all callers.  In particular ->d_revalidate(),
> which calls invalidate_inode_pages2_range() in fuse, may be called
> with or without i_mutex.


Which I think is mostly a fuse problem.  I really hate bloating the
generic inode (into which the address_space is embedded) with another
mutex for deficits in rather special case filesystems. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
