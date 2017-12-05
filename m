Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF936B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 02:08:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u3so15521716pfl.5
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 23:08:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v72si11574275pfa.126.2017.12.04.23.08.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 23:08:43 -0800 (PST)
Date: Tue, 5 Dec 2017 08:08:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171205070838.u3br5lvshywkwxby@dhcp22.suse.cz>
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204113113.GA13465@rapoport-lnx>
 <6777116d-ad9e-48c9-0009-01d10274135e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6777116d-ad9e-48c9-0009-01d10274135e@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>

On Mon 04-12-17 18:52:27, John Hubbard wrote:
> On 12/04/2017 03:31 AM, Mike Rapoport wrote:
> > On Sun, Dec 03, 2017 at 06:14:11PM -0800, john.hubbard@gmail.com wrote:
> >> From: John Hubbard <jhubbard@nvidia.com>
> >>
> [...]
> >> +.IP
> >> +Given the above limitations, one of the very few ways to use this option
> >> +safely is: mmap() a region, without specifying MAP_FIXED. Then, within that
> >> +region, call mmap(MAP_FIXED) to suballocate regions. This avoids both the
> >> +portability problem (because the first mmap call lets the kernel pick the
> >> +address), and the address space corruption problem (because the region being
> >> +overwritten is already owned by the calling thread).
> > 
> > Maybe "address space corruption problem caused by implicit calls to mmap"?
> > The region allocated with the first mmap is not exactly owned by the
> > thread and a multi-thread application can still corrupt its memory if
> > different threads use mmap(MAP_FIXED) for overlapping regions.
> > 
> > My 2 cents.
> > 
> 
> Hi Mike,
> 
> Yes, thanks for picking through this, and I agree that the above is misleading.
> It should definitely not use the word "owned" at all. Re-doing the whole 
> paragraph in order to make it all fit together nicely, I get this:
> 
> "Given the above limitations, one of the very few ways to use this option
> safely is: mmap() an enclosing region, without specifying MAP_FIXED.
> Then, within that region, call mmap(MAP_FIXED) to suballocate regions
> within the enclosing region. This avoids both the portability problem 
> (because the first mmap call lets the kernel pick the address), and the 
> address space corruption problem (because implicit calls to mmap will 
> not affect the already-mapped enclosing region)."
> 
> ...how's that sound to you? I'll post a v3 soon with this.

It sounds to me you are trying to tell way to much while actually being
a bit misleading. Even sub-range MAP_FIXED is not multi-thread safe.

Really the more corner cases you will try to cover the worse the end
result will end up. I would just try to be simple here and mention the
address space corruption issues you've had earlier and be done with it.
Maybe add a note that some architectures might need a special alignement
and fail if it is not the case but nothing really specific.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
