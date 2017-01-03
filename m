Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83F4E6B025E
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 05:37:51 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id qs7so56460724wjc.4
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 02:37:51 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id h188si73064869wma.91.2017.01.03.02.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 02:37:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id A576F1C2541
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 10:37:49 +0000 (GMT)
Date: Tue, 3 Jan 2017 10:37:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20170103103749.fjj6uf27wuqvbnta@techsingularity.net>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
 <alpine.DEB.2.10.1612301412390.85559@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612301412390.85559@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 30, 2016 at 02:30:32PM -0800, David Rientjes wrote:
> On Fri, 30 Dec 2016, Mel Gorman wrote:
> 
> > Michal is correct in that my intent for defer was to have "never stall"
> > as the default behaviour.  This was because of the number of severe stalls
> > users experienced that lead to recommendations in tuning guides to always
> > disable THP. I'd also seen multiple instances in bug reports for stalls
> > where it was suggested that THP be disabled even when it could not have
> > been a factor. It would be preferred to keep the default behaviour to
> > avoid reintroducing such bugs.
> > 
> 
> I sympathize with that, I've dealt with a number of issues that we have 
> encountered where thp defrag was either at fault or wasn't, and there were 
> also suggestions to set defrag to "madvise" to rule it out and that 
> impacted other users.
> 
> I'm curious if you could show examples where there were severe stalls 
> being encountered by applications that did madvise(MADV_HUGEPAGE)

I do not have a bug report that is specific to MADV_HUGEPAGE. Until very
recently they would have been masked by THP fault overhead in general.
The current defer logic isn't in the field long enough to generate bugs
that are detailed enough to catch something like this.

> and 
> users were forced to set madvise to "never". 

In the bugs I've dealt with, the switch was between "always" and "never". I
haven't seen a bug specific to "madvise".

> That is, after all, the only 
> topic for consideration in this thread: the direct impact to users of 
> madvise(MADV_HUGEPAGE).  If an application does it, I believe that's a 
> demand for work to be done at allocation time to try to get hugepages.  
> They can certainly provide an application-level option to not do the 
> MADV_HUGEPAGE.  Qemu is no different, you can add options to do 
> madvise(MADV_HUGEPAGE) or not, and you can also do it after fault.
> 

True, it's possible that this is minor hence why I didn't want to outright
Nak the patch.

> The problem with the current option set is that we don't have the ability 
> to trigger background compaction for everybody, which only very minimally 
> impacts their page fault latency since it just wakes up kcompactd, and 
> allow MADV_HUGEPAGE users to accept that up-front cost by doing direct 
> compaction.  My usecase, remapping .text segment and faulting thp memory 
> at startup, demands that ability.  Setting defrag=madvise gets that 
> behavior, but nobody else triggers background compaction when thp memory 
> fails and we _want_ that behavior so work is being done to defrag.  
> Setting defrag=defer makes MADV_HUGEPAGE a no-op for page fault, and I 
> argue that's the wrong behavior.
> 

Again, I accept your reasoning and I don't have direct evidence that it'll be
a problem. In an emergency, it could also be worked around using LD_PRELOAD
or a systemtap script until a kernel fix could be applied. Unfortunately it
could also be years before a patch like this would hit enough users for me
to spot the problem in the field. That's not enough to Nak the patch but
it was enough to suggest an alternative that would side-step the problem
ever occurring.

> > I'll neither ack nor nak this patch. However, I would much prefer an
> > additional option be added to sysfs called defer-fault that would avoid
> > all fault-based stalls but still potentially stall for MADV_HUGEPAGE. I
> > would also prefer that the default option is "defer" for both MADV_HUGEPAGE
> > and faults.
> > 
> 
> If you want a fifth option added to sysfs for thp defrag, that's fine, we 
> can easily do that.  I'm slightly concerned with more and more options 
> added that we will eventually approach the 2^4 option count that I 
> mentioned earlier and nobody will know what to select.  I'm fine with the 
> kernel default remaining as "madvise,"

I find it hard to believe this one *can* explode. There are a limited
number of user-triggable actions that can trigger stalls.

> we will just set it to whatever 
> gets us "direct for madvise, background for everybody else" behavior as we 
> were planning on using "defer."
> 
> We can either do
> 
>  (1) merge this patch and allow madvise(MADV_HUGEPAGE) users to always try
>      to get hugepages, potentially adding options to qemu to suppress 
>      their MADV_HUGEPAGE if users have complained (would even fix the 
>      issue on 2.6 kernels) or do it after majority has been faulted, or
> 
>  (2) add a fifth defrag option to do this suggested behavior and maintain
>      that option forever.
> 
> I'd obviously prefer the former since I consider MADV_HUGEPAGE and not 
> willing to stall as a userspace issue that can _trivially_ be worked 
> around in userspace, but in the interest of moving forward on this we can 
> do the latter if you'd prefer.

The latter is preferred because it prevents any possibility of encountering
this in the field and being unable to workaround it with LD_PRELOAD or
systemtap hackery but I won't nak the former either on the grounds I have
no data it's a problem and it could be a year or more before I have an
example. If it's encountered, we'll be back at introducing another sysfs
option.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
