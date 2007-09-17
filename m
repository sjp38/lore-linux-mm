Date: Mon, 17 Sep 2007 11:10:28 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH][RESEND] maps: PSS(proportional set size) accounting in smaps
Message-ID: <20070917161027.GY4219@waste.org>
References: <389996856.30386@ustc.edu.cn> <20070916235120.713c6102.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070916235120.713c6102.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, John Berthels <jjberthels@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 16, 2007 at 11:51:20PM -0700, Andrew Morton wrote:
> On Mon, 17 Sep 2007 10:40:54 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> 
> > Matt Mackall's pagemap/kpagemap and John Berthels's exmap can also do the job.
> > They are comprehensive tools. But for PSS, let's do it in the simple way. 
> 
> right.  I'm rather reluctant to merge anything which could have been done from
> userspace via the maps2 interfaces.

It can be done via maps2, but it's considerably less efficient. So if
this particular metric is a useful one, we ought to consider putting
it in-kernel.

Now is this PSS metric that useful? I'd argue yes. By comparison, the
RSS and VSS numbers are of basically no help in answering the most
common question about memory usage: "how much memory is my process
actually using?" Most people fall back to RSS and a bunch of
hand-waving, but that tends to fall over because typically sum(RSS) >
available RAM (sometimes by an order of magnitude), leaving users
completely confused. This was perhaps the biggest complaint from one
of the people on the Kernel Summit user panel, by the way. The PSS
numbers always sum to used RAM and give a fairly intuitive accounting
of shared mappings.

The big downside to PSS is that it's expensive to track. We have to
either visit each page when we report the count or we have to update
each PSS counter when we change the use count on a shared page. There
might be some tricks we can pull here but RSS and VSS, on the other
hand, are effectively O(1). An efficient in-kernel PSS calculator
might be a little painful if used in something like top(1), but the
map2 approach definitely won't be fast enough here.

Also, there's a second number we should be reporting at the same
time, which I've been calling USS (unique or unshared set size), which
is the size of the unshared pages. This is, for example, the amount of
memory that will get freed when you kill one of 20 Apache threads, or,
alternately, the amount of memory that adding another one will consume.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
