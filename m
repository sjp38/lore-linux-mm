Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9E86B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 22:25:11 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id l92so2219045otc.12
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 19:25:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v95sor1651208ota.33.2018.10.12.19.25.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 19:25:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181013021057.GA213522@joelaf.mtv.corp.google.com>
References: <20181012013756.11285-2-joel@joelfernandes.org>
 <20181012113056.gxhcbrqyu7k7xnyv@kshutemo-mobl1> <20181012125046.GA170912@joelaf.mtv.corp.google.com>
 <20181012.111836.1569129998592378186.davem@davemloft.net> <20181013013540.GA207108@joelaf.mtv.corp.google.com>
 <CAKOZueuNvWvn18vffJWpbpg7h-uScT8gXrrudTB2pnT4M2HJ_w@mail.gmail.com>
 <20181013014429.GB207108@joelaf.mtv.corp.google.com> <CAKOZues25aaKz3_AiyfJ=r2QBd5MghgY3ky_ptg4Z8=ST4DCgw@mail.gmail.com>
 <20181013021057.GA213522@joelaf.mtv.corp.google.com>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 12 Oct 2018 19:25:08 -0700
Message-ID: <CAKOZueu2wdkeUFYLQ8qE48yJs1_uRz-9RVJRkp==CL=jp=Q8+g@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: David Miller <davem@davemloft.net>, kirill@shutemov.name, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@android.com, Minchan Kim <minchan@kernel.org>, Ramon Pantin <pantin@google.com>, Hugh Dickins <hughd@google.com>, Lokesh Gidra <lokeshgidra@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, aryabinin@virtuozzo.com, luto@kernel.org, bp@alien8.de, catalin.marinas@arm.com, Chris Zankel <chris@zankel.net>, dave.hansen@linux.intel.com, elfring@users.sourceforge.net, fenghua.yu@intel.com, geert@linux-m68k.org, gxt@pku.edu.cn, deller@gmx.de, mingo@redhat.com, jejb@parisc-linux.org, jdike@addtoit.com, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, lftan@altera.com, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm <linux-mm@kvack.org>, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Max Filippov <jcmvbkbc@gmail.com>, nios2-dev@lists.rocketboards.org, Peter Zijlstra <peterz@infradead.org>, richard@nod.at

On Fri, Oct 12, 2018 at 7:10 PM, Joel Fernandes <joel@joelfernandes.org> wrote:
> On Fri, Oct 12, 2018 at 06:54:33PM -0700, Daniel Colascione wrote:
>> I wonder whether it makes sense to expose to userspace somehow whether
>> mremap is "fast" for a particular architecture. If a feature relies on
>> fast mremap, it might be better for some userland component to disable
>> that feature entirely rather than blindly use mremap and end up
>> performing very poorly. If we're disabling fast mremap when THP is
>> enabled, the userland component can't just rely on an architecture
>> switch and some kind of runtime feature detection becomes even more
>> important.
>
> I hate to point out that its forbidden to top post on LKML :-)
> https://kernelnewbies.org/mailinglistguidelines
> So don't that Mr. Dan! :D

Guilty as charged. I really should switch back to Gnus. :-)

> But anyway, I think this runtime detection thing is not needed. THP is
> actually expected to be as fast as this anyway, so if that's available then
> we should already be as fast.

Ah, I think the commit message is confusing. (Or else I'm misreading
the patch now.) It's not quite that we're disabling the feature when
THP is enabled anywhere, but rather that we use the move_huge_pmd path
for huge PMDs and use the new code only for non-huge PMDs. (Right?) If
that's the case, the commit message shouldn't say "Incase THP is
enabled, the optimization is skipped". Even if THP is enabled on a
system generally, we might use the new PMD-moving code for mapping
types that don't support THP-ization, right?

> This is for non-THP where THP cannot be enabled
> and there is still room for some improvement. Most/all architectures will be
> just fine with this. This flag is more of a safety-net type of thing where in
> the future if there is this one or two weird architectures that don't play
> well, then they can turn it off at the architecture level by not selecting
> the flag. See my latest patches for the per-architecture compile-time
> controls. Ideally we'd like to blanket turn it on on all, but this is just
> playing it extra safe as Kirill and me were discussing on other threads.

Sure. I'm just pointing out that the 500x performance different turns
the operation into a qualitatively different feature, so if we expect
to actually ship a mainstream architecture without support for this
thing, we should make it explicit. If we're not, we shouldn't.
