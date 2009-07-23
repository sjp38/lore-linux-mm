Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D8BA16B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 07:36:42 -0400 (EDT)
Date: Thu, 23 Jul 2009 12:36:30 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
In-Reply-To: <20090722165202.GA8937@random.random>
Message-ID: <Pine.LNX.4.64.0907231202550.12896@sister.anvils>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com> <20090721175139.GE2239@random.random>
 <Pine.LNX.4.64.0907221313370.529@sister.anvils> <20090722165202.GA8937@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 2009, Andrea Arcangeli wrote:
> On Wed, Jul 22, 2009 at 01:45:15PM +0100, Hugh Dickins wrote:
> > If they're to be vm_normal_page pages (I think we'll agree they are),
> > then for now they have to be counted either as file pages or as anon
> > pages.  We could trawl through mm/ adding the third category for KSM
> > pages, but I don't think that would be sensible - KSM is mostly
> > keeping out of everybody's way, and I want to preserve that.
> 
> That was basically the idea, keeping out of everybody's way. This was
> more true in the past than today, I mean back when CONFIG_KSM=m was
> allowed.. Today instead KSM is more like CONFIG_SWAP, which is surely
> nice from the standpoint that it should be always available and I like
> that.
> 
> > swapping these pages we will use a PAGE_MAPPING_KSM bit 2 (set in
> > addition to PAGE_MAPPING_ANON), so that the pointer in page->mapping
> 
> Ok if it was my choice I wouldn't make them Anon pages.
> 
> My background is that in theory, and from a madvise API standpoint,
> Ksm could work on more than Anon pages in the future.

Right (I say "right" blithely, but fear what might be involved -
though you've thought it through more, and have a particular case
in mind); but marking the KSM pages as Anon where they're replacing
Anon pages seems appropriate to me for now; and then when/if they
can replace pagecache pages later, I agree those instances should not
be PageAnon.  (And perhaps by that time we'll be seeing them as a
third category, rather than as a qualifier of anon/file: I've no
view on that yet.)

By the way, it did occur to me late last night that I've unconsciously
and unfairly biased this argument towards me by using the words "anon"
and "file", which makes it fairly obvious that the current KSM pages
should be considered "anon".  But if I'd chosen the words "private"
and "shared", and that may well be the background you're coming from,
then there's a very reasonable argument for considering them "shared".

I'd still contend that the manner in which they're shared is much
more like the way anon pages are shared across fork (as the fifth
line of ksm.c indicates), than the way in which file pages are
shared with pagecache and backing store.  And I'd still contend
that it's an unnecessary surprise for KSM to be raising file rss
and lowering anon rss.  But I did bias the argument unfairly.

> 
> Example is when pagecache is enabled in host to provide the same
> pre-cache feature that tmem provides to Xen. We already have that
> pre-cache of tmem since day zero in KVM (in fact we only more recently
> had a way to switch it off and do zerocopy DMA with O_DIRECT, kind of
> turning off tmem).
> 
> So it wouldn't be impossible to have a shared pre-cache even when we
> don't share the same parent qcow2 image, but that is purely
> theoretical, and it likely never happen. So I am ok with considering
> ksm pages as anon...

Thanks!

> 
> For swap we'll need to sue a new bitflag there and adjust PageAnon to
> check against &(PAGE_MAPPING_ANON|PAGE_MAPPING_KSM)!=0, which will
> have the same runtime cost, so no problem there.

Yup.

> 
> > But I'd still expect them to be PageAnon: even more so, really -
> > once they're swapping, they're even more ordinary anonymous pages.
> 
> Frankly the fact they swap on swap device, doesn't make them more
> anonymous the same way /dev/shm files are filebacked and they swap to
> swap device too.

True - though they're another odd case.

> 
> > Leave them out of such accounting completely, or give them their
> > own stats: yes, that can be done, but not without changes elsewhere;
> > which I think we'd prefer not to press until KSM is a more accepted
> > part of regular mm operation.
> 
> Ok.
> 
> > That's certainly the ugliest part of accepting PageKsm pages as
> > PageAnon, and I wept when I realized we needed that check (well,
> > I exaggerate a little ;).
> 
> Yes, that very change is exactly what actually made me to rewind back
> to the issue of why Ksm pages provides benefit to be Anon pages too.

Yes, it was a strong reason for making that a separate patch,
to parade that shame openly for comment.

> 
> > It didn't cross my mind to move it into reuse_swap_page(): yes,
> > we could do that.  I don't see how it's safer; and to be honest,
> 
> I thought it was safer, because reuse_swap_page is the thing that tell
> us if we can takeover an anon page and avoid COW. So anybody calling
> reuse_swap_page should first check if it's a Ksm page outside of it,
> and not takeover in that case. Ksm pages must always be readonly to
> avoid screwing stable tree lookups (stable tree is never regenerated
> and we need it to stay stable). The swapin path right now doesn't
> require the check because we know Ksm pages won't come in from swap
> but I thought it was safer to have reuse_swap_page to be aware instead
> of leaving the job to the caller. Not that it makes much difference.

I think, until reuse_swap_page gets more callers anyway, that we're
best off keeping that regrettable test highly visible in do_wp_page.

(I wouldn't be surprised if we later decide that it's good to keep
once-stable pages around for longer, and hold one reference to them
in the stable tree: in which case, do_wp_page's extra test could go.)

> 
> > its main appeal to me is that it would hide this wart away more,
> > where fewer eyes would notice it.  Which may not be the best
> > argument for making the move!  Technically, I think it would
> > just increase the overhead of COWing a KSM page (getting that
> > page lock, maybe having to drop ptlock etc.), but that may not
> > matter much: please persuade me it's safer in reuse_swap_page()
> > and I'll move it there.
> 
> Yes it increases overhead a bit, but Ksm pages are never locked so the
> difference in overhead is negligeable. It's up to you...

They're not locked in ksm.c; but if we were to move the PageKsm test
from do_wp_page down to reuse_swap_page, then they would briefly be
locked whenever breaking COW on them, with contention arising there.
I should think there are much more sigificant inefficiencies to
worry about than this one, but we've no need for it.

> 
> Ack 6/10 too..

Many thanks.
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
