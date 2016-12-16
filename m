Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15CA86B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:14:31 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o2so35103244wje.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:14:31 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ue16si6962964wjb.138.2016.12.16.05.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 05:14:29 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u144so5426447wmu.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:14:29 -0800 (PST)
Date: Fri, 16 Dec 2016 14:14:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: crash during oom reaper
Message-ID: <20161216131427.GM13940@dhcp22.suse.cz>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <20161216104438.GD27758@node>
 <20161216114243.GG13940@dhcp22.suse.cz>
 <20161216123555.GE27758@node>
 <20161216125650.GJ13940@dhcp22.suse.cz>
 <20161216130730.GF27758@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216130730.GF27758@node>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 16-12-16 16:07:30, Kirill A. Shutemov wrote:
> On Fri, Dec 16, 2016 at 01:56:50PM +0100, Michal Hocko wrote:
> > On Fri 16-12-16 15:35:55, Kirill A. Shutemov wrote:
> > > On Fri, Dec 16, 2016 at 12:42:43PM +0100, Michal Hocko wrote:
> > > > On Fri 16-12-16 13:44:38, Kirill A. Shutemov wrote:
> > > > > On Fri, Dec 16, 2016 at 11:11:13AM +0100, Michal Hocko wrote:
> > > > > > On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
> > > > > > [...]
> > > > > > > I don't think it's a bug in the OOM reaper itself, but either of the
> > > > > > > following two patches will fix the problem (without my understand how or
> > > > > > > why):
> > > > > > > 
> > > > > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > > > > index ec9f11d4f094..37b14b2e2af4 100644
> > > > > > > --- a/mm/oom_kill.c
> > > > > > > +++ b/mm/oom_kill.c
> > > > > > > @@ -485,7 +485,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
> > > > > > > struct mm_struct *mm)
> > > > > > >  	 */
> > > > > > >  	mutex_lock(&oom_lock);
> > > > > > > 
> > > > > > > -	if (!down_read_trylock(&mm->mmap_sem)) {
> > > > > > > +	if (!down_write_trylock(&mm->mmap_sem)) {
> > > > > > 
> > > > > > __oom_reap_task_mm is basically the same thing as MADV_DONTNEED and that
> > > > > > doesn't require the exlusive mmap_sem. So this looks correct to me.
> > > > > 
> > > > > BTW, shouldn't we filter out all VM_SPECIAL VMAs there? Or VM_PFNMAP at
> > > > > least.
> > > > > 
> > > > > MADV_DONTNEED doesn't touch VM_PFNMAP, but I don't see anything matching
> > > > > on __oom_reap_task_mm() side.
> > > > 
> > > > I guess you are right and we should match the MADV_DONTNEED behavior
> > > > here. Care to send a patch?
> > > 
> > > Below. Testing required.
> > > 
> > > > > Other difference is that you use unmap_page_range() witch doesn't touch
> > > > > mmu_notifiers. MADV_DONTNEED goes via zap_page_range(), which invalidates
> > > > > the range. Not sure if it can make any difference here.
> > > > 
> > > > Which mmu notifier would care about this? I am not really familiar with
> > > > those users so I might miss something easily.
> > > 
> > > No idea either.
> > > 
> > > Is there any reason not to use zap_page_range here too?
> > 
> > Yes, zap_page_range is much more heavy and performs operations which
> > might lock AFAIR which I really would like to prevent from.
> 
> What exactly can block there? I don't see anything with that potential.

I would have to rememeber all the details. This is mostly off-topic for
this particular thread so I think it would be better if you could send a
full patch separatelly and we can discuss it there?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
