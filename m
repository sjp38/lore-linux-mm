Date: Mon, 9 Apr 2007 11:20:12 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/4] x86_64: (SPARSE_VIRTUAL doubles sparsemem speed)
Message-ID: <20070409182012.GW2986@holomorphy.com>
References: <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com> <1175544797.22373.62.camel@localhost.localdomain> <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com> <461169CF.6060806@google.com> <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com> <4614E293.3010908@shadowen.org> <Pine.LNX.4.64.0704051119400.9800@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com> <20070409164029.GT2986@holomorphy.com> <Pine.LNX.4.64.0704091014350.4878@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704091014350.4878@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@google.com>, Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, William Lee Irwin III wrote:
>> Whatever's going on with the rest of this, I really like this
>> instrumentation patch. It may be worthwhile to allow pc_start() to be
>> overridden so things like performance counter MSR's are usable, but
>> the framework looks very useful.

On Mon, Apr 09, 2007 at 10:16:06AM -0700, Christoph Lameter wrote:
> Yeah. I also did some measurements on quicklists on x86_64 and it seems 
> that caching page table pages is also useful:
[...]

Sadly these timings will not address the arguments made on behalf of
eager zeroing, which are essentially that "precharging the cache" will
benefit fork(). I personally still find them meaningful.

I think a demonstration that will deal with more of others' concerns
might be instrumenting fault latency after a fresh execve() and
comparing fork() timings. This is clearly awkward given the scheduling
opportunities in these areas, but a virtual time measurement may suffice
to cope with those.

The fault latency after a fresh execve() is particularly relevant
because it's a scenario where incremental pagetable construction occurs
in "real life." It's actually less common for processes to merely fork()
than to fork() then execve() and then perform most of their work in the
context set up in execve(). The pagetables set up for fork() are most
commonly short-lived and the utility of caching them or even
constructing them so questionable that pagetable sharing and other
methods of avoiding the copy are quite plausible, though perhaps in
need of some heuristics to avoid new faults for the purposes of merely
copying pagetables where possible (AIUI such are considered or
implemented in pagetable sharing patches; of course, Dave McCracken has
far more detailed knowledge of the performance considerations there).

I daresay it's highly dubious to consider pagetable construction for
fork() in isolation when the common case is to almost immediately flush
all those pagetables down the toilet via execve().

Basically, if we can establish that (1) pagetable caching doesn't hurt
fork() or maybe even speeds it up then (2) it speeds up post-execve()
faults, then things look good. Raw timings on the pagetable allocation
primitives are unfortunately too micro to adequately make our case.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
