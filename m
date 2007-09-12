Date: Wed, 12 Sep 2007 04:56:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03 of 24] prevent oom deadlocks during read/write
 operations
Message-Id: <20070912045659.2cd1ede6.akpm@linux-foundation.org>
In-Reply-To: <5566f2af006a171cd47d.1187786930@v2.random>
References: <patchbomb.1187786927@v2.random>
	<5566f2af006a171cd47d.1187786930@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:50 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778124 -7200
> # Node ID 5566f2af006a171cd47d596c6654f51beca74203
> # Parent  90afd499e8ca0dfd2e0284372dca50f2e6149700
> prevent oom deadlocks during read/write operations
> 
> We need to react to SIGKILL during read/write with huge buffers or it
> becomes too easy to prevent a SIGKILLED task to run do_exit promptly
> after it has been selected for oom-killage.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -925,6 +925,13 @@ page_ok:
>  			goto out;
>  		}
>  
> +		if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
> +			/*
> +			 * Must not hang almost forever in D state in presence of sigkill
> +			 * and lots of ram/swap (think during OOM).
> +			 */
> +			break;
> +

please try to keep the code inside 80 cols.

this code leaks a page ref.

>  		/* nr is the maximum number of bytes to copy from this page */
>  		nr = PAGE_CACHE_SIZE;
>  		if (index == end_index) {
> @@ -1868,6 +1875,13 @@ generic_file_buffered_write(struct kiocb
>  		unsigned long index;
>  		unsigned long offset;
>  		size_t copied;
> +
> +		if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
> +			/*
> +			 * Must not hang almost forever in D state in presence of sigkill
> +			 * and lots of ram/swap (think during OOM).
> +			 */
> +			break;
>  
>  		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
>  		index = pos >> PAGE_CACHE_SHIFT;
> 

I had to rejig this code quite a lot on top of the stuff which is pending
in -mm and I might have missed a path.  Nick, can you please review this
closely?

The patch adds sixty-odd bytes of text to some of the most-used code in the
kernel.  Based on the above problem description I'm doubting that this is
justified.  Please tell us more?

diff -puN mm/filemap.c~oom-handling-prevent-oom-deadlocks-during-read-write-operations mm/filemap.c
--- a/mm/filemap.c~oom-handling-prevent-oom-deadlocks-during-read-write-operations
+++ a/mm/filemap.c
@@ -916,6 +916,15 @@ page_ok:
 			goto out;
 		}
 
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
+			/*
+			 * Must not hang almost forever in D state in presence
+			 * of sigkill and lots of ram/swap (think during OOM).
+			 */
+			page_cache_release(page);
+			goto out;
+		}
+
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
 		if (index == end_index) {
@@ -2050,6 +2059,15 @@ static ssize_t generic_perform_write_2co
 			break;
 		}
 
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
+			/*
+			 * Must not hang almost forever in D state in presence
+			 * of sigkill and lots of ram/swap (think during OOM).
+			 */
+			status = -ENOMEM;
+			break;
+		}
+
 		page = __grab_cache_page(mapping, index);
 		if (!page) {
 			status = -ENOMEM;
@@ -2220,6 +2238,15 @@ again:
 			break;
 		}
 
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
+			/*
+			 * Must not hang almost forever in D state in presence
+			 * of sigkill and lots of ram/swap (think during OOM).
+			 */
+			status = -ENOMEM;
+			break;
+		}
+
 		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
 						&page, &fsdata);
 		if (unlikely(status))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
