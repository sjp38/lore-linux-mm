Date: Sun, 27 Jan 2008 21:52:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Only print kernel debug information for OOMs caused by
 kernel allocations
Message-Id: <20080127215249.94db142b.akpm@linux-foundation.org>
In-Reply-To: <20080116222421.GA7953@wotan.suse.de>
References: <20080116222421.GA7953@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008 23:24:21 +0100 Andi Kleen <ak@suse.de> wrote:

> 
> I recently suffered an 20+ minutes oom thrash disk to death and computer
> completely unresponsive situation on my desktop when some user program
> decided to grab all memory. It eventually recovered, but left lots
> of ugly and imho misleading messages in the kernel log. here's a minor
> improvement
> 
> -Andi
> 
> ---
> 
> Only print kernel debug information for OOMs caused by kernel allocations
> 
> For any page cache allocation don't print the backtrace and the detailed
> zone debugging information. This makes the problem look less like 
> a kernel bug because it typically isn't.
> 
> I needed a new task flag for that. Since the bits are running low
> I reused an unused one (PF_STARTING) 
> 
> Also clarify the error message (OOM means nothing to a normal user) 
> 

That information is useful for working out why a userspace allocation
attempt failed.  If we don't print it, and the application gets killed and
thus frees a lot of memory, we will just never know why the allocation
failed.

>  struct page *__page_cache_alloc(gfp_t gfp)
>  {
> +	struct task_struct *me = current;
> +	unsigned old = (~me->flags) & PF_USER_ALLOC;
> +	struct page *p;
> +
> +	me->flags |= PF_USER_ALLOC;
>  	if (cpuset_do_page_mem_spread()) {
>  		int n = cpuset_mem_spread_node();
> -		return alloc_pages_node(n, gfp, 0);
> -	}
> -	return alloc_pages(gfp, 0);
> +		p = alloc_pages_node(n, gfp, 0);
> +	} else
> +		p = alloc_pages(gfp, 0);
> +	/* Clear USER_ALLOC if it wasn't set originally */
> +	me->flags ^= old;
> +	return p;
>  }

That's appreciable amount of new overhead for at best a fairly marginal
benefit.  Perhaps __GFP_USER could be [re|ab]used.

Alternatively: if we've printed the diagnostic on behalf of this process
and then decided to kill it, set some flag to prevent us from printing it
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
