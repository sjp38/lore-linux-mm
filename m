Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6A86B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 07:36:35 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so98383731wjc.2
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:36:35 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id ju1si62164595wjc.128.2016.12.30.04.36.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 04:36:34 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 6FA031DC01D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 12:36:33 +0000 (UTC)
Date: Fri, 30 Dec 2016 12:36:20 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 22, 2016 at 01:05:27PM -0800, David Rientjes wrote:
> On Thu, 22 Dec 2016, Michal Hocko wrote:
> 
> > > Currently, when defrag is set to "madvise", thp allocations will direct
> > > reclaim.  However, when defrag is set to "defer", all thp allocations do
> > > not attempt reclaim regardless of MADV_HUGEPAGE.
> > > 
> > > This patch always directly reclaims for MADV_HUGEPAGE regions when defrag
> > > is not set to "never."  The idea is that MADV_HUGEPAGE regions really
> > > want to be backed by hugepages and are willing to endure the latency at
> > > fault as it was the default behavior prior to commit 444eb2a449ef ("mm:
> > > thp: set THP defrag by default to madvise and add a stall-free defrag
> > > option").
> > 
> > AFAIR "defer" is implemented exactly as intended. To offer a never-stall
> > but allow to form THP in the background option. The patch description
> > doesn't explain why this is not good anymore. Could you give us more
> > details about the motivation and why "madvise" doesn't work for
> > you? This is a user visible change so the reason should better be really
> > documented and strong.
> > 
> 

I ended up not reading this whole thread in detail because it went back
and forth a lot.

Michal is correct in that my intent for defer was to have "never stall"
as the default behaviour.  This was because of the number of severe stalls
users experienced that lead to recommendations in tuning guides to always
disable THP. I'd also seen multiple instances in bug reports for stalls
where it was suggested that THP be disabled even when it could not have
been a factor. It would be preferred to keep the default behaviour to
avoid reintroducing such bugs.

That said;

> The offering of defer breaks backwards compatibility with previous 
> settings of defrag=madvise, where we could set madvise(MADV_HUGEPAGE) on 
> .text segment remap and try to force thp backing if available but not 
> directly reclaim for non VM_HUGEPAGE vmas.  This was very advantageous.  
> We prefer that to stay unchanged and allow kcompactd compaction to be 
> triggered in background by everybody else as opposed to direct reclaim.  
> We do not have that ability without this patch.
> 

I accept the reasoning that applications that use MADV_HUGEPAGE really
want huge pages and may be willing to incur a large stall to get them.
It's impossible for the kernel to know in all cases which behaviour is
desirable so something is needed.

> Without this patch, we will be forced to offer multiple sysfs tunables to 
> define (1) direct vs background compact, (2) madvise behavior, (3) always, 
> (4) never and we cannot have 2^4 settings for "defrag" alone.

In itself, I don't see this as a bad thing. I won't nak the patch as-is
although I consider it unfortunate and worry that we'll see bugs again about
slow start times for qemu (the most common application I'm aware of that
uses MADV_HUGEPAGE). If that happens, we'd be forced to have a workaround
like a systemtap script that intercepted MADV_HUGEPAGE and stripped it
or LD_PRELOAD if a specific application can be controlled.

I'll neither ack nor nak this patch. However, I would much prefer an
additional option be added to sysfs called defer-fault that would avoid
all fault-based stalls but still potentially stall for MADV_HUGEPAGE. I
would also prefer that the default option is "defer" for both MADV_HUGEPAGE
and faults.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
