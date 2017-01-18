Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDDD6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:55:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so2007296wmv.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:55:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26si28501832wrp.329.2017.01.18.01.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:55:51 -0800 (PST)
Date: Wed, 18 Jan 2017 10:55:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/4] mm, page_alloc: move cpuset seqcount checking to
 slowpath
Message-ID: <20170118095549.GM7015@dhcp22.suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-4-vbabka@suse.cz>
 <20170118094054.GJ7015@dhcp22.suse.cz>
 <7b984dde-78c5-2efc-daef-bcdcc51fc9cb@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7b984dde-78c5-2efc-daef-bcdcc51fc9cb@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 18-01-17 10:48:55, Vlastimil Babka wrote:
> On 01/18/2017 10:40 AM, Michal Hocko wrote:
> > On Tue 17-01-17 23:16:09, Vlastimil Babka wrote:
> > > This is a preparation for the following patch to make review simpler. While
> > > the primary motivation is a bug fix, this could also save some cycles in the
> > > fast path.
> > 
> > I cannot say I would be happy about this patch :/ The code is still very
> > confusing and subtle. I really think we should get rid of
> > synchronization with the concurrent cpuset/mempolicy updates instead.
> > Have you considered that instead?
> 
> Not so thoroughly yet, but I already suspect it would be intrusive for
> stable. We could make copies of nodemask and mems_allowed and protect just
> the copying with seqcount, but that would mean overhead and stack space.
> Also we might try revert 682a3385e773 ("mm, page_alloc: inline the fast path
> of the zonelist iterator") ...

If reverting that patch makes the problem go away and it is applicable
for the stable I would rather go that way for stable and take a deep
breath and rethink the whole cpuset and nodemask manipulation in the
allocation path for a better long term solution.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
