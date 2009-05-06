Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D954B6B007E
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:34:06 -0400 (EDT)
Date: Wed, 6 May 2009 15:34:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506133434.GX16078@random.random>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 12:16:52PM +0100, Hugh Dickins wrote:
> I'm very much with those who suggested an madvise(), for which Chris
> prepared a patch.  I know Andrea felt uneasy with an madvise() going
> to a possibly-configured-out-or-never-loaded module, but it is just
> advice, so I don't have a problem with that myself, so long as it
> is documented in the manpage.

I don't have so much of a problem with that, but there are a couple of
differences: normally madvise doesn't depend on the admin to start
some kernel thread to be meaningful, and normally madvise isn't a
privileged operation, see below.

> Whereas I do worry just what capability should be required for this:
> can't a greedy app simply fork itself, touch all its pages, and thus
> lock itself into memory in this way?  And I do worry about the cpu

KSM pages are supposed to be swappable in the long run so let's think
longer term.

> cost of all the scanning, if it were to get used more generally -
> it would be a pity if we just advised complainers to tune it out.

Clearly if tons of apps maliciously register themself in ksm, they'll
waste tons of CPU for no good, they'll just populate the unstable tree
with pages that are all equal except for the last 4 bytes slowing down
KSM for nothing. This is also why it's good to have a /dev/ksm ioctl
that the admin can allow only certain users to use for registering
virtual ranges (for example only the kvm/qemu user or all users in
scientific environments). Otherwise we'd need some kind of permissions
settings in sysfs with some API that certainly is less intuitive than
chown/chmod on /dev/ksm. We just can't allow madvise to succeed on any
luser registering itself in KSM, so if it was madvise, it shall return
-EPERM somehow sometime.

> I'm still working my way through ksm.c, and not gone back to look at
> Chris's madvise patch, but doubt it will be sufficient.  There's an
> interesting difference between what you're doing in ksm.c, and how
> madvise usually behaves, regarding unmapped areas: madvice doesn't
> usually apply to an unmapped area, and goes away with an area when
> it is unmapped; whereas in KSM's case, the advice applies to whatever
> happens to get mapped in the area specified, persisting across unmaps.

Given the apps using KSM tends to be quite special, the fact it's
sticky, it doesn't go away with munmap isn't big deal, quite to the
contrary those apps will likely have an easier time thanks to the
registration not going away over munmap/mmap, without requiring
reloading of malloc/new calls.

To skip over holes during virtual scans we just vma->vm_next.

> But I do appreciate the separation you've kept so far,
> and wouldn't want to tie it all together too closely.

The above plus the fact it remains self contained without making the
VM any more complicated, gives some value. Even swapping I'd like to
add it without VM specific knowledge about KSM. tmpfs has an easier
time because it has its own vma type, here we've KSM pages mixed
inside regular anonymous !vma->vm_file regions and !vm_ops.

> p.s.  I wish you'd chosen different name than KSM - the kernel
> has supported shared memory for many years - and notice ksm.c itself
> says "Memory merging driver".  "Merge" would indeed have been a less
> ambiguous term than "Share", but I think too late to change that now
> - except possibly in the MADV_ flag names?

I don't actually care about names, so I leave this to other to discuss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
