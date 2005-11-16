Date: Wed, 16 Nov 2005 08:31:51 -0300
From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [PATCH 01/05] NUMA: Generic code
Message-ID: <20051116083151.B1163@almesberger.net>
References: <20051110090920.8083.54147.sendpatchset@cherry.local> <200511110516.37980.ak@suse.de> <aec7e5c30511150034t5ff9e362jb3261e2e23479b31@mail.gmail.com> <200511151515.05201.ak@suse.de> <aec7e5c30511152122w70703fbfl98bd377fb6fb9af4@mail.gmail.com> <p73sltxowx4.fsf@verdi.suse.de> <aec7e5c30511152357g560127c6n88d0bce3b5a2f4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aec7e5c30511152357g560127c6n88d0bce3b5a2f4e@mail.gmail.com>; from magnus.damm@gmail.com on Wed, Nov 16, 2005 at 04:57:59PM +0900
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Andi Kleen <ak@suse.de>, Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> Sorry, but which one did not work very well? CKRM memory controller or
> NUMA emulation + CPUSETS?

We tried to partition our memory using the NUMA emulation, such that
timing-critical processes would allocate from one node, while all
the rest of the system would allocate from the other node.

The idea was that the timing-critical processes, with a fairly
"calm" allocation behaviour (read file data into the page cache,
then evict it again), would never or almost never trigger memory
reclaim this way, and thus have better worst-case latency.

Unfortunately, our benchmarks didn't show any improvements in
latency. In fact, the results were slightly worse, perhaps because
of processes on the "regular" node holding shared resources while
in memory reclaim.

I'm not entirely sure why this didn't work better. At least in
theory, it should have.

We did this in the ABISS project, about one year ago in response
to quite nasty reclaim latency suddenly appearing in an earlier
2.6 kernel. When we asked various MM developers, but none of them
was aware of any change that would make reclaims all of a sudden
very intrusive, and they attributed it to the "butterfly effect".
After a while (i.e., in later kernels), the butterflies must have
chosen a different victim, and the latency got better on its own.

So, in the end, we didn't need that NUMA hack to control reclaims.
But if they should rear their ugly heads again, it may be worth
having a second look.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
