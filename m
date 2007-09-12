From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 03 of 24] prevent oom deadlocks during read/write operations
Date: Wed, 12 Sep 2007 12:18:34 +1000
References: <patchbomb.1187786927@v2.random> <5566f2af006a171cd47d.1187786930@v2.random> <20070912045659.2cd1ede6.akpm@linux-foundation.org>
In-Reply-To: <20070912045659.2cd1ede6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709121218.34840.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 12 September 2007 21:56, Andrew Morton wrote:

> I had to rejig this code quite a lot on top of the stuff which is pending
> in -mm and I might have missed a path.  Nick, can you please review this
> closely?

I think it looks OK. Is -ENOMEM the right thing to return here? I guess
userspace won't see it if they have a SIGKILL pending? (EINTR or
something may be more logical, but maybe the call chain can't
handle it?)

>
> The patch adds sixty-odd bytes of text to some of the most-used code in the
> kernel.  Based on the above problem description I'm doubting that this is
> justified.  Please tell us more?
>
> diff -puN
> mm/filemap.c~oom-handling-prevent-oom-deadlocks-during-read-write-operation
>s mm/filemap.c ---
> a/mm/filemap.c~oom-handling-prevent-oom-deadlocks-during-read-write-operati
>ons +++ a/mm/filemap.c
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
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
