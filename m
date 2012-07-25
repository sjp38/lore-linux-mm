Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 27FAF6B0044
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 04:36:44 -0400 (EDT)
Date: Wed, 25 Jul 2012 09:36:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120725083637.GA9222@suse.de>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
 <20120720145121.GJ9222@suse.de>
 <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
 <20120723114007.GU9222@suse.de>
 <alpine.LSU.2.00.1207231702440.1683@eggly.anvils>
 <20120724093406.GO9222@suse.de>
 <alpine.LSU.2.00.1207241108010.1749@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207241108010.1749@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 24, 2012 at 12:23:58PM -0700, Hugh Dickins wrote:
> On Tue, 24 Jul 2012, Mel Gorman wrote:
> > On Mon, Jul 23, 2012 at 06:08:05PM -0700, Hugh Dickins wrote:
> > > 
> > > So, after a bout of anxiety, I think my &= ~VM_MAYSHARE remains good.
> > > 
> > 
> > I agree with you. When I was thinking about the potential problems, I was
> > thinking of them in the general context of the core VM and what we normally
> > take into account.
> > 
> > I confess that I really find this working-by-coincidence very icky and am
> > uncomfortable with it but your patch is the only patch that contains the
> > mess to hugetlbfs. I fixed exit_mmap() for my version but only by changing
> > the core to introduce exit_vmas() to take mmap_sem for write if a hugetlb
> > VMA is found so I also affected the core.
> 
> "icky" is not quite the word I'd use, but yes, it feels like you only
> have to dislodge a stone somewhere at the other end of the kernel,
> and the whole lot would come tumbling down.
> 
> If I could think of a suitable VM_BUG_ON to insert next to the ~VM_MAYSHARE,
> I would: to warn us when assumptions change.  If we were prepared to waste
> another vm_flag on it (and just because there's now a type which lets them
> expand does not mean we can be profligate with them), then you can imagine
> a VM_GOINGAWAY flag set in unmap_region() and exit_mmap(), and we key off
> that instead; or something of that kind.
> 

A new VM flag would be overkill for this right now.

> But I'm afraid I see that as TODO-list material: the one-liner is pretty
> good for stable backporting, and I felt smiled-upon when it turned out to
> be workable (and not even needing a change in arch/x86/mm, that really
> surprised me).  It seems ungrateful not to seize the simple fix it offers,
> which I found much easier to understand than the alternatives.
> 

That's fair enough.

> > 
> > So, lets go with your patch but with all this documented! I stuck a
> > changelog and an additional comment onto your patch and this is the end
> > result.
> 
> Okay, thanks.  (I think you've copied rather more of my previous mail
> into the commit description than it deserves, but it looks like you
> like more words where I like less!)
> 

I did copy more than was necessary, I'll fix it.

> > 
> > Do you want to pick this up and send it to Andrew or will I?
> 
> Oh, please change your Reviewed-by to Signed-off-by: almost all of the
> work and description comes from you and Michal; then please, you send it
> in to Andrew - sorry, I really need to turn my attention to other things.
> 

That's fine, I'll pick it. Thanks for working on this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
