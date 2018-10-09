Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78CFF6B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 13:35:09 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id b202-v6so1523511oii.23
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 10:35:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24sor10468033otd.21.2018.10.09.10.35.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 10:35:07 -0700 (PDT)
MIME-Version: 1.0
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074457.GD22173@dhcp22.suse.cz> <CAPcyv4ht=ueiZwPTWuY5Y4y1BUOi_z+pHMjfoiXG+Bjd-h55jA@mail.gmail.com>
 <20181009112216.GM8528@dhcp22.suse.cz>
In-Reply-To: <20181009112216.GM8528@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Oct 2018 10:34:55 -0700
Message-ID: <CAPcyv4gAsyw7Tpp6QKQUA=P3k-Gw=KzutS-PzBiisnxQ1R24gw@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Oct 9, 2018 at 4:28 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 04-10-18 09:44:35, Dan Williams wrote:
> > Hi Michal,
> >
> > On Thu, Oct 4, 2018 at 12:53 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 03-10-18 19:15:18, Dan Williams wrote:
> > > > Changes since v1:
> > > > * Add support for shuffling hot-added memory (Andrew)
> > > > * Update cover letter and commit message to clarify the performance impact
> > > >   and relevance to future platforms
> > >
> > > I believe this hasn't addressed my questions in
> > > http://lkml.kernel.org/r/20181002143015.GX18290@dhcp22.suse.cz. Namely
> > > "
> > > It is the more general idea that I am not really sure about. First of
> > > all. Does it make _any_ sense to randomize 4MB blocks by default? Why
> > > cannot we simply have it disabled?
> >
> > I'm not aware of any CVE that this would directly preclude, but that
> > said the entropy injected at 4MB boundaries raises the bar on heap
> > attacks. Environments that want more can adjust that with the boot
> > parameter. Given the potential benefits I think it would only make
> > sense to default disable it if there was a significant runtime impact,
> > from what I have seen there isn't.
> >
> > > Then and more concerning question is,
> > > does it even make sense to have this randomization applied to higher
> > > orders than 0? Attacker might fragment the memory and keep recycling the
> > > lowest order and get the predictable behavior that we have right now.
> >
> > Certainly I expect there are attacks that can operate within a 4MB
> > window, as I expect there are attacks that could operate within a 4K
> > window that would need sub-page randomization to deter. In fact I
> > believe that is the motivation for CONFIG_SLAB_FREELIST_RANDOM.
> > Combining that with page allocator randomization makes the kernel less
> > predictable.
>
> I am sorry but this hasn't explained anything (at least to me). I can
> still see a way to bypass this randomization by fragmenting the memory.
> With that possibility in place this doesn't really provide the promissed
> additional security. So either I am missing something or the per-order
> threshold is simply a wrong interface to a broken security misfeature.

I think a similar argument can be made against
CONFIG_SLAB_FREELIST_RANDOM the randomization benefits can be defeated
with more effort, and more effort is the entire point.

> > Is that enough justification for this patch on its own?
>
> I do not think so from what I have heard so far.

I'm missing what bar you are judging the criteria for these patches,
my bar is increased protection against allocation ordering attacks as
seconded by Kees, and the memory side caching effects. That said I
don't have a known CVE in my mind that would be mitigated by 4MB page
shuffling.

> > It's
> > debatable. Combine that though with the wider availability of
> > platforms with memory-side-cache and I think it's a reasonable default
> > behavior for the kernel to deploy.
>
> OK, this sounds a bit more interesting. I am going to speculate because
> memory-side-cache is way too generic of a term for me to imagine
> anything specific.

No need to imagine, a memory side cache shipped on a previous product
as Robert linked in his comments.

> Many years back while at a university I was playing
> with page coloring as a method to reach a more stable performance
> results due to reduced cache conflicts. It was not always a performance
> gain but it definitely allowed for more stable run-to-run comparable
> results. I can imagine that a randomization might lead to a similar effect
> although I am not sure how much and it would be more interesting to hear
> about that effect.

Cache coloring is effective up until your workload no longer fits in
that color. Randomization helps to attenuate the cache conflict rate
when that happens. For workloads that may fit in the cache, and/or
environments that need more explicit cache control we have the recent
changes to numa_emulation [1] to arrange for cache sized numa nodes.

> If this is really the case then I would assume on/off
> knob to control the randomization without something as specific as
> order.

Are we only debating the enabling knob at this point? I'm not opposed
to changing that, but I do think we want to keep the rest of the
infrastructure to allow for shuffling on a variable page size boundary
in case there is enhanced security benefits at smaller buddy-page
sizes.

[1]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cc9aec03e58f
