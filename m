Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC701800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 07:21:39 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 33so2320480wrs.3
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:21:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4si2050586wre.318.2018.01.24.04.21.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 04:21:38 -0800 (PST)
Date: Wed, 24 Jan 2018 13:21:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
Message-ID: <20180124122136.GD28465@dhcp22.suse.cz>
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
 <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
 <20180123160509.GT1526@dhcp22.suse.cz>
 <218a11e6-766c-d8f6-a266-cbd0852de1c8@codeaurora.org>
 <20180124093839.GJ1526@dhcp22.suse.cz>
 <acd4279f-0e2b-20b7-8f3e-10d2f50ade0e@codeaurora.org>
 <20180124111130.GB28465@dhcp22.suse.cz>
 <7e50564b-960d-5a07-47ec-6b1d86a3c32d@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e50564b-960d-5a07-47ec-6b1d86a3c32d@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz

On Wed 24-01-18 17:39:44, Vinayak Menon wrote:
> On 1/24/2018 4:41 PM, Michal Hocko wrote:
> > On Wed 24-01-18 16:13:06, Vinayak Menon wrote:
> >> On 1/24/2018 3:08 PM, Michal Hocko wrote:
> > [...]
> >>> Try to be more realistic. We have way too many sysctls. Some of them are
> >>> really implementation specific and then it is not really trivial to get
> >>> rid of them because people tend to (think they) depend on them. This is
> >>> a user interface like any others and we do not add them without a due
> >>> scrutiny. Moreover we do have an interface to suppress the effect of the
> >>> faultaround. Instead you are trying to add another tunable for something
> >>> that we can live without altogether. See my point?
> >> I agree on the sysctl part. But why should we disable faultaround and
> >> not find a way to make it useful ?
> > I didn't say that. Please read what I've written. I really hate your new
> > sysctl, because that is not a solution. If you can find a different one
> > than disabling it then go ahead. But do not try to put burden to users
> > because they know what to set. Because they won't.
> 
> What about an expert level config option which is by default disabled ?

so we have way too many sysctls and it is hard for users to decide what
to do and now you are suggesting a config option instead? How come this
makes any sense?

> Whether to consider faultaround ptes as old or young is dependent on
> architectural details that can't be gathered at runtime by reading
> some system registers. This needs to be figured out by experiments,
> just like how a value for watermark_scale_factor is arrived at. So the
> user, in this case an engineer expert in this area decides whether the
> option can be enabled or not in the build.
> I agree that it need not be a sysctl, but what is the problem that
> you see in making it a expert level config ? How is it a burden to a
> non-expert user ?

Our config space is immense. Adding more on top will not put a relief.
Just imagine that you get a bug report about a strange reclaim behavior.
Now you have a one more aspect to consider.

Seriously, if a heuristic fails on somebody then just make it more
conservative. Maybe it is time to sit down and rethink how the fault
around should be implemented. No shortcuts and fancy tunables to paper
over those problems.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
