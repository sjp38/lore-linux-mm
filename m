Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECE266B026C
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 14:03:21 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d23-v6so6568421oib.6
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:03:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4-v6sor7923161oig.83.2018.10.11.11.03.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 11:03:20 -0700 (PDT)
MIME-Version: 1.0
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074457.GD22173@dhcp22.suse.cz> <CAPcyv4ht=ueiZwPTWuY5Y4y1BUOi_z+pHMjfoiXG+Bjd-h55jA@mail.gmail.com>
 <20181009112216.GM8528@dhcp22.suse.cz> <CAPcyv4gAsyw7Tpp6QKQUA=P3k-Gw=KzutS-PzBiisnxQ1R24gw@mail.gmail.com>
 <20181010084731.GB5873@dhcp22.suse.cz> <CAPcyv4j1QZSk_soYY=xpMiv0exYzdGoa0uqWppSs_dJwF4TPnw@mail.gmail.com>
 <20181011115238.GU5873@dhcp22.suse.cz>
In-Reply-To: <20181011115238.GU5873@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 11 Oct 2018 11:03:07 -0700
Message-ID: <CAPcyv4i38LAh1-bDE5cAAV=pAWMQeOYSmWF7ucM+Qt2O+GYMWw@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Oct 11, 2018 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 10-10-18 17:13:14, Dan Williams wrote:
> [...]
> > On Wed, Oct 10, 2018 at 1:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> > ...and now that I've made that argument I think I've come around to
> > your point about the shuffle_page_order parameter. The only entity
> > that might have a better clue about "safer" shuffle orders than
> > MAX_ORDER is the distribution provider.
>
> And how is somebody providing a kernel for large variety of workloads
> supposed to know?

True, this would be a much easier discussion with a wider / deeper data set.

>
> [...]
>
> > Note, you can also think about this just on pure architecture terms.
> > I.e. that for a direct mapped cache anywhere in a system you can have
> > a near zero cache conflict rate on a first run of a workload and high
> > conflict rate on a second run based on how lucky you are with memory
> > allocation placement relative to the first run. Randomization keeps
> > you out of such performance troughs and provides more reliable average
> > performance.
>
> I am not disagreeing here. That reliable average might be worse than
> what you get with the non-randomized case. And that might be a fair
> deal for some workloads. You are, however, providing a functionality
> which is enabled by default without any actual numbers (well except for
> _a_java_ workload that seems to benefit) so you should really do your
> homework stop handwaving and give us some numbers and/or convincing
> arguments please.

The latest version of the patches no longer enable it by default. I'm
giving you the data I can give with respect to pre-production
hardware.

> > With the numa emulation patch I referenced an
> > administrator could constrain a workload to run in a cache-sized
> > subset of the available memory if they really know what they are doing
> > and need firmer guarantees.
>
> Then mention how and what you can achieve by that in the changelog.

The numa_emulation aspect is orthogonal to the randomization
implementation. It does not belong in the randomization changelog.

> > The risk if Linux does not have this capability is unstable hacks like
> > zonesort and rebooting, as referenced in that KNL article, which are
> > not suitable for a general purpose kernel / platform.
>
> We could have lived without those for quite some time so this doesn't
> seem to be anything super urgent to push through without a proper
> justification.

We lived without them previously because memory-side-caches were
limited to niche hardware, now this is moving into general purpose
server platforms and the urgency / impact goes up accordingly.

> > > > > Many years back while at a university I was playing
> > > > > with page coloring as a method to reach a more stable performance
> > > > > results due to reduced cache conflicts. It was not always a performance
> > > > > gain but it definitely allowed for more stable run-to-run comparable
> > > > > results. I can imagine that a randomization might lead to a similar effect
> > > > > although I am not sure how much and it would be more interesting to hear
> > > > > about that effect.
> > > >
> > > > Cache coloring is effective up until your workload no longer fits in
> > > > that color.
> > >
> > > Yes, that was my observation back then more or less. But even when you
> > > do not fit into the cache a color aware strategy (I was playing with bin
> > > hoping as well) produced a more deterministic/stable results. But that
> > > is just a side note as it doesn't directly relate to your change.
> > >
> > > > Randomization helps to attenuate the cache conflict rate
> > > > when that happens.
> > >
> > > I can imagine that. Do we have any numbers to actually back that claim
> > > though?
> > >
> >
> > Yes, 2.5X cache conflict rate reduction, in the change log.
>
> Which is a single benchmark result which is not even described in detail
> to be able to reproduce that measurement. I am sorry for nagging
> here but I would expect something less obscure.

No need to apologize.

> How does this behave for
> usual workloads that we test cache sensitive workloads. I myself am not
> a benchmark person but I am pretty sure there are people who can help
> you to find proper ones to run and evaluate.

I wouldn't pick benchmarks that are cpu-cache sensitive since those
are small number of MBs in size, a memory-side cache is on the order
of 10s of GBs.

>
> > > > For workloads that may fit in the cache, and/or
> > > > environments that need more explicit cache control we have the recent
> > > > changes to numa_emulation [1] to arrange for cache sized numa nodes.
> > >
> > > Could you point me to some more documentation. My google-fu is failing
> > > me and "5.2.27.5 Memory Side Cache Information Structure" doesn't point
> > > to anything official (except for your patch referencing it).
> >
> > http://www.uefi.org/sites/default/files/resources/ACPI%206_2_A_Sept29.pdf
>
> Thanks!
>
> [...]
>
> > > With all that being said, I think the overal idea makes sense but you
> > > should try much harder to explain _why_ we need it and back your
> > > justification by actual _data_ before I would consider my ack.
> >
> > I don't have a known CVE, I only have the ack of people more
> > knowledgeable about security than myself like Kees to say in effect,
> > "yes, this complicates attacks". If you won't take Kees' word for it,
> > I'm not sure what other justification I can present on the security
> > aspect.
>
> In general (nothing against Kees here of course), I prefer a stronger
> justification than "somebody said it will make attacks harder". At least
> my concern about fragmented memory which is not really hard to achieve
> at all should be reasonably clarified. I am fully aware there is no
> absolute measure here but making something harder under ideal conditions
> doesn't really help for common attack strategies which can prepare the
> system into an actual state to exploit allocation predictability. I am
> no expert here but if an attacker can deduce the allocation pattern then
> fragmenting the memory is one easy step to overcome what people would
> consider a security measure.
>
> So color me unconvinced for now.

Another way to attack heap randomization without fragmentation is to
just perform heap spraying and hope that lands the data the attacker
needs in the right place. I still think that allocation entropy > 0 is
positive benefit, but I don't know how to determine the curve of
security benefit relative to shuffle order.

> > 2.5X cache conflict reduction on a Java benchmark workload that the
> > exceeds the cache size by multiple factors is the data I can provide
> > today. Post launch it becomes easier to share more precise data, but
> > that's post 4.20. The hope of course is to have this capability
> > available in an upstream released kernel in advance of wider hardware
> > availability.
>
> I will not comment on timing but in general, any performance related
> changes should come with numbers for a wider variety of workloads.

That's fair.

> In any case, I believe the change itself is not controversial as long it
> is opt-in (potentially autotuned based on specific HW)

Do you mean disable shuffling on systems that don't have a
memory-side-cache unless / until we can devise a security benefit
curve relative to shuffle-order? The former I can do, the latter, I'm
at a loss.

> with a reasonable
> API. And no I do not consider $RANDOM_ORDER a good interface.

I think the current v4 proposal of compile-time setting is reasonable
once we have consensus / guidance on the default shuffle-order.
