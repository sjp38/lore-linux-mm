Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4BB5B6B00B2
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 05:38:04 -0500 (EST)
Received: by fxm25 with SMTP id 25so3733776fxm.6
        for <linux-mm@kvack.org>; Fri, 20 Nov 2009 02:38:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1258709153.11284.429.camel@laptop>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
Date: Fri, 20 Nov 2009 12:38:02 +0200
Message-ID: <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> Did anything change recently? git-log mm/slab.c doesn't show anything
> obvious, although ec5a36f94e7ca4b1f28ae4dd135cd415a704e772 has the exact
> same lock recursion msg ;-)

No, SLAB hasn't changed for a while.

On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> So basically its this stupid recursion issue where you allocate the slab
> meta structure using the slab allocator, and now have to free while
> freeing, right?

Yes.

On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> The code in kmem_cache_create() suggests its not even fixed size, so
> there is no single cache backing all this OFF_SLAB muck :-(

Oh, crap, I missed that. It's variable-length because we allocate the
freelists (bufctls in slab-speak) in the slab managment structure. So
this is a genuine bug.

On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> It does appear to be limited to the kmalloc slabs..
>
> There's a few possible solutions -- in order of preference:
>
> =A01) do the great slab cleanup now and remove slab.c, this will avoid an=
y
> further waste of manhours and braincells trying to make slab limp along.

:-) I don't think that's an option for 2.6.33.

On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> =A02) propagate the nesting information and user spin_lock_nested(), give=
n
> that slab is already a rat's nest, this won't make it any less obvious.

spin_lock_nested() doesn't really help us here because there's a
_real_ possibility of a recursive spin lock here, right?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
