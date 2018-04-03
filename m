Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCD56B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 08:30:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f3so13626038ioa.8
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 05:30:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f12-v6si322067itc.123.2018.04.03.05.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 05:30:24 -0700 (PDT)
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
	<201803301934.DHF12420.SOFFJQMLVtHOOF@I-love.SAKURA.ne.jp>
	<20180403121414.GD5832@bombadil.infradead.org>
	<20180403121950.GW5501@dhcp22.suse.cz>
In-Reply-To: <20180403121950.GW5501@dhcp22.suse.cz>
Message-Id: <201804032129.HIH05759.FJOFOQLtVHMFSO@I-love.SAKURA.ne.jp>
Date: Tue, 3 Apr 2018 21:29:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, riel@redhat.com

Michal Hocko wrote:
> On Tue 03-04-18 05:14:14, Matthew Wilcox wrote:
> > On Fri, Mar 30, 2018 at 07:34:59PM +0900, Tetsuo Handa wrote:
> > > Maybe we can make "give up by default upon SIGKILL" and let callers
> > > explicitly say "do not give up upon SIGKILL".
> > 
> > I really strongly disapprove of this patch.  This GFP flag will be abused
> > like every other GFP flag.
> > 
> > > +++ b/mm/page_alloc.c
> > > @@ -4183,6 +4183,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > >  	if (current->flags & PF_MEMALLOC)
> > >  		goto nopage;
> > >  
> > > +	/* Can give up if caller is willing to give up upon fatal signals */
> > > +	if (fatal_signal_pending(current) &&
> > > +	    !(gfp_mask & (__GFP_UNKILLABLE | __GFP_NOFAIL))) {
> > > +		gfp_mask |= __GFP_NOWARN;
> > > +		goto nopage;
> > > +	}
> > > +
> > >  	/* Try direct reclaim and then allocating */
> > 
> > This part is superficially tempting, although without the UNKILLABLE.  ie:
> > 
> > +	if (fatal_signal_pending(current) && !(gfp_mask & __GFP_NOFAIL)) {
> > +		gfp_mask |= __GFP_NOWARN;
> > +		goto nopage;
> > +	}
> > 
> > It makes some sense to me to prevent tasks with a fatal signal pending
> > from being able to trigger reclaim.  But I'm worried about what memory
> > allocation failures it might trigger on paths that aren't accustomed to
> > seeing failures.

Userspace tasks might call routines which need GFP_FS or GFP_NOIO (for
direct reclaim), and giving up upon fatal signals leads to more problems
like FS error or I/O error. Thus, we can't unconditionally give up upon
fatal signals.

> 
> Please be aware that we _do_ allocate in the exit path. I have a strong
> suspicion that even while fatal signal is pending. Do we really want
> fail those really easily.

Does the exit path mean inside do_exit() ? If yes, fatal signals are already
cleared before reaching do_exit().
