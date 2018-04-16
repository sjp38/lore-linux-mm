Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48F566B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:07:40 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y22-v6so1702978pll.12
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 03:07:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17-v6si6386520plz.469.2018.04.16.03.07.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 03:07:39 -0700 (PDT)
Date: Mon, 16 Apr 2018 12:07:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
Message-ID: <20180416100736.GG17484@dhcp22.suse.cz>
References: <CAG48ez2NtCr8+HqnKJTFBcLW+kCKUa=2pz=7HD9p9u1p-MfJqw@mail.gmail.com>
 <13801e2a-c44d-e940-f872-890a0612a483@nvidia.com>
 <CAG48ez085cASur3kZTRkdJY20dFZ4Yqc1KVOHxnCAn58_NtW8w@mail.gmail.com>
 <cfbbbe06-5e63-e43c-fb28-c5afef9e1e1d@nvidia.com>
 <9c714917-fc29-4d12-b5e8-cff28761a2c1@gmail.com>
 <20180413064917.GC17484@dhcp22.suse.cz>
 <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
 <20180413160435.GA17484@dhcp22.suse.cz>
 <CAG48ez3-xtmAt2EpRFR8GNKKPcsDsyg7XdwQ=D5w3Ym6w4Krjw@mail.gmail.com>
 <CAG48ez1PdzMs8hkatbzSLBWYucjTc75o8ovSmeC66+e9mLvSfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1PdzMs8hkatbzSLBWYucjTc75o8ovSmeC66+e9mLvSfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Fri 13-04-18 18:17:36, Jann Horn wrote:
> On Fri, Apr 13, 2018 at 6:05 PM, Jann Horn <jannh@google.com> wrote:
> > On Fri, Apr 13, 2018 at 6:04 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >> On Fri 13-04-18 17:04:09, Jann Horn wrote:
> >>> On Fri, Apr 13, 2018 at 8:49 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >>> > On Fri 13-04-18 08:43:27, Michael Kerrisk wrote:
> >>> > [...]
> >>> >> So, you mean remove this entire paragraph:
> >>> >>
> >>> >>               For cases in which the specified memory region has not been
> >>> >>               reserved using an existing mapping,  newer  kernels  (Linux
> >>> >>               4.17  and later) provide an option MAP_FIXED_NOREPLACE that
> >>> >>               should be used instead; older kernels require the caller to
> >>> >>               use addr as a hint (without MAP_FIXED) and take appropriate
> >>> >>               action if the kernel places the new mapping at a  different
> >>> >>               address.
> >>> >>
> >>> >> It seems like some version of the first half of the paragraph is worth
> >>> >> keeping, though, so as to point the reader in the direction of a remedy.
> >>> >> How about replacing that text with the following:
> >>> >>
> >>> >>               Since  Linux 4.17, the MAP_FIXED_NOREPLACE flag can be used
> >>> >>               in a multithreaded program to avoid  the  hazard  described
> >>> >>               above.
> >>> >
> >>> > Yes, that sounds reasonable to me.
> >>>
> >>> But that kind of sounds as if you can't avoid it before Linux 4.17,
> >>> when actually, you just have to call mmap() with the address as hint,
> >>> and if mmap() returns a different address, munmap() it and go on your
> >>> normal error path.
> >>
> >> This is still racy in multithreaded application which is the main point
> >> of the whole section, no?
> >
> > No, it isn't.

I could have been more specific, sorry.

> mmap() with a hint (without MAP_FIXED) will always non-racily allocate
> a memory region for you or return an error code. If it does allocate a
> memory region, it belongs to you until you deallocate it. It might be
> at a different address than you requested -

Yes, this all is true. Except the atomicity is guaranteed only for the
syscall. Once you return to the userspace any error handling is error
prone and racy because your mapping might change under you feet. So...

> in that case you can
> emulate MAP_FIXED_NOREPLACE by calling munmap() and treating it as an
> error; or you can do something else with it.
> 
> MAP_FIXED_NOREPLACE is just a performance optimization.

This is not quite true because you get _your_ area or _an error_
atomically which is not possible with 2 syscalls.

-- 
Michal Hocko
SUSE Labs
