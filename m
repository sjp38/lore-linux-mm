Subject: Re: blk_congestion_wait racy?
Message-ID: <OF214BC5A0.606D60A9-ONC1256E53.0034F9B5-C1256E54.006525C2@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Thu, 11 Mar 2004 19:24:48 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




> Martin, have you tried adding this printk?

Sorry for the delay. I had to get 2.6.4-mm1 working before doing the
"ouch" test. The new pte_to_pgprot/pgoff_prot_to_pte stuff wasn't easy.
I tested 2.6.4-mm1 with the blk_run_queues move and the ouch printk.
The first interesting observation is that 2.6.4-mm1 behaves MUCH better
then 2.6.4:

2.6.4-mm1 with 1 cpu
# time ./mempig 600
Count (1Meg blocks) = 600
600  of 600
Done.

real    0m2.587s
user    0m0.100s
sys     0m0.730s
#

2.6.4-mm1 with 2 cpus
# time ./mempig 600
Count (1Meg blocks) = 600
600  of 600
Done.

real    0m10.313s
user    0m0.160s
sys     0m0.780s
#

2.6.4 takes > 1min for the test with 2 cpus.

The second observation is that I get only a few "ouch" messages. They
all come from the blk_congestion_wait in try_to_free_pages, as expected.
What I did not expect is that I only got 9 "ouches" for the run with
2 cpus.

blue skies,
   Martin

Linux/390 Design & Development, IBM Deutschland Entwicklung GmbH
Schonaicherstr. 220, D-71032 Boblingen, Telefon: 49 - (0)7031 - 16-2247
E-Mail: schwidefsky@de.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
