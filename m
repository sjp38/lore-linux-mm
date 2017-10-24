Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 807546B0289
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:30:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k15so11932932wrc.1
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:30:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u54si389508wrf.243.2017.10.24.08.30.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:30:38 -0700 (PDT)
Date: Tue, 24 Oct 2017 17:30:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Fix false error message in
 __swp_swapcount()
Message-ID: <20171024153037.gjemriarubzoqai5@dhcp22.suse.cz>
References: <20171024024700.23679-1-ying.huang@intel.com>
 <20171024083809.lrw23yumkassclgm@dhcp22.suse.cz>
 <87vaj4poff.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vaj4poff.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

On Tue 24-10-17 23:15:32, Huang, Ying wrote:
> Hi, Michal,
> 
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Tue 24-10-17 10:47:00, Huang, Ying wrote:
> >> From: Ying Huang <ying.huang@intel.com>
> >> 
> >> __swp_swapcount() is used in __read_swap_cache_async().  Where the
> >> invalid swap entry (offset > max) may be supplied during swap
> >> readahead.  But __swp_swapcount() will print error message for these
> >> expected invalid swap entry as below, which will make the users
> >> confusing.
> >   ^^
> > confused... And I have to admit this changelog has left me confused as
> > well. What is an invalid swap entry in the readahead? Ohh, let me
> > re-real Fixes: commit. It didn't really help "We can avoid needlessly
> > allocating page for swap slots that are not used by anyone.  No pages
> > have to be read in for these slots."
> >
> > Could you be more specific about when and how this happens please?
> 
> Sorry for confusing.
> 
> When page fault occurs for a swap entry, the original swap readahead
> (not new VMA base swap readahead) may readahead several swap entries
> after the fault swap entry.  The readahead algorithm calculates some of
> the swap entries to readahead via increasing the offset of the fault
> swap entry without checking whether they are beyond the end of the swap
> device and it rely on the __swp_swapcount() and swapcache_prepare() to
> check it.  Although __swp_swapcount() checks for the swap entry passed
> in, it will complain with error message for the expected invalid swap
> entry.  This makes the end user confusing.
> 
> Is this a little clearer.

yes, this makes more sense (modulo the same typo ;)). Can you make this
information into the changelog please? Thanks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
