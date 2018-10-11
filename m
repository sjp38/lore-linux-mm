Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2907E6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:13:29 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v188-v6so4924760oie.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:13:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l83-v6sor11772030oib.132.2018.10.10.17.13.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 17:13:27 -0700 (PDT)
MIME-Version: 1.0
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074457.GD22173@dhcp22.suse.cz> <CAPcyv4ht=ueiZwPTWuY5Y4y1BUOi_z+pHMjfoiXG+Bjd-h55jA@mail.gmail.com>
 <20181009112216.GM8528@dhcp22.suse.cz> <CAPcyv4gAsyw7Tpp6QKQUA=P3k-Gw=KzutS-PzBiisnxQ1R24gw@mail.gmail.com>
 <20181010084731.GB5873@dhcp22.suse.cz>
In-Reply-To: <20181010084731.GB5873@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 10 Oct 2018 17:13:14 -0700
Message-ID: <CAPcyv4j1QZSk_soYY=xpMiv0exYzdGoa0uqWppSs_dJwF4TPnw@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Oct 10, 2018 at 1:48 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 09-10-18 10:34:55, Dan Williams wrote:
> > On Tue, Oct 9, 2018 at 4:28 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 04-10-18 09:44:35, Dan Williams wrote:
> > > > Hi Michal,
> > > >
> > > > On Thu, Oct 4, 2018 at 12:53 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Wed 03-10-18 19:15:18, Dan Williams wrote:
> > > > > > Changes since v1:
> > > > > > * Add support for shuffling hot-added memory (Andrew)
> > > > > > * Update cover letter and commit message to clarify the performance impact
> > > > > >   and relevance to future platforms
> > > > >
> > > > > I believe this hasn't addressed my questions in
> > > > > http://lkml.kernel.org/r/20181002143015.GX18290@dhcp22.suse.cz. Namely
> > > > > "
> > > > > It is the more general idea that I am not really sure about. First of
> > > > > all. Does it make _any_ sense to randomize 4MB blocks by default? Why
> > > > > cannot we simply have it disabled?
> > > >
> > > > I'm not aware of any CVE that this would directly preclude, but that
> > > > said the entropy injected at 4MB boundaries raises the bar on heap
> > > > attacks. Environments that want more can adjust that with the boot
> > > > parameter. Given the potential benefits I think it would only make
> > > > sense to default disable it if there was a significant runtime impact,
> > > > from what I have seen there isn't.
> > > >
> > > > > Then and more concerning question is,
> > > > > does it even make sense to have this randomization applied to higher
> > > > > orders than 0? Attacker might fragment the memory and keep recycling the
> > > > > lowest order and get the predictable behavior that we have right now.
> > > >
> > > > Certainly I expect there are attacks that can operate within a 4MB
> > > > window, as I expect there are attacks that could operate within a 4K
> > > > window that would need sub-page randomization to deter. In fact I
> > > > believe that is the motivation for CONFIG_SLAB_FREELIST_RANDOM.
> > > > Combining that with page allocator randomization makes the kernel less
> > > > predictable.
> > >
> > > I am sorry but this hasn't explained anything (at least to me). I can
> > > still see a way to bypass this randomization by fragmenting the memory.
> > > With that possibility in place this doesn't really provide the promissed
> > > additional security. So either I am missing something or the per-order
> > > threshold is simply a wrong interface to a broken security misfeature.
> >
> > I think a similar argument can be made against
> > CONFIG_SLAB_FREELIST_RANDOM the randomization benefits can be defeated
> > with more effort, and more effort is the entire point.
>
> If there is relatively simple way to achieve that (which I dunno about
> the slab free list randomization because I am not familiar with the
> implementation) then the feature is indeed questionable. I would
> understand an argument about feasibility if bypassing was extremely hard
> but fragmenting the memory is relatively a simple task.
>
> > > > Is that enough justification for this patch on its own?
> > >
> > > I do not think so from what I have heard so far.
> >
> > I'm missing what bar you are judging the criteria for these patches,
> > my bar is increased protection against allocation ordering attacks as
> > seconded by Kees, and the memory side caching effects.
>
> As said above, if it is quite easy to bypass the randomization then
> calling and advertizing this as a security feature is a dubious. Not
> enough to ouright nak it of course but also not something I would put my
> stamp on. And arguments would be much more solid if they were backed by
> some numbers (not only for the security aspect but also the side caching
> effects).

In fact you don't even need to fragment since you'll have 4MB
contiguous targets by default, but that's not the point. We'll now
have more entropy in the allocation order to compliment the entropy
introduced at the per-SLAB level with CONFIG_SLAB_FREELIST_RANDOM.

...and now that I've made that argument I think I've come around to
your point about the shuffle_page_order parameter. The only entity
that might have a better clue about "safer" shuffle orders than
MAX_ORDER is the distribution provider. I'll cut a v4 to move all of
this under a configuration symbol and make the shuffle order a compile
time setting.

