Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57AA06B000A
	for <linux-mm@kvack.org>; Sat,  6 Oct 2018 13:01:34 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n23-v6so11750349otl.2
        for <linux-mm@kvack.org>; Sat, 06 Oct 2018 10:01:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20-v6sor4630518oic.57.2018.10.06.10.01.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Oct 2018 10:01:30 -0700 (PDT)
MIME-Version: 1.0
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074457.GD22173@dhcp22.suse.cz> <CAPcyv4ht=ueiZwPTWuY5Y4y1BUOi_z+pHMjfoiXG+Bjd-h55jA@mail.gmail.com>
In-Reply-To: <CAPcyv4ht=ueiZwPTWuY5Y4y1BUOi_z+pHMjfoiXG+Bjd-h55jA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 6 Oct 2018 10:01:17 -0700
Message-ID: <CAPcyv4jKGJLGqTHbxPvSD0X=kNGce-iJCYvTHJA8x2JSST5ETQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Oct 4, 2018 at 9:44 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Hi Michal,
>
> On Thu, Oct 4, 2018 at 12:53 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 03-10-18 19:15:18, Dan Williams wrote:
> > > Changes since v1:
> > > * Add support for shuffling hot-added memory (Andrew)
> > > * Update cover letter and commit message to clarify the performance impact
> > >   and relevance to future platforms
> >
> > I believe this hasn't addressed my questions in
> > http://lkml.kernel.org/r/20181002143015.GX18290@dhcp22.suse.cz. Namely
> > "
> > It is the more general idea that I am not really sure about. First of
> > all. Does it make _any_ sense to randomize 4MB blocks by default? Why
> > cannot we simply have it disabled?
>
> I'm not aware of any CVE that this would directly preclude, but that
> said the entropy injected at 4MB boundaries raises the bar on heap
> attacks. Environments that want more can adjust that with the boot
> parameter. Given the potential benefits I think it would only make
> sense to default disable it if there was a significant runtime impact,
> from what I have seen there isn't.
>
> > Then and more concerning question is,
> > does it even make sense to have this randomization applied to higher
> > orders than 0? Attacker might fragment the memory and keep recycling the
> > lowest order and get the predictable behavior that we have right now.
>
> Certainly I expect there are attacks that can operate within a 4MB
> window, as I expect there are attacks that could operate within a 4K
> window that would need sub-page randomization to deter. In fact I
> believe that is the motivation for CONFIG_SLAB_FREELIST_RANDOM.
> Combining that with page allocator randomization makes the kernel less
> predictable.
>
> Is that enough justification for this patch on its own? It's
> debatable. Combine that though with the wider availability of
> platforms with memory-side-cache and I think it's a reasonable default
> behavior for the kernel to deploy.

Hi Michal,

Does the above address your concerns? v4.20 is perhaps the last
upstream kernel release in advance of wider hardware availability.
