Date: Wed, 19 Nov 2003 01:19:51 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test9-mm4
Message-Id: <20031119011951.66300f0d.akpm@osdl.org>
In-Reply-To: <20031119090223.GO22764@holomorphy.com>
References: <20031118225120.1d213db2.akpm@osdl.org>
	<20031119090223.GO22764@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> On Tue, Nov 18, 2003 at 10:51:20PM -0800, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test9/2.6.0-test9-mm4/
> > . Several fixes against patches which are only in -mm at present.
> > . Minor fixes which we'll queue for post-2.6.0.
> > . The interactivity problems which the ACPI PM timer patch showed up
> >   should be fixed here - please sing out if not.
> 
> I'm not sure if this is within the scope of current efforts, but I
> gave it a shot just to see how bad untangling it from highpmd and
> O(1) buffered_rmqueue() was. It turns out it wasn't that hard.
> 
> The codebase (so to speak) has been in regular use since June, though
> the port to -mm only lightly tested (basically testbooted on a laptop).

Any performance numbers?

> There is some minor core impact.

hm, big.

> +#ifdef CONFIG_SMP
> +#define smp_local_irq_save(x)		local_irq_save(x)
> +#define smp_local_irq_restore(x)	local_irq_restore(x)
> +#define smp_local_irq_disable()		local_irq_disable()
> +#define smp_local_irq_enable()		local_irq_enable()
> +#else
> +#define smp_local_irq_save(x)		do { (void)(x); } while (0)
> +#define smp_local_irq_restore(x)	do { (void)(x); } while (0)
> +#define smp_local_irq_disable()		do { } while (0)
> +#define smp_local_irq_enable()		do { } while (0)
> +#endif /* CONFIG_SMP */

Interesting.

> @@ -890,6 +894,9 @@ int try_to_free_pages(struct zone *cz,
>  		 */
>  		wakeup_bdflush(total_scanned);
>  
> +		/* shoot down some pagetable caches before napping */
> +		shrink_pagetable_cache(gfp_mask);

Maybe this could hook into the shrink_slab() mechanism?  There's actually
nothing slab-specific about shrink_slab().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
