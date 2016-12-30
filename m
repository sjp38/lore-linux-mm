Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6027C6B025E
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 17:30:35 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id n189so681482061pga.4
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 14:30:35 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id c128si58211834pfb.26.2016.12.30.14.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Dec 2016 14:30:34 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id y62so129258227pgy.1
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 14:30:34 -0800 (PST)
Date: Fri, 30 Dec 2016 14:30:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1612301412390.85559@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 Dec 2016, Mel Gorman wrote:

> Michal is correct in that my intent for defer was to have "never stall"
> as the default behaviour.  This was because of the number of severe stalls
> users experienced that lead to recommendations in tuning guides to always
> disable THP. I'd also seen multiple instances in bug reports for stalls
> where it was suggested that THP be disabled even when it could not have
> been a factor. It would be preferred to keep the default behaviour to
> avoid reintroducing such bugs.
> 

I sympathize with that, I've dealt with a number of issues that we have 
encountered where thp defrag was either at fault or wasn't, and there were 
also suggestions to set defrag to "madvise" to rule it out and that 
impacted other users.

I'm curious if you could show examples where there were severe stalls 
being encountered by applications that did madvise(MADV_HUGEPAGE) and 
users were forced to set madvise to "never".  That is, after all, the only 
topic for consideration in this thread: the direct impact to users of 
madvise(MADV_HUGEPAGE).  If an application does it, I believe that's a 
demand for work to be done at allocation time to try to get hugepages.  
They can certainly provide an application-level option to not do the 
MADV_HUGEPAGE.  Qemu is no different, you can add options to do 
madvise(MADV_HUGEPAGE) or not, and you can also do it after fault.

The problem with the current option set is that we don't have the ability 
to trigger background compaction for everybody, which only very minimally 
impacts their page fault latency since it just wakes up kcompactd, and 
allow MADV_HUGEPAGE users to accept that up-front cost by doing direct 
compaction.  My usecase, remapping .text segment and faulting thp memory 
at startup, demands that ability.  Setting defrag=madvise gets that 
behavior, but nobody else triggers background compaction when thp memory 
fails and we _want_ that behavior so work is being done to defrag.  
Setting defrag=defer makes MADV_HUGEPAGE a no-op for page fault, and I 
argue that's the wrong behavior.

> I'll neither ack nor nak this patch. However, I would much prefer an
> additional option be added to sysfs called defer-fault that would avoid
> all fault-based stalls but still potentially stall for MADV_HUGEPAGE. I
> would also prefer that the default option is "defer" for both MADV_HUGEPAGE
> and faults.
> 

If you want a fifth option added to sysfs for thp defrag, that's fine, we 
can easily do that.  I'm slightly concerned with more and more options 
added that we will eventually approach the 2^4 option count that I 
mentioned earlier and nobody will know what to select.  I'm fine with the 
kernel default remaining as "madvise," we will just set it to whatever 
gets us "direct for madvise, background for everybody else" behavior as we 
were planning on using "defer."

We can either do

 (1) merge this patch and allow madvise(MADV_HUGEPAGE) users to always try
     to get hugepages, potentially adding options to qemu to suppress 
     their MADV_HUGEPAGE if users have complained (would even fix the 
     issue on 2.6 kernels) or do it after majority has been faulted, or

 (2) add a fifth defrag option to do this suggested behavior and maintain
     that option forever.

I'd obviously prefer the former since I consider MADV_HUGEPAGE and not 
willing to stall as a userspace issue that can _trivially_ be worked 
around in userspace, but in the interest of moving forward on this we can 
do the latter if you'd prefer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
