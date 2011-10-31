Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0BA6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 14:17:03 -0400 (EDT)
Date: Mon, 31 Oct 2011 19:16:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111031181651.GF3466@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 08:21:31AM -0700, Dan Magenheimer wrote:
> real users and real distros and real products waiting, so if there
> are any real issues, let's get them resolved.

We already told you the real issues there are and you did nothing so
far to address those, so much was built on top of a flawed API that I
guess an heartquake of massive scale has to come in to actually
convince Xen to change any of the huge amount of code built on the
flawed API.

I don't know the exact Xen details (it's possible Xen design doesn't
allow these below 4 issues to be fixed, I've no idea) but for all
other non-virt usages (compressed-swap/compressed-pagecache, ramster)
I doubt it is impossible to change the design of the tmem API to
address at least one of those basic huge troubles that such an API
imposes:

1) 4k page limit (no way to handle hugepages)

 Ok swapcache and pagecache are always 4k, but that may change. Plus
 it's generally flawed these days to add a new API people will build
 code on that can't handle hugepages, at least hugetlbfs should be
 handled. And especially considering it was born for virt, in virt
 space we only work with hugepages.

2) synchronous

3) not zerocopy, requires one bounce buffer for every get and one
   bounce buffer again for every put (like highmem I/O with 32bit pci)

 In my view point 3 is definitely fixable for swapcache compression
 and pagecache compression, there's no way we can accept a copy before
 starting compressing the data, the source of the compression
 algorithm must be the _userland_ page but instead you copy first, and
 compress on the copy destination, correct me if I'm wrong.

4) can't handle batched requests

 Requires one vmexit for each 4k page accessed if KVM hypervisor wants
 to access tmem, it's impossible we want to use this in KVM, at most
 we could consider exiting every 2M page, impossible to vmexit every
 4k or performance is destroyed and we'd run as slow as no-EPT/NPT.

Address these 4 points (or at least the ones that are solvable) and
it'll become appealing. Or at least try to explain why it's impossible
to solve all these 4 points to convince us this API is the best we can
get for the non-virt usages (let's ignore Xen/KVM for the sake of this
discussion, as Xen may have legitimate reasons for why those 4 above
points are impossible to fix).

At the moment to me it still looks a legacy-compatibility API to make
life easier to Xen users that uses a limited API (at least it's
simpler I'd agree on it being simpler this way) to share cache across
different guests and tries to impose those above 4 limits (and
horrendous performance in accessing tmem from Xen Guest but still
faster than I/O isn't it? :) even to the non-virt usages.

Even frontswap, there is no way we can accept to do synchronous bounce
buffers for every single 4k page that is going to hit swap. That's
worse than HIGHMEM 32bit... Obviously you must be mlocking all Oracle
db memory so you won't hit that bounce buffering ever with
Oracle. Also note, historically there's nobody that hated bounce
buffers more than Oracle (at least I remember the highmem issues with
pci32 cards :). Also Oracle was the biggest user of hugetlbfs.

So it sounds weird that you like this API forces bounce buffering CPU
cache-destroying and 4k page units, for everything that passes through
it.

If I'm wrong please correct me, I hadn't lots of time to check
code. But we already raised these points before without much answer.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
