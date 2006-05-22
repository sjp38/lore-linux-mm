Date: Mon, 22 May 2006 15:12:27 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH (try #2)] mm: avoid unnecessary OOM kills
Message-Id: <20060522151227.37fd9e51.pj@sgi.com>
In-Reply-To: <200605222143.k4MLhs2w021071@calaveras.llnl.gov>
References: <200605222143.k4MLhs2w021071@calaveras.llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, linux-mm@kvack.org, garlick@llnl.gov, mgrondona@llnl.gov
List-ID: <linux-mm.kvack.org>

Dave wrote:
> -	if (printk_ratelimit()) {
> -		printk("oom-killer: gfp_mask=0x%x, order=%d\n",
> -			gfp_mask, order);
> -		dump_stack();
> -		show_mem();
> -	}
> -
> +	printk("oom-killer: gfp_mask=0x%x, order=%d\n", gfp_mask, order);
> +	dump_stack();
> +	show_mem();

Why disable this printk_ratelimit?  Does this expose us to a Denial of
Service attack from someone forcing multiple oom-kills in a small
cpuset, generating much kernel printk output?

> +/* Try to allocate one more time before invoking the OOM killer. */
> +static struct page * oom_alloc(gfp_t gfp_mask, unsigned int order,

This comment is slightly stale.  Not only does oom_alloc() try one
more allocation, it also actually does invoke the OOM killer.

How about the comment:

   /* Serialize oom killing, while trying to allocate a page */

Or some such ..

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
