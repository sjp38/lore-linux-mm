Date: Thu, 11 Mar 2004 10:55:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: blk_congestion_wait racy?
Message-Id: <20040311105527.0de6b69a.akpm@osdl.org>
In-Reply-To: <OF214BC5A0.606D60A9-ONC1256E53.0034F9B5-C1256E54.006525C2@de.ibm.com>
References: <OF214BC5A0.606D60A9-ONC1256E53.0034F9B5-C1256E54.006525C2@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: piggin@cyberone.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> > Martin, have you tried adding this printk?
> 
> Sorry for the delay. I had to get 2.6.4-mm1 working before doing the
> "ouch" test. The new pte_to_pgprot/pgoff_prot_to_pte stuff wasn't easy.

Yes, sorry, all the world's an x86 :( Could you please send me whatever
diffs were needed to get it all going?

There are porting instructions in
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.4/2.6.4-mm1/broken-out/remap-file-pages-prot-2.6.4-rc1-mm1-A1.patch
but maybe it's a bit late for that.

> I tested 2.6.4-mm1 with the blk_run_queues move and the ouch printk.
> The first interesting observation is that 2.6.4-mm1 behaves MUCH better
> then 2.6.4:
> 
> 2.6.4-mm1 with 1 cpu
> # time ./mempig 600
> Count (1Meg blocks) = 600
> 600  of 600
> Done.
> 
> real    0m2.587s
> user    0m0.100s
> sys     0m0.730s
> #

I thought you were running a 256MB machine?  Two seconds for 400 megs of
swapout?  What's up?

> 2.6.4-mm1 with 2 cpus
> # time ./mempig 600
> Count (1Meg blocks) = 600
> 600  of 600
> Done.
> 
> real    0m10.313s
> user    0m0.160s
> sys     0m0.780s
> #
> 
> 2.6.4 takes > 1min for the test with 2 cpus.
> 
> The second observation is that I get only a few "ouch" messages. They
> all come from the blk_congestion_wait in try_to_free_pages, as expected.
> What I did not expect is that I only got 9 "ouches" for the run with
> 2 cpus.

An ouch-per-second sounds reasonable.  It could simply be that the CPUs
were off running other tasks - those timeout are less than scheduling
quanta.

The 4x performance difference remains not understood.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
