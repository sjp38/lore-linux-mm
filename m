Date: Thu, 26 Aug 2004 21:59:27 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
Message-Id: <20040826215927.0af2dee9.akpm@osdl.org>
In-Reply-To: <412EBD22.2090508@jp.fujitsu.com>
References: <412DD1AA.8080408@jp.fujitsu.com>
	<1093535402.2984.11.camel@nighthawk>
	<412E6CC3.8060908@jp.fujitsu.com>
	<20040826171840.4a61e80d.akpm@osdl.org>
	<412E8009.3080508@jp.fujitsu.com>
	<412EBD22.2090508@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> 
> Hi,
> I testd set_bit()/__set_bit() ops, atomic and non atomic ops, on my Xeon.
> I think this test is not perfect, but shows some aspect of pefromance of atomic ops.

Oh, atomic ops on a P4 hurt like hell.  Try doing this:

	time dd if=/dev/null of=foo bs=1 count=1M

on an SMP kernel and compare it with a uniproc kernel.  The difference is
large.

Certainly, executing an atomic op in a tight loop will show a lot of
difference.  But that doesn't mean that making these operations non-atomic
makes a significant difference to overall kernel performance!

But whatever - it all adds up.  The microoptimisation is fine - let's go
that way.

> Result:
> [root@kanex2 atomic]# nice -10 ./test-atomics
> score 0 is            64011 note: cache hit, no atomic
> score 1 is           543011 note: cache hit, atomic
> score 2 is           303901 note: cache hit, mixture
> score 3 is           344261 note: cache miss, no atomic
> score 4 is          1131085 note: cache miss, atomic
> score 5 is           593443 note: cache miss, mixture
> score 6 is           118455 note: cache hit, dependency, noatomic
> score 7 is           416195 note: cache hit, dependency, mixture
> 
> smaller score is better.
> score 0-2 shows set_bit/__set_bit performance during good cache hit rate.
> score 3-5 shows set_bit/__set_bit performance during bad cache hit rate.
> score 6-7 shows set_bit/__set_bit performance during good cache hit
> but there is data dependency on each access in the tight loop.

I _think_ the above means atomic ops are 10x more costly, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
