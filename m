Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37EF06B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 12:02:11 -0400 (EDT)
Date: Wed, 2 Nov 2011 17:02:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111102160201.GB18879@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <20111031181651.GF3466@redhat.com>
 <1320142590.7701.64.camel@dabdike>
 <4EB16572.70209@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EB16572.70209@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Hi Avi,

On Wed, Nov 02, 2011 at 05:44:50PM +0200, Avi Kivity wrote:
> If you look at cleancache, then it addresses this concern - it extends
> pagecache through host memory.  When dropping a page from the tail of
> the LRU it first goes into tmem, and when reading in a page from disk
> you first try to read it from tmem.  However in many workloads,
> cleancache is actually detrimental.  If you have a lot of cache misses,
> then every one of them causes a pointless vmexit; considering that
> servers today can chew hundreds of megabytes per second, this adds up. 
> On the other side, if you have a use-once workload, then every page that
> falls of the tail of the LRU causes a vmexit and a pointless page copy.

I also think it's bad design for Virt usage, but hey, without this
they can't even run with cache=writeback/writethrough and they're
forced to cache=off, and then they claim specvirt is marketing, so for
Xen it's better than nothing I guess.

I'm trying right now to evaluate it as a pure zcache host side
optimization. If it can drive us in the right long term direction and
we're free to modify it as we wish to boost swapping I/O too using
compressed data, then it may be viable. Otherwise it's better they add
some Xen specific hook and leave whatever zcache infrastructure "free
to be modified as the VM needs" "as Xen needs not". I currently don't
know exactly where the Xen ABI starts and the kernel stops in tmem so
it's hard to tell how hackable it is and if it is actually a
complication to try to hide things away from the VM or not. Certainly
the highly advertised automatic dynamic sizing of the tmem pools is an
OOM timebomb without proper VM control on it. So it just can't stay
away from the VM too much. Currently it's unlikely to be safe in all
workloads (i.e. mlockall growing fast).

Whatever happens in tmem it must be still "owned by the kernel" so it
will be written out to disk with bios. Doesn't need to happpen
immediately, doesn't need to be perfect, but must definitely be
possible to add it later without Xen folks complaining at whatever
change we do in tmem.

The fact not a line of code of Xen was written over the last two
years, doesn't mean there aren't dependencies on the code, just maybe
those never broke and so Xen never needed to be modified either becuse
they kept the tmem ABI/API fixed while adding the other backends of
tmem (zcache etc..). I mean just the fact I read in those emails the
word "ABI" signals something is wrong. There can't be any ABI there,
only an API and even the API is a kernel internal one so it must be
allowed to break freely. Or we can't innovate. Again if we can't
change whatever ABI/API without first talking with the Xen folks I
think it's better they split the two projects and just submit the Xen
hooks separately. That wouldn't remove value to tmem (assuming it's
the way to go which I'm not entirely convinced yet).

In any case starting fixing up the zcache layer sounds good to me,
first things that come to mind are to document with a comment why it
disables irqs and which is the exact code racing with the compression
that runs from irqs or softirqs, fix the casts in tmem_put, rename
tmem_put to tmem_store etc... Then we see if Xen side complains by
just those small needed cleanups.

Ideally the API should also be stackable so you can do ramster on top
of zcache on top of cleancache/frontswap so we can write a swap driver
for the zcache and we can do swapper -> zcache -> frontswap, we could
even write compressed pagecache to disk that way.

And the whole thing should handle all allocation failures with a
fallback all up to the top layer (which for swap would mean go to the
regular swapout path if oom happens within those calls and for
pagecache would mean to really free the page not compress it in some
tmem memory). That is a design that may be good. I hadn't an huge
amount of time to think about it but if you remove virt from the
equation it looks less bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
