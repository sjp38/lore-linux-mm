Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04BE08E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:38:20 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so7312177eda.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:38:19 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si119885edn.280.2018.12.11.08.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 08:38:18 -0800 (PST)
Date: Tue, 11 Dec 2018 17:38:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/4] filemap: drop the mmap_sem for all blocking
 operations
Message-ID: <20181211163817.GA4020@quack2.suse.cz>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-4-josef@toxicpanda.com>
 <20181207110138.GE13008@quack2.suse.cz>
 <20181210184438.va7mdwjgwndgri4s@macbook-pro-91.dhcp.thefacebook.com>
 <20181211094034.GD17539@quack2.suse.cz>
 <20181211160851.hqezlvlded6zujrm@macbook-pro-91.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211160851.hqezlvlded6zujrm@macbook-pro-91.dhcp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Jan Kara <jack@suse.cz>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

On Tue 11-12-18 11:08:53, Josef Bacik wrote:
> On Tue, Dec 11, 2018 at 10:40:34AM +0100, Jan Kara wrote:
> > > The lock_page_or_retry() case in particular gets hit a lot with
> > > multi-threaded applications that got paged out because of heavy memory
> > > pressure.  By no means is it as high as just the normal readpage or
> > > readahead cases, but it's not 0, so I'd rather have the extra helper here
> > > to make sure we're never getting screwed.
> > 
> > Do you mean the case where we the page is locked in filemap_fault() (so
> > that lock_page_or_retry() bails after waiting) and when the page becomes
> > unlocked it is not uptodate? Because that is the reason why you opencode
> > lock_page_or_retry(), right? I'm not aware of any normal code path that
> > would create page in page cache and not try to fill it with data before
> > unlocking it so that's why I'm really trying to make sure we understand
> > each other.
> 
> Uhh so that's embarressing.  We have an internal patchset that I thought
> was upstream but hasn't come along yet.  Basically before this patchset
> the way we dealt with this problem was to short-circuit readahead IO's by
> checking to see if the blkcg was congested (or if there was a fatal
> signal pending) and doing bio_wouldblock_error on the bio.  So this very
> case came up a lot, readahead would go through because it got in before
> we were congested, but would then get throttled, and then once the
> throttling was over would get aborted.  Other threads would run into
> these pages that had been locked, but they are never read in which means
> they waited for the lock to be dropped, did the VM_FAULT_RETRY, came back
> unable to drop the mmap_sem and did the actual readpage() and would get
> throttled.

OK, I'm somewhat unsure why we throttle on bios that actually get aborted
but that's a separate discussion over a different patches. Overall it makes
sense that some submitted readahead may actually get aborted on congestion
and thus unlocked pages will not be uptodate. So I agree that this case is
actually reasonably likely to happen. Just please mention case like aborted
readahead in the comment so that we don't wonder about the reason in a few
years again.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
