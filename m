Message-ID: <403C66D2.6010302@cyberone.com.au>
Date: Wed, 25 Feb 2004 20:11:46 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: More vm benchmarking
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita Danilov <Nikita@Namesys.COM>
List-ID: <linux-mm.kvack.org>

Well you can imagine my surprise to see your numbers so I've started
redoing some benchmarks to see what is going wrong.

This first set are 2.6.3, 2.6.3-mm2, 2.6.3-mm3. All SMP kernels
compiled with the same compiler and using the same .config (where
possible). Booting with maxcpus=1 and mem=64M. Test is gcc 3.3.3
compiling 2.4.21. I can provide any other information you're
interested in.

While previously I have been doing a single run of a range of
different parallelisation factors, here I've done two runs each over a
smaller range so you can see I am getting fairly consistient results.

kernel | run | -j5 | -j10 | -j15 |
2.6.3    1     136   886    2511
2.6.3    2     150   838    2465

-mm2     1     136   646    1484
-mm2     2     142   676    1265

-mm3     1     135   881    1828
-mm3     2     146   790    1844

This quite clearly shows your patches hurting as I told you. Why did
it get slower? I assume it is because the batching patch places uneven
pressure on normal and DMA zones. This leads to suboptimal eviction
choice - anything else would be a sign of fundamental problems.

Regarding Nikita and my patches, they all showed improvements on this
machine for this type of test *except* the throttling patch which
didn't cause any change. I just thought it was courteous to try not to
stall a possibly unlucky run.

I will now try a set of SMP tests and possibly ones with different
available memory. I would be disappointed but not very surprised if
SMP is causing lots of problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
