Date: Thu, 3 Jan 2008 01:53:42 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 03 of 24] prevent oom deadlocks during read/write
	operations
Message-ID: <20080103005341.GG30939@v2.random>
References: <patchbomb.1187786927@v2.random> <5566f2af006a171cd47d.1187786930@v2.random> <20070912045659.2cd1ede6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912045659.2cd1ede6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 04:56:59AM -0700, Andrew Morton wrote:
> The patch adds sixty-odd bytes of text to some of the most-used code in the
> kernel.  Based on the above problem description I'm doubting that this is
> justified.  Please tell us more?

It's quite simple, malloc(1g) from 100 tasks and then read(1G) from
nfs on the same 100 tasks at the same time and they all go oom at the
same time. Without the sigkill check the oom killer is not very useful
and thing simply hangs for long.

> diff -puN mm/filemap.c~oom-handling-prevent-oom-deadlocks-during-read-write-operations mm/filemap.c
> --- a/mm/filemap.c~oom-handling-prevent-oom-deadlocks-during-read-write-operations
> +++ a/mm/filemap.c
> @@ -916,6 +916,15 @@ page_ok:
>  			goto out;
>  		}
>  
> +		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
> +			/*
> +			 * Must not hang almost forever in D state in presence
> +			 * of sigkill and lots of ram/swap (think during OOM).
> +			 */
> +			page_cache_release(page);
> +			goto out;
> +		}
> +
>  		/* nr is the maximum number of bytes to copy from this page */
>  		nr = PAGE_CACHE_SIZE;
>  		if (index == end_index) {
> @@ -2050,6 +2059,15 @@ static ssize_t generic_perform_write_2co
>  			break;
>  		}
>  
> +		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
> +			/*
> +			 * Must not hang almost forever in D state in presence
> +			 * of sigkill and lots of ram/swap (think during OOM).
> +			 */
> +			status = -ENOMEM;
> +			break;
> +		}
> +
>  		page = __grab_cache_page(mapping, index);
>  		if (!page) {
>  			status = -ENOMEM;
> @@ -2220,6 +2238,15 @@ again:
>  			break;
>  		}
>  
> +		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
> +			/*
> +			 * Must not hang almost forever in D state in presence
> +			 * of sigkill and lots of ram/swap (think during OOM).
> +			 */
> +			status = -ENOMEM;
> +			break;
> +		}
> +
>  		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
>  						&page, &fsdata);
>  		if (unlikely(status))

Was there another approach for this? I merged your version anyway in
the meantime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
