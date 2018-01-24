Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6F3B800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:38:44 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r82so1865817wme.0
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 01:38:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si629740wmf.69.2018.01.24.01.38.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 01:38:43 -0800 (PST)
Date: Wed, 24 Jan 2018 10:38:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
Message-ID: <20180124093839.GJ1526@dhcp22.suse.cz>
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
 <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
 <20180123160509.GT1526@dhcp22.suse.cz>
 <218a11e6-766c-d8f6-a266-cbd0852de1c8@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <218a11e6-766c-d8f6-a266-cbd0852de1c8@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz

On Wed 24-01-18 14:35:54, Vinayak Menon wrote:
> 
> On 1/23/2018 9:35 PM, Michal Hocko wrote:
> > On Tue 23-01-18 21:08:36, Vinayak Menon wrote:
> >>
> >> On 1/23/2018 8:25 PM, Michal Hocko wrote:
> >>> [Please cc linux-api when proposing user interface]
> >>>
> >>> On Mon 22-01-18 11:10:14, Vinayak Menon wrote:
> >>>> Based on Kirill's patch [1].
> >>>>
> >>>> Currently, faultaround code produces young pte.  This can screw up
> >>>> vmscan behaviour[2], as it makes vmscan think that these pages are hot
> >>>> and not push them out on first round.
> >>>>
> >>>> During sparse file access faultaround gets more pages mapped and all of
> >>>> them are young. Under memory pressure, this makes vmscan swap out anon
> >>>> pages instead, or to drop other page cache pages which otherwise stay
> >>>> resident.
> >>>>
> >>>> Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
> >>>> is set, so they can easily be reclaimed under memory pressure.
> >>>>
> >>>> This can to some extend defeat the purpose of faultaround on machines
> >>>> without hardware accessed bit as it will not help us with reducing the
> >>>> number of minor page faults.
> >>> So we just want to add a knob to cripple the feature? Isn't it better to
> >>> simply disable it than to have two distinct implementation which is
> >>> rather non-intuitive and I would bet that most users will be clueless
> >>> about how to set it or when to touch it at all. So we will end up with
> >>> random cargo cult hints all over internet giving you your performance
> >>> back...
> >>
> >> If you are talking about non-HW access bit systems, then yes it would be better to disable faultaround
> >> when want_old_faultaround_pte is set to 1, like MInchan did here https://patchwork.kernel.org/patch/9115901/
> >> I can submit a patch for that.
> >>
> >>> I really dislike this new interface. If the fault around doesn't work
> >>> for you then disable it.
> >>
> >> Faultaround works well for me on systems with HW access bit. But
> >> the benefit is reduced because of making the faultaround ptes young
> >> [2]. Ideally they should be old as they are speculatively mapped and
> >> not really accessed. But because of issues on certain architectures
> >> they need to be made young[3][4]. This patch is trying to help the
> >> other architectures which can tolerate old ptes, by fixing the vmscan
> >> behaviour. And this is not a theoretical problem that I am trying to
> >> fix. We have really seen the benefit of faultaround on arm mobile
> >> targets, but the problem is the vmscan behaviour due to the young
> >> pte workaround. And this patch helps in fixing that.  Do you think
> >> something more needs to be added in the documentation to make things
> >> more clear on the flag usage ?
> > No, I would either prefer auto-tuning or document that fault around
> > can lead to this behavior and recommend to disable it rather than add a
> > new knob.
> 
> 
> One of the objectives of making it a sysctl was to let user space
> tune it based on vmpressure [5]. But I am not sure how effective it
> would be. The vmpressure increase itself can be because of making
> faultaround ptes young [6] and it could be difficult to find a
> heuristic to enable/disable faultaround. And with the way vmpressure
> works, it can happen that vmpressure values don't indicate exact
> vmscan behavior always. Same is the case with auto-tuning based
> on vmpressure. Any other suggestions on how auto tuning can be
> implemented ?

I would start simple. Just disable it on platforms which are known to
suffer from this heuristic. Do not try to invent a sysctl nobody will
know hot to setup.

> Could you elaborate a bit on why you think sysctl is not a good option
> ? Is it because of the difficulty for the user to figure out how and
> when to use the interface ?

Absolutely. Not only that but the mere fact to realize that the fault
around is the culprit is not something most users will be able/willing
to do. So instead we will end up in yet another "disable THP because
that solves all the problems in universe" cargo cult.

> If the document clearly explains what the knob is, wouldn't be easy
> for the user to just try the knob and see if his workload benefits
> or not. It's not just non-x86 devices that can benefit. There may be
> x86 workloads where the vmscan behavior masks the benefit of avoiding
> micro faults.

Try to be more realistic. We have way too many sysctls. Some of them are
really implementation specific and then it is not really trivial to get
rid of them because people tend to (think they) depend on them. This is
a user interface like any others and we do not add them without a due
scrutiny. Moreover we do have an interface to suppress the effect of the
faultaround. Instead you are trying to add another tunable for something
that we can live without altogether. See my point?

> Or if you think sysctl is not the right place for such knobs, do you
> think it should be an expert level config option or a kernel command
> line param ?

No it doesn't make much difference. It is still a user interface. Maybe
one that is slightly easier to deprecate but just think about it. Do you
really need a faultaround so much you really want to fiddle with such
lowlevel stuff like old-vs-you pte bits?

> Since there are lots of mobile and embedded devices that can get the
> full benefits of faultaround with such an option, I really don't
> think it is a good option to just document the problem and disable
> faultaround on those devices.

Could you point me to some numbers that prove that? Your unixbench
doesn't sound overly convincing. And if this is really about some arches
then change them to use old ptes in an arch specific code. Do not make
it tunable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
