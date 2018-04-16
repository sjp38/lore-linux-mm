Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 245F86B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:11:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31so14268766wrr.2
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:11:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r25si57159edm.165.2018.04.16.14.11.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 14:11:17 -0700 (PDT)
Date: Mon, 16 Apr 2018 23:11:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
Message-ID: <20180416211115.GU17484@dhcp22.suse.cz>
References: <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
 <20180413160435.GA17484@dhcp22.suse.cz>
 <CAG48ez3-xtmAt2EpRFR8GNKKPcsDsyg7XdwQ=D5w3Ym6w4Krjw@mail.gmail.com>
 <CAG48ez1PdzMs8hkatbzSLBWYucjTc75o8ovSmeC66+e9mLvSfA@mail.gmail.com>
 <20180416100736.GG17484@dhcp22.suse.cz>
 <CAG48ez3DwRXMtiinUWKnan6hAppLYLdx-w+VzXG6ubioZUacQg@mail.gmail.com>
 <20180416191805.GS17484@dhcp22.suse.cz>
 <CAG48ez1nf96nHj8a+aZy22RwqYTUZBGrsGFcz=ZhZBUWzaEZ9w@mail.gmail.com>
 <20180416195726.GT17484@dhcp22.suse.cz>
 <CAG48ez1bV_zZP3Y2ioDndP+H8mLCcxOtU1vCbWe7Q8myEGfXQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1bV_zZP3Y2ioDndP+H8mLCcxOtU1vCbWe7Q8myEGfXQQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon 16-04-18 22:17:40, Jann Horn wrote:
> On Mon, Apr 16, 2018 at 9:57 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 16-04-18 21:30:09, Jann Horn wrote:
> >> On Mon, Apr 16, 2018 at 9:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> >> > Yes, reasonably well written application will not have this problem.
> >> > That, however, requires an external synchronization and that's why
> >> > called it error prone and racy. I guess that was the main motivation for
> >> > that part of the man page.
> >>
> >> What requires external synchronization? I still don't understand at
> >> all what you're talking about.
> >>
> >> The following code:
> >>
> >> void *try_to_alloc_addr(void *hint, size_t len) {
> >>   char *x = mmap(hint, len, ...);
> >>   if (x == MAP_FAILED) return NULL;
> >>   if (x == hint) return x;
> >
> > Any other thread can modify the address space at this moment.
> 
> But not parts of the address space that were returned by this mmap() call.
?
> > Just
> > consider that another thread would does mmap(x, MAP_FIXED) (or any other
> > address overlapping [x, x+len] range)
> 
> If the other thread does that without previously having created a
> mapping covering the area in question, that would be a bug in the
> other thread.

MAP_FIXED is sometimes used without preallocated address ranges.

> MAP_FIXED on an unmapped address is almost always a bug
> (excluding single-threaded cases with no library code, and even then
> it's quite weird) - for example, any malloc() call could also cause
> libc to start using the memory range you're trying to map with
> MAP_FIXED.

Yeah and that's why we there is such a large paragraph in the man page
;)

> > becaus it is seemingly safe as x
> > != hint.
> 
> I don't understand this part. Are you talking about a hypothetical
> scenario in which a programmer attempts to segment the virtual memory
> space into areas that are exclusively used by threads without creating
> memory mappings for those areas?

Yeah, that doesn't sound all that over-exaggerated, right? And yes,
such a code would be subtle and most probably buggy. I am not trying to
argue for those hypothetical cases. All I am saying is that MAP_FIXED is
subtle.

I _do_ agree that using it solely on the preallocated and _properly_
managed address ranges is safe. I still maintain my position on error
prone though. And besides that there are usecases which do not operate
on preallocated address ranges so people really have to be careful.

I do not really care what is the form. I find the current wording quite
informative and showing examples of how things might be broken. I do
agree with your remark that "MAP_FIXED on preallocated ranges is safe"
should be added. But MAP_FIXED is dangerous API and should have few big
fat warnings.
-- 
Michal Hocko
SUSE Labs
