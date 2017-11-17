Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF8686B0069
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:13:00 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b6so3061649pff.18
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 11:13:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n9si3200928pgc.688.2017.11.17.11.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 11:12:59 -0800 (PST)
Date: Fri, 17 Nov 2017 11:12:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171117191251.GA1601@bombadil.infradead.org>
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116101900.13621-2-mhocko@kernel.org>
 <CAGXu5jKssQCcYcZujvQeFy5LTzhXSW=f-a0riB=4+caT1i38BQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKssQCcYcZujvQeFy5LTzhXSW=f-a0riB=4+caT1i38BQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Nov 16, 2017 at 04:27:36PM -0800, Kees Cook wrote:
> On Thu, Nov 16, 2017 at 2:18 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > MAP_FIXED is used quite often to enforce mapping at the particular
> > range. The main problem of this flag is, however, that it is inherently
> > dangerous because it unmaps existing mappings covered by the requested
> > range. This can cause silent memory corruptions. Some of them even with
> > serious security implications. While the current semantic might be
> > really desiderable in many cases there are others which would want to
> > enforce the given range but rather see a failure than a silent memory
> > corruption on a clashing range. Please note that there is no guarantee
> > that a given range is obeyed by the mmap even when it is free - e.g.
> > arch specific code is allowed to apply an alignment.
> >
> > Introduce a new MAP_FIXED_SAFE flag for mmap to achieve this behavior.
> > It has the same semantic as MAP_FIXED wrt. the given address request
> > with a single exception that it fails with ENOMEM if the requested
> > address is already covered by an existing mapping. We still do rely on
> > get_unmaped_area to handle all the arch specific MAP_FIXED treatment and
> > check for a conflicting vma after it returns.
> 
> I like this much more than special-casing the ELF loader. It is an
> unusual property that MAP_FIXED does _two_ things, so I like having
> this split out.
> 
> Bikeshedding: maybe call this MAP_NO_CLOBBER? It's a modifier to
> MAP_FIXED, really...

Way back when, I proposed a new flag called MAP_FIXED_WEAK.  I was
dissuaded from it when userspace people said it was just as easy for
them to provide the address hint, then run fixups on their data if the
address they were assigned wasn't the one they asked for.

The real problem is that MAP_FIXED should have been called MAP_FORCE.

So ... do we really have users that want failure instead of success at
a different address?  And if so, is it really a hardship for them to
make a call to unmap on success-at-the-wrong-address?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
