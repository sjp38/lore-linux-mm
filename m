Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 527F36B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 03:38:02 -0400 (EDT)
Date: Thu, 2 Aug 2012 08:37:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120802073757.GC29814@suse.de>
References: <20120727102356.GD612@suse.de>
 <5016DC5F.7030604@redhat.com>
 <20120731124650.GO612@suse.de>
 <50181AA1.0@redhat.com>
 <20120731200650.GB19524@tiehlicka.suse.cz>
 <50189857.4000501@redhat.com>
 <20120801082036.GC4436@tiehlicka.suse.cz>
 <20120801123209.GK4436@tiehlicka.suse.cz>
 <501945F9.2030402@redhat.com>
 <20120802071934.GA7557@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120802071934.GA7557@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 02, 2012 at 09:19:34AM +0200, Michal Hocko wrote:
> Hi Larry,
> 
> On Wed 01-08-12 11:06:33, Larry Woodman wrote:
> > On 08/01/2012 08:32 AM, Michal Hocko wrote:
> > >
> > >I am really lame :/. The previous patch is wrong as well for goto out
> > >branch. The updated patch as follows:
> > This patch worked fine Michal!  
> 
> Thanks for the good news!
> 
> > You and Mel can duke it out over who's is best. :)
> 
> The answer is clear here ;) Mel did the hard work of identifying the
> culprit so kudos go to him.

I'm happy once it's fixed!

> I just tried to solve the issue more inside x86 arch code. The pmd
> allocation outside of sharing code seemed strange to me for quite some
> time I just underestimated its consequences completely.
> 
> Both approaches have some pros. Mel's patch is more resistant to other
> not-yet-discovered races and it also makes the arch independent code
> more robust because relying on the pmd trick is not ideal.

If there is another race then it is best to hear about it, understand
it and fix the underlying problem. More importantly, your patch ensures
that two processes faulting at the same time will share page tables with
each other. My patch only noted that this missed opportunity could cause
problems with fork.

> On the other hand, mine is more coupled with the sharing code so it
> makes the code easier to follow and also makes the sharing more
> effective because racing processes see pmd populated when checking for
> shareable mappings.
> 

It could do with a small comment above huge_pmd_share() explaining that
calling pmd_alloc() under the i_mmap_mutex is necessary to prevent two
parallel faults missing a sharing opportunity with each other but it's
not mandatory.

> So I am more inclined to mine but I don't want to push it because both
> are good and make sense. What other people think?
> 

I vote yours

Reviewed-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
