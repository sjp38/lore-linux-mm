Date: Sat, 23 Feb 2008 00:06:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/28] mm: memory reserve management
Message-Id: <20080223000606.d7474c91.akpm@linux-foundation.org>
In-Reply-To: <20080220150306.548965000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150306.548965000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:20 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Generic reserve management code. 
> 
> It provides methods to reserve and charge. Upon this, generic alloc/free style
> reserve pools could be build, which could fully replace mempool_t
> functionality.
> 
> It should also allow for a Banker's algorithm replacement of __GFP_NOFAIL.

Generally: the comments in this code are a bit straggly and hard to follow.
They'd be worth a revisit.

> +/*
> + * Simple output of the reserve tree in: /proc/reserve_info
> + * Example:
> + *
> + * localhost ~ # cat /proc/reserve_info
> + * total reserve                  8156K (0/544817)
> + *   total network reserve          8156K (0/544817)
> + *     network TX reserve             196K (0/49)
> + *       protocol TX pages              196K (0/49)
> + *     network RX reserve             7960K (0/544768)
> + *       IPv6 route cache               1372K (0/4096)
> + *       IPv4 route cache               5468K (0/16384)
> + *       SKB data reserve               1120K (0/524288)
> + *         IPv6 fragment cache            560K (0/262144)
> + *         IPv4 fragment cache            560K (0/262144)
> + */

Well, "Simple" was a freudian typo.  Not designed for programmatic parsing,
I see.

> +static __init int mem_reserve_proc_init(void)
> +{
> +	struct proc_dir_entry *entry;
> +
> +	entry = create_proc_entry("reserve_info", S_IRUSR, NULL);

I think we're supposed to use proc_create().  Blame Alexey.

> +	if (entry)
> +		entry->proc_fops = &mem_reserve_opterations;
> +
> +	return 0;
> +}
> +
> +__initcall(mem_reserve_proc_init);

module_init() is more trendy.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
