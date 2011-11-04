Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 176126B006E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 12:45:51 -0400 (EDT)
Date: Fri, 4 Nov 2011 17:45:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (SUMMARY)
Message-ID: <20111104164532.GO18879@redhat.com>
References: <904b5bd7-efef-49fe-8413-966f0a554d1e@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <904b5bd7-efef-49fe-8413-966f0a554d1e@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Neo Jia <cyclonusj@gmail.com>, levinsasha928@gmail.com, JeremyFitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, ngupta@vflare.org, LKML <linux-kernel@vger.kernel.org>, Theodore Tso <tytso@mit.edu>, James Bottomley <James.Bottomley@HansenPartnership.com>, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Nov 04, 2011 at 07:01:23AM -0700, Dan Magenheimer wrote:
>   evolve", "this overall sounds very positive (or at least

You quoted me wrong! If you check back my email I said:

=====
Thanks. So this overall sounds _fairly_ positive (or at least better
than neutral) to me.
=====

I guess your clipboard buffer stored in tmem memory in between the cut
and paste and you still got a bug in there that corrupts memory :).

>   last remaining issue (need batching for KVM) now has a viable
>   solution that works with no frontswap commit-set changes,
>   but Andrea has not confirmed

I think it really should be vectored, just like get_user_pages is
vectored and we're not forced to call it one page at time. This is
even more important here because you have a "size" parameter which
means you can push "bytes" into tmem memory, so there's no way you can
possibly want to push bytes with an external call for each one of
those bytes.

You said the tmem.c is all free to be modified so it may be improved
later.

My biggest concern of all is this moves memory outside the VM, and in
control of tmem, but the major trouble will be how the VM controls the
size of tmem. It'll be huge hard to be able to tell what's the ideal
size of tmem at any given time. You admitted yourself that's the messy
part. And your current code isn't handling this properly today, so it
looks simpler than what will really happen if we can handle a mlockall
program allocating 90% of ram at max CPU speed without going OOM
because of zcache enabled.

I also don't think the frontswap+KVM effort is worth it, I doubt we
want to deal with the added complexity of it and the obvious
unreliability we'd run into to shrink the tmem pools. Xen may be ok
unreliable, KVM must be rock solid, we have a design that is as solid
as Linux bare metal, no change at all in terms of VM algorithms in the
hypervisor, and that's our core value. There's no way we add
unreliability with a mlock program allocating ram in the host and going OOM
because some VM is running, even if we solve the vmexit every 4k which
would destroy performance.

So my main interest is only for having compressed swap for linux in
general. It may speedup swap I/O too if done right. I'm still not sure
what's the right design it to handle compressed swap, but whatever we
do should eventually be able to write to disk the compressed data,
which zcache can't today, so I focused on making sure it's freely
hackable and not constrained by Xen ABI, so I liked your confirmation
it's all hackable. It's an intriguing design if we can make the
plugins stackable and we can change the backing store of the zcache
compressed ram with ramster or a one writing to disk. The dark side of
it, is the magic algorithm that will be needed to reliably shrink the
tmem pools, which right now seems disconnected to the VM and can't be
reliable. It looks a design that simplify things but once it will be
reliable things will get more complex and it will have to be driven by
the core VM so that it can react fast to memory pressure events, even
the decision to write to disk or send the zcache compressed pages to
other nodes with ramster should come from the main VM. I still have no
idea if this is the simpler design to allow it or not though, but
again I can't exclude it is and for some things it's certainly
intriguing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
