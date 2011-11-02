Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7FEBC6B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 12:13:26 -0400 (EDT)
Message-ID: <4EB16C17.40906@redhat.com>
Date: Wed, 02 Nov 2011 18:13:11 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default> <75efb251-7a5e-4aca-91e2-f85627090363@default> <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy> <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com> <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default> <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike> <4EB16572.70209@redhat.com> <20111102160201.GB18879@redhat.com>
In-Reply-To: <20111102160201.GB18879@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On 11/02/2011 06:02 PM, Andrea Arcangeli wrote:
> Hi Avi,
>
> On Wed, Nov 02, 2011 at 05:44:50PM +0200, Avi Kivity wrote:
> > If you look at cleancache, then it addresses this concern - it extends
> > pagecache through host memory.  When dropping a page from the tail of
> > the LRU it first goes into tmem, and when reading in a page from disk
> > you first try to read it from tmem.  However in many workloads,
> > cleancache is actually detrimental.  If you have a lot of cache misses,
> > then every one of them causes a pointless vmexit; considering that
> > servers today can chew hundreds of megabytes per second, this adds up. 
> > On the other side, if you have a use-once workload, then every page that
> > falls of the tail of the LRU causes a vmexit and a pointless page copy.
>
> I also think it's bad design for Virt usage, but hey, without this
> they can't even run with cache=writeback/writethrough and they're
> forced to cache=off, and then they claim specvirt is marketing, so for
> Xen it's better than nothing I guess.

Surely Xen can use the pagecache, it uses Linux for I/O just like kvm.

> I'm trying right now to evaluate it as a pure zcache host side
> optimization.

zcache style usage is fine.  It's purely internal so no ABI constraints,
and no hypercalls either.  It's still synchronous though so RAMster like
approaches will not work well.


<snip>

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
