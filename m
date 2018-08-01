Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B38E16B000D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 20:09:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b12-v6so2574336plr.17
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 17:09:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e4-v6sor4661059plk.26.2018.07.31.17.09.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 17:09:58 -0700 (PDT)
Date: Tue, 31 Jul 2018 17:09:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Linux 4.18-rc7
In-Reply-To: <20180731145718.pbyy3qkp2a2yvucs@kshutemo-mobl1>
Message-ID: <alpine.LSU.2.11.1807311611380.8601@eggly.anvils>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com> <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com> <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com> <20180731062927.hjknfcb2cj3bwd7b@kshutemo-mobl1> <20180731145718.pbyy3qkp2a2yvucs@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Amit Pundir <amit.pundir@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling257@gmail.com

On Tue, 31 Jul 2018, Kirill A. Shutemov wrote:
> On Tue, Jul 31, 2018 at 09:29:27AM +0300, Kirill A. Shutemov wrote:
> > On Mon, Jul 30, 2018 at 06:01:26PM -0700, Linus Torvalds wrote:
> > > 
> > > So to me it looks like a historical check that simply doesn't
> > > "normally" trigger, but there's no reason I can see why we should care
> > > about the case it tests against.
> > 
> > I'll think more on what could go wrong with __split_huge_pmd() called on
> > anon-THP page without mmap_sem(). It's not yet clear cut to me.
> 
> I think not having mmap_sem taken at least on read when we call
> __split_huge_pmd() opens possiblity of race with khugepaged:
> khugepaged can collapse the page back to THP as soon as we drop ptl.
> As result pmd_none_or_trans_huge_or_clear_bad() would return true and we
> basically leave the THP behind, not zapped.

I think we don't care deeply about the POSIX truncate semantics on the
kind of "file" that has managed to get to this point: in the unlikely
event that a THP is immediately recreated there, never mind, so long as
we don't crash or leak memory or suchlike (the surplus THP would get
freed at exit).

I think we're altogether better off just deleting that VM_BUG_ON_VMA();
but I do find it very very hard to arrive at a firm conclusion on the
absolute safety of splitting a pmd without mmap_sem there (though any
problem unlikely even if real, and more likely a figment of my paranoia).

I believe the VM_BUG_ON is a relic from the old days, when anon_vma_lock
played a big part in guarding the pmd+page split: remember how mmap_sem
is one of the ways you can guarantee that the anon_vma will not vanish
beneath you (page_get_anon_vma was added later than anon THP).

I'm a little more worried by the nearby zap_huge_pmd() (which could
never be covered by a suitable VM_BUG_ON): the way that frees a
previously deposited page table, and you have no guarantee of when
and where that page table was last used. Again I can't point to an
actual problem, just the recollection that it's been found subtly
safe in the past, but any change in the conditions might affect that.

And a little worried to see how split_huge_page_to_list() uses
anon_vma_lock on PageAnon versus i_mmap_lock on !PageAnon: which
makes complete sense in itself, but won't protect against a PageAnon
THP being concurrently split from the truncate_pagecache() direction,
where unmap_mapping_range() uses i_mmap_lock. (simple_setattr() the
default setattr: that's a bit of a worry too.)

I feel I'm moaning and crying at shadows, rather than providing any
useful suggestions or patches; but thought I ought to report back.

Hugh
