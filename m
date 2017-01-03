Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6E46B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 16:57:39 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so1356622419pgc.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:57:39 -0800 (PST)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id 64si70265795ply.171.2017.01.03.13.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 13:57:38 -0800 (PST)
Received: by mail-pg0-x22b.google.com with SMTP id i5so154190602pgh.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:57:38 -0800 (PST)
Date: Tue, 3 Jan 2017 13:57:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20170103103749.fjj6uf27wuqvbnta@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1701031334020.131960@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
 <alpine.DEB.2.10.1612301412390.85559@chino.kir.corp.google.com> <20170103103749.fjj6uf27wuqvbnta@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 3 Jan 2017, Mel Gorman wrote:

> > I sympathize with that, I've dealt with a number of issues that we have 
> > encountered where thp defrag was either at fault or wasn't, and there were 
> > also suggestions to set defrag to "madvise" to rule it out and that 
> > impacted other users.
> > 
> > I'm curious if you could show examples where there were severe stalls 
> > being encountered by applications that did madvise(MADV_HUGEPAGE)
> 
> I do not have a bug report that is specific to MADV_HUGEPAGE. Until very
> recently they would have been masked by THP fault overhead in general.

I parse this, the masking of thp fault overhead in general, as an 
indication that the qemu user was using defrag set to "always" rather than 
the new kernel default of "madvise".

I wholeheartedly agree that we don't want defrag to be set to "always" be 
default, but that's not really a huge concern: we can easily set it to 
anything else by initscripts.

Qemu, when they added the MADV_HUGEPAGE, obviously wanted to try to 
allocate hugepages at fault using the available means when defrag was set 
to "madvise": https://patchwork.ozlabs.org/patch/177695

So now qemu notices no difference that the kernel default has changed, but 
you later reference qemu in your email about bugs concerning "slow start 
times."  It's puzzling unless you're offering a defrag setting of "defer" 
to workaround this potential bug report, which affects the whole machine 
and now qemu users have _no_ option to try to get thp at fault because the 
admin thinks he knows better, essentially making MADV_HUGEPAGE a no-op 
with no alternative provided.  That's specifically what I'm arguing 
against.

Qemu can be fixed, and I'll do it myself if necessary, when allocating a 
new RAMBlock or translation buffer to suppress the MADV_HUGEPAGE if 
configured.  It's a very trivial change, and I can do that if you'll 
kindly point me to the initial bug report so I can propose it to the 
appropriate user.

As Vlastimil also correctly brings up, there is already a 
prctl(PR_SET_THP_DISABLE) option available to prevent hugepages at fault 
and simply requires you to fork the process in the correct context to 
inherit the vma setting, see commit 1e1836e84f87.

> The current defer logic isn't in the field long enough to generate bugs
> that are detailed enough to catch something like this.
> 

Let us consider this email as a generating a bug that we, the users of 
MADV_HUGEPAGE that are using the madvise(2) correctly and add flags to 
suppress it when desired correctly, have no option to allow background 
compaction for everybody when we cannot allocate thp immediately but also 
allow users of our library to accept the cost of direct compaction at 
fault because they really want their .text segment remapped and backed by 
hugepages.

> > The problem with the current option set is that we don't have the ability 
> > to trigger background compaction for everybody, which only very minimally 
> > impacts their page fault latency since it just wakes up kcompactd, and 
> > allow MADV_HUGEPAGE users to accept that up-front cost by doing direct 
> > compaction.  My usecase, remapping .text segment and faulting thp memory 
> > at startup, demands that ability.  Setting defrag=madvise gets that 
> > behavior, but nobody else triggers background compaction when thp memory 
> > fails and we _want_ that behavior so work is being done to defrag.  
> > Setting defrag=defer makes MADV_HUGEPAGE a no-op for page fault, and I 
> > argue that's the wrong behavior.
> > 
> 
> Again, I accept your reasoning and I don't have direct evidence that it'll be
> a problem. In an emergency, it could also be worked around using LD_PRELOAD
> or a systemtap script until a kernel fix could be applied. Unfortunately it
> could also be years before a patch like this would hit enough users for me
> to spot the problem in the field. That's not enough to Nak the patch but
> it was enough to suggest an alternative that would side-step the problem
> ever occurring.
> 

Or simply forking the application after doing prctl(PR_SET_THP_DISABLE)?  
What exactly are you working around with a LD_PRELOAD that isn't addressed 
by this?

Btw, is there a qemu bug filed that makes doing the MADV_HUGEPAGE 
configurable?  I don't find it at https://bugs.launchpad.net/qemu.

> > If you want a fifth option added to sysfs for thp defrag, that's fine, we 
> > can easily do that.  I'm slightly concerned with more and more options 
> > added that we will eventually approach the 2^4 option count that I 
> > mentioned earlier and nobody will know what to select.  I'm fine with the 
> > kernel default remaining as "madvise,"
> 
> I find it hard to believe this one *can* explode. There are a limited
> number of user-triggable actions that can trigger stalls.
> 

I'm confused as to whether you support the addition of a fifth option that 
users will have to learn what they want, or whether you are open to 
changing the behavior of "defer" to actually respect userspace madvise(2)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
