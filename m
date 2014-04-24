Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 02F9A6B0036
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 04:49:32 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so1560571eek.8
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 01:49:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si7339763eel.106.2014.04.24.01.49.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 01:49:31 -0700 (PDT)
Date: Thu, 24 Apr 2014 10:49:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140424084928.GI17824@quack.suse.cz>
References: <53558507.9050703@zytor.com>
 <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
 <53559F48.8040808@intel.com>
 <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
 <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
 <20140422075459.GD11182@twins.programming.kicks-ass.net>
 <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
 <alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
 <20140423184145.GH17824@quack.suse.cz>
 <alpine.LSU.2.11.1404231247230.3173@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404231247230.3173@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Wed 23-04-14 13:11:20, Hugh Dickins wrote:
> On Wed, 23 Apr 2014, Jan Kara wrote:
> > Now I'm not sure how to fix Linus' patches. For all I care we could just
> > rip out pte dirty bit handling for file mappings. However last time I
> > suggested this you corrected me that tmpfs & ramfs need this. I assume this
> > is still the case - however, given we unconditionally mark the page dirty
> > for write faults, where exactly do we need this?
> 
> Good, Linus has already replied to you on this this: you appear to be
> suggesting that there would be no issue, and Linus's patches would not
> be needed at all, if only tmpfs and ramfs played by the others' rules.
  No, that's not what I wanted to say. I wanted to say - keep Linus'
patches and additionally rip out pte dirty bit handling for "normal"
filesystems to not confuse filesystems with dirty pages where they don't
expect them. But after reading replies and thinking about it even that is
not enough because then we would again miss writes done by other cpus after
we tore down rmap but before we flushed TLBs.

> But (sadly) I don't think that's so: just because zap_pte_range()'s
> current "if (pte_dirty) set_page_dirty" does nothing on most filesystems,
> does not imply that nothing needs to be done on most filesystems, now
> that we're alert to the delayed TLB flushing issue.
> 
> Just to answer your (interesting but irrelevant!) question about tmpfs
> and ramfs: their issue is with read faults which bring in a zeroed page,
> with page and pte not marked dirty.  If userspace modifies that page, the
> pte_dirty needs to be propagated through to PageDirty, to prevent page
> reclaim from simply freeing the apparently clean page.
  Ah, I keep forgetting about that vma_wants_writenotify() thing in mmap
which changes whether a shared page is mapped RW or RO on read fault.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
