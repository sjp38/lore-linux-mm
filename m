Date: Tue, 11 Nov 2008 20:55:07 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
Message-ID: <20081111195507.GD10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <20081111103051.979aea57.akpm@linux-foundation.org> <4919D370.7080301@redhat.com> <20081111111110.decc0f06.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111111110.decc0f06.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, ieidus@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

thanks for looking into this.

On Tue, Nov 11, 2008 at 11:11:10AM -0800, Andrew Morton wrote:
> What userspace-only changes could fix this?  Identify the common data,
> write it to a flat file and mmap it, something like that?

The whole idea is to do something that works transparently and isn't
tailored for kvm. The mmu notifier change_pte method can be dropped as
well if you want (I recommended not to have it in the first submission
but Izik preferred to keep it because it will optimize away a kvm
shadow pte minor fault the first time kvm access the page after
sharing it). The page_wrprotect and replace_page can also be embedded
in ksm.

So the idea is that while we could do something specific to ksm that
keeps most of the code in userland, it'd be more tricky as it'd
require some communication with the core VM anyway (we can't just do
it in userland with mprotect, memcpy, mmap(MAP_PRIVATE) as it wouldn't
be atomic and second it'd be inefficient in terms of vma-buildup for
the same reason nonlinear-vmas exist), but most important: it wouldn't
work for all other regular process. With KSM we can share anonymous
memory for the whole system, KVM is just a random user.

This implementation is on the simple side because it can't
swap. Swapping and perhaps the limitation of sharing anonymous memory
is the only trouble here but those will be addressed in the
future. ksm is a new device driver so it's like /dev/mem, so no
swapping isn't a blocker here.

By sharing anon pages, in short we're making anonymous vmas nonlinear,
and this isn't supported by the current rmap code. So swapping can't
work unless we mark those anon-vmas nonlinear and we either build the
equivalent of the old pte_chains on demand just for those nonlinear
shared pages, or we do a full scan of all ptes in the nonlinear
anon-vmas. An external rmap infrastructure can allow ksm to build
whatever it wants inside ksm.c to track the nonlinear anon-pages
inside a regular anon-vma and rmap.c can invoke those methods to find
the ptes for those nonlinear pages. The core VM won't get more complex
and ksm can decide if to do a full nonlinear scan of the vma, or to
build the equivalent of pte_chains. This again has to be added later
and once everybody sees ksm, it'll be easier to agree on a
external-rmap API to allow it to swap. While the pte_chains are very
inefficent to reverse the regular anonymous mappings, they're
efficient solution as an exception for the shared KSM pages that gets
scattered over the linear anon-vmas.

It's a bit like the initial kvm that was merged despite it couldn't
swap. Then we added mmu notifiers, and now kvm can swap. So we add ksm
now without swapping and later we build an external-rmap to allow ksm
to swap after we agree ksm is useful and people starts using it.

> There has been the occasional discussion about idenfifying all-zeroes
> pages and scavenging them, repointing them at the zero page.  Could
> this infrastructure be used for that?  (And how much would we gain from
> it?)

Zero pages makes a lot of difference for windows, but they're totally
useless for linux. With current ksm all guest pagecache is 100% shared
across hosts, so when you start an app the .text runs on the same
physical memory on both guests. Works fine and code is quite simple in
this round. Once we add swapping it'll be a bit more complex in VM
terms as it'll have to handle nonlinear anon-vmas.

If we ever decide to share MAP_SHARED pagecache it'll be even more
complicated than just adding the external-rmap... I think this can be
done incrementally if needed at all. OpenVZ if the install is smart
enough could share the pagecache by just hardlinking the equal
binaries.. but AFIK they don't do that normally. For the anon ram they
need this too, they can't solve equal anon ram in userland as it has
to be handled atomically at runtime.

The folks at CERN LHC (was visiting it last month) badly need KSM too
for certain apps they're running that are allocating huge arrays
(aligned) in anon memory and they're mostly equal for all
processes. They tried to work around it with fork but it's not working
well, KSM would solve their problem (it'd solve it both on the same OS
and across OS with kvm as virtualization engine running on the same host).

So I think this is good stuff, and I'd focus discussions and reviews
on the KSM API of /dev/ksm that if merged will be longstanding and
much more troublesome than the rest of the code if changed later (if
we change the ksm internals at any time nobody will notice), and
post-merging we can focus on the external-rmap to make KSM pages first
class citizens in VM terms. But then anything can be changed here, so
suggestions welcome!

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
