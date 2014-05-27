Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 78FC36B0087
	for <linux-mm@kvack.org>; Tue, 27 May 2014 09:05:28 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so1677653wib.4
        for <linux-mm@kvack.org>; Tue, 27 May 2014 06:05:27 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id c17si6281452wiv.21.2014.05.27.06.05.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 May 2014 06:05:22 -0700 (PDT)
Date: Tue, 27 May 2014 15:05:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
Message-ID: <20140527130509.GD5444@laptop.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
 <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
 <20140526203232.GC5444@laptop.programming.kicks-ass.net>
 <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net>
 <20140527105438.GW13658@twins.programming.kicks-ass.net>
 <CALYGNiNCp5ShyKLAQi_cht_-sPt79Zxzj=Q=VSzqCvdnsCE5ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CALYGNiNCp5ShyKLAQi_cht_-sPt79Zxzj=Q=VSzqCvdnsCE5ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, May 27, 2014 at 03:11:36PM +0400, Konstantin Khlebnikov wrote:
> On Tue, May 27, 2014 at 2:54 PM, Peter Zijlstra <peterz@infradead.org> wr=
ote:
> > On Tue, May 27, 2014 at 12:29:09PM +0200, Peter Zijlstra wrote:
> >> On Tue, May 27, 2014 at 12:49:08AM +0400, Konstantin Khlebnikov wrote:
> >> > Another suggestion. VM_RESERVED is stronger than VM_LOCKED and exten=
ds
> >> > its functionality.
> >> > Maybe it's easier to add VM_DONTMIGRATE and use it together with VM_=
LOCKED.
> >> > This will make accounting easier. No?
> >>
> >> I prefer the PINNED name because the not being able to migrate is only
> >> one of the desired effects of it, not the primary effect. We're really
> >> looking to keep physical pages in place and preserve mappings.
>=20
> Ah, I just mixed it up.
>=20
> >>
> >> The -rt people for example really want to avoid faults (even minor
> >> faults), and DONTMIGRATE would still allow unmapping.
> >>
> >> Maybe always setting VM_PINNED and VM_LOCKED together is easier, I
> >> hadn't considered that. The first thing that came to mind is that that
> >> might make the fork() semantics difficult, but maybe it works out.
> >>
> >> And while we're on the subject, my patch preserves PINNED over fork()
> >> but maybe we don't actually need that either.
> >
> > So pinned_vm is userspace exposed, which means we have to maintain the
> > individual counts, and doing the fully orthogonal accounting is 'easier'
> > than trying to get the boundary cases right.
> >
> > That is, if we have a program that does mlockall() and then does the IB
> > ioctl() to 'pin' a region, we'd have to make mm_mpin() do munlock()
> > after it splits the vma, and then do the pinned accounting.
> >
> > Also, we'll have lost the LOCKED state and unless MCL_FUTURE was used,
> > we don't know what to restore the vma to on mm_munpin().
> >
> > So while the accounting looks tricky, it has simpler semantics.
>=20
> What if VM_PINNED will require VM_LOCKED?
> I.e. user must mlock it before pining and cannot munlock vma while it's p=
inned.

So I don't like restrictions like that if its at all possible to avoid
-- and in this case, I already wrote the code and its not _that_
complicated.

But also; that would mean that we'd either have to make mm_mpin() do the
mlock unconditionally (which rather defeats the purpose) or break
userspace assumptions. I'm fairly sure the IB ioctl() don't require the
memory to be mlocked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
