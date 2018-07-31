Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 278AD6B026D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:57:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t26-v6so4887534pfh.0
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:57:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4-v6sor3838280pgh.210.2018.07.31.07.57.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 07:57:25 -0700 (PDT)
Date: Tue, 31 Jul 2018 17:57:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180731145718.pbyy3qkp2a2yvucs@kshutemo-mobl1>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1>
 <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <20180731062927.hjknfcb2cj3bwd7b@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731062927.hjknfcb2cj3bwd7b@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Amit Pundir <amit.pundir@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling257@gmail.com

On Tue, Jul 31, 2018 at 09:29:27AM +0300, Kirill A. Shutemov wrote:
> On Mon, Jul 30, 2018 at 06:01:26PM -0700, Linus Torvalds wrote:
> > On Mon, Jul 30, 2018 at 2:53 PM Hugh Dickins <hughd@google.com> wrote:
> > >
> > > I have no problem with reverting -rc7's vma_is_anonymous() series.
> > 
> > I don't think we need to revert the whole series: I think the rest are
> > all fairly obvious cleanups, and shouldn't really have any semantic
> > changes.
> > 
> > It's literally only that last patch in the series that then changes
> > that meaning of "vm_ops". And I don't really _mind_ that last step
> > either, but since we don't know exactly what it was that it broke, and
> > we're past rc7, I don't think we really have any option but the revert
> > it.
> > 
> > And if we revert it, I think we need to just remove the
> > VM_BUG_ON_VMA() that it was supposed to fix. Because I do think that
> > it is quite likely that the real bug is that overzealous BUG_ON(),
> > since I can't see any reason why anonymous mappings should be special
> > there.
> > 
> > But I'm certainly also ok with re-visiting that commit later.  I just
> > think that right _now_ the above is my preferred plan.
> > 
> > Kirill?
> 
> Considering the timing, I'm okay with reverting the last patch with
> dropping the VM_BUG_ON_VMA().
> 
> But in the end I would like to see strong vma_is_anonymous().
> 
> The VM_BUG_ON_VMA() is only triggerable by the test case because
> vma_is_anonymous() false-positive in fault path and we get anon-THP
> allocated in file-private mapping.
> 
> I don't see immediately how this may trigger other crashes.
> But it definitely looks wrong.
> 
> > > I'm all for deleting that VM_BUG_ON_VMA() in zap_pmd_range(), it was
> > > just a compromise with those who wanted to keep something there;
> > > I don't think we even need a WARN_ON_ONCE() now.
> > 
> > So to me it looks like a historical check that simply doesn't
> > "normally" trigger, but there's no reason I can see why we should care
> > about the case it tests against.
> 
> I'll think more on what could go wrong with __split_huge_pmd() called on
> anon-THP page without mmap_sem(). It's not yet clear cut to me.

I think not having mmap_sem taken at least on read when we call
__split_huge_pmd() opens possiblity of race with khugepaged:
khugepaged can collapse the page back to THP as soon as we drop ptl.
As result pmd_none_or_trans_huge_or_clear_bad() would return true and we
basically leave the THP behind, not zapped.

-- 
 Kirill A. Shutemov
