Date: Sat, 22 Jan 2000 15:02:23 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.3.96.1000121220237.14221B-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.21.0001221445150.440-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Benjamin C.R. LaHaise wrote:

>I think the deadlock being referred by Rik to is that of getting stuck
>trying to allocate memory while trying to perform a swapout.  Sure, it's
>rare now, but not on low memory machines.

It's exactly the same problem for getblk. I am aware of the create_buffers
async allocation loop too but that's even less unlikely to happens
thanks to the async-reserved bh heads.

>> About your proposed change (as I just said), the semantic you want to
>> change whith your diff that I am quoting here:
>> 
>> >-               if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
>> >+               if (!freed && !(gfp_mask & __GFP_HIGH))
>> 
>> makes a difference _only_ if the machine goes _OOM_ (so when
>> try_to_free_pages fails) and that's completly _unrelated_ with the
>> failed-atomic-allocation case we are talking about. If the machine is OOM
>> it's perfectly normal that atomic allocations fails. That's expected.
>
>Wrong.  I have to agree with Rik on this one: even during normal use, you
>want to keep at least freepages.min pages reserved only for atomic memory
>allocations.  We did this back in 2.0, even in 1.2, and for good reason:

During normal use you _just_ take freepages.min pages reserved only for
atomic memory allocations.

It's during OOM that you want to eat all memory. Why should you left
3mbyte of memory unused if there aren't atomic allocations at all?

>if an interrupt comes along and needs to allocate memory, we do *not* want
>to be calling do_try_to_free_pages from irq context -- it throws the
>latency of the interrupt through the roof!  Keeping that small pool of
>atomic-only memory around means that the machine can continue routing
>packets while netscape is starting up and eating all your memory, without
>needlessly dropping packets or adding latency.  It also means that there
>are a few pages grace for helping to combat memory fragmentation, and
>gives heavy NFS traffic a better chance at getting thru.

That just happens. I definitely don't see your point. We just reserve such
atomic pool during normal use.

What you want to change is to left such pool reserved also during OOM and
that make no sense at all to me. During OOM atomic allocation should fail
exactly like all other allocations.

The current problem isn't that GFP_KERNEL is eating the atomic memory, but
that GFP_ATOMIC is eating all the pool before kswapd can notice that. My
patch will address exactly that.

>> You are basically making GFP_KERNEL equal to GFP_USER and that's wrong. It
>> makes sense that allocation triggered by the kernel have access to the
>> whole free memory available: kernel allocations have the same privilegies
>> of atomic allocations. The reason atomic allocations are atomic is that
>> they can't sleep, that's all. If they could sleep they would be GFP_KERNEL
>> allocations instead. The only difference between the two, is that the
>> non-atomic allocations will free memory themselfs before accessing _all_
>> the free memory because they _can_ do that.
>
>GFP_KERNEL for the normal case *is* equal to GFP_USER.  It's GFP_BUFFER

_Exactly_ I just know that. The only difference between GFP_KERNEL and
GFP_USER happens during OOM and you want to make GFP_KERNEL and GFP_USER
equal also during OOM and that make no sense to me. During OOM there's no
one point to not use the remaining 3mbyte for kernel progresses. We just
make sure to kill userspace ASAP anyway (that's the point for the 
GFP_USER difference between GFP_KERNEL).

>and GFP_ATOMIC that are special and need to have access to a normally
>untouched pool of memory. 

IMHO only GFP_USER shouldn't have access to the whole memory for a subtle
reason: we want to kill userspace as soon as we detect OOM. Everything
else can eat all the memory. This not only make sense to me but it will
also give us more probability to not fail anything except the killed task.

BTW, I just noticed GFP_BUFFER has a strange thing. He uses a low prio and
so it can't access the whole memory. This seems wrong. I think it should
be changed this way:

--- 2.2.14/include/linux/mm.h	Fri Jan 21 03:31:05 2000
+++ /tmp/mm.h	Sat Jan 22 14:57:40 2000
@@ -334,7 +334,7 @@
 
 #define __GFP_DMA	0x80
 
-#define GFP_BUFFER	(__GFP_LOW | __GFP_WAIT)
+#define GFP_BUFFER	(__GFP_MID | __GFP_WAIT)
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_USER	(__GFP_LOW | __GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_MED | __GFP_WAIT | __GFP_IO)


NOTE: the above patch is unrelated to the atomic allocation problems, it's
just another thing I noticed now.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/GFP_BUFFER-1.gz

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
