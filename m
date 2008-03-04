Date: Tue, 4 Mar 2008 12:34:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
Message-Id: <20080304123459.364f879b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
	<47CD4AB3.3080409@linux.vnet.ibm.com>
	<20080304103636.3e7b8fdd.akpm@linux-foundation.org>
	<47CDA081.7070503@cs.helsinki.fi>
	<20080304193532.GC9051@csn.ul.ie>
	<84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
	<Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI>
	<Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: penberg@cs.helsinki.fi, mel@csn.ul.ie, kamalesh@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org, apw@shadowen.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008 12:07:39 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> I think this is the correct fix.
> 
> The NUMA fallback logic should be passing local_flags to kmem_get_pages() 
> and not simply the flags.
> 
> Maybe a stable candidate since we are now simply 
> passing on flags to the page allocator on the fallback path.

Do we know why this is only reported in 2.6.25-rc3-mm1?

Why does this need fixing in 2.6.24.x?

Thanks.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/slab.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.25-rc3-mm1/mm/slab.c
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/mm/slab.c	2008-03-04 12:01:07.430911920 -0800
> +++ linux-2.6.25-rc3-mm1/mm/slab.c	2008-03-04 12:04:54.449857145 -0800
> @@ -3277,7 +3277,7 @@ retry:
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_enable();
>  		kmem_flagcheck(cache, flags);
> -		obj = kmem_getpages(cache, flags, -1);
> +		obj = kmem_getpages(cache, local_flags, -1);
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_disable();
>  		if (obj) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
