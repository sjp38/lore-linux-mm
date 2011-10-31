Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCF36B006E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 14:44:57 -0400 (EDT)
Date: Mon, 31 Oct 2011 19:44:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111031184443.GH3466@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
 <20138.62532.493295.522948@quad.stoffel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20138.62532.493295.522948@quad.stoffel.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 02:28:20PM -0400, John Stoffel wrote:
> and service.  How would TM benefit me?  I don't use Xen, don't want to
> play with it honestly because I'm busy enough as it is, and I just
> don't see the hard benefits.

If you used Xen tmem would be more or less the equivalent of
cache=writethrough/writeback. For us tmem is the linux host pagecache
running on the baremetal in short. But at least when we vmexit for a
read we read 128-512k of it (depending on if=virtio or others and
guest kernel readahead decision), not just a fixed absolutely worst
case 4k unit like tmem would do...

Without tmem Xen can only work like KVM cache=off.

If at least it would drop us a copy, but no, it still does the bounce
buffer, so I'd rather bounce in the host kernel function
file_read_actor than in some superflous (as far as KVM is concerned)
tmem code, plus we normally read orders of magnitude more than 4k in
each vmexit, so our default cache=writeback/writethroguh may already
be more efficient than if we'd use tmem for that.

We could only consider for swap compression but for swap compression
I've no idea why we still need to do a copy, instead of just
compressing from userland page in zerocopy (worst case using any
mechanism introduced to provide stable pages).

And when host linux pagecache will go hugepage we'll get a >4k copy in
one go while tmem bounce will still be stuck at 4k...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
