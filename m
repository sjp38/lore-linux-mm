Message-Id: <200301281801.NAA14177@boo-mda02.boo.net>
From: jasonp@boo.net
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
Date: Tue, 28 Jan 2003 18:01:51 GMT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> set_num_colors() needs to go downstairs under arch/ Some of the
> current->pid checks look a bit odd esp. for GFP_ATOMIC and/or
> in_interrupt() cases. I'm not sure why this is a config option; it
> should be mandatory. I also wonder about the interaction of this with
> the per-cpu lists. This may really want to be something like a matrix
> with (cpu, color) indices to find the right list; trouble is, there's a
> high potential for many pages to be trapped there. mapnr's (page -
> zone->zone_mem_map etc.) are being used for pfn's; this may raise
> issues if zones' required alignments aren't num_colors*PAGE_SIZE or
> larger. proc_misc.c can be used instead of page_color_init(). ->free_list
> can be removed. get_rand() needs locking, per-zone state. Useful stuff.

The current->pid tests date back to the 2.2 kernel patch, to get around
a bug where reusing an old task_struct didn't reinitialize the counter.
I'd much rather initialize the counter properly when a process starts, but
am not smart enough to track down all the places in the kernel where it
happens (kernel/fork.c only seems to account for half the pids on my system,
whereas in 2.4 virtually every process went through fork.c)

I originally had a much better RNG in place of the present one, but
at least one person didn't like explicit long-long calculations. Rather
than locking, what about the (admittedly much slower) nondeterministic RNG
interface? Also, the new __rmqueue is probably sufficiently slower than
the original (especially when accounting for non-power-of-two cache sizes)
that the latency for random numbers may not matter much.

Not sure how to handle pfn's properly in light of your observation, though.
What do you suggest? Likewise, I'll have to look at this per-cpu thing, older
patches didn't need to care about it.

Thanks to everyone for their feedback; I'll keep at it.

jasonp

---------------------------------------------
This message was sent using Endymion MailMan.
http://www.endymion.com/products/mailman/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
