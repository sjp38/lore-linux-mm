Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 754326B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 16:36:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id n189so446199923pga.4
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 13:36:57 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id b69si47693162pli.222.2016.12.27.13.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 13:36:56 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id y62so96424641pgy.1
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 13:36:56 -0800 (PST)
Date: Tue, 27 Dec 2016 13:36:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20161227094008.GC1308@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1612271324300.67790@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161223085150.GA23109@dhcp22.suse.cz> <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz> <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com> <20161226090211.GA11455@dhcp22.suse.cz> <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com> <20161227094008.GC1308@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Dec 2016, Michal Hocko wrote:

> > Important to who?
> 
> To all users who want to have THP without stalls experience. This was
> the whole point of 444eb2a449ef ("mm: thp: set THP defrag by default to
> madvise and add a stall-free defrag option").
> 

THEY DO NOT STALL.  If the application is not using 
madvise(MADV_HUGEPAGE), all we do is kick kcompactd.  Nothing else.  We 
don't need any kernel tunable for an admin to override an application 
doing madvise(MADV_HUGEPAGE) when it wants hugepages and is perfectly 
happy stalling for them.

> > > You seem to think that it
> > > is the application which is under the control. And I am not all that
> > > surprised because you are under control of the whole userspace in your
> > > deployments.
> > 
> > I have no control over the userspace that runs on my "deployments," I 
> > caution you to not make any inferences.
> 
> the usecase you have described suggested otherwise. The way how you are
> using madvise sounds pretty much intentional to me. This is quite a
> different thing than running an application which uses madivise because
> it _thinks_ it is a good idea and you are left with that decision and
> cannot do anything about that.
> 

I literally cannot believe I am reading this on lkml.  I am legitimately 
stunned by this.  You are saying that the admin thinks it knows better 
than the application writer and that its madvise(MADV_HUGEPAGE) wasn't 
actually intentional?  We don't introduce tunables so that admins can 
control the intentional behavior of an application, unless that behavior 
is a security concern.  The application has specified it wants to wait for 
hugepages and has backwards compatibility with defrag=madvise settings 
since thp was introduced, which introduced MADV_HUGEPAGE.  It's the entire 
point of MADV_HUGEPAGE existing.

> > > Long stalls during the page faults are
> > > often seen as bugs and users might not really care whether the
> > > application writer really wanted THP or not...
> > > 
> > 
> > There are no long stalls during page faults introduced by this patch, we 
> > are waking up a kthread to do the work.
> 
> Yes there _are_. All madvised vmas can stall now which was not the case
> before. This is breaking the semantic of the defer option as it was
> introduced and intended (which should be pretty clear from its name).
>  

All madvised VMAs stall now because THEY WANT TO STALL.  It is 
unbelievable that you would claim otherwise or think that you know better 
than the application writer about their application.

> > We are addressing thp defrag here, not any other use for background 
> > compaction for other high-order allocations.  I'd prefer that we stay on 
> > topic, please.  This is only about setting thp defrag to "defer" and if it 
> > is possible to kick background compaction and defer direct compaction.  We 
> > need this patch, Kirill has acked it, and I simply have no more time to 
> > talk in circles.
> 
> You seem to completely ignore the review feedback and given arguments
> which is really sad...
> 

I am perfectly satisfied with Kirill's review feedback because (1) it 
makes sense and (2) it supports allowing users who do MADV_HUGEPAGE to 
actually try to get hugepages, which is the point of the madvise.

> > That said, I simply don't have the time to continue in circular arguments 
> > and would respectfully ask Andrew to apply this acked patch.
> 
> for reasons mentioned already
> Nacked-by: Michal Hocko <mhocko@suse.com>

I hope I'm not being unrealistically optimistic in assuming that this will 
be the end of this thread.  The patch should be merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
