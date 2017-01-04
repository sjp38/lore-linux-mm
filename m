Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3BF6B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:12:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so83093953wmw.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:12:21 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id k2si77314646wmg.13.2017.01.04.02.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 02:12:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 7EF281C1C5B
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 10:12:19 +0000 (GMT)
Date: Wed, 4 Jan 2017 10:12:18 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20170104101218.x7c5pwf65psy2l52@techsingularity.net>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
 <alpine.DEB.2.10.1612301412390.85559@chino.kir.corp.google.com>
 <20170103103749.fjj6uf27wuqvbnta@techsingularity.net>
 <alpine.DEB.2.10.1701031334020.131960@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701031334020.131960@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 03, 2017 at 01:57:33PM -0800, David Rientjes wrote:
> On Tue, 3 Jan 2017, Mel Gorman wrote:
> 
> > > I sympathize with that, I've dealt with a number of issues that we have 
> > > encountered where thp defrag was either at fault or wasn't, and there were 
> > > also suggestions to set defrag to "madvise" to rule it out and that 
> > > impacted other users.
> > > 
> > > I'm curious if you could show examples where there were severe stalls 
> > > being encountered by applications that did madvise(MADV_HUGEPAGE)
> > 
> > I do not have a bug report that is specific to MADV_HUGEPAGE. Until very
> > recently they would have been masked by THP fault overhead in general.
> 
> I parse this, the masking of thp fault overhead in general, as an 
> indication that the qemu user was using defrag set to "always" rather than 
> the new kernel default of "madvise".
> 

There is a slight disconnect. The bug reports I'm aware of predate the
introduction of "defer" and the current "madvise" semantics for defrag. The
current semantics have not had enough time in the field to generate
reports. I expect lag before users are aware of "defer" due to the number
of recommendations out there about blindly disabling THP.  This because
the majority of users I deal with are not running mainline kernels.

> <SNIP>
>
> Qemu can be fixed, and I'll do it myself if necessary, when allocating a 
> new RAMBlock or translation buffer to suppress the MADV_HUGEPAGE if 
> configured.  It's a very trivial change, and I can do that if you'll 
> kindly point me to the initial bug report so I can propose it to the 
> appropriate user.
> 

I don't have a QEMU-related bug to point to. Even if I did, it would be
an enterprise distribution bug that isn't public. My expectation is that
if I get a bug, that it's going to be QEMU-related but I'm guessing.

> As Vlastimil also correctly brings up, there is already a 
> prctl(PR_SET_THP_DISABLE) option available to prevent hugepages at fault 
> and simply requires you to fork the process in the correct context to 
> inherit the vma setting, see commit 1e1836e84f87.
> 

That disables everything and functionally similar to disabling THP.

> > The current defer logic isn't in the field long enough to generate bugs
> > that are detailed enough to catch something like this.
> > 
> 
> Let us consider this email as a generating a bug that we, the users of 
> MADV_HUGEPAGE that are using the madvise(2) correctly and add flags to 
> suppress it when desired correctly, have no option to allow background 
> compaction for everybody when we cannot allocate thp immediately but also 
> allow users of our library to accept the cost of direct compaction at 
> fault because they really want their .text segment remapped and backed by 
> hugepages.
> 

Again, I accept that. A new option for the semantics you want instead
of adjusting the existing "defer" semantics is preferred to give the
"more heavyweight version of madvise" you're looking for. This is simply
because it's easier to resolve in the field when users are not always that
knowledgable and are typically reluctant to modify application launching
but usually open to adjusting kernel tunables.

> > > The problem with the current option set is that we don't have the ability 
> > > to trigger background compaction for everybody, which only very minimally 
> > > impacts their page fault latency since it just wakes up kcompactd, and 
> > > allow MADV_HUGEPAGE users to accept that up-front cost by doing direct 
> > > compaction.  My usecase, remapping .text segment and faulting thp memory 
> > > at startup, demands that ability.  Setting defrag=madvise gets that 
> > > behavior, but nobody else triggers background compaction when thp memory 
> > > fails and we _want_ that behavior so work is being done to defrag.  
> > > Setting defrag=defer makes MADV_HUGEPAGE a no-op for page fault, and I 
> > > argue that's the wrong behavior.
> > > 
> > 
> > Again, I accept your reasoning and I don't have direct evidence that it'll be
> > a problem. In an emergency, it could also be worked around using LD_PRELOAD
> > or a systemtap script until a kernel fix could be applied. Unfortunately it
> > could also be years before a patch like this would hit enough users for me
> > to spot the problem in the field. That's not enough to Nak the patch but
> > it was enough to suggest an alternative that would side-step the problem
> > ever occurring.
> > 
> 
> Or simply forking the application after doing prctl(PR_SET_THP_DISABLE)?  
> What exactly are you working around with a LD_PRELOAD that isn't addressed 
> by this?
> 

LD_PRELOAD can mask the MADV flag for get the existing "defer"
semantics. Disabling THP entirely is something else.

> Btw, is there a qemu bug filed that makes doing the MADV_HUGEPAGE 
> configurable?  I don't find it at https://bugs.launchpad.net/qemu.
> 

Not that I'm aware of but I didn't go looking either.

> > > If you want a fifth option added to sysfs for thp defrag, that's fine, we 
> > > can easily do that.  I'm slightly concerned with more and more options 
> > > added that we will eventually approach the 2^4 option count that I 
> > > mentioned earlier and nobody will know what to select.  I'm fine with the 
> > > kernel default remaining as "madvise,"
> > 
> > I find it hard to believe this one *can* explode. There are a limited
> > number of user-triggable actions that can trigger stalls.
> > 
> 
> I'm confused as to whether you support the addition of a fifth option that 
> users will have to learn what they want, or whether you are open to 
> changing the behavior of "defer" to actually respect userspace madvise(2)?

I would prefer the fifth option and have users select the option if they
need it and preserve the existing semantics of defer. However, as I've
stated before, as I'm not actually aware of problems with madvise and the
current semantics so I cannot nak the patch you have. It'll simply require
to have some solution in mind if a bug is encountered. When THP was first
introduced, it was months before users started reporting bugs as most users
I deal with are not running mainline kernels. There was similar lag when
automatic NUMA balancing was introduced. I expect a similar lag for the
existing "madvise" default and some education about using "defer" instead
of disabling THP entirely when stalls are encountered. It's the hazard of
dealing with users that lag behind mainline and it's not a unique problem.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
