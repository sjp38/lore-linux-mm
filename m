Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F136E6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:57:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z13so9949136pfe.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:57:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3-v6si12541029plb.536.2018.04.16.12.57.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 12:57:28 -0700 (PDT)
Date: Mon, 16 Apr 2018 21:57:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
Message-ID: <20180416195726.GT17484@dhcp22.suse.cz>
References: <9c714917-fc29-4d12-b5e8-cff28761a2c1@gmail.com>
 <20180413064917.GC17484@dhcp22.suse.cz>
 <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
 <20180413160435.GA17484@dhcp22.suse.cz>
 <CAG48ez3-xtmAt2EpRFR8GNKKPcsDsyg7XdwQ=D5w3Ym6w4Krjw@mail.gmail.com>
 <CAG48ez1PdzMs8hkatbzSLBWYucjTc75o8ovSmeC66+e9mLvSfA@mail.gmail.com>
 <20180416100736.GG17484@dhcp22.suse.cz>
 <CAG48ez3DwRXMtiinUWKnan6hAppLYLdx-w+VzXG6ubioZUacQg@mail.gmail.com>
 <20180416191805.GS17484@dhcp22.suse.cz>
 <CAG48ez1nf96nHj8a+aZy22RwqYTUZBGrsGFcz=ZhZBUWzaEZ9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1nf96nHj8a+aZy22RwqYTUZBGrsGFcz=ZhZBUWzaEZ9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon 16-04-18 21:30:09, Jann Horn wrote:
> On Mon, Apr 16, 2018 at 9:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > Yes, reasonably well written application will not have this problem.
> > That, however, requires an external synchronization and that's why
> > called it error prone and racy. I guess that was the main motivation for
> > that part of the man page.
> 
> What requires external synchronization? I still don't understand at
> all what you're talking about.
> 
> The following code:
> 
> void *try_to_alloc_addr(void *hint, size_t len) {
>   char *x = mmap(hint, len, ...);
>   if (x == MAP_FAILED) return NULL;
>   if (x == hint) return x;

Any other thread can modify the address space at this moment. Just
consider that another thread would does mmap(x, MAP_FIXED) (or any other
address overlapping [x, x+len] range) becaus it is seemingly safe as x
!= hint. This will succeed and ...
>   munmap(x, len);
... now you are munmaping somebody's else memory range

>   return NULL;

Do code _is_ buggy but it is not obvious at all.

> }
> 
> has no need for any form of external synchronization.

If the above mmap/munmap section was protected by a lock and _all_ other
mmaps (direct or indirect) would use the same lock then you are safe
against that.
-- 
Michal Hocko
SUSE Labs
