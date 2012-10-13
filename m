Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9491D6B0068
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 19:46:20 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/2] RFC SLUB: increase range of kmalloc slab sizes
References: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk>
Date: Sat, 13 Oct 2012 16:46:19 -0700
In-Reply-To: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk>
	(Richard Kennedy's message of "Sat, 13 Oct 2012 17:31:23 +0100")
Message-ID: <m2y5jarl4k.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Richard Kennedy <richard@rsk.demon.co.uk> writes:

> This patch increases the range of slab sizes available to kmalloc, adding
> slabs half way between the existing power of two sized ones, so allowing slightly
>  more efficient use of memory.
> Most of the new slabs already exist as kmem_cache slabs so only the 1.5k,3k & 6k 
> are entirely new.

I'm not sure what order slab/slub use by default these days, but for
order 0 none of your new sizes sound like a winner:

4K / 1.5 = 2  = 4K / 2K 
4K / 3K  = 1  = 4K / 4K
8K / 6K  = 1  = 8K / 8K

I think you need better data that it actually saves memory with some
reproducible workloads.

Revisiting the sizes is a good idea -- the original Bonwick slab paper
explicitely recommended against power of twos -- but I think it needs a
more data driven process to actually select better ones than what you
used.

Most likely the best fits are different between 32bit and 64bit
and also will change occasionally as kernel data structures grow
(or rarely shrink)

In fact I suspect it would be an interesting option for feedback
control for embedded kernels - measure workload, reboot/recompile with
slab fitting the workload well.

So I think before trying any of this you need a good slab profiler
and a good set of workloads.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
