Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 38FD76B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 15:45:38 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id oy12so3569864veb.12
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:45:37 -0700 (PDT)
Received: from mail-vc0-x22c.google.com (mail-vc0-x22c.google.com [2607:f8b0:400c:c03::22c])
        by mx.google.com with ESMTPS id iy9si1186006vec.33.2014.04.24.12.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 12:45:37 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id la4so3585520vcb.17
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:45:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
References: <53558507.9050703@zytor.com>
	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	<53559F48.8040808@intel.com>
	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	<20140422075459.GD11182@twins.programming.kicks-ass.net>
	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
	<alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
	<20140423184145.GH17824@quack.suse.cz>
	<CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
	<20140424065133.GX26782@laptop.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
Date: Thu, 24 Apr 2014 12:45:36 -0700
Message-ID: <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Thu, Apr 24, 2014 at 11:40 AM, Hugh Dickins <hughd@google.com> wrote:
> safely with page_mkclean(), as it stands at present anyway.
>
> I think that (in the exceptional case when a shared file pte_dirty has
> been encountered, and this mm is active on other cpus) zap_pte_range()
> needs to flush TLB on other cpus of this mm, just before its
> pte_unmap_unlock(): then it respects the usual page_mkclean() protocol.
>
> Or has that already been rejected earlier in the thread,
> as too costly for some common case?

Hmm. The problem is that right now we actually try very hard to batch
as much as possible in order to avoid extra TLB flushes (we limit it
to around 10k pages per batch, but that's still a *lot* of pages). The
TLB flush IPI calls are noticeable under some loads.

And it's certainly much too much to free 10k pages under a spinlock.
The latencies would be horrendous.

We could add some special logic that only triggers for the dirty pages
case, but it would still have to handle the case of "we batched up
9000 clean pages, and then we hit a dirty page", so it would get
rather costly quickly.

Or we could have a separate array for dirty pages, and limit those to
a much smaller number, and do just the dirty pages under the lock, and
then the rest after releasing the lock. Again, a fair amount of new
complexity.

I would almost prefer to have some special (per-mapping?) lock or
something, and make page_mkclean() be serialize with the unmapping
case.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
