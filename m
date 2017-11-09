Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9248F440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:05:35 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id n37so2855108wrb.17
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:05:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si569503edf.545.2017.11.09.02.05.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:05:33 -0800 (PST)
Date: Thu, 9 Nov 2017 11:05:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
Message-ID: <20171109100531.3cn2hcqnuj7mjaju@dhcp22.suse.cz>
References: <b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
 <20171107125055.cl5pyp2zwon44x5l@dhcp22.suse.cz>
 <1510068865.1000.19.camel@perches.com>
 <20171107154351.ebtitvjyo5v3bt26@dhcp22.suse.cz>
 <1510070607.1000.23.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510070607.1000.23.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 07-11-17 08:03:27, Joe Perches wrote:
> On Tue, 2017-11-07 at 16:43 +0100, Michal Hocko wrote:
> > On Tue 07-11-17 07:34:25, Joe Perches wrote:
> []
> > > I believe, but have not tested, that using a specific width
> > > as an argument to %*pb[l] will constrain the number of
> > > spaces before the '(null)' output in any NULL pointer use.
> > > 
> > > So how about a #define like
> > > 
> > > /*
> > >  * nodemask_pr_args is only used with a "%*pb[l]" format for a nodemask.
> > >  * A NULL nodemask uses 6 to emit "(null)" without leading spaces.
> > >  */
> > > #define nodemask_pr_args(maskp)			\
> > > 	(maskp) ? MAX_NUMNODES : 6,		\
> > > 	(maskp) ? (maskp)->bits : NULL
> > 
> > Why not -1 then?
> 
> I believe it's the field width and not the precision that
> needs to be set.

But the first of the two arguments is the field with specifier, not the
precision. /me confused...

Anyway, the following works as expected when printing the OOM report:
[   47.005321] mem_eater invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   47.007183] mem_eater cpuset=/ mems_allowed=0-1
[   47.007829] CPU: 3 PID: 3223 Comm: mem_eater Tainted: G        W       4.13.0-pr1-dirty #11

I hope I haven't overlooked anything
---
