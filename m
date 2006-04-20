Date: Thu, 20 Apr 2006 09:41:11 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [RFC] - Kernel text replication on IA64
Message-ID: <20060420164111.GA18770@agluck-lia64.sc.intel.com>
References: <20060420135315.GA28021@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060420135315.GA28021@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-ia64@vger.kernel.org, lee.schermerhorn@hp.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 20, 2006 at 08:53:16AM -0500, Jack Steiner wrote:

> There was a question about the effects of kernel text replication last
> month.  I was curious so I resurrected an old trillian patch (Tony Luck's)
> & got it working again. Here is the preliminary patch & some data about
> the benefit.

It's not *that* old ... just from Atlas days, not from Trillian.  Google
carbon dating shows old versions of this patch from around the August
2002 time frame (against 2.4.19).

> All tests were run on a 12 cpu (Itanium2, 900 MHz, 1.5MB L3) , 6 node
> system. All cpus are idle with the exception of the cpu running the test.

Presumably results would be even better on a bigger system where the
distance from the test node to node 0 is even bigger.

On truly huge systems does node0 (or the interconnects leading to it) ever
suffer measureable slowdown from the instruction fetch traffic coming from
the other 255 (or more) nodes?

> Enabling replication reserves 1 additional DTLB entry for kernel code.
> This reduces the number of DTLB entries that is available for user code.
> There is the potential that this could impact some applications.
> Additional measurements are still needed.

Ken's recent patch to free up the DTLB that is currently used for per-cpu
data would mitigate this (though I'm sure he'll be unamused if I blow the
1.6% gain he saw on his transaction processing benchmark on this :-)

> ------------------------------------------------------
>   Cold cache. Running on node 3 of 6 node system
> 
>                          NoRep        Rep   %improvement
> null                :    0.894 :    0.812 :         9.17
> forkexit            :  521.518 :  416.467 :        20.14
> openclose           :  106.683 :   75.000 :        29.70
> pid                 :    2.577 :    2.356 :         8.58
> time                :   17.882 :   11.693 :        34.61
> gettimeofday        :   17.523 :   11.695 :        33.26

Those are some pretty nice numbers.

> ------------------------------------------------------
>    Hot cache. Running on node 3 of 6 node system
> 
>                          NoRep        Rep   %improvement
> forkexit            :  162.019 :  151.927 :         6.23
> openclose           :    8.445 :    8.128 :         3.75

These ones are good too.  But a bit surprising ... it implies that we
are still seeing significant kernel-code i-cache misses even in a
micro-benchmark tight loop.  Montecito (with the big L2 icache) should
be better here (and so see less improvement with replicated text).

> +	  Say Y if you want to eeplicate kernel text on each node of a NUMA system.

s/eeplicate/replicate/

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
