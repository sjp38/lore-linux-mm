Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8176B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 04:41:38 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so53760934wmf.3
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 01:41:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si49281114wjn.46.2016.12.27.01.41.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 01:41:36 -0800 (PST)
Date: Tue, 27 Dec 2016 10:41:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161227094008.GC1308@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161223085150.GA23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
 <20161226090211.GA11455@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 26-12-16 16:53:39, David Rientjes wrote:
> On Mon, 26 Dec 2016, Michal Hocko wrote:
> 
> > But my primary argument is that if you tweak "defer" value behavior
> > then you lose the only "stall free yet allow background compaction"
> > option. That option is really important.
> 
> Important to who?

To all users who want to have THP without stalls experience. This was
the whole point of 444eb2a449ef ("mm: thp: set THP defrag by default to
madvise and add a stall-free defrag option").

> What regresses if we kick a background kthread to compact memory for 
> order-9 pageblocks?

I am not worried about this part. I am worried about the direct
compaction part.

> Why don't we allow userspace to clear __GFP_KSWAPD_RECLAIM if we don't 
> want background reclaim for allocations?
> 
> > You seem to think that it
> > is the application which is under the control. And I am not all that
> > surprised because you are under control of the whole userspace in your
> > deployments.
> 
> I have no control over the userspace that runs on my "deployments," I 
> caution you to not make any inferences.

the usecase you have described suggested otherwise. The way how you are
using madvise sounds pretty much intentional to me. This is quite a
different thing than running an application which uses madivise because
it _thinks_ it is a good idea and you are left with that decision and
cannot do anything about that.

> > But there are others where the administrator is not under
> > the control of what application asks for yet he is responsible for the
> > overal "experience" if you will.
> 
> The administrator is in charge of an "experience" and wants to avoid 
> background compaction for thp allocations but not background reclaim for 
> any other allocation?

I do not understand why you are mentioning the background
reclaim/compaction again. All I am talking about here is the _direct_
compaction and the way to prevent from it for _all_ THP requests
regardless of the madvise status because that is not under the admin
control.

> (Why am I even replying to this?)  If the admin is 
> concerned about anybody doing compaction, they can set defrag to "never".  
> They have had this ability since thp was introduced.
>
> > Long stalls during the page faults are
> > often seen as bugs and users might not really care whether the
> > application writer really wanted THP or not...
> > 
> 
> There are no long stalls during page faults introduced by this patch, we 
> are waking up a kthread to do the work.

Yes there _are_. All madvised vmas can stall now which was not the case
before. This is breaking the semantic of the defer option as it was
introduced and intended (which should be pretty clear from its name).
 
> > I definitely _agree_ that this is a very important usecase! I am just
> > trying to think long term and a more sophisticated background compaction
> > is something that we definitely lack and _want_ longterm. There are more
> > high order users than THP. I believe we really want to teach kcompactd
> > to maintain configurable amount of highorder pages.
> > 
> 
> We are addressing thp defrag here, not any other use for background 
> compaction for other high-order allocations.  I'd prefer that we stay on 
> topic, please.  This is only about setting thp defrag to "defer" and if it 
> is possible to kick background compaction and defer direct compaction.  We 
> need this patch, Kirill has acked it, and I simply have no more time to 
> talk in circles.

You seem to completely ignore the review feedback and given arguments
which is really sad...

> > If there is really a need for an immediate solution^Wworkaround then I
> > think that tweaking the madvise option should be reasonably safe. Admins
> > are really prepared for stalls because they are explicitly opting in for
> > madvise behavior and they will get a background compaction on top. This
> > is a new behavior but I do not see how it would be harmful. If an
> > excessive compaction is a problem then THP can be reduced to madvise
> > only vmas.
> > 
> > But, I really _do_ care about having a stall free option which is not a
> > complete disable of the background compaction for THP.
> > 
> 
> This is completely wrong.  Before the "defer" option has been introduced, 
> we had "madvise" and should maintain its behavior as much as possible so 
> there are no surprises.  We don't change behavior for a tunable out from 
> under existing users because you think you know better.  With the new 
> "defer" option, we can make this a stronger variant of "madvise", which 

I do not see why "defer" would be any different in that regards. The
defer option is there for 3 releases already. It's not an rc thing...
I fail to see why adding a background behavior to one existing knob is
a problem while adding a _directly_ visible one to another is OK. This
just doesn't make any sense to me.

> Kirill acked, so that existing users of MADV_HUGEPAGE have no change in 
> behavior and we can configure whether we do direct or background 
> compaction for everybody else.  If people don't want background 
> compaction, they can set defrag to "madvise".  If they want it, they can 
> set it to "defer".  It's very simple.
>
>
> That said, I simply don't have the time to continue in circular arguments 
> and would respectfully ask Andrew to apply this acked patch.

for reasons mentioned already
Nacked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
