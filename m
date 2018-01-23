Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D010A800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 11:05:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g187so663518wmg.2
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:05:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r82si6907239wme.253.2018.01.23.08.05.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 08:05:10 -0800 (PST)
Date: Tue, 23 Jan 2018 17:05:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
Message-ID: <20180123160509.GT1526@dhcp22.suse.cz>
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
 <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz

On Tue 23-01-18 21:08:36, Vinayak Menon wrote:
> 
> 
> On 1/23/2018 8:25 PM, Michal Hocko wrote:
> > [Please cc linux-api when proposing user interface]
> >
> > On Mon 22-01-18 11:10:14, Vinayak Menon wrote:
> >> Based on Kirill's patch [1].
> >>
> >> Currently, faultaround code produces young pte.  This can screw up
> >> vmscan behaviour[2], as it makes vmscan think that these pages are hot
> >> and not push them out on first round.
> >>
> >> During sparse file access faultaround gets more pages mapped and all of
> >> them are young. Under memory pressure, this makes vmscan swap out anon
> >> pages instead, or to drop other page cache pages which otherwise stay
> >> resident.
> >>
> >> Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
> >> is set, so they can easily be reclaimed under memory pressure.
> >>
> >> This can to some extend defeat the purpose of faultaround on machines
> >> without hardware accessed bit as it will not help us with reducing the
> >> number of minor page faults.
> > So we just want to add a knob to cripple the feature? Isn't it better to
> > simply disable it than to have two distinct implementation which is
> > rather non-intuitive and I would bet that most users will be clueless
> > about how to set it or when to touch it at all. So we will end up with
> > random cargo cult hints all over internet giving you your performance
> > back...
> 
> 
> If you are talking about non-HW access bit systems, then yes it would be better to disable faultaround
> when want_old_faultaround_pte is set to 1, like MInchan did here https://patchwork.kernel.org/patch/9115901/
> I can submit a patch for that.
> 
> > I really dislike this new interface. If the fault around doesn't work
> > for you then disable it.
> 
> 
> Faultaround works well for me on systems with HW access bit. But
> the benefit is reduced because of making the faultaround ptes young
> [2]. Ideally they should be old as they are speculatively mapped and
> not really accessed. But because of issues on certain architectures
> they need to be made young[3][4]. This patch is trying to help the
> other architectures which can tolerate old ptes, by fixing the vmscan
> behaviour. And this is not a theoretical problem that I am trying to
> fix. We have really seen the benefit of faultaround on arm mobile
> targets, but the problem is the vmscan behaviour due to the young
> pte workaround. And this patch helps in fixing that.  Do you think
> something more needs to be added in the documentation to make things
> more clear on the flag usage ?

No, I would either prefer auto-tuning or document that fault around
can lead to this behavior and recommend to disable it rather than add a
new knob.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