> > That said I
> > don't have a known CVE in my mind that would be mitigated by 4MB page
> > shuffling.
> >
> > > > It's
> > > > debatable. Combine that though with the wider availability of
> > > > platforms with memory-side-cache and I think it's a reasonable default
> > > > behavior for the kernel to deploy.
> > >
> > > OK, this sounds a bit more interesting. I am going to speculate because
> > > memory-side-cache is way too generic of a term for me to imagine
> > > anything specific.
> >
> > No need to imagine, a memory side cache shipped on a previous product
> > as Robert linked in his comments.
>
> Could you make this a part of the changelog? I would really appreciate
> to see justification based on actual numbers rather than quite hand wavy
> "it helps".

I put in the changelog that these patches reduced the cache conflict
rate by 2.5X on a Java benchmark. I specifically did not put KNL data
directly into the changelog because that is not a general purpose
server platform.

Note, you can also think about this just on pure architecture terms.
I.e. that for a direct mapped cache anywhere in a system you can have
a near zero cache conflict rate on a first run of a workload and high
conflict rate on a second run based on how lucky you are with memory
allocation placement relative to the first run. Randomization keeps
you out of such performance troughs and provides more reliable average
performance.  With the numa emulation patch I referenced an
administrator could constrain a workload to run in a cache-sized
subset of the available memory if they really know what they are doing
and need firmer guarantees.

The risk if Linux does not have this capability is unstable hacks like
zonesort and rebooting, as referenced in that KNL article, which are
not suitable for a general purpose kernel / platform.

> > > Many years back while at a university I was playing
> > > with page coloring as a method to reach a more stable performance
> > > results due to reduced cache conflicts. It was not always a performance
> > > gain but it definitely allowed for more stable run-to-run comparable
> > > results. I can imagine that a randomization might lead to a similar effect
> > > although I am not sure how much and it would be more interesting to hear
> > > about that effect.
> >
> > Cache coloring is effective up until your workload no longer fits in
> > that color.
>
> Yes, that was my observation back then more or less. But even when you
> do not fit into the cache a color aware strategy (I was playing with bin
> hoping as well) produced a more deterministic/stable results. But that
> is just a side note as it doesn't directly relate to your change.
>
> > Randomization helps to attenuate the cache conflict rate
> > when that happens.
>
> I can imagine that. Do we have any numbers to actually back that claim
> though?
>

Yes, 2.5X cache conflict rate reduction, in the change log.

> > For workloads that may fit in the cache, and/or
> > environments that need more explicit cache control we have the recent
> > changes to numa_emulation [1] to arrange for cache sized numa nodes.
>
> Could you point me to some more documentation. My google-fu is failing
> me and "5.2.27.5 Memory Side Cache Information Structure" doesn't point
> to anything official (except for your patch referencing it).

http://www.uefi.org/sites/default/files/resources/ACPI%206_2_A_Sept29.pdf

>
> > > If this is really the case then I would assume on/off
> > > knob to control the randomization without something as specific as
> > > order.
> >
> > Are we only debating the enabling knob at this point? I'm not opposed
> > to changing that, but I do think we want to keep the rest of the
> > infrastructure to allow for shuffling on a variable page size boundary
> > in case there is enhanced security benefits at smaller buddy-page
> > sizes.
>
> I am still trying to understand the benefit of this change. If the
> caching effects are actually the most important part and there is a
> reasonable cut in allocation order to keep the randomization effective
> during the runtime then I would like to understand the thinking behind
> that. In other words does the randomization at smaller orders than
> biggest order still visible in actual benchmarks? If not then on/off
> knob should be sufficient with potential auto tuning based on actual HW
> rather than to expect poor admin to google for $RANDOM_ORDER to use on a
> specific HW and all the potential cargo cult that will grow around it.

So, I've come around to your viewpoint on this. Especially when we
have CONFIG_SLAB_FREELIST_RANDOM the security benefit of smaller than
MAX_ORDER shuffling is hard to justify and likely does not need kernel
parameter based control.

> As I've said before, I am not convinced about the security argument but
> even if I am wrong here then I am still quite sure that you do not want
> to expose the security aspect as "chose an order to randomize from"
> because admins will have no real way to know what is the $RANDOM_ORDER
> to set. So even then it should be on/off thing. You are going to pay
> some of the performance because you would lose some page allocator
> optimizations (e.g. pcp lists) but that is unavoidable AFAICS.
>
> With all that being said, I think the overal idea makes sense but you
> should try much harder to explain _why_ we need it and back your
> justification by actual _data_ before I would consider my ack.

I don't have a known CVE, I only have the ack of people more
knowledgeable about security than myself like Kees to say in effect,
"yes, this complicates attacks". If you won't take Kees' word for it,
I'm not sure what other justification I can present on the security
aspect.

2.5X cache conflict reduction on a Java benchmark workload that the
exceeds the cache size by multiple factors is the data I can provide
today. Post launch it becomes easier to share more precise data, but
that's post 4.20. The hope of course is to have this capability
available in an upstream released kernel in advance of wider hardware
availability.
