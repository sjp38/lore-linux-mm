Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 406E56B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 08:19:53 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g61-v6so9612625plb.10
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 05:19:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si2130777pfk.311.2018.04.03.05.19.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 05:19:52 -0700 (PDT)
Date: Tue, 3 Apr 2018 14:19:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180403121950.GW5501@dhcp22.suse.cz>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
 <201803301934.DHF12420.SOFFJQMLVtHOOF@I-love.SAKURA.ne.jp>
 <20180403121414.GD5832@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403121414.GD5832@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, riel@redhat.com

On Tue 03-04-18 05:14:14, Matthew Wilcox wrote:
> On Fri, Mar 30, 2018 at 07:34:59PM +0900, Tetsuo Handa wrote:
> > Maybe we can make "give up by default upon SIGKILL" and let callers
> > explicitly say "do not give up upon SIGKILL".
> 
> I really strongly disapprove of this patch.  This GFP flag will be abused
> like every other GFP flag.
> 
> > +++ b/mm/page_alloc.c
> > @@ -4183,6 +4183,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >  	if (current->flags & PF_MEMALLOC)
> >  		goto nopage;
> >  
> > +	/* Can give up if caller is willing to give up upon fatal signals */
> > +	if (fatal_signal_pending(current) &&
> > +	    !(gfp_mask & (__GFP_UNKILLABLE | __GFP_NOFAIL))) {
> > +		gfp_mask |= __GFP_NOWARN;
> > +		goto nopage;
> > +	}
> > +
> >  	/* Try direct reclaim and then allocating */
> 
> This part is superficially tempting, although without the UNKILLABLE.  ie:
> 
> +	if (fatal_signal_pending(current) && !(gfp_mask & __GFP_NOFAIL)) {
> +		gfp_mask |= __GFP_NOWARN;
> +		goto nopage;
> +	}
> 
> It makes some sense to me to prevent tasks with a fatal signal pending
> from being able to trigger reclaim.  But I'm worried about what memory
> allocation failures it might trigger on paths that aren't accustomed to
> seeing failures.

Please be aware that we _do_ allocate in the exit path. I have a strong
suspicion that even while fatal signal is pending. Do we really want
fail those really easily.
-- 
Michal Hocko
SUSE Labs
