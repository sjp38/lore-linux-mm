Date: Fri, 15 Sep 2006 01:06:22 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060915010622.0e3539d2.akpm@osdl.org>
In-Reply-To: <20060915004402.88d462ff.pj@sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006 00:44:02 -0700
Paul Jackson <pj@sgi.com> wrote:

> Andrew wrote:
> > Well some bright spark went and had the idea of using cpusets and fake numa
> > nodes as a means of memory paritioning, didn't he?
> 
> If that bright spark is lurking here, perhaps he could educate
> me a little.  I mostly ignored the fake numa node stuff when it
> went by, because I figured it was just an amusing novelty.

numa=fake=N is an x86_64-only hack which Andi stuck in there in the early
days just for developer NUMA testing.  Once opterons became commodity it
bitrotted because there was no need for it.

Then it occurred to me (although apparently another
brightspark@somewhere.jp has the same idea earlier on) that if you can
slice a UMA machine into 128 or 256 little pieces and manage them using
cpusets, you have *all* the infrastructure you need to do crude but
effective machine partitioning.

David has fixed numa=fake (it was badly busted) and has been experimenting
with a 3GB machine sliced into 64 "nodes".  So he can build containers
whose memory allocation is variable in 40-odd-megabyte hunks.

Testing looks promising: a group of processes in container A remains
constrained to its allocation - if it gets too fat it starts getting
reclaimed or swapped.

I _think_ it goes all the way up to getting oom-killed (David?).  The
oom-killer appears to be doing the right thing - we don't want it to be
killing processes which aren't inside the offending container.

> Perhaps its time I learned why it is valuable.  Can someone
> explain it to me, and describe a bit the situations in which
> it is useful.  Seems like NUMA mechanisms are being (ab)used
> for micro-partitioning memory.

yup.  afaict the only problem which has been encountered with this is that
search complexity in the page allocator.

> As Andrew speculates, this could lead to reconsidering and
> fancifying up some of the mechanisms, to cover a wider range
> of situations efficiently.

Yes.  Speeding up get_page_from_freelist() is less than totally trivial. 
I've been putting off thinking about it until we're pretty sure that there
aren't any other showstoppers.

I'm (very) impressed at how well the infrastructre which you and Christoph
have put together has held up under this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
