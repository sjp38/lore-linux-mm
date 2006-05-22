Message-Id: <7.0.0.16.2.20060522154857.02429fd8@llnl.gov>
Date: Mon, 22 May 2006 16:35:14 -0700
From: Dave Peterson <dsp@llnl.gov>
Subject: Re: [PATCH (try #2)] mm: avoid unnecessary OOM kills
In-Reply-To: <20060522151227.37fd9e51.pj@sgi.com>
References: <200605222143.k4MLhs2w021071@calaveras.llnl.gov>
 <20060522151227.37fd9e51.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, linux-mm@kvack.org, garlick@llnl.gov, mgrondona@llnl.gov
List-ID: <linux-mm.kvack.org>

At 03:12 PM 5/22/2006, Paul Jackson wrote:
>Why disable this printk_ratelimit?  Does this expose us to a Denial of
>Service attack from someone forcing multiple oom-kills in a small
>cpuset, generating much kernel printk output?

I figured that the printk_ratelimit() was probably placed there to
eliminate excessive noise due to the following scenario:

    - Process X calls out_of_memory() and shoots process Y.
    - Until Y gets a chance to execute and expire, lots of
      other processes will probably be failing their memory
      allocations and calling out_of_memory(), spewing more
      printk() messages.

I figured that since serializing the OOM kills would eliminate
this behavior, the printk_ratelimit() was no longer necessary.

However, there would still be lots of messages if the OOM killer
is repeatedly triggered due to lots of little processes eating
up memory.  In this case the printk_ratelimit() would serve a
purpose.  In any event there's no harm in leaving it in.  I'll
add back the printk_ratelimit() and make a new patch...

>> +/* Try to allocate one more time before invoking the OOM killer. */
>> +static struct page * oom_alloc(gfp_t gfp_mask, unsigned int order,
>
>This comment is slightly stale.  Not only does oom_alloc() try one
>more allocation, it also actually does invoke the OOM killer.
>
>How about the comment:
>
>   /* Serialize oom killing, while trying to allocate a page */
>
>Or some such ..

How about the following?

/* If an OOM kill is not already in progress, try once more to
 * allocate memory.  If allocation fails this time, invoke the
 * OOM killer.
 */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
