Date: Wed, 6 Apr 2005 12:27:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: "orphaned pagecache memleak fix" question.
Message-Id: <20050406122711.1875931a.akpm@osdl.org>
In-Reply-To: <16979.53442.695822.909010@gargle.gargle.HOWL>
References: <16978.46735.644387.570159@gargle.gargle.HOWL>
	<20050406005804.0045faf9.akpm@osdl.org>
	<16979.53442.695822.909010@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrea@Suse.DE, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
>   > I think it would be better to make ->invalidatepage always succeed though. 
>   > The situation is probably rare.
> 
>  What about the following:
>  ----------------------------------------------------------------------
>  diff -u bk-linux-2.5/Documentation/filesystems/Locking bk-linux/Documentation/filesystems/Locking
>  --- bk-linux-2.5/Documentation/filesystems/Locking	2005-04-04 19:40:53.000000000 +0400
>  +++ bk-linux/Documentation/filesystems/Locking	2005-04-06 15:57:46.000000000 +0400
>  @@ -266,10 +266,13 @@
>   instances do not actually need the BKL. Please, keep it that way and don't
>   breed new callers.
>   
>  -	->invalidatepage() is called when the filesystem must attempt to drop
>  -some or all of the buffers from the page when it is being truncated.  It
>  -returns zero on success.  If ->invalidatepage is zero, the kernel uses
>  -block_invalidatepage() instead.
>  +    ->invalidatepage() is called when whole page or its portion is invalidated
>  +during truncate. PG_locked and PG_writeback bits of the page are acquired by
>  +the current thread before calling ->invalidatepage(), so it is guaranteed that
>  +no IO against this page is going on. Result of ->invalidatepage() is ignored
>  +and page is unconditionally removed from the mapping. File system has to
>  +either release all additional references to the page or to remove the page
>  +from ->lru list and to track its lifetime.

I'd prefer to say "the fs _must_ release the page's private metadata,
unless, as a special concession to block-backed filesystems, that happens
to be buffer_heads".

Not for any deep reason: it's just that thus-far we've avoided fiddling
witht he LRU queues in filesystems and it'd be nice to retain that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
