Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0742D280276
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 06:18:27 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id dh1so7357022wjb.0
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 03:18:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9si31632090wmk.86.2016.12.23.03.18.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 03:18:25 -0800 (PST)
Date: Fri, 23 Dec 2016 12:18:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161223111817.GC23109@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161223085150.GA23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 23-12-16 02:01:33, David Rientjes wrote:
> On Fri, 23 Dec 2016, Michal Hocko wrote:
> 
> > > The offering of defer breaks backwards compatibility with previous 
> > > settings of defrag=madvise, where we could set madvise(MADV_HUGEPAGE) on 
> > > .text segment remap and try to force thp backing if available but not 
> > > directly reclaim for non VM_HUGEPAGE vmas.
> > 
> > I do not understand the backwards compatibility issue part here. Maybe I
> > am missing something but the semantic of defrag=madvise hasn't changed
> > and a new flag can hardly break backward compatibility.
> > 
> 
> We have no way to compact memory for users who are not using 
> MADV_HUGEPAGE,

yes we have. it is defrag=always. If you do not want direct compaction
and the resulting allocation stalls then you have to rely on kcompactd
which is something we should work longterm.

> which is some customers, others require MADV_HUGEPAGE for 
> .text segment remap while loading their binary, without defrag=always or 
> defrag=defer.  The problem is that we want to demand direct compact for 
> MADV_HUGEPAGE: they _really_ want hugepages, it's the point of the 
> madvise.

and that is the point of defrag=madvise to give them this direct
compaction.

> We have no setting, without this patch, to ask for background 
> compaction for everybody so that their fault does not have long latency 
> and for some customers to demand compaction.

that is true and what I am trying to say is that we should aim to give
this background compaction for everybody via kcompactd because there are
more users than THP who might benefit from low latency high order pages
availability. We shouldn't tweak the defer option for that purpose.

> It's a userspace decision, not a kernel decision, and we have lost
> that ability.

I must be missing something but which setting did allow this before?
 
> > > This was very advantageous.  
> > > We prefer that to stay unchanged and allow kcompactd compaction to be 
> > > triggered in background by everybody else as opposed to direct reclaim.  
> > > We do not have that ability without this patch.
> > 
> > So why don't you use defrag=madvise?
> > 
> 
> Um, wtf?  Prior to the patch, we used defrag=always because we do not have 
> low latency option; everybody was forced into it.  Now that we do have 
> the option, we wish to use deferred compaction so that we have opportunity 
> to fault hugepages in near future. We also have userspace apps, and 
> others have database apps, which want hugepages and are ok with any 
> latency.  This should not be a difficult point to understand.  Allow the 
> user to define if they are willing to accept latency with MADV_HUGEPAGE.
> 
> > I disagree. I think the current set of defrag values should be
> > sufficient. We can completely disable direct reclaim, enable it only for
> > opt-in, enable for all and never allow to stall. The advantage of this
> > set of values is that they have _clear_ semantic and behave
> > consistently. If you change defer to "almost never stall except when
> > MADV_HUGEPAGE" then the semantic is less clear. Admin might have a good
> > reason to never allow stalls - especially when he doesn't have a control
> > over the code he is running. Your patch would break this usecase.
> > 
> 
> ?????? Why does the admin care if a user's page fault wants to reclaim to 
> get high order memory?

Because the whole point of the defrag knob is to allow _administrator_
control how much we try to fault in THP. And the primary motivation were
latencies. The whole point of introducing defer option was to _never_
stall in the page fault while it still allows to kick the background
compaction. If you really want to tweak any option then madvise would be
more appropriate IMHO because the semantic would be still clear. Use
direct compaction for MADV_HUGEPAGE vmas and kick in kswapd/kcompactd
for others.

That being said, I understand your usecase and agree that it is useful
to allow background compaction to allow smooth THP deferred allocations
while madvise users can tolerate stalls from the direct compaction. I
just disagree with tweaking defer option to allow for that because I
_believe_ that we should accomplish this in a more generic way and allow
kcompactd to be more configurable and proactive. We definitely need
background compaction for other users than THP. So please try to think
about it some more before sending more wtf replies...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
