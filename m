Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 708426B0034
	for <linux-mm@kvack.org>; Mon, 20 May 2013 20:04:40 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [RFC PATCH 00/02] swap: allowing a more flexible DISCARD policy
Date: Mon, 20 May 2013 21:04:23 -0300
Message-Id: <cover.1369092449.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

Howdy folks,

While working on a backport for the following changes:

3399446 swap: discard while swapping only if SWAP_FLAG_DISCARD
052b198 swap: don't do discard if no discard option added

We found ourselves around an interesting discussion on how limiting 
the behavior with regard to user-visible swap areas configuration has become
after applying the aforementioned changesets.

Before commit 3399446, if the swap backing device supported DISCARD,
then a batched discard was issued at swapon(8) time, and fine-grained DISCARDs
were issued in between freeing swap page-clusters and re-writing to them.
As noticed at 3399446's commit message, the fine-grained discards often
didn't help on improving performance as expected, and were potentially causing
more trouble than desired. So, commit 3399446 introduced a new swapon flag,
to make the fine-grained discards while swapping conditional.
However a batched discard would have been issued everytime swapon(8) was
turning a new swap area available.

This batched operation that remained at sys_swapon was considered troublesome
for some setups, and specially because a sysadmin was not flagging swapon(8)
to do discards -- http://www.spinics.net/lists/linux-mm/msg31741.html 
then, commit 052b198 got merged to address the scenario described above.
After this last commit, now we can either only do both batched and fine-grained
discards for swap, or none of them.

As depicted above, this seems to be not very flexible as it could be,
and the whole discussion we had (internally) left us wondering if does upstream
feel it would be useful to allow for both a batched discard as well as a
fine-grained discard option for swap? (By batched, here, it could mean just
the one time operation at swapon, or something similar to what fstrim does).

In fact, we all agreed with having no discards sent down at all as the default
behaviour. But thinking a little more about the use cases where device supports
discard:
a) and can do it quickly;
b) but it's slow to do in small granularities (or concurrent with other
   I/O);
c) but the implementation is so horrendous that you don't even want to
   send one down;

And assuming that the sysadmin considers it useful to send the discards down
at all, we would (probably) want the following solutions:

1) do the fine-grained discards if swap device is capable of doing so;
2) do batched discards, either at swapon or via something like fstrim; or
3) turn it off completely (default behavior nowadays)


i.e.: Today, if we have a swap device like (b), we cannot perform (2) even if
it might be regardeed as interesting, or necessary to the workload because it
would imply (1), and the device cannot do that and perform optimally.


With all that in mind, and in order to attempt to sort out the (un)flexibility
problem exposed above, I came up with the following patches:

01 (kernel)     swap: discard while swapping only if SWAP_FLAG_DISCARD_CLUSTER
02 (util-linux) swapon: add "cluster-discard" support


Sorry for the long email.

Your feedback is very much appreciated!
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
