Date: Wed, 22 Mar 2006 14:51:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 00/34] mm: Page Replacement Policy Framework
Message-Id: <20060322145132.0886f742.akpm@osdl.org>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, iwamoto@valinux.co.jp, christoph@lameter.com, wfg@mail.ustc.edu.cn, npiggin@suse.de, torvalds@osdl.org, riel@redhat.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> 
> This patch-set introduces a page replacement policy framework and 4 new 
> experimental policies.

Holy cow.

> The page replacement algorithm determines which pages to swap out.
> The current algorithm has some problems that are increasingly noticable, even
> on desktop workloads.

Rather than replacing the whole lot four times I'd really prefer to see
precise descriptions of these problems, see if we can improve the situation
incrementally rather than wholesale slash-n-burn...

Once we've done that work to the best of our ability, *then* we're in a
position to evaluate the performance benefits of this new work.  Because
there's not much point in comparing known-to-have-unaddressed-problems old
code with fancy new code.

> Measurements:
> 
> (Walltime, so lower is better)
> 
> cyclic-anon ; Cyclic access pattern with anonymous memory.
>               (http://programming.kicks-ass.net/benchmarks/cyclic-anon.c)
> 
> 2.6.16-rc6              14:28
> 2.6.16-rc6-useonce      15:11
> 2.6.16-rc6-clockpro     10:51
> 2.6.16-rc6-cart          8:55
> 2.6.16-rc6-random     1:09:50
> 
> cyclic-file ; Cyclic access pattern with file backed memory.
>               (http://programming.kicks-ass.net/benchmarks/cyclic-file.c)
> 
> 2.6.16-rc6              11:24
> 2.6.16-rc6-clockpro      8:14
> 2.6.16-rc6-cart          8:09
> 
> webtrace ; Replay of an IO trace from the Umass trace repository
>            (http://programming.kicks-ass.net/benchmarks/spc/)
> 
> 2.6.16-rc6               8:27
> 2.6.16-rc6-useonce       8:24
> 2.6.16-rc6-clockpro     10:23
> 2.6.16-rc6-cart         15:30
> 2.6.16-rc6-random       15:52
> 
> mdb-bench ; Low frequency benchmark.
>             (http://linux-mm.org/PageReplacementTesting)
> 
> 2.6.16-rc6            4:20:44
> 2.6.16-rc6 (mlock)    3:52:15
> 2.6.16-rc6-useonce    4:20:59
> 2.6.16-rc6-clockpro   3:56:17
> 2.6.16-rc6-cart       4:11:54
> 2.6.16-rc6-random     5:21:30

2.6.16-rc6 seems to do OK.  I assume the cyclic patterns exploit the lru
worst case thing?  Has consideration been given to tweaking the existing
code, detect the situation and work avoid the problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
