Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44C486B02D0
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 03:51:56 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so39966082wmu.1
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 00:51:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si4117704wjx.186.2016.12.23.00.51.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 00:51:54 -0800 (PST)
Date: Fri, 23 Dec 2016 09:51:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161223085150.GA23109@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 22-12-16 13:05:27, David Rientjes wrote:
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
> The offering of defer breaks backwards compatibility with previous 
> settings of defrag=madvise, where we could set madvise(MADV_HUGEPAGE) on 
> .text segment remap and try to force thp backing if available but not 
> directly reclaim for non VM_HUGEPAGE vmas.

I do not understand the backwards compatibility issue part here. Maybe I
am missing something but the semantic of defrag=madvise hasn't changed
and a new flag can hardly break backward compatibility.

> This was very advantageous.  
> We prefer that to stay unchanged and allow kcompactd compaction to be 
> triggered in background by everybody else as opposed to direct reclaim.  
> We do not have that ability without this patch.

So why don't you use defrag=madvise?

> Without this patch, we will be forced to offer multiple sysfs tunables to 
> define (1) direct vs background compact, (2) madvise behavior, (3) always, 
> (4) never and we cannot have 2^4 settings for "defrag" alone.

I disagree. I think the current set of defrag values should be
sufficient. We can completely disable direct reclaim, enable it only for
opt-in, enable for all and never allow to stall. The advantage of this
set of values is that they have _clear_ semantic and behave
consistently. If you change defer to "almost never stall except when
MADV_HUGEPAGE" then the semantic is less clear. Admin might have a good
reason to never allow stalls - especially when he doesn't have a control
over the code he is running. Your patch would break this usecase.

If we want to provide a better background THP availability we should
focus more on kcompactd and the way how it is invoked. Currently we only
wake it up during the page allocation path. Long term we want to make it
more watermak based I believe. Similar to kswapd. Vlastimil is already
playing with this idea. I would prefer such a long term plan more than
tweaking THP configuration.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
