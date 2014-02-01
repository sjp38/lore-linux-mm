Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A491D6B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 21:49:39 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so5138773pab.17
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 18:49:39 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id ot3si12531202pac.224.2014.01.31.18.49.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 18:49:38 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so5092034pbb.6
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 18:49:38 -0800 (PST)
Date: Fri, 31 Jan 2014 18:49:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/swap: fix race on swap_info reuse between swapoff
 and swapon
In-Reply-To: <CAL1ERfM82H_n4WF6fnsmbyMDXP1fRkXgcsZOHF7=FqyRxhs+mA@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1401311807400.4217@eggly.anvils>
References: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com> <20140110171108.32b2be171cd5e54bf22fb2a4@linux-foundation.org> <CAL1ERfPnaROPiRAeWHpvwGezHsqN4R8j=QSyS48xs25ax14AhA@mail.gmail.com> <20140112192744.9bca5c6d.akpm@linux-foundation.org>
 <CAL1ERfOx7NF-GLuCnK4KXYpunKxQnVmSDA6FkPKXH3CxauzQcQ@mail.gmail.com> <20140113062702.GA26880@mguzik.redhat.com> <CAL1ERfM82H_n4WF6fnsmbyMDXP1fRkXgcsZOHF7=FqyRxhs+mA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Mateusz Guzik <mguzik@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Weijie Yang <weijie.yang@samsung.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fusionio.com>, Bob Liu <bob.liu@oracle.com>, stable@vger.kernel.org, Krzysztof Kozlowski <k.kozlowski@samsung.com>

On Mon, 13 Jan 2014, Weijie Yang wrote:
> On Mon, Jan 13, 2014 at 2:27 PM, Mateusz Guzik <mguzik@redhat.com> wrote:
> >
> > Newly introduced window:
> >
> > p->swap_map == NULL && (p->flags & SWP_USED)
> >
> > breaks swap_info_get:
> >         if (!(p->flags & SWP_USED))
> >                 goto bad_device;
> >         offset = swp_offset(entry);
> >         if (offset >= p->max)
> >                 goto bad_offset;
> >         if (!p->swap_map[offset])
> >                 goto bad_free;
> >
> > so that would need a trivial adjustment.
> >
> 
> Hi, Mateusz. Thanks for review.
> 
> It could not happen. swapoff call try_to_unuse() to force all
> swp_entries unused before
> set p->swap_map NULL. So if somebody still hold a swp_entry by this
> time, there must be some error elsewhere.

That's not quite the right answer: we would still prefer to issue a
warning than oops on the NULL pointer; the key is that p->max is reset
to 0 before p->swap_map is set to NULL.

But those lines were written in the days before we became so aware of
memory barriers.  If I'm to insist on that p->max argument, I should
be adding smp_wmb()s and smp_rmb()s to enforce it.

But y'know, I'm going to leave it as is, and fall back on your
"there must be some error elsewhere" argument to justify not adding
barriers, that have not yet proved to be needed in practice here.

> 
> Say more about it, I don't think it is a newly introduced window, the
> current code set
> p->swap_map NULL and then clear p->flags in swapoff, swap_info_get
> access these fields
> without lock, so this impossible window "exist" for many years.
> 
> It is really confusing, that is why I plan to resend a patchset to
> make it clear, by comments
> at least.
> 
> > Another nit is that swap_start and swap_next do the following:
> > if (!(si->flags & SWP_USED) || !si->swap_map)
> >         continue;
> >
> > Testing for swap_map does not look very nice and regardless of your
> > patch the latter cannot be true if the former is not, thus the check
> > can be simplified to mere !si->swap_map.
> 
> Yes, mere !si->swap_map is enough. But how about use SWP_WRITEOK, I
> think it is more clear and hurt nobody.

No, I don't like your use of SWP_WRITEOK there in 2/8, for this reason:
it would exclude an area in try_to_unuse() from being shown, and that
function can take such a very long time, that it's rather helpful to
see if it's making slow progress through /proc/swaps or "swapon -s".

Using si->swap_map alone, yes, I guess that would do; or si->max.
With a comment if you wish.

> 
> > I'm wondering if it would make sense to dedicate a flag (SWP_ALLOCATED?)
> > to control whether swapon can use give swap_info. That is, it would be
> > tested and set in alloc_swap_info & cleared like you clear SWP_USED now.
> > SWP_USED would be cleared as it is and would be set in _enable_swap_info
> >
> > Then swap_info_get would be left unchanged and swap_* would test for
> > SWP_USED only.
> 
> I think SWP_USED and SWP_WRITEOK are enough, introduce another flag
> would make things more complex.

I share your instinct on that.

Hugh

> The first thing in my opition is make the lock and flag usage more
> clear and readable in swapfile.c
> 
> If I miss something, plead let me know. Thanks!
> 
> > --
> > Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
